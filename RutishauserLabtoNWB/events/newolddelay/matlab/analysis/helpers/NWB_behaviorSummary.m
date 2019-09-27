% plots summary of new/old task behavior.
%
%doPlot: 0 no, 1 summary plot, 2 z-ROC plots
%
%urut/march09
%urut/aug18 split out from NO_DM_behaviorSummary.m and simplified.
function [T,allSlopes, AUC, isIncluded_exclMode1, accuracyHighLow, typeCountersSame] = NWB_behaviorSummary(NWBsessions, allLearnSessionsToUse, modeBehavior, doPlot, basepath, modeExcludeSlowRT)

T=[]; %decision threshold for each session. T(j)>= is OLD
Thigh=[];%decision threshold for a stimulus to be of high confidence
nrT=[];
allConfCountsTP=[]; %for each session, probability of each confidence button press
countersAv=[];
TP_FP_chosen=[]; %TP/FP at the picked decision point
Tp_FP_HighLowConf=[]; %TP/FP at the picked low/high confidence decision point
allSlopes=[]; % slope of line fit in z-ROC space
countersHistory=[]; %store all for later use in plotting
fitHistory=[];
errorRatesLearn=[]; %animal yes/no perc correct during learning

sessionCounters=[0 0 0]; %all, exclMode1, exclMode2

accuracyHighLow = []; % inclusionStatus high low
accuracySeparate = []; %order: Old high, Old med, Old low, New low, New med, New High

TP_FP_minErr = []; 
TP_FP_all=[]; %what is the TP/FP not using confidence ratings (new vs old)
typeCounters_all=[];
RTall=[];
mConf_all=[]; %mean confidence all correct, mean confidence all incorrect  (one row per session)
sessionStats=[]; %  nrRecogTrials avDelayOfftoQ

