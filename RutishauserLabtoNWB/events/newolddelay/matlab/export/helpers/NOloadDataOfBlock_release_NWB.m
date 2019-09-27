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
%the following are only set if the NO experiment type includes an src component:
%recallResponses: recall response from log file
%recallEventfile: recall response from events file
%newOldRecall: where image was during learning (ground truth, from experimentStimuli)
%events: all events of this entire block of the experiment
%
%urut/aug18: made simplified version for release
function [stimuliLearn, stimuliRecog, newOldRecogLabels, recogResponses, responsesEventfile, recallResponses, recallEventfile, newOldRecall, events, categoryMapping, ...
    errorRateLearn, RTs,RTs_vsQonset, StimOff_toQ_delay, StimOn_toOff_delay] = NOloadDataOfBlock_release( NOsession, extractionMode, basepath )
errorRateLearn=nan;
recallResponses=[];
recallEventfile=[];
newOldRecall=[];

if extractionMode==1
    experimentID = NOsession.EXPERIMENTIDRecog;
else
    experimentID = NOsession.EXPERIMENTIDLearn;
end

setMarkerIDs;

%== define filenames
% eventsFile = [basepath '/events/' NOsession.session '/eventsRaw.mat'];
eventsFile_withTaskDescr = [basepath '/events/' NOsession.session '/' NOsession.taskDescr '/eventsRaw.mat'];

% logfile = [basepath '/events/' NOsession.session '/newold' num2str(experimentID) '.txt' ];
logfile_withTaskDescr = [basepath '/events/' NOsession.session '/' NOsession.taskDescr '/newold' num2str(experimentID) '.txt' ];

%==process events file
if experimentID<0
    disp(['undefined experiment ID ' num2str(experimentID) ', dont load']);
    events=[];
else
    % see if this task has a subdirectory or not
    if exist(eventsFile_withTaskDescr)
        eventsFile_toUse = eventsFile_withTaskDescr;
        logfile_toUse = logfile_withTaskDescr;
    else        
        error(['missing ' eventsFile_withTaskDescr]);
        %         eventsFile_toUse = eventsFile;
        %         logfile_toUse = logfile;
    end
    
    if exist(eventsFile_toUse)
        disp(['using exp ID: ' num2str(experimentID) ' loading: ' eventsFile_toUse ]);
        load(eventsFile_toUse);
        events = events(find(events(:,3)==experimentID),1:3);
        indsStimOn = find(events(:,2)==STIMULUS_ON);
        responsesEventfile = events( indsStimOn+3,2);
        
        
        switch ( extractionMode )
            case 1 %recog
                responsesEventfile = responsesEventfile-30;  %convert to 1-6 scale
            case 2 %learn
                responsesEventfile = responsesEventfile;  %leave it as is                
            otherwise
                error('unknown extractionMode');
        end                
        
        %reaction time of the response
        stimOnsetTime = events( indsStimOn,1);        
        
        stimOffsetTime = events( indsStimOn+1,1);        
        
        questionOnsetTime = events(indsStimOn+2,1);

        StimOff_toQ_delay = (questionOnsetTime-stimOffsetTime)/1000;
        StimOn_toOff_delay = (stimOffsetTime-stimOnsetTime)/1000;
        
        responseTime  = events( indsStimOn+3,1);

        RTs = (responseTime-stimOnsetTime)/1000; %in ms
        RTs_vsQonset = (responseTime-questionOnsetTime)/1000; 
    else
        warning(['Events file does not exist,skip loading: ' eventsFile]);
        events=[];
        indsStimOn=[];
        responsesEventfile=[];    
        RTs=[];
    end
end

%== load the stimuli for the appropriate block
blockIDLearning=NOsession.blockIDLearn;
blockIDRecog=NOsession.blockIDRecog;

if ~isfield(NOsession,'variant')
    error('Error in NO definition - fix');
end
if isempty(NOsession.variant)
    error('Error in NO definition - fix');
end

%==== load stimulus definition file
switch ( NOsession.variant )
    case 1
        load([ 'newOldDelayStimuli.mat']);
        load([ 'NewOldDelay_v3.mat']);
    case 2
        load([ 'newOldDelayStimuli2.mat']);
        load([ 'NewOldDelay2_v3.mat']);        
    case 3
        load([ 'newOldDelayStimuli3.mat']);
        load([ 'NewOldDelay3_v3.mat']);        
    otherwise
        error(['NOvariant undefined: ' num2str(NOsession.variant)]);
end

%== recog stimuli
stimuliRecog = experimentStimuli(blockIDRecog).stimuliRecog;
newOldRecogLabels = experimentStimuli(blockIDRecog).newOldRecog;

