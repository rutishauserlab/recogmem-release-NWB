%% Main file for new/old analysis using the NWB data format (behavior and single-unit)
%==================================================================
% NWBneural_main_release.m
%
% Code that demonstrates how to read and utilize the human single-unit MTL data acquired during the new/old recognition task.
% This version of the code relies on the NWB-formated version of the data.
%
% See Chandravadia et al. 2019, submitted.
%==================================================================


%% Section 1: Set Parameters - modify this section before running this code !

% Point this directory to where the downloaded code is located.
%codePath = 'C:\svnwork\nwbsharing\RutishauserLabtoNWB\'; % => enter here your path where the code is located. For Windows: 'nwb_example\'; For Linux or Mac: 'nwb_example/'
codePath = 'C:\svnwork\nwbsharing\RutishauserLabtoNWB\';

% Point this directory to where the downloaded NWB data is located.
%basepathData = 'V:\LabUsers\chandravadian\NWB Data\matlab_win\';%  => enter here your path where the data is located. For Windows: 'data\'; For Linux or Mac: 'data/'
basepathData = 'V:\LabUsers\chandravadian\NWB Data\NWBData\';
   
%List of sessions to analyze (for testing purposes)
allSessionsToUse = [5]; 

runAllAvailableSesssions = 0 ; % enable to process all available sessions (not just the one(s) specified above). Uses NWB_listOf_allUsable

addpath(fullfile(codePath)); 

%% Section 2: Which sessions to process 

inifileName = [codePath, filesep, 'events', filesep, 'newolddelay', filesep, ... 
    'defineNOsessions_release.ini']; 

[filepath,name,ext] = fileparts(inifileName);
if exist([filepath, filesep, 'matlab', filesep, 'analysis'])
    addpath([filepath, filesep, 'matlab', filesep, 'analysis']);
end 

%Add paths
NWBneural_main_addpath(codePath);

if ~exist(inifileName)
    error('This file does not exist: %s', inifileName)
else 
    %Read INI file 
    [keys,sections,subsections] = inifile(inifileName,'readall'); 
    %Convert INI file to matlab readable 
    [NWBsessions] = convertIni2NOsessions(keys);  
    %Get list of all usable sessions to use (see defineNOsessions_release.ini)
    NWB_listOf_allUsable = cellfun(@str2num, sections(:, 1)); 
end 

%generateCore() for first instantiation of matnwb API
if exist([codePath, filesep, '3rdParty', filesep, 'matnwb', filesep, ... 
         '+types', filesep, '+core', filesep, 'NWBFile.m'])
     disp(['generateCore() already initialized...']) %only need to do once
else 
    cd([codePath, filesep, '3rdParty', filesep, 'matnwb'])
    generateCore();
    disp(['generateCore() initialized...'])
end 

if runAllAvailableSesssions
    allSessionsToUse = NWB_listOf_allUsable %process all available
end

%% Section 3: Analyze and plot behavior
doPlot_behavior = 1;
modeBehavior = 1;  %0: fixed, 1: criterion threshold, 2: TP threshold. DEFAULT is 1
modeExcludeSlowRT = 0; %all trials (default); if one, slow RT trials are excluded to see if this effects results. 0 none, 1 strict (1sd, <5s), 2 lenient (3sd, <30s). See NObehaviorROC.m

%-- behavior summary figure (all sessions)
if length(allSessionsToUse)>1    % only works if at least two sessions are analyzed
   if  doPlot_behavior == 1
       figure(7);
   end
    decisionThresholds = NWB_behaviorSummary(NWBsessions, allSessionsToUse, modeBehavior, doPlot_behavior, basepathData, modeExcludeSlowRT);
end


%% Section 4: Single-neuron analysis. Loop over all available cells and run analysis on each independently
% which analysis to run.  1 is recognition/retrieval part (category/MS cells); 2 is learning part (VS cells only)
analysisMode = 1;    % recogexportnition part. only this mode allows what follows to run (MS/VS cell analysis)
%analysisMode = 2;    % learning part. No MS cell analysis here since all images are novel at this point.

paramsInPreset=[];
paramsInPreset.doPlot =  0;   % plot significant units. Warning, doPlot=1 generates a lot of figures! Put doPlot=0 to avoid that: it will only run statistics but don't make plots.
paramsInPreset.plotAlways = 0; % if enabled, plot all cells regardless of significance
% paramsInPreset.onlyChannels = [];   % to focus on particular set of channel(s), set this to a list of numbers. ie. [22 25 28].  [] means all channels available.
paramsInPreset.onlyAreas = [1, 2, 3, 4, 8, 13];   % which areas to process. see translateArea.m 
paramsInPreset.exportFig = 0; % store figs as eps; check path in NO_singleCellAnalysis_release.m
[totStats,cellStatsAll] = NWBneural_loopOverSessions_release(allSessionsToUse, NWBsessions, basepathData,analysisMode, paramsInPreset ); 


%% summary stats across all neurons
%how many diff vs baseline

nrMS=length(find([cellStatsAll.pNewOld]<0.05));
nrVS=length(find([cellStatsAll.pCategory]<0.05));
nrTot = length([cellStatsAll.cellNr]);

disp(['#tot: ' num2str(nrTot) ' #MS:' num2str(nrMS) ' #VS:' num2str(nrVS)]);
