%
% evaluates whether a particular session should be included or not for NO retrieval analysis
%
%newOldRecogLabels: ground truth. 0-new, 1-old
%
% AUC behavioral AUC
% respCounts raw response (1-6) to each trial
%
% enforceBehaviorExclusions : 0 include all; 1 include all with valid behavior; 2 include only those that distinguished high/low correctly
%
% rawAccuracies: high med low; accuracy separately for each conf level, without applying a high/low split
% rawAccuracies2: accuracy separately for high/low and for new/old.   order: Old high, Old med, Old low, New low, New med, New High
%
%urut/CSMC/oct13
function [isIncluded, AUC, percAccuracy_high, percAccuracy_low, TP, FP,respCounts,rawAccuracies, rawAccuracies2] = NO_behavior_evaluateSessionStatus(responses, newOldRecogLabels,enforceBehaviorExclusions)
if nargin<3
    enforceBehaviorExclusions=2;    
end

useDynamicSplitMode=0;
minAccuracyLow=0.55;
minAccuracyHigh=0.7;

% count the responses
respCounts=[];
for k=1:6
    respCounts(k) = length(find(responses==k));
end


mode=2; %all 6 confidence levels
typeCounters = calcEmpiricalROC(mode, newOldRecogLabels, responses);


dS = calcCumulativeD( typeCounters );

d = dS( 4:5, :); %only H/F of interest here
FP=d(2,:);
TP=d(1,:);
AUC = calcROC_AUC(TP,FP);

                      
% decide whether to include this session
isIncluded=1;

%list of exclusion criteria
if (AUC<0.6) & enforceBehaviorExclusions>0    % Default is AUC<0.60
    isIncluded=0;
end

%see if session has both high/low ratings for both new and old
if (length(find(respCounts(1:3)==0))>1 | length(find(respCounts(4:6)==0))>1) & enforceBehaviorExclusions>0
    isIncluded=0;
end

nrOld_all=length(find(newOldRecogLabels==1));
nrNew_all=length(find(newOldRecogLabels==0));


if useDynamicSplitMode
    %-- use dynamic split to get high/low nr trials and accuracy
    [splitMode, indsTPhigh, indsTPlow, indsFPhigh, ...
        indsFPlow, indsTNhigh, indsTNlow, indsFNhigh, indsFNlow,splitStats] = NO_dynamic_lowHighSplit( newOldRecogLabels, responses, 0  );
    
    nrTN_high = length(indsTNhigh);
    nrTP_high = length(indsTPhigh);
    nrTN_all = length(indsTNhigh)+length(indsTNlow);
    nrTP_all = length(indsTPhigh)+length(indsTPlow);
    nrTN_low = length(indsTNlow);
    nrTP_low = length(indsTPlow);
    
    nrHighResponses = length(indsTPhigh)+length(indsTNhigh)+length(indsFNhigh)+length(indsFPhigh);
    nrLowResponses = length(indsTPlow)+length(indsTNlow)+length(indsFNlow)+length(indsFPlow);
else
    %-- this is for fixed threshold
    nrTN_high = length(find( responses==1 & newOldRecogLabels'==0));
    nrTP_high = length(find( responses==6 & newOldRecogLabels'==1));
    
    nrTN_all = length(find( responses<=3 & newOldRecogLabels'==0));
    nrTP_all = length(find( responses>=4 & newOldRecogLabels'==1));
    
    nrTN_low = length(find( responses>=2 & responses<=3 & newOldRecogLabels'==0));
    nrTP_low = length(find( responses>=4 & responses<=5 & newOldRecogLabels'==1));
    
    nrHighResponses = length(find(responses==1 | responses==6));
    nrLowResponses = length(find(responses>=2 & responses<=5 ));
end

percAccuracy_high = (nrTN_high+nrTP_high)/nrHighResponses;
percAccuracy_low = (nrTN_low+nrTP_low)/nrLowResponses;

percAccuracy_all = (nrTN_all+nrTP_all)/length(responses);


%=== get a raw accuracy -- for each confidence, no split
nrTN_high = length(find( responses==1 & newOldRecogLabels'==0));
nrTP_high = length(find( responses==6 & newOldRecogLabels'==1));
nrTN_mid = length(find( responses==2 & newOldRecogLabels'==0));
nrTP_mid = length(find( responses==5 & newOldRecogLabels'==1));
nrTN_low = length(find( responses==3 & newOldRecogLabels'==0));
nrTP_low = length(find( responses==4 & newOldRecogLabels'==1));

%count nr total responses, regardless of correctness
nrHighRespNew = length(find(responses==1));
nrHighRespOld = length(find(responses==6));
nrMedRespNew = length(find(responses==2));
nrMedRespOld = length(find(responses==5));
nrLowRespNew = length(find(responses==3));
nrLowRespOld = length(find(responses==4));

nrHighResponses = nrHighRespNew + nrHighRespOld;
nrMidResponses  = nrMedRespNew + nrMedRespOld; 
nrLowResponses  = nrLowRespNew + nrLowRespOld;

rawAccuracy_high = (nrTN_high+nrTP_high)/nrHighResponses;
rawAccuracy_med  = (nrTN_mid+nrTP_mid)/nrMidResponses;
rawAccuracy_low  = (nrTN_low+nrTP_low)/nrLowResponses;

rawAccuracies = [rawAccuracy_high rawAccuracy_med rawAccuracy_low];


%order: Old high, Old med, Old low, New low, New med, New High
rawAccuracies2 = [nrTP_high/nrHighRespOld nrTP_mid/nrMedRespOld nrTP_low/nrLowRespOld nrTN_low/nrLowRespNew nrTN_mid/nrMedRespNew nrTN_high/nrHighRespNew ];

%low conf-only
%nOLD=sum(typeCounters(1,:));
%nNEW=sum(typeCounters(4,:));

%C1=sum(typeCounters(:,2:3)')';
%[dLow] = calcDPrime(C1, nOLD, nNEW);

%C2=typeCounters(:,1);
%[dHigh] = calcDPrime(C2, nOLD, nNEW);


% require high-conf to have at least X% higher accuracy then low conf
%if ~(percAccuracy_high>percAccuracy_low+0.01) & enforceBehaviorExclusions==2
%    isIncluded=0;
%end

%high confidence needs to be above chance
if percAccuracy_high<minAccuracyHigh & enforceBehaviorExclusions==2
    isIncluded=0;
end

%low confidence accuracy needs to be above chance
if percAccuracy_low<minAccuracyLow & enforceBehaviorExclusions==2
    isIncluded=0;
end