%reduce nr trials if manual overwrite is provided
if isfield(NOsession, 'recogNrTrials')
    if ~isempty(NOsession.recogNrTrials)
        if NOsession.recogNrTrials>0
            warning(['Manually reducing nr trials to: ' num2str(NOsession.recogNrTrials)]);
            newOldRecogLabels=newOldRecogLabels(1:NOsession.recogNrTrials);
            stimuliRecog=stimuliRecog(1:NOsession.recogNrTrials);
        end
    end
end

%% == read data from logfile of this experiment (retrieval part)
if ~exist(logfile_toUse)
%     % Try to fix missing logfile issue - copy them from original location
%     logfile_oldLocation = [basepath 'events/' NOsession.session '/' NOsession.taskDescr '/newold' num2str(experimentID) '.txt'];
%     if ~exist(logfile_toUse)
%         copyfile(logfile_oldLocation, logfile_toUse);
%         disp(['copied logfile from ' logfile_oldLocation ' to ' logfile_toUse '; re-run and should work now']);
%     else
%         disp(['target already exists: ' logfile_toUse]);
%     end
disp(['error loading ',logfile_toUse]);
end

disp(['loading: ' logfile_toUse]);
D=dlmread(logfile_toUse, ';',1, 0);

%responses are 31....36, 31=1=sure new ..... 36=6=sure old
%recogResponses = D(find(D(:,2)>=31 & D(:,2)<=36),2);

indsStimOnLog = find( D(:,2)==STIMULUS_ON );
recogResponses = D( indsStimOnLog+3,2);

%convert to 1-6 scale
recogResponses = recogResponses-30;

% %== determine if experiment has an src part
% fid=fopen(logfile_toUse);
% C=textscan(fid,'%s %s %s',1,'delimiter',';');
% logEntry=C{3}{1};
% 
% if length(logEntry)>0   %if old file format, there will be no header,so ignore (has no src info if no header)
%     C2=textscan(logEntry,'%n %n %n %n %n',1,'delimiter',',');
%     fclose(fid);
% 
%     if C2{4}>0
%         disp([logfile_toUse ' file contains info about src recall,extract.']);
% 
%         %file contains src recall info, extract it
%         nStimuli = length(recogResponses);
% 
%         %parse the log and event file
%         recallResponses = ones(nStimuli,1)*-1;
%         recallEventfile = ones(nStimuli,1)*-1;
%         for i=1:nStimuli
%             if recogResponses(i)>3   %answer was OLD
%                 %5 is the offset of the src response relative to stimulus onset
%                 recallResponses(i) = D(indsStimOnLog(i)+5,2)-30;
%                 
%                 if size(events,1)>0
%                     recallEventfile(i) = events( indsStimOn(i)+5,2)-30;
%                 end
%             end
%         end
% 
%         newOldRecall = experimentStimuli(blockIDRecog).newOldRecall;
%     end
% end

%set event file responses equal to responses in log file -- only for preliminary analysis when event file is not available yet


%% == learning stimuli
%only if this session has a valid learning block.
if blockIDLearning>0 & extractionMode==2
    % size from logfile if no event file
    if size(responsesEventfile,1)>0
         nrLearnTrials =  size(responsesEventfile,1);
    else
         nrLearnTrials =  size( recogResponses, 1);   
    end
    
    switch (nrLearnTrials)
         case 100
             %normal - nothing needs to be done
             stimuliLearn = experimentStimuli(blockIDLearning).stimuliLearn;            
         case 50
             %short version - need to removed unused once
             stimuliLearn = experimentStimuli(blockIDLearning).stimuliLearn_onlySameDay2;    
         otherwise
             warning(['unusual nr of learning trials: ' num2str(nrLearnTrials) ]);
             stimuliLearn = experimentStimuli(blockIDLearning).stimuliLearn;            
    end   
     
    %determine whether the animal yes/no response was correct during learning
    
    CATEGORYNR_ANIMAL=5; %which category is the animal category
    
    groundTruth = categoryMapping(stimuliLearn,2);    
    groundTruth(find(groundTruth<CATEGORYNR_ANIMAL))  = 0; % binary, 0=no, 1=yes
    groundTruth(find(groundTruth==CATEGORYNR_ANIMAL)) = 1; % binary, 0=no, 1=yes
    
    respAnimal = nan(nrLearnTrials,1);    
    respAnimal( find(responsesEventfile==RESPONSE_LEARNING_ANIMAL)) = 1; %response was yes
    respAnimal( find(responsesEventfile==RESPONSE_LEARNING_NONANIMAL)) = 0; %response was no
    
    if length(respAnimal)==length(groundTruth)
        errorTrials = find( (respAnimal-groundTruth)~=0 );
    
        errorRateLearn = length(errorTrials)/nrLearnTrials;
    else
        warning('nr learn trials different from gnd truth -- cant calculate errorRateLearn');
        errorRateLearn = nan; 
    end
    
else
    stimuliLearn = [];
end
