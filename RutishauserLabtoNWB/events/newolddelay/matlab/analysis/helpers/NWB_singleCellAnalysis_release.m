%
% Simplified version of the per-cell analysis function used for the new/old task using the NWB data format.
% This cell is a callback function for NWBrunForAllCellsInSession.m
%
%
%urut/aug16
function params = NWB_singleCellAnalysis_release( timestampsOfCell, figNr, brainAreaOfCell, plabel, params, varargin )
params.nrProcessed = params.nrProcessed+1;

%% parameters used
stepsize = 250;
normalizeCounts = 1; % convert to Hz (spikes/sec)
alphaLim = 0.01; % sig limit to trigger plotting

analysisMode = params.analysisMode;   % 1 is recog, 2 is learn  (which part of the task is analyzed)

%% prepare trial indices
stimOnset = 1000; %relative to begin of trial,when does the stimulus come on.
stimLength = 1000; 
delayPeriod = 500; %how long till the question comes on
trialLength = stimOnset + stimLength + delayPeriod;

if analysisMode==1
    %Recognition part
    periods_toProcess = params.periodsRecog;

    %Visual category of each image that was shown
    modeStr='RR';
    stimuliCategories = params.stimuliRecog;

    recogResponses = params.recogResponses;     % response that was given (1-6)
    correctIncorrect=zeros(1,length(recogResponses));
    correctIncorrect( find(params.newOldRecogLabels'==0 & params.recogResponses<=3) ) = 1;
    correctIncorrect( find(params.newOldRecogLabels'==1 & params.recogResponses>=4) ) = 1;
    indsCorrect = find(correctIncorrect==1);  % only trials where ground truth and response correspond
    newOldRecogLabels = params.newOldRecogLabels ;  %ground truth - isOld flag. 1 is old, 0 is new
else
    %Learning part
    periods_toProcess = params.periodsLearn;
    
    if isempty(periods_toProcess)
        disp(['Has no learning session - skip. NOID:' num2str(params.NOind) ]);
        return;
    end
    
    modeStr='LL';
    %stimuliCategories = params.params.stimuliLearn;
    stimuliCategories = params.stimuliLearn;
    
    if length(stimuliCategories)~= size(periods_toProcess,1)
        disp(['Has invalid nr responses in learning session - skip. NOID:' num2str(params.NOind) ]);
        return;
    end
    
    recogResponses=[];
    correctIncorrect=[];
    newOldRecogLabels=[];
end

indCat1 = find( stimuliCategories == 1 );
indCat2 = find( stimuliCategories == 2 );
indCat3 = find( stimuliCategories == 3 );
indCat4 = find( stimuliCategories == 4 );
indCat5 = find( stimuliCategories == 5 );

%% get spike counts for trials

%== get spikecounts
countPeriod = [ stimOnset stimOnset+stimLength ];

countBaseline = extractPeriodCountsSimple( timestampsOfCell, periods_toProcess, 0, stimOnset, normalizeCounts );   % from 0 to stim onset (baseline)
countStimulus_long = extractPeriodCountsSimple( timestampsOfCell, periods_toProcess, stimOnset+200, stimOnset+1700, normalizeCounts );  % 200 to 1.7s after stim onset

%overall rate -- only calculated based on trials in this task
indsSpikesInExperiment = find ( timestampsOfCell > periods_toProcess(1,2) & timestampsOfCell <= periods_toProcess(end,2) );
if ~isempty(indsSpikesInExperiment)
    rate = length(indsSpikesInExperiment)/((timestampsOfCell(indsSpikesInExperiment(end))-timestampsOfCell(indsSpikesInExperiment(1)))/1e6);
else
    rate = nan;  % this cell has no spikes in this experiment
end

%% Tests - baseline and category
% baseline responsiveness
[h,pBaseline] = ttest2( countBaseline, countStimulus_long );

% assess category selectivity with ANOVA
DVs = {   stimuliCategories };
[pCategory,table,stats] = anovan( countStimulus_long, DVs,'alpha', 0.05,'display','off', 'model', 'interaction');

%% test if selective for new/old
if analysisMode==1
    %only correct
    labelsToUse = newOldRecogLabels;
    indsOldUse = find(labelsToUse==1 & correctIncorrect==1 );
    indsNewUse = find(labelsToUse==0 & correctIncorrect==1 );
    
    countOld = countStimulus_long( indsOldUse );
    countNew = countStimulus_long( indsNewUse );
    
    B=1000; %how many bootstrap runs
    %[pNewOld,tNull,tOB] = bootstrapMeanEqualTestSimple( countOld, countNew, B); % two-sided test
    [pNewOld, tNull,tOB] = bootstrapMeanEqualTest(countOld,countNew,B); 
    tOB=abs(tOB); %two-sided test
else
    pNewOld=1;
    tOB=nan;
    countOld=[];
    countNew=[];
    indsOldUse=[];
    indsNewUse=[];
end

%% decide type of MS neuron: FS or NS
%neuronType is decided only for neurons that are significant according to a bootstrap.
neuronType=0; % new>old
if pNewOld<=0.05 && mean(countOld)>mean(countNew)
    neuronType = 1;
end

%% plot raster
disp(['Cell in processing: ' plabel]);

plotAlways = copyFieldIfExists( params, 'plotAlways', 0 );
doPlot = params.doPlot;

if (pNewOld<0.01 & doPlot) | (pCategory<0.01 & doPlot) | plotAlways
    disp([modeStr ' sig MS p:' num2str(pNewOld) ' sig Cat diff p:' num2str(pCategory) ' pB:' num2str(pBaseline) ' ClID:' num2str(params.origClusterID) ]);

    figNr=params.pannelNr + params.NOind*100;
    figure( figNr );

    normalize = 0;
    binsizePlotting = 250; % bin size for PSTH
    
    %plot category raster
    if analysisMode==1
        groupLabels = {'C1','C2','C3','C4','C5','all','New','Old'};
        subplotSize = plotRasters(binsizePlotting, alphaLim, figNr, ['ID:' num2str(params.NOind) ' ' plabel ' p:' num2str(pCategory) ' pB:' num2str(pBaseline)], timestampsOfCell, trialLength+500, [stimOnset stimOnset+stimLength], countPeriod, normalize, groupLabels, ...
            periods_toProcess(indCat1,:), periods_toProcess(indCat2,:), periods_toProcess(indCat3,:), periods_toProcess(indCat4,:), periods_toProcess(indCat5,:), periods_toProcess, periods_toProcess(indsNewUse,:),periods_toProcess(indsOldUse,:));
    else
        % learning - only plot category
        groupLabels = {'C1','C2','C3','C4','C5','all'};
        subplotSize = plotRasters(binsizePlotting, alphaLim, figNr, ['ID:' num2str(params.NOind) ' ' plabel ' p:' num2str(pCategory) ' pB:' num2str(pBaseline)], timestampsOfCell, trialLength+500, [stimOnset stimOnset+stimLength], countPeriod, normalize, groupLabels, ...
            periods_toProcess(indCat1,:), periods_toProcess(indCat2,:), periods_toProcess(indCat3,:), periods_toProcess(indCat4,:), periods_toProcess(indCat5,:), periods_toProcess );
    end
    
    if analysisMode==1
        subplot(subplotSize,subplotSize,subplotSize^2);
        hist(tNull);
        line([tOB tOB],[0 200],'color','r');
        title(['pBoot=' num2str(pNewOld)]);
    end
    
    if analysisMode==1
        meanwaveform = params.meanWaveform_recog;% plot mean waveform during recognition task
    else
        meanwaveform = params.meanWaveform_learn;% plot mean waveform during learning task
    end
    subplot(subplotSize,subplotSize,subplotSize*3+1);
    plot([1:256]/100,meanwaveform);
    title('mean waveform');
    ylim([-max(abs(meanwaveform))-5 max(abs(meanwaveform))+5]);
    xlim([0 2.56]);
    ylabel('Amplitude [uV]');
    xlabel(['time [ms]']);
    clear meanwaveform
    
    %=== to export all figures automatically (set path manually first)
    if params.exportFig 
       outName = ['R:\results\NOdataReleaseFigs\recog\NOID' num2str(params.NOind) '_Ch' num2str(params.channel) '-' num2str( params.cellNr) '.eps'];
       set(gcf, 'Position', [50 50 2000 1200]);
       export_fig(outName, '-eps','-painters');
       close;   %close figure after export
    end
    
end

% add to list of stats of all processed neurons
% pN has multiple entries! (column counts)
if ~isfield(params,'allStats')
    params.allStats=[];
end

%params.allStats( size(params.allStats,1)+1,:) = [params.channel params.cellNr brainAreaOfCell pBaseline pNewOld pCategory neuronType length(countOld) length(countNew) rate];

% prepare data to return
cellStats=[];
cellStats.channel = params.channel;
cellStats.cellNr = params.cellNr;
cellStats.brainAreaOfCell = brainAreaOfCell;
cellStats.origClusterID = params.origClusterID;
cellStats.timestamps = timestampsOfCell;
cellStats.diagnosisCode = params.diagnosisCode;
cellStats.recogResponses = recogResponses;
cellStats.newOldRecogLabels = newOldRecogLabels;
cellStats.stimuliCategories = stimuliCategories;
cellStats.stimuliRecog = params.stimuliRecog;  % original stimulus ID of each recognition trial
cellStats.countBaseline = countBaseline;
cellStats.countStimulus_long = countStimulus_long;
cellStats.neuronType = neuronType;
cellStats.indsOldUse = indsOldUse;
cellStats.indsNewUse = indsNewUse;
cellStats.pVals = [pBaseline pNewOld pCategory];
cellStats.pNewOld = pNewOld; 
cellStats.pCategory = pCategory; 
cellStats.rate= rate;  
cellStats.periods=periods_toProcess;

%store spike counts for later analysis
runInd=params.pannelNr;
params.cellStats(runInd) = cellStats;
