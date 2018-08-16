function [TPR,FPR,FNR,TNR,TFPNMatrix, Threshold] = roc (target, outputs)
% This function takes TPR and FPR and calculates the area under the ROC curve

% Input         :   target     : truth data used in supervised learning
%                   outputs    : probability output from logistic regression
%
% Output        :   TPR         : True positive
%                   FPR         : False positive
%                   FNR         : False negative
%                   TNR         : True negative
%                   Threshold   : Array of thresholds used on the logistic regression to generate each
%                                   corresponding TP, FP, FN, and TN

% Developed by Bojan Gavrilovic, UHN. June 1 2017

outputs=outputs.*100;
Threshold=0:1:100;

len=length(Threshold);
TP=zeros(len,1);
FP=zeros(len,1);
FN=zeros(len,1);
TN=zeros(len,1);
TPR=zeros(len,1);
FPR=zeros(len,1);
FNR=zeros(len,1);
TNR=zeros(len,1);

for i=1:len
    
    TP(i)=sum(target&logical(outputs>=Threshold(i)));
    FP(i)=sum((~target)&logical(outputs>=Threshold(i)));
    FN(i)=sum((target)&logical(outputs<=Threshold(i)));
    TN(i)=sum((~target)&logical(outputs<=Threshold(i)));
    
    TPR(i)=TP(i)/(TP(i)+FN(i));
    FPR(i)=FP(i)/(TN(i)+FP(i));
	FNR(i)=FN(i)/(TP(i)+FN(i));
	TNR(i)=TN(i)/(TN(i)+FP(i));
end

TFPNMatrix=[TP,TN,FP,FN];
end