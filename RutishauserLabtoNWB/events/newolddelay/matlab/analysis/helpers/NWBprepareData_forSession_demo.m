% Prepare meta data needed for analysis of a session
%
% paramsIn: additional parameters, are passed on as-is to the callback function
%
%urut/aug16 -- simplified from preparePopDataRecog.m
function [params, basedirData_forSession,basedirEvents_forSession,brainArea] = NWBprepareData_forSession_demo( basepath, NOsession_toUse, ind, paramsIn )

%% load behavioral data of session
%load stimuli and behavioral responses - recognition
[~, stimuliRecog, newOldRecogLabels, recogResponses, responsesEventfile, recallResponses, recallEventfile, newOldRecall, eventsRecog, categoryMappingRecog, ~, ...
    RTRecog_raw, RTRecog_vsQ] = NWBloadDataOfBlock_release( NOsession_toUse, ind, 1,basepath ); %1 mode recog

%load stimuli --learning
if NOsession_toUse.EXPERIMENTIDLearn>0    %if this session has a learning block
    [stimuliLearn, ~, ~, ~, ~, ~, ~, ~, eventsLearn, categoryMappingLearn] = NWBloadDataOfBlock_release( NOsession_toUse, ind, 2, basepath ); %2 mode recog
else
    stimuliLearn=[];
    eventsLearn=[];
end

%Cut to specified nr trials if provided (for aborted sessions)
if isfield(NOsession_toUse, 'recogNrTrials')
    if ~isempty(NOsession_toUse.recogNrTrials)
        if NOsession_toUse.recogNrTrials>0
            newNrTrials = NOsession_toUse.recogNrTrials;
            warning(['Manually reducing nr trials to: ' num2str(newNrTrials)]);
            newOldRecogLabels=newOldRecogLabels(1:newNrTrials);
            stimuliRecog=stimuliRecog(1:newNrTrials);
        end
    end
end

%% determine the trial period timestamps
%determine recog periods
setMarkerIDs; %load markers

%3s total for each trial
StimOnTime  = 1500;  %for NO: 1s stim, 1s after stim (so 2s total after stim onset)
StimBaseline= 1000; %before stim onset

indsStimONRecog = find( eventsRecog(:,2) == STIMULUS_ON );
indsStimOffRecog = find( eventsRecog(:,2) == STIMULUS_OFF );
indsQuestionONRecog = find( eventsRecog(:,2) == DELAY1_OFF );
indsTrialEnd = find( eventsRecog(:,2) == DELAY2_OFF );

%for verification; duration of every trial from stim onset till ofset of after-response delay
trialDuration = eventsRecog( indsTrialEnd,1) - eventsRecog( indsStimONRecog,1);       % entire trial duration
if length(indsStimOffRecog)~=length(indsStimONRecog)
    trialDuration2=nan;
else
    trialDuration2 = eventsRecog( indsStimOffRecog,1) - eventsRecog( indsStimONRecog,1);  % from stim on to offset
end

periodsRecog = determinePeriods( indsStimONRecog, eventsRecog, StimBaseline, StimOnTime ); %stimBaseline -> before, StimOnTime -> after; both relative to indsStimONLearn timepoint.
periodsRecog_QuestionAligned = determinePeriods( indsQuestionONRecog, eventsRecog, StimBaseline, StimOnTime ); %stimBaseline -> before, StimOnTime -> after; both relative to indsStimONLearn timepoint.

if ~isempty(eventsLearn)
    indsStimONLearn = find( eventsLearn(:,2) == STIMULUS_ON );
    indsLearnResponse = indsStimONLearn+3;
    periodsLearn = determinePeriods( indsStimONLearn, eventsLearn, StimBaseline, StimOnTime ); %stimBaseline -> before, StimOnTime -> after; both relative to indsStimONLearn timepoint.
else
    periodsLearn=[];
end

%% load data files
%== paths
basedirData_forSession   = basepath;
basedirEvents_forSession = basepath;

brainArea=[];

%% package into params for passing to analysis function
params=[];
params.periodsRecog = periodsRecog;
params.periodsRecog_QuestionAligned = periodsRecog_QuestionAligned;
params.stimuliRecog = stimuliRecog;

%==recog block
params.categoryMappingRecog=categoryMappingRecog;
params.recogResponses = recogResponses;
params.newOldRecogLabels=newOldRecogLabels;
params.trialDuration = trialDuration;
params.trialDuration2 = trialDuration2; 

%==learning block
params.categoryMappingLearn=categoryMappingLearn;
params.stimuliLearn = stimuliLearn;
params.periodsLearn = periodsLearn;

params.nrProcessed=0;

%import additional parameters
if exist('paramsIn')
   params = copyStructFields( paramsIn, params );
end