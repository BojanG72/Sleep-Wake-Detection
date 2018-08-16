% Performing and testing logistic regression with cross correlation
clear all;
clc;

load('C:\Users\gavrilb\Documents\MATLAB\SleepDB\Sleep-Wake Detection\featureMatrix.mat');

X = featureMatrix(:,1:end-1);
Y = featureMatrix(:,end);

cp = cvpartition(Y,'k',10); % Stratified cross-validation

fun = @logReg;

cfMat = crossval(fun,X,Y,'partition',cp);
cfMat = reshape(sum(cfMat),3,3);