for j=1:length(allLearnSessionsToUse) 
    NOind = allLearnSessionsToUse(j);

    [typeCountersSame, typeCountersOvernight, bSame, bOvernight, daSame, daOvernight,tmp,tmp,tmp,tmp,errorRateLearn, RTsRecog,RTsLearn,~,~,responses2, recogState2,RTsRecog_vsQonset, StimOff_toQ_delay, StimOn_toOff_delay] = NWBbehaviorROC_prepare(NWBsessions, NOind, -1, 0, basepath, modeExcludeSlowRT);
    
    sessionStats(j,:)=[NOind length(RTsRecog) mean(StimOff_toQ_delay) mean(StimOn_toOff_delay)]; %  nrRecogTrials avDelayOfftoQ OntoOffDelay
    
    dS = calcCumulativeD( typeCountersSame );

    errorRatesLearn(j) = errorRateLearn;
    
    allSlopes(j) = bSame(2);
    
    if doPlot==2
        subplot(4,4,j);
        
        plotZROC_NO(typeCountersSame, typeCountersOvernight, bSame, bOvernight, ['NOId ' num2str(NOind) ' s=' num2str(bSame(2)) ] );
    end
    
    if j==1
        countersAv = typeCountersSame;
    else
        countersAv = countersAv + typeCountersSame;
    end
    
    typeCounters_all{j} = typeCountersSame;
    
    allConfCountsTP(j,:) = typeCountersSame(1,:)./sum(typeCountersSame(1,:));
    allConfCountsTN(j,:) = typeCountersSame(4,:)./sum(typeCountersSame(4,:));
    
    countersHistory{j} = typeCountersSame;
    fitHistory(j,:) = bSame;
    
    [T(j), goalUsed ] =  determineNODecisionThreshold( typeCountersSame, modeBehavior );
    
    dS = calcCumulativeD( typeCountersSame );
    TP_tmp = dS(4,:);
    FP_tmp = dS(5,:);
    
    [minErrCurve, minErrPoint ] = getROC_minErrorCriteria(TP_tmp, FP_tmp);
    
    TP_FP_minErr(j,:) = [TP_tmp(minErrPoint) FP_tmp(minErrPoint)];
    
    Thigh(j)=T(j)+1;
    if Thigh(j)>6
        %cant use this session
        Thigh(j)=nan;
    end
    
    %threshold as index -- different ref frame. T(j) is on OLD=6,...1=NEW scale & and >=
    %intThresh is on 1=OLD...NEW scale
    intThresh = 7-T(j); 
    
    nrT(j) = sum(typeCountersSame(1,1:intThresh));  %nr trials TP    
    
    dPrime(j) = dS(1,3);

    nrOldCorrect_all = sum(typeCountersSame(1,1:3));
    nrNewCorrect_all = sum(typeCountersSame(4,4:6));
    accuracy_all = (nrOldCorrect_all+nrNewCorrect_all)/sum(typeCountersSame(:));
    
    AUC = calcROC_AUC(TP_tmp,FP_tmp);
     
    [bSame] = calcZROCSlope( typeCountersSame );
    Tp_FP_chosen(j,1:3) = [ dS(4:5, intThresh)' T(j) ];

    if ~isnan(Thigh(j))
        intThreshHigh = 7-Thigh(j); %convert to internal representation
        Tp_FP_HighConf(j,1:3)= [ dS(4:5, intThreshHigh)' Thigh(j) ];
    else
        Tp_FP_HighConf(j,1:3)= nan(1,3);
    end

    %=== Determine if this session qualifies for neuronal analysis
    extractionMode=1; %recog
    responses=responses2;
    newOldRecogLabels=recogState2;
    
    exclusionMode=1;
    [isIncluded_exclMode1] = NO_behavior_evaluateSessionStatus(responses, newOldRecogLabels, exclusionMode);
    exclusionMode=2;
    [isIncluded_exclMode2,~,percAccuracy_high, percAccuracy_low,~,~,~,rawAccuracies,rawAccuracies2] = NO_behavior_evaluateSessionStatus(responses, newOldRecogLabels, exclusionMode);

    accuracyHighLow = [ accuracyHighLow; [isIncluded_exclMode1 isIncluded_exclMode2 percAccuracy_high percAccuracy_low]];
    accuracySeparate = [ accuracySeparate; rawAccuracies2 ]; 

    TP_FP_all(j,:) = [ TP_tmp(3) FP_tmp(3) accuracy_all AUC bSame(2) isIncluded_exclMode1 isIncluded_exclMode2 rawAccuracies ];    
    
    sessionCounters(1)=sessionCounters(1)+1;
    if isIncluded_exclMode1
        sessionCounters(2)=sessionCounters(2)+1;
    end
    if isIncluded_exclMode2
        sessionCounters(3)=sessionCounters(3)+1;
    end
    
    % RT analysis
    indsTN_high = find( responses==1 & newOldRecogLabels'==0);
    indsTP_high = find( responses==6 & newOldRecogLabels'==1);
    indsTN_low = find( responses>=2 & responses<=3 & newOldRecogLabels'==0);
    indsTP_low = find( responses>=4 & responses<=5 & newOldRecogLabels'==1);
    
    mRTs = [ mean(RTsRecog_vsQonset(indsTP_high)) mean(RTsRecog_vsQonset(indsTP_low)) mean(RTsRecog_vsQonset(indsTN_high)) mean(RTsRecog_vsQonset(indsTN_low)) ];
    RTall(j,:) = mRTs;
    
    %=== compute average confidence for all correct and all incorrect responses
    indsCorrect   = find( (responses<=3 & newOldRecogLabels'==0) | (responses>=4 & newOldRecogLabels'==1) );
    indsIncorrect = find( (responses<=3 & newOldRecogLabels'==1) | (responses>=4 & newOldRecogLabels'==0) );
    
    responsesRemapped = responses;
    responsesRemapped( find(responses==6) ) = 1;
    responsesRemapped( find(responses==5) ) = 2;
    responsesRemapped( find(responses==4) ) = 3;
        
    mConf_all(j,:) = [mean(responsesRemapped(indsCorrect)) mean(responsesRemapped(indsIncorrect)) ];
end

disp(['error rate learn:' num2str(mean(errorRatesLearn))]);

goalStr=['Goal-Meth:' num2str(modeBehavior) ' GoalT:' num2str(goalUsed)];

[mTP,sTP,seTP] = calcMeanSEOfSample( allConfCountsTP );
[mTN,sTN,seTN] = calcMeanSEOfSample( allConfCountsTN );

[mTp_FP_HighConf, tt, seTp_FP_HighConf] = calcMeanSEOfSample ( Tp_FP_HighConf );
[mTp_FP_chosen, tt, seTp_FP_chosen] = calcMeanSEOfSample ( Tp_FP_chosen );

if doPlot==1 & length(allLearnSessionsToUse)>1
    
    %distribution of key usage
    subplot(3,4,1)
    hs(1)=errorbar( 6:-1:1, mTP, seTP,'b');
    hold on
    hs(2)=errorbar( 6:-1:1, mTN, seTN,'r');
    hold off
    set(gca,'XTick',[1:6]);
    xlim([0 7]);
    set(hs(1),'linewidth',2);
    set(hs(2),'linewidth',2);
    xlabel('Confidence');
    ylabel('Probability of response');
    legend(hs,{'Old stimuli','New stimuli'});
    title(['n=' num2str(size(allConfCountsTP,1)) ' sessions']);

    %mean ROC
    subplot(3,4,2);
    modeROC=2;   % 1 original (with 0/0 and 1/1 points); 2 modified (no 0/0 and 1/1 points)
    IdsToHighlight = [ 3 10 40];
    colGray = [0.8 0.8 0.8];
    if modeROC==1
        addCorners=1;
    else
        addCorners=-1;
    end
    
    rawROC_x=[];
    rawROC_y=[];
    for k=1:length(typeCounters_all)
        [bSame, d2, s, daSame, RsquareSame] = calcZROCSlope( typeCounters_all{k} );
        plotFit=0;
        if k>1
            hold on
        end
        [hROC,xROC,yROC] = plotCumulativeROC(typeCounters_all{k}, [], [], 'R', plotFit, addCorners);
        set(hROC,'MarkerSize',3, 'LineStyle','-', 'color', colGray, 'MarkerFaceColor', colGray, 'Marker','o')
        
        rawROC_x(k,:)=xROC;
        rawROC_y(k,:)=yROC;
    end
    xlim([0 1]);
    ylim([0 1]);
    [bSame, d2, s, daSame, RsquareSame] = calcZROCSlope( countersAv );
    if modeROC==1
        plotFit=1;
    else
        plotFit=0;
    end
    hROC=plotCumulativeROC_NO(countersAv, [], [bSame(2) 0], [daSame 0], '', plotFit, addCorners );
    set(hROC(1),'LineWidth', 2);
    hold off
    title(['average ROC slope=' num2str(bSame(2))]);
    
    %z-ROC of the mean ROC
    subplot(3,4,3)
    [bSame, d2, s, daSame, RsquareSame] = calcZROCSlope( countersAv );
    plotZROC_NO(countersAv, [], bSame, [], [' s=' num2str(bSame(2)) ] );
    hold off

    % overall performance of each subject
    subplot(3,4,4);
    dotsColor=[0.5 0.5 0.5];
    h=plot( TP_FP_all(:,2), TP_FP_all(:,1), ['ok'],'MarkerSize',5, 'MarkerFaceColor', dotsColor );
    set(h,'color', dotsColor);
    [mFP,sFP]=calcMeanSEOfSample( TP_FP_all(:,2) );
    [mTP,sTP]=calcMeanSEOfSample( TP_FP_all(:,1) );    
    hold on
    errorbar( mFP, mTP, sTP, 'k', 'linewidth',2 );
    herr=herrorbar( mFP, mTP, sFP, 'k' );
    set(herr,'linewidth',2);
    hold off
    xlim([0 1]);
    ylim([0 1]);
    line([0 1],[0 1],'color','k');
    %line([0 0.5],[1 0.5],'color','k');
    xlabel('false alarm rate');
    ylabel('hit rate');
    title(['Overall performance mTP=' num2str(mTP) '\pm' num2str(sTP) ' mFP=' num2str(mFP) '\pm' num2str(sFP) ]);

    % histogram of behavioral AUC values
    subplot(3,4,5);
    AUC_all = TP_FP_all(:,4);
    hist( AUC_all,15);
    [mAUC,sAUC]=calcMeanSEOfSample( AUC_all );
    title(['AUC m=' num2str(mAUC) '\pm' num2str(sAUC)]);
    xlim([0.5 1]);
    ylabel('nr of subjects');
    xlabel('AUC');
    
    % high/low accuracy comparison, all subjects
    subplot(3,4,6);
    acc = accuracyHighLow(:,3:4)*100;
    [m3,s3] = calcMeanSEOfSample( acc );
    [h,p]=ttest2( acc(:,1), acc(:,2) );
    plot([1.2 1.8],  acc', 'o-');
    hold on
    hsErr=errorbar( [1 2], m3, s3, '.');
    hold off
    set(hsErr,'LineWidth',2);
    xlim([0.8 2.2])
    ylim([0 100]);
    ylabel('accuracy (% correct)');
    title(['p=' num2str(p)]);
    set(gca,'XTick',[1 2]);
    [h,p1]=ttest( acc(:,1), 50)
    [h,p2]=ttest( acc(:,2), 50)
    set(gca,'XTickLabel',{['high p=' num2str(p1)],['low p=' num2str(p2)]});
    xlabel('confidence p vs. 50%');
    line([1 2],[50 50],'color','k');
    
    % compare mean confidence correct vs incorrect
    subplot(3,4,7)
    [mConf,sdConf,seConf,nConf] = calcMeanSEOfSample( mConf_all );
    bar(1:2, mConf);
    hold on
    errorbar(1:2, mConf, seConf,'.');
    hold off
    ylabel('confidence 1=high,3=guess');
    set(gca,'XTick',1:2);
    set(gca,'XTickLabel',{'Correct','Incorrect'});
    [~,pConf]=ttest2( mConf_all(:,1), mConf_all(:,2) );
    title(['pT2=' num2str(pConf) ' n=' num2str(nConf)]);
end

%=====internal functions
function [h, seTP,seFP] = plotAverageROCpoint( TPs, FNs, colorCode, plotErrorbarsMode)
[mTP,sTP,seTP,nTP] = calcMeanSEOfSample(TPs );
[mFP,sFP,seFP,nFP] = calcMeanSEOfSample( FNs );        
h=plot( mTP, mFP, ['d' colorCode],'MarkerSize',8, 'MarkerFaceColor', colorCode);
if plotErrorbarsMode
    errorbar( mTP, mFP, seTP, 'k' );
    herrorbar( mTP, mFP, seFP, 'k' );
end