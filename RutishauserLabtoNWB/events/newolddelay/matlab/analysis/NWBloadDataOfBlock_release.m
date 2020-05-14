% New/Old Experiment. Load behavioral and stimulus data.
%
%loads stimuli definitions, eventfile and logfile of a specific experimental block.
%extractionMode: 1 recog, 2 learn
%
%returns:
%stimuliLearn, stimuliRecog, newOldRecogLabels: data from experimentStimuli file (ground truth)
%recogResponses: recognition response from log file
%responsesEventfile: recognition response from events file (should be same)
%

function [stimuliLearn, stimuliRecog, newOldRecogLabels, recogResponses, responsesEventfile, recallResponses, recallEventfile, newOldRecall, events_all, categoryMapping, ...
    errorRateLearn, RTs,RTs_vsQonset, StimOff_toQ_delay, StimOn_toOff_delay] = NWBloadDataOfBlock_release( NWBsession, ind, extractionMode, basepath )
errorRateLearn=nan;
recallResponses=[];
recallEventfile=[];
newOldRecall=[];

% Read in nwbfiles


%Read NWB file 
nwbFname = [basepath NWBsession.filename];


if exist(nwbFname) && ~isempty(NWBsession.filename)
    disp(['Currently Processing: ', nwbFname]);
    disp(['Session #: ' num2str(ind)]); 
    nwb = nwbRead([basepath, filesep, NWBsession.filename]);
else 
    error('Either this file (%s) does not exist or this session does not exist: (%s) ', nwbFname, NWBsession.filename)
end 


experimentIDs = unique(nwb.acquisition.get('experiment_ids').data.load());

if extractionMode==1
    experimentID = NWBsession.EXPERIMENTIDRecog; 
else
    experimentID =  NWBsession.EXPERIMENTIDLearn; 
end

setMarkerIDs;

% need to get the following variables: 
% events, 
% indsStimOn,
% responsesEventfile, 
% stimOnsetTime, 
% stimOffsetTime, 
% questionOnsetTime, 
% StimOff_toQ_delay, 
% StimOn_toOff_delay,
% responseTime, 
% RTs, 
% RTs_vsQonset
% 

events_data = cellfun(@str2num, nwb.acquisition.get('events').data.load());
events_ts = nwb.acquisition.get('events').timestamps.load().*10.^6;
events_experiment_ids = nwb.acquisition.get('experiment_ids').data.load();

events = events_data((events_experiment_ids == experimentID));
indsStimOn = find(events==STIMULUS_ON);
responsesEventfile = events(indsStimOn+3);

events_all=[];
events_all(:, 1) = [events_ts(events_experiment_ids == experimentID)];
events_all(:, 2) =  [events];

switch ( extractionMode )
    case 1 %recog
        responsesEventfile = responsesEventfile-30;  %convert to 1-6 scale
    case 2 %learn
        responsesEventfile = responsesEventfile;  %leave it as is                
    otherwise
        error('unknown extractionMode');
end  


%reaction time of the response
stimOnsetTime = events_all( indsStimOn);        

stimOffsetTime = events_all( indsStimOn+1);        

questionOnsetTime = events_all(indsStimOn+2);

StimOff_toQ_delay = (questionOnsetTime-stimOffsetTime)/1000;
StimOn_toOff_delay = (stimOffsetTime-stimOnsetTime)/1000;

responseTime  = events_all( indsStimOn+3);

RTs = (responseTime-stimOnsetTime)/1000; %in ms
RTs_vsQonset = (responseTime-questionOnsetTime)/1000; 



%== recog stimuli

all_category_ids = double(nwb.intervals_trials.vectordata.get('stimCategory').data.load());
newOldRecogLabels = [];
stimuliRecog = [];
stimuliLearn = [];

if length(all_category_ids) == 150 
    stimuliRecog = all_category_ids(51:150);
    stimuliLearn = all_category_ids(1:50);
    for i = 51:150
            temp = nwb.intervals_trials.vectordata.get('new_old_labels_recog').data.load();
            newOldRecogLabels = [newOldRecogLabels, (temp(i))];
        
    end
elseif length(all_category_ids) == 197
    stimuliRecog = all_category_ids(98:197);
    stimuliLearn = all_category_ids(1:97); 
    for i = 98:197
            temp = nwb.intervals_trials.vectordata.get('new_old_labels_recog').data.load();
            newOldRecogLabels = [newOldRecogLabels, (temp(i))];       
    end
else
    stimuliRecog = all_category_ids(101:200);
    stimuliLearn = all_category_ids(1:100);
    for i = 101:200
            temp = nwb.intervals_trials.vectordata.get('new_old_labels_recog').data.load();
            newOldRecogLabels = [newOldRecogLabels, (temp(i))];
    end
end

if iscell(newOldRecogLabels)
    newOldRecogLabels = str2num(cell2mat(newOldRecogLabels(:)));
    newOldRecogLabels = newOldRecogLabels';
end 

categoryMapping = [];

events = events_data((events_experiment_ids == experimentID));
indsStimOn = find(events==STIMULUS_ON);
recogResponses = events(indsStimOn+3) - 30;
