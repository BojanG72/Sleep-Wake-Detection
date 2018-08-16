% Performing and testing logistic regression with leave one out cross validation
clear all
clc;

load('O:\Sleep Lab\Sleep Management\Patch\Sleep-Wake Analysis\Results and Processed Data\MATLAB Results\SleepWake Results\featureMatrix.mat');

% numOfSubjects = featureMatrix(end,1) - featureMatrix(1,1) +1;
% subjectNumber = [featureMatrix(1,1):featureMatrix(end,1)];
subjectNumber = [4 6 7 9 10 12 13 14 15 16];  %patient 5
numOfSubjects = numel(subjectNumber);
% subjectRand = randperm(numOfSubjects) + featureMatrix(1,1) -1;

% trainingSize = round(0.7*numOfSubjects);
correctRate = [];
modelSensitivity = [];
modelSpecificity = [];

numberAwake = [];
trueNumberAwake = [];
TPR = [];
FPR = [];

for validationCycle = 2:numOfSubjects
    trainingSubjects = subjectNumber(subjectNumber~=subjectNumber(validationCycle));
    testingSubject = subjectNumber(validationCycle);
    trainingData = [];
    for i = 1:numOfSubjects-1
        trainingDataTemp = featureMatrix(featureMatrix(:,1)==trainingSubjects(i),:);
        trainingData = [trainingData; trainingDataTemp];
    end
    
    testingData = [];
    testingData = featureMatrix(featureMatrix(:,1)==testingSubject,:);
    
    % Generate logistic model using the training data
    
    [logitCoeff, dev, stats] = mnrfit(trainingData(:,1:end-1), categorical(trainingData(:,end)));
    model(:,validationCycle) = logitCoeff;
    
    % test the accuracy on the testing data set
    justOnes = ones(numel(testingData(:,1)),1);
    testingData = [justOnes testingData];
    
    b = testingData(:,1:end-1)*logitCoeff;
    b = exp(b);
    p = 1 - (b./(1+b));
    
%     %% Check results
%     
    sleepWake = p > 0.3;
    trueSleepWake = logical(testingData(:,end));
%     
%     % PositiveValue = 1;
%     % NegativeValue = 0;
%     
%     % CP = classperf(trueSleepWake, sleepWake, 'Positive', PositiveValue, 'Negative', NegativeValue);
    CP = classperf(trueSleepWake, sleepWake);
    correctRate = [correctRate CP.correctRate];
    modelSensitivity = [modelSensitivity CP.sensitivity];
    modelSpecificity = [modelSpecificity CP.specificity];
    
    numberAwake = [numberAwake sum(sleepWake)];
    trueNumberAwake = [trueNumberAwake sum(trueSleepWake)];
    
    figure
    subplot(2,1,1)
    plot(trueSleepWake);
    subplot(2,1,2)
    plot(sleepWake);
%% Generate ROC curve
    [TPR1,FPR1,FNR1,TNR1,TFPNMatrix1, Threshold] = roc (trueSleepWake, p);
    TPR = [TPR TPR1];
    FPR = [FPR FPR1];
    
end

avgCorrectRate = mean(correctRate);
avgSensitivity = mean(modelSensitivity);
avgSpecificity = mean(modelSpecificity);
trueAwakeStats = [mean(trueNumberAwake) std(trueNumberAwake)];
awakeStats = [mean(numberAwake) std(numberAwake)];

%% Calculate the sleep time and sleep efficiency from the testing data
trueSleepTime = (numel(trueSleepWake) - sum(trueSleepWake))*30;
patchSleepTime = (numel(sleepWake) - sum(sleepWake))*30;
sleepTimeError = (1 - patchSleepTime/trueSleepTime)*100;
sleepTimeDiff = abs(patchSleepTime - trueSleepTime)/60;

%% Average the ROC data
avgTPR = mean(TPR,2);
avgFPR = mean(FPR,2);
area = auc(avgTPR,avgFPR);
figure
plot(avgFPR,avgTPR);
hold
plot(linspace(0,1,100), linspace(0,1,100));

%% Final model
FinalModel = mean(model')';

save('O:\Sleep Lab\Sleep Management\Patch\Sleep-Wake Analysis\Results and Processed Data\MATLAB Results\SleepWake Results\FinalModel.mat', 'FinalModel');




