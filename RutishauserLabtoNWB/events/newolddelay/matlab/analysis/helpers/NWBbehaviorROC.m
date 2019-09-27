%behavioral data for new/old with certainty task
%
%produces ROCs 
%
%typeCounters: for each confidence rating (1-3), lists how many TP/FN/TN/FP. 3 columns, 4 rows
%
%modeExcludeSlowRT: 0 all included, 1 strict, 2 lenient
%
%responses/recogState are returned with too high RT items removed if this is enabled (modeExcludeSlowRT)
%
%===
function [FPOld,TPOld, FPNew,TPNew, typeCounters, percError, percCorrect,errorRateLearn, RTsRecog, RTsLearn,percAccuracy_high, percAccuracy_low, responses, recogState,RTsRecog_vsQonset,StimOff_toQ_delay,StimOn_toOff_delay] = NWBbehaviorROC(NOsession, ind, NOsessionLearn, doPlot, basepath, modeExcludeSlowRT)
if nargin<4
    basepath='/data/';
end
if nargin<5
    modeExcludeSlowRT=0;
end

extractionMode=1; %recog
[tmp, stimuliRecog, newOldRecogLabels, responses, responsesEventfile,tmp,tmp,tmp,tmp,tmp,tmp,RTsRecog, RTsRecog_vsQonset,StimOff_toQ_delay,StimOn_toOff_delay] = NWBloadDataOfBlock_release( NOsession, ind, extractionMode, basepath);
extractionMode=2; %learn
if NOsession.EXPERIMENTIDLearn>-1
     [stimuliLearn, tmp, tmp, tmp, responsesLearn,tmp,tmp,tmp,tmp,tmp,errorRateLearn,RTsLearn] = NWBloadDataOfBlock_release( NOsession, ind, extractionMode, basepath);
    %responsesLearn is animal yes/no response
else
    stimuliLearn=[];
end

%if this is overnight recall,no learning; go back to previous session
if length(stimuliLearn)==0
    if ~isempty(NOsessionLearn)
        [stimuliLearn, tmp, tmp, tmp, tmp,tmp,tmp,tmp,tmp,tmp,errorRateLearn,RTsLearn] = NWBloadDataOfBlock_release( NOsessionLearn, ind, extractionMode,basepath);
    else
        RTsLearn=nan;
        errorRateLearn=nan;
        stimuliLearn=nan;
    end
end

% NO tasks where same stimuli are shown during learn and recog
%  recogState = determineRecogState(stimuliRecog, stimuliLearn);

%validation that correct file was loaded -- all should be zero
% disp(length(newOldRecogLabels))
% disp(length(recogState))
% s1=sum(recogState - newOldRecogLabels);

recogState = newOldRecogLabels;

% if isempty(responsesEventfile)
%     warning('no eventfile was loaded');
%     s2=0;
% else
%     s2=sum(responsesEventfile - responses);
% end
% 
% if s1~=0 | (s2~=0)
%     warning('wrong file loaded?');
% end

%should be 90 each (v1) or 50 each (v2)
nrOLD=length(find(recogState==1));
nrNEW=length(find(recogState==0));

certaintyOLD=[6 5 4 3 2 1];
%6=very sure OLD ....
certaintyNEW=[1 2 3 4 5 6];

disp(['nr Old:' num2str(nrOLD) ' nr New:' num2str(nrNEW)]);

if length(responses) ~= length(recogState)
    warning(['Nr trials different from ground truth. GT has ' num2str(length(recogState)) ' but available are ' num2str(length(responses)) ]);
end

%---- to count nr high/low correct trials of each kind after dynamic split,
%to assess viability of session for analysis
enforceBehavioralExclusions=2;
[isIncluded,AUC,percAccuracy_high, percAccuracy_low, TP, FP] = NO_behavior_evaluateSessionStatus(responses, recogState, enforceBehavioralExclusions);

