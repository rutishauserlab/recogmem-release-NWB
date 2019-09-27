%
% calculate AUC values for all cells
%
% used to be part of NO_popAnalysis_ROC.m; split out 03/18/15 to run bootstrap
%
%urut/march15
function [ROCstats,All_AUCstats,mCounts,baselineRate_formCounts,  ...
    All_AUC_high_TP,All_AUC_low_TP,All_AUC_high_FP,All_AUC_low_FP, cellStatsAll] = NO_popAnalysis_ROC_eval(cellStatsAll, cellsToProcess, sigCellList, countWindow, highLowSplitDynamic, randomizeHighLow, balanceNrTrials)

debugPlot  = 0; % ROC plot
debugPlot2 = 0; % behavior plot (nr trials)
debugPlot3 = 0; % raster plot

ROCstats=[];
mCounts=[];
baselineRate_formCounts=[];
covered=[];
for k=1:length(cellsToProcess)
    cellStats = cellsToProcess(k);
    cellStr = ['NOid: ' num2str(cellStats.NOind) ' Ch-C:' num2str(cellStats.channel) '-' num2str(cellStats.cellNr)];
    
    baselineRate = cellStats.rate; 
    
    %cellStr='';
    % ROCs for different types of cells
    groundTruth = cellStats.newOldRecogLabels;   %ground truth
    behavioralResponse = cellStats.recogResponses;
    
    %labelsToUse = behaviorLabels; 
    %indsOldUse = find(labelsToUse==1 & params.recogResponses'>4 );
    %indsNewUse = find(labelsToUse==0 & params.recogResponses'<3 );
    
    % behavior, regardless of truth but excluding guesses
    % behavioral response, 6 vs 4+5
    %indsOld = find( behavioralResponse>=6);
    %indsNew = find( behavioralResponse<6 & behavioralResponse>=4);

    % ground truth, regardless of response
    %indsOld = find( groundTruth==1);
    %indsNew = find( groundTruth==0);

    % ground truth, correct answers only
    indsOld = find( groundTruth==1 & behavioralResponse'>=4);
    indsNew = find( groundTruth==0 & behavioralResponse'<=3);

    % ground truth, correct answers only, high conf only
    %indsOld = find( groundTruth==1 & behavioralResponse'>=5);
    %indsNew = find( groundTruth==0 & behavioralResponse'<=2);

    % ground truth, correct answers only, low conf only
    %indsOld = find( groundTruth==1 & (behavioralResponse'==4 | behavioralResponse'==5) );
    %indsNew = find( groundTruth==0 & (behavioralResponse'==3 | behavioralResponse'==2) );

    % ground truth, correct answers only, high OLD vs all NEW
    %indsOld = find( groundTruth==1 & (behavioralResponse'>=5) );
    %indsNew = find( groundTruth==0 & (behavioralResponse'<=3)  );

    % ground truth, correct answers only, low OLD vs all NEW
    %indsOld = find( groundTruth==1 & (behavioralResponse'==4 | behavioralResponse'==4 ) );
    %indsNew = find( groundTruth==0 & (behavioralResponse'<=3)  );

    % ground truth, correct answers only, all OLD vs high NEW
    %indsOld = find( groundTruth==1 & (behavioralResponse'>=4 ) );
    %indsNew = find( groundTruth==0 & (behavioralResponse'<=1)  );

    % ground truth, correct answers only, all OLD vs low NEW
    %indsOld = find( groundTruth==1 & (behavioralResponse'>=4 ) );
    %indsNew = find( groundTruth==0 & (behavioralResponse'==2 | behavioralResponse'==3)  );

    % ground truth, incorrect answers only
    %indsOld = find( groundTruth==0 & behavioralResponse'>=4);    % subject said old, but stimulus is new.
    %indsNew = find( groundTruth==1 & behavioralResponse'<=3);

    % remembered (old) vs forgotten (new)
    %indsOld = find( groundTruth==1 & behavioralResponse'>=4);   % TP
    %indsNew = find( groundTruth==1 & behavioralResponse'<=3);   % FN

    % remembered (old) vs false positive (new)
    %indsOld = find( groundTruth==1 & behavioralResponse'>=4);   % TP
    %indsNew = find( groundTruth==0 & behavioralResponse'>=4);   % FP
    
    

    %trial types
    indsTP = find( groundTruth==1 & behavioralResponse'>=4);   % TP
    indsFN = find( groundTruth==1 & behavioralResponse'<=3);   % FN
    indsTN = find( groundTruth==0 & behavioralResponse'<=3);   % TN
    indsFP = find( groundTruth==0 & behavioralResponse'>=3);   % TN

    
    % decide high/low split dynamically
    
    if highLowSplitDynamic
        [splitMode, indsTPhigh, indsTPlow, indsFPhigh, ...
        indsFPlow, indsTNhigh, indsTNlow, indsFNhigh, indsFNlow,splitStats] = NO_dynamic_lowHighSplit( groundTruth, behavioralResponse, 0  );
    else
        
        splitModeFixed = 1; 
        
        [splitMode, indsTPhigh, indsTPlow, indsFPhigh, ...
        indsFPlow, indsTNhigh, indsTNlow, indsFNhigh, indsFNlow,splitStats] = NO_dynamic_lowHighSplit( groundTruth, behavioralResponse, splitModeFixed  );
        
    end
    
    
    %if isempty(find(covered==cellStats.NOind))
    if debugPlot2    
        % plot this ROC and split
        figure(333);
        subplot(6,6,length(covered)+1);
        
        [isIncluded, AUC, percAccuracy_high, percAccuracy_low, TP, FP,respCounts] = NO_behavior_evaluateSessionStatus(behavioralResponse, groundTruth);

        bar(respCounts);
        
        title(['NOind=' num2str(cellStats.NOind) ' m=' num2str(splitMode) ' ' num2str(splitStats)]);
        
        covered = [ covered cellStats.NOind];
    end
    
    stimOnset=1000; %relative to begin of trial,when does the stimulus come on.
    stimLength=1000;
    delayPeriod=500; %how long till the question comes on
    trialLength = stimOnset + stimLength + delayPeriod;
    countPeriod = [ stimOnset+200 stimOnset+stimLength+500+200 ];  %1.5s window starting 200ms after onset
    
    normalizeCounts=1;
    countTP = extractPeriodCountsSimple(cellStats.timestamps, cellStats.periods(indsTP,:), countWindow(1), countWindow(2), normalizeCounts );
    countFN = extractPeriodCountsSimple(cellStats.timestamps, cellStats.periods([indsFN ],:), countWindow(1), countWindow(2), normalizeCounts );
    countFP = extractPeriodCountsSimple(cellStats.timestamps, cellStats.periods(indsFP,:), countWindow(1), countWindow(2), normalizeCounts );
    countTN = extractPeriodCountsSimple(cellStats.timestamps, cellStats.periods(indsTN ,:), countWindow(1), countWindow(2), normalizeCounts );

    countTPhigh = extractPeriodCountsSimple(cellStats.timestamps, cellStats.periods(indsTPhigh ,:), countWindow(1), countWindow(2), normalizeCounts );
    countTPlow = extractPeriodCountsSimple(cellStats.timestamps, cellStats.periods(indsTPlow ,:), countWindow(1), countWindow(2), normalizeCounts );
    countTNhigh = extractPeriodCountsSimple(cellStats.timestamps, cellStats.periods(indsTNhigh ,:), countWindow(1), countWindow(2), normalizeCounts );
    countTNlow = extractPeriodCountsSimple(cellStats.timestamps, cellStats.periods(indsTNlow ,:), countWindow(1), countWindow(2), normalizeCounts );

    countFPhigh = extractPeriodCountsSimple(cellStats.timestamps, cellStats.periods(indsFPhigh ,:), countWindow(1), countWindow(2), normalizeCounts );
    countFPlow = extractPeriodCountsSimple(cellStats.timestamps, cellStats.periods(indsFPlow ,:), countWindow(1), countWindow(2), normalizeCounts );
    countFNhigh = extractPeriodCountsSimple(cellStats.timestamps, cellStats.periods(indsFNhigh ,:), countWindow(1), countWindow(2), normalizeCounts );
    countFNlow = extractPeriodCountsSimple(cellStats.timestamps, cellStats.periods(indsFNlow ,:), countWindow(1), countWindow(2), normalizeCounts );
    
    % if any are empty, cannot use
    minNrCorrect = 2;
    if length(countTPhigh)<minNrCorrect | length(countTPlow)<minNrCorrect | length(countTNhigh)<minNrCorrect | length(countTNlow)<minNrCorrect
        countTPhigh=nan;
        countTPlow=nan;
        countTNhigh=nan;
        countTNlow=nan;
    end

    minNrErrors = 2;
    if length(countFPhigh)<minNrErrors | length(countFPlow)<minNrErrors | length(countFNhigh)<minNrErrors | length(countFNlow)<minNrErrors
        countFPhigh=nan;
        countFPlow=nan;
        countFNhigh=nan;
        countFNlow=nan;
    end
    
    %control condition - mix high/low while keeping TP/FN intact.does not scramble error trials
    if randomizeHighLow

        %---- randomly intermix high/low for TP
        nTPhigh = length(countTPhigh);
        nTPlow  = length(countTPlow);
        
        countTPmerge = [ countTPhigh countTPlow ];
        R = randperm(nTPhigh+nTPlow);

        countTPhigh = countTPmerge(R(1:nTPhigh));
        countTPlow = countTPmerge(R(nTPhigh+1:end));

        %---- randomly intermix high/low for TN
        nTNhigh = length(countTNhigh);
        nTNlow  = length(countTNlow);
        
        countTNmerge = [ countTNhigh countTNlow ];
        R2 = randperm(nTNhigh+nTNlow);

        countTNhigh = countTNmerge(R2(1:nTNhigh));
        countTNlow = countTNmerge(R2(nTNhigh+1:end));
    end
   
    % countStimulus_long is 1.5s, starting 200ms after stim onset
    countNew = cellStats.countStimulus_long(indsNew);
    countOld = cellStats.countStimulus_long(indsOld);
    
    if ~isempty(countNew) & ~isempty(countOld)
        
        nrStepsROC = 25;
        
        [AUC, TP, FP, TusedROC] = calcAUC_forOldDecoding(countNew, countOld, cellStats.neuronType, nrStepsROC, balanceNrTrials);   % all correct trials

        if cellStats.neuronType == 1
            %old>new
            % test TPhigh vs (all TN) and TPlow vs (all TN)
            countOld_toUse = [countTPhigh countTPlow];
            countNew_toUse = [ countTNhigh countTNlow];
            nNew_subset = length(countNew_toUse);
            nOld_high = length(countTPhigh);
            nOld_low = length(countTPlow);
            
            [AUC_high, TP_high, FP_high] = calcAUC_forOldDecoding( countNew_toUse, [countTPhigh], cellStats.neuronType,nrStepsROC, balanceNrTrials);   % all correct trials
            [AUC_low, TP_low, FP_low] = calcAUC_forOldDecoding( countNew_toUse, [countTPlow], cellStats.neuronType,nrStepsROC, balanceNrTrials);   % all correct trials
            
            %FN (GT:old,choice:new) vs TN   (to see if residual memory
            %signal)
            [AUC_FNall, TP_FNall, FP_FNall] = calcAUC_forOldDecoding( countNew_toUse, [countFNhigh countFNlow], cellStats.neuronType,nrStepsROC);  
            [AUC_FNhigh] = calcAUC_forOldDecoding( countNew_toUse, [countFNhigh ], cellStats.neuronType,nrStepsROC );  
            [AUC_FNlow] = calcAUC_forOldDecoding( countNew_toUse, [countFNlow ], cellStats.neuronType,nrStepsROC);  

            [AUC_FPall] = calcAUC_forOldDecoding( [countFPhigh countFPlow], countOld_toUse, cellStats.neuronType,nrStepsROC);  
            [AUC_FPhigh] = calcAUC_forOldDecoding( [countFPhigh ], countOld_toUse, cellStats.neuronType,nrStepsROC);  
            [AUC_FPlow] = calcAUC_forOldDecoding( [ countFPlow], countOld_toUse, cellStats.neuronType,nrStepsROC);  
            
            
            % for cellType0, first>second group is hypothesis;  FN>FP for old>new neuron
            
            [AUC_FN_vs_FP] = calcAUC_forOldDecoding([countFNhigh countFNlow],[countFPhigh countFPlow], 0,nrStepsROC);  
            
            [zTP_high,zFP_high] = getZROC(TP_high,FP_high, nOld_high, nNew_subset );
            [zTP_low,zFP_low] = getZROC(TP_low,FP_low, nOld_low, nNew_subset );
        else
            %new>old
            % test TNhigh vs (all TP) and TNlow vs (all TP)
            countOld_toUse = [countTPhigh countTPlow];
            countNew_toUse = [ countTNhigh countTNlow];
            nOld_subset = length(countOld_toUse);
            nNew_high = length(countTNhigh);
            nNew_low = length(countTNlow);
            
            [AUC_high, TP_high, FP_high] = calcAUC_forOldDecoding( [ countTNhigh], countOld_toUse, cellStats.neuronType,nrStepsROC,balanceNrTrials);   % all correct trials
            [AUC_low, TP_low, FP_low] = calcAUC_forOldDecoding( [countTNlow], countOld_toUse, cellStats.neuronType,nrStepsROC,balanceNrTrials);   % all correct trials

            %FN vs. old; [original in paper]
            %Now switch to FN vs. TN to test for residual memory signal
            %=[AUC_FNall, TP_FNall, FP_FNall] = calcAUC_forOldDecoding( [countFNhigh countFNlow], countOld_toUse, cellStats.neuronType,nrStepsROC);  
            %=[AUC_FNhigh] = calcAUC_forOldDecoding( [countFNhigh ], countOld_toUse, cellStats.neuronType,nrStepsROC);  
            %=[AUC_FNlow] = calcAUC_forOldDecoding( [countFNlow ], countOld_toUse, cellStats.neuronType,nrStepsROC);  

            [AUC_FNall, TP_FNall, FP_FNall] = calcAUC_forOldDecoding( countNew_toUse, [countFNhigh countFNlow], cellStats.neuronType,nrStepsROC);  
            [AUC_FNhigh] = calcAUC_forOldDecoding( countNew_toUse, [countFNhigh ], cellStats.neuronType,nrStepsROC);  
            [AUC_FNlow] = calcAUC_forOldDecoding( countNew_toUse, [countFNlow ], cellStats.neuronType,nrStepsROC);  

            [AUC_FPall] = calcAUC_forOldDecoding( [countFPhigh countFPlow], countOld_toUse, cellStats.neuronType,nrStepsROC);  
            [AUC_FPhigh] = calcAUC_forOldDecoding( [countFPhigh ], countOld_toUse, cellStats.neuronType,nrStepsROC);  
            [AUC_FPlow] = calcAUC_forOldDecoding( [ countFPlow], countOld_toUse, cellStats.neuronType,nrStepsROC);  
            
            % for cellType0, first>second group is hypothesis; FP>FN for new>old neuron
            [AUC_FN_vs_FP] = calcAUC_forOldDecoding([countFPhigh countFPlow],  [countFNhigh countFNlow], 0, nrStepsROC);  
            
            [zTP_high,zFP_high] = getZROC(TP_high,FP_high, nOld_subset, nNew_high );
            [zTP_low,zFP_low] = getZROC(TP_low,FP_low, nOld_subset, nNew_low );

        end

        All_AUC_high_TP(k,:) = TP_high;
        All_AUC_low_TP(k,:) = TP_low;
        
        All_AUC_high_FP(k,:) = FP_high;
        All_AUC_low_FP(k,:) = FP_low;

        % ROC stats for all confidence ratings
        [zTP_all,zFP_all,dP_all] = getZROC(TP,FP, length(countOld), length(countNew) );
        [d_a, c_e] = calcROC_stats_nonUnitSlope( zTP_all, zFP_all );
        [Rsquare, pValSlope, slope, intercept, bint] = getZROC_slope(zFP_all, zTP_all);
        
        % ROC stats for high confidence
        [d_a_high, c_e_high] = calcROC_stats_nonUnitSlope( zTP_high, zFP_high );

        % ROC stats for low confidence
        [d_a_low, c_e_low] = calcROC_stats_nonUnitSlope( zTP_low, zFP_low );
        
        [minErrCurve, minErrPoint ] = getROC_minErrorCriteria(TP, FP);
        
        d_a_all = d_a(minErrPoint);
        c_e_all = c_e(minErrPoint);
        
        All_AUCstats(k,:) = [ d_a_high(minErrPoint) d_a_low(minErrPoint) c_e_high(minErrPoint) c_e_low(minErrPoint) ];
    
        disp(['Sig cell: ' cellStr ' cellType:' num2str(cellStats.neuronType) ]);

    else
        AUC=nan;
        AUC_high=nan;
        AUC_low=nan;
        AUC_FNall=nan;
        AUC_FNhigh=nan;
        AUC_FNlow=nan;
        All_AUCstats=nan;
        AUC_FN_vs_FP=nan;
        AUC_FPall=nan;
        AUC_FPhigh=nan;
        AUC_FPlow=nan;
        TP=nan;
        FP=nan;
        zTP1=nan;
        zFP1=nan;
        slope=nan;
        minErrPoint=1;
        minErrCurve=nan;
    end
    
    
    mCounts(k,:) = [cellStats.neuronType AUC mean(countTP) mean(countFP) mean(countFN) mean(countTN) mean(countTPhigh) mean(countTPlow)  mean(countTNlow) mean(countTNhigh) mean(countFPhigh) mean(countFPlow) mean(countFNlow) mean(countFNhigh) ];
    baselineRate_formCounts(k) = baselineRate;
    
    
    ROCdata.FP=FP;
    ROCdata.TP=TP;
    ROCdata.FP_high=FP_high;
    ROCdata.TP_high=TP_high;
    ROCdata.FP_low=FP_low;
    ROCdata.TP_low=TP_low;
    ROCdata.AUC_high=AUC_high;
    ROCdata.AUC_low=AUC_low;
    ROCdata.AUC = AUC;    
    ROCdata.minErrCurve=minErrCurve;
    
    cellStatsAll( sigCellList(k) ).ROCdata = ROCdata;
    
    if debugPlot %& cellStats.neuronType == 1 %& AUC>0.6
        figure(k) 
        subplot(2,3,1);
        
        h1=plot( FP, TP, 'bo-');
        hold on
        h2=plot( FP_high, TP_high, 'go-');
        h3=plot( FP_low, TP_low, 'ro-');
        
        hold off
        legend([h1 h2 h3],{['all AUC=' num2str(AUC)],['high AUC=' num2str(AUC_high)],['low AUC=' num2str(AUC_low)]});
        
        line([0 1],[0 1],'color','k');
        ylabel(['AUC=' num2str(AUC)]);
        title([cellStr ' Ntype=' num2str(cellStats.neuronType) ' nTrials=' num2str(length(countOld)) ' vs ' num2str(length(countNew)) ]);
        
        %subplot(2,3,2);
        %plot( zFP1, zTP1, 'ro');
        %xlabel('zFP'); ylabel('zTP');

        %plotZROC_slope(zFP1, zTP1, slope, intercept, 'k');
        %title(['s=' num2str(slope) ' p=' num2str(pValSlope)]);
        
        subplot(2,3,3);
        
        plot( FP, minErrCurve, '-o');
        hold on
        plot( FP(minErrPoint), minErrCurve(minErrPoint), 'rd');
        hold off
        xlim([0 1]);
        title('minimum error test');
        
        subplot(2,3,4);

        bar(1:4, [length(indsTP) length(indsFN) length(indsTN) length(indsFP)] );
        set(gca,'XTick',1:4);
        set(gca,'XTickLabel',{'TP','FN','TN','FP'});
        ylabel('nr of trials');
        
        %ROC for different conditions
        subplot(2,3,5);

        hs=[];
        labelStrs=[];
        AUCVals=[];
        for j=1:6
            switch(j)
                case 1
                    % TP vs TN
                    indsOld=indsTP;
                    indsNew=indsTN;
                    labelStrs{j}='TP vs TN';
                case 2
                    % TP vs FP
                    indsOld=indsTP;
                    indsNew=indsFP;
                    labelStrs{j}='TP vs FP';
                case 3
                    % TP vs FN
                    indsOld=indsTP;
                    indsNew=indsFN;
                    labelStrs{j}='TP vs FN';
                case 4
                    % FP vs TN
                    indsOld=indsFP;
                    indsNew=indsTN;
                    labelStrs{j}='FP vs TN';
                case 5
                    % FP vs FN
                    indsOld=indsFP;
                    indsNew=indsFN;
                    labelStrs{j}='FP vs FN';
                case 6
                    % TN vs FN
                    indsOld=indsFN;
                    indsNew=indsTN;
                    labelStrs{j}='FN vs TN';
            end
        
            [AUC_subset, TP_subset, FP_subset] = calcAUC_forOldDecoding(cellStats.countStimulus_long(indsNew), cellStats.countStimulus_long(indsOld), cellStats.neuronType); 
            
            if j>1
               hold on
            end;
               
            hs(j)=plot( FP_subset, TP_subset, [ rotatingColorCode(j) 'o-']);
            
            AUCVals(j) = AUC_subset;
        end
        hold off
        line([0 1],[0 1],'color','k');
        legend(hs,labelStrs);
        
        subplot(2,3,6);
        bar( 1:length(AUCVals), AUCVals );
        set(gca,'XTick', 1:length(AUCVals) );
        set(gca,'XTickLabel', labelStrs);
        ylabel('AUC');
    end
    
    if debugPlot3 %& cellStats.neuronType == 1
        figure(k*100);
        binsizePlotting=250; % bin size for PSTH
        alphaLim=0.05;
        figNr=k*100;
        normalize=0;
        
%        subplotSize = plotRasters(binsizePlotting, alphaLim, figNr, [cellStr], cellStats.timestamps, trialLength+500, [stimOnset stimOnset+stimLength], ...
%            countPeriod, normalize, {'TP-high','TP-low','TN-low','TN-high'},  cellStats.periods(indsTPhigh,:),cellStats.periods(indsTPlow,:), cellStats.periods(indsTNlow,:), cellStats.periods(indsTNhigh,:) );
%        subplotSize = plotRasters(binsizePlotting, alphaLim, figNr, [cellStr], cellStats.timestamps, trialLength+500, [stimOnset stimOnset+stimLength], ...
%            countPeriod, normalize, {'TP','FP','FN','TN'},  cellStats.periods(indsTP,:),cellStats.periods(indsFP,:), cellStats.periods(indsFN,:), cellStats.periods(indsTN,:) );
        subplotSize = plotRasters(binsizePlotting, alphaLim, figNr, [cellStr], cellStats.timestamps, trialLength+500, [stimOnset stimOnset+stimLength], ...
            countPeriod, normalize, {'TP','TN'},  cellStats.periods(indsTP,:),cellStats.periods(indsTN,:) );

        %  experiment with cumsum plots
        
        subplot(subplotSize,subplotSize,7);

        binsizeCum=100;
        [binned_TP, histFit, edges ] = getBinnedCounts_generic( cellStats.timestamps, cellStats.periods(indsTPhigh,:)+1e6, trialLength, binsizeCum, [] );
        [binned_TN, histFit, edges ] = getBinnedCounts_generic( cellStats.timestamps, cellStats.periods(indsTNhigh,:)+1e6, trialLength, binsizeCum, [] );

        
        %baselineCumSum = mean( [ binned_TN(1:1000/binsizeCum)' binned_TP(1:1000/binsizeCum)' ] );
        
        baselineCumSum=0;
        cTP = cumsum( binned_TP-baselineCumSum );
        cTN = cumsum( binned_TN-baselineCumSum );
        
        plot( 1000+edges+binsizeCum/2, cTP, 'x-r',  1000+edges+binsizeCum/2, cTN, 'x-g');
        ylabel('cumsum');
        title(['bin=' num2str(binsizeCum)]);
    end
    ROCstats(k,:) = [ slope, intercept, pValSlope, cellStats.neuronType AUC FP(minErrPoint) TP(minErrPoint) AUC_high AUC_low d_a_all c_e_all AUC_FNall AUC_FNhigh AUC_FNlow AUC_FN_vs_FP AUC_FPall AUC_FPhigh AUC_FPlow];
end
