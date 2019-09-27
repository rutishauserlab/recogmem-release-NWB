%
%forked from calcAUC.m
%
%calc area-under-the-curve for arbitrary two distribution of two population of numbers 
%
%Directionality depends on cellType.
%cellType=0:  new>old
%cellType=1:  old>new
%
%thus, the TP is always from the perspective of Old.
%
%balanceNrTrials: 0 no, 1 yes; cut bigger group by random subset
%
%urut/aug13
function [AUC, TP, FP, T] = calcAUC_forOldDecoding(countNEW,countOLD, cellType, nrSteps, balanceNrTrials )
if nargin<4
    nrSteps=20;
end
if nargin<5
    balanceNrTrials=0;
end

if balanceNrTrials==1   % equalize group sizes
    nrNEW=length(countNEW);
    nrOLD=length(countOLD);
    grpSize = min([nrNEW nrOLD]);

    if grpSize<nrOLD
        R=randperm(nrOLD);
        countOLD = countOLD(R(1:grpSize));
    end
    if grpSize<nrNEW
        R=randperm(nrNEW);
        countNEW = countNEW(R(1:grpSize));
    end
end


nrNEW=length(countNEW);
nrOLD=length(countOLD);

maxCount=max([max(countNEW) max(countOLD)]);

% T=maxCount+0.2:-maxCount/nrSteps:0; %thresholds, for ROC

T = linspace( maxCount+0.2, 0, nrSteps); % fixed nr thresholds in the ROC curve

if length(find(T==0))==0
    T=[T 0];
end
if length(T)==1 && T(1)==0
    T=[1 0];
end

TP=[];
FP=[];
for i=1:length(T)
   
    if cellType==1 %fam
        TP(i) = length ( find( countOLD >= T(i) ) ) / nrOLD;
        FP(i) = length ( find( countNEW >= T(i) ) ) / nrNEW;
    end

    if cellType==0 %novel
        TP(i) = length ( find( countNEW >= T(i) ) ) / nrNEW;
        FP(i) = length ( find( countOLD >= T(i) ) ) / nrOLD;
        
        % 
        %TP(i) = length ( find( countOLD <= T(end-i+1) ) ) / nrOLD;
        %FP(i) = length ( find( countNEW <= T(end-i+1) ) ) / nrNEW;
    end
    
end

%calc AUC (integrate curve)
AUC=0;
assigned=0;
for i=2:length(T)
    if FP(i-1) < FP(i) %only if it has slope for FP (if FP(i-1)==FP(i), no increase in area
        AUC = AUC + (FP(i)-FP(i-1))*TP(i-1);
        AUC = AUC + 1/2 * (TP(i)-TP(i-1))*(FP(i)-FP(i-1));
        assigned=1;
    end
end

%error,AUC could not be calculated,set it to impossible value
if ~assigned
    AUC = nan;
end