nrOldCorrect = length(find(recogState==1 & responses'>3));
nrNewCorrect = length(find(recogState==0 & responses'<4));

[splitMode, indsTPhigh, indsTPlow, indsFPhigh, ...
    indsFPlow, indsTNhigh, indsTNlow, indsFNhigh, indsFNlow, splitStats] = NO_dynamic_lowHighSplit( recogState, responses, 0 );

%== compute the ROC on th 1-6 scale
[TPOld,FPOld] = calcMultipointROC(certaintyOLD, recogState, responses, nrOLD, nrNEW, 1, 0); %from point of view of OLD
[TPNew,FPNew] = calcMultipointROC(certaintyNEW, recogState, responses, nrNEW, nrOLD, 0, 1); %from point of view of NEW

if modeExcludeSlowRT
    % for calculation of RT, exclude some low RT trials    
    if modeExcludeSlowRT==1
        %values below are same as in cut_off.m
        % <5s, 1sd
        cut_off_fixed_high = 5*1000;  % in ms
        cut_off_fixed_low = 0;
        cut_off_std = 1;
    else
        % <30s, 3sd
        cut_off_fixed_high = 30*1000;  % in ms
        cut_off_fixed_low = 0;
        cut_off_std = 3;        
    end

    outliers_fixed = RTsRecog < cut_off_fixed_low | RTsRecog > cut_off_fixed_high;

    sOfRT = std(RTsRecog(outliers_fixed==0));
    mOfRt = mean(RTsRecog(outliers_fixed==0));

    cut_off_std = [mOfRt-cut_off_std*sOfRT mOfRt+cut_off_std*sOfRT];

    indsKeep = find ( RTsRecog >  cut_off_std(1) & RTsRecog < cut_off_std(2) & RTsRecog>cut_off_fixed_low & RTsRecog<cut_off_fixed_high);

    disp([' HighRTW discard: keep n=' num2str(length(indsKeep)) ' of n=' num2str(length(RTsRecog)) ]);
    RTsRecog = RTsRecog(indsKeep);
    recogState =recogState(indsKeep);
    responses = responses(indsKeep);
end

mode=2; %all 6 confidence levels
typeCounters = calcEmpiricalROC(mode, recogState, responses);

mode=1; %only 3 confidence levels
typeCountersCollapsed = calcEmpiricalROC(mode, recogState, responses);

% percentage correct/error as a function of confidence.
% percentage is normalized to percentage of _all responses made_
percError=[];
percCorrect=[];
tmp=typeCountersCollapsed;
for k=1:3    
    %cummulative
    [nTP]=sum(tmp(1,1:k));
    [nFN]=sum(tmp(2,1:k));
    [nTN]=sum(tmp(3,1:k));
    [nFP]=sum(tmp(4,1:k));

    nTot=nFP+nFN+nTP+nTN;
    percError(k) = ((nFP+nFN)/nTot)*100;
    percCorrect(k) = ((nTP+nTN)/nTot)*100;
end

if doPlot
    %== plot the ROC
    figure(9)
    subplot(1,3,1)
    %,FPNew, TPNew,'-xr',
    plot( FPOld,TPOld, '-ob', FPNew,TPNew, '-or','linewidth',2.5);
    hold on
    for i=1:length(certaintyOLD)
        text(FPOld(i)+0.025,TPOld(i),['K:' num2str(certaintyOLD(i))]);
        text(FPNew(i)+0.025,TPNew(i),['K:' num2str(certaintyNEW(i))]);
    end
    hold off

    legend('Old','New');

    xlim([0 1]);ylim([0 1]);
    h=line([0 1],[0 1]);
    set(h,'color','r');
    %legend('New','Old');

    xlabel('P(New|Old) or P(Old|New);   (FP)');
    ylabel('P(Old|Old) or P(New|New);   (TP)');
    title([ NOsession.sessionID ' - Behavioral ROC for new/old with 6 levels of certainty']);

    subplot(1,3,2)
    plot( 1:length(RTsLearn), RTsLearn-mean(RTsLearn), 'o');
    title('RT learn');

    subplot(1,3,3)
    plot( 1:length(RTsRecog), RTsRecog-mean(RTsRecog), 'o');
    title('RT recog');
end