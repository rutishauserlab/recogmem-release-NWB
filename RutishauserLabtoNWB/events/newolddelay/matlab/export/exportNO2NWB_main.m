%% Export New/old Dataset into NWB (Neurodata Without Borders)
% 
%
%--------------------------------------------------------------------------
%         Rutishauser Lab, Cedars-Sinai Medical Center/Caltech, 2019.  
%                    http://www.rutishauserlab.org/
% -------------------------------------------------------------------------
%  Overview:
%     This is the main file (exportNO2NWB_main) that exports human single-unit 
%     Medial Temporal Lobe data acquired during a new/old recognition task 
%     into the NWB format (Neurodata Without Borders).
%
%
%   This code is part of the data, code, and description released as part 
%   of our 2019 data release [link will be added here after acceptance].
%
%  Submitted paper:
%  "A NWB-based Dataset and Processing Pipeline of Human Single-Neuron Activity During a Declarative Memory Task" by 
%  N. Chandravadia, D. Liang, A. G.P. Schjetnan, A. Carlson, M. Faraut, J.M. Chung, C.M. Reed, B. Dichter, U. Maoz, 
%  S. Kalia, T. Valiante, A. N. Mamelak & U. Rutishauser. Submitted (2019).
%
%  The two published papers that describe this data are:
%
%  Rutishauser, U., S. Ye, M. Koroma, O. Tudusciuc, I.B. Ross, J.M. Chung, 
%  and A.N. Mamelak. Representation of retrieval confidence by single 
%  neurons in the human medial temporal lobe. Nature Neuroscience, 2015. 
%  18(7): p. 1041-50.
%
%  Faraut, M.C.M., Carlson, A., Sullivan, S., Tudusciuc, O., Ross, I., 
%  Reed, C.M., Chung, J.M., Mamelak, A.N., Rutishauser, U. Dataset of 
%  human medial temporal lobe single neuron activity during declarative 
%  memory encoding and recognition. Scientific Data, (2017).
%
%  Feel free to use this code and data for your own purposes. 
%  If you publish work based on this data/code, please cite
%  our data descriptor.
%
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------


%% Section 1 -- Set Parameters - modify this section before running this code !

%Path to native data to be exported

%basepath = 'C:\Users\chandravadn1\Desktop\code\data\Faraut et al 2018\';
basepath = 'V:\LabUsers\chandravadian\NWB Data\NativeData\';

%Add base code path (e.g., 'C:\svnwork\nwbsharing') 
codePath = 'C:\svnwork\nwbsharing\RutishauserLabtoNWB\';

exportStimInfo = 1;   % 0 no, 1 yes.  If turned off, the resulting NWB files do not contain the stimuli shown (images). This reduces the size of the NWB files considerably

% =======================No modifications needed below this======================================
%% Create NWB file object 

%Get ini file
inifileName = [codePath, filesep, 'events', filesep, 'newolddelay', filesep, ...
    'defineNOsessions_release.ini'];

%Add paths 
[filepath,name,ext] = fileparts(inifileName);
if exist([filepath, filesep, 'matlab', filesep, 'analysis'])
    addpath([filepath, filesep, 'matlab', filesep, 'analysis']);
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

NWBneural_main_addpath(codePath, basepath); 
    
%Instantiate the NWB file
nwb = NwbFile();

%% Parse Info from files 

%Convert INI file ----> New/Old sessions 
if ~exist(inifileName)
    error('This file does not exist: %s', inifileName)
else 
    %Read INI file 
    [keys,sections,subsections] = inifile(inifileName,'readall'); 
    %Convert INI file to matlab readable 
    [NOsessions] = convertIni2NOsessions(keys);  
    %clean NOsessions
    NOsessions = removeEmptyCells_NOsessions(NOsessions); 
end 


%Get path to save NWB files from user 
basepath_NWBsave = input('Where do you want to save the NWB files: ', 's'); 

while ~exist(basepath_NWBsave)
    warning('Sorry, this file directory does not exist: %s',basepath_NWBsave)
    warning('Please enter a valid file directory...')
    basepath_NWBsave = input('Where do you want to save the NWB files: ', 's');
end 



%%  Write General Properties to NWB file (i.e, lab, institution, sessionID, etc.)

for i = 1:length(NOsessions)

    %Add Attributes
    identifier = NOsessions(i).session;
    variant = NOsessions(i).variant;  
    lab = 'Rutishauser';
    institution = 'Cedars-Sinai Medical Center';
    related_publications = 'Faraut et al. 2018, Scientific Data; Rutishauser et al. 2015, Nat Neurosci';
    source_script = 'exportNO2NWB_main.m';
    source_script_file = 'exportNO2NWB_main';
    sessionID = NOsessions(i).ID;
    
    % == Write Here:
    nwb.identifier = identifier;
    nwb.session_description = ['NEW/OLD variant: ' num2str(variant), '|| NOID: ', cell2mat(sections(i)); ];
    date = '1900-01-01'; %Provide default date to protect PHI. Note: This date is not the ACTUAL date of the experiment 
    nwb.session_start_time = datetime(date,'Format','yyyy-MM-dd');
    nwb.general_lab = lab;
    nwb.general_institution = NOsessions(i).institution;
    nwb.general_related_publications = related_publications;
    nwb.general_source_script = source_script;
    nwb.general_source_script_file_name = source_script_file;
    nwb.general_session_id = num2str(sessionID);
    nwb.general_experiment_description = ... 
        ['The data contained within this file describes a new/old recogntion task performed in patients with intractable epilepsy implanted with depth electrodes and Behnke-Fried microwires in the human Medical Temporal Lobe (MTL).'];
    nwb.general_data_collection = ['learning: ', num2str(NOsessions(i).EXPERIMENTIDLearn), ...
        ', recognition: ', num2str(NOsessions(i).EXPERIMENTIDRecog)];
    
    %% Write Subject Information
    
    species = 'Human';
    subjectID = NOsessions(i).ID;
    sex = NOsessions(i).sex;
    age = num2str(NOsessions(i).age); 
    
    nwb.general_subject = types.core.Subject(...
        'species', species, ...
        'subject_id', subjectID, ...
        'sex', sex, 'age', age);
    
    
    %% %% load stimulus info for this session
    
    %Get NO sessions
    sessionInfo = NOsessions(i); %Which NO session
    basepathData = [basepath filesep 'Data' filesep]; %Where data from Faraut et al. is located
    
    % ====Add Events ==========
    
    %Get events file for each session 
        eventsFile = [basepathData, filesep, 'events', filesep, NOsessions(i).session, filesep ,NOsessions(i).taskDescr, ...
            filesep, 'eventsRaw.mat'];
        if ~exist(eventsFile)
            error('This file does not exist: %s', eventsFile)
        else
            load([eventsFile]);
        end
        
     TIME_SCALING = (10.^(-6));
     events_description = ['The events coorespond to the TTL markers for each trial. ', ...
         'For the learning trials, the TTL markers are the following: 55 = start of the experiment, ', ...
         '1 = stimulus ON, 2 = stimulus OFF, 3 = Question Screen Onset, ', ...
         '20 = Yes (21 = NO) during learning, 6 = End of Delay after Response, ', ...
         '66 = End of Experiment. For the recognition trials, the TTL markers are the following: ', ... 
         '55 = start of experiment, 1 = stimulus ON, 2 = stimulus OFF, 3 = Question Screen Onset, ' ...
         '31:36 = Confidence (Yes vs. No) response, 66 = End of Experiment'];
     
     %Set Events
      events_ts = types.core.AnnotationSeries('data', num2str(events(:, 2)), 'data_unit', 'NA', ...
           'timestamps', (events(:, 1)).*TIME_SCALING, 'description', events_description); 
      
      %Description for nwb.acquisition.get('experiment_ids')
      experiment_ids_description = ['The experiment_ids coorespond to the encoding (i.e., learning) or recogniton trials. ', ...
         'The learning trials are demarcated by: ' num2str(NOsessions(i).EXPERIMENTIDLearn), ...
         '. The recognition trials are demarcated by: ' num2str(NOsessions(i).EXPERIMENTIDRecog)];
     
     %Set Experiment IDs
     experiment_ids = types.core.TimeSeries('data',int8( events(:, 3)), 'data_unit', 'NA', ...
         'timestamps', [(events(:, 1))].*TIME_SCALING, 'description', ... 
         experiment_ids_description);
     
    %Assign events + Experiment IDs to NWB file (nwb.acquisition)
    nwb.acquisition.set('events', events_ts);
    nwb.acquisition.set('experiment_ids', experiment_ids);
    
    % ======== Get Events Learn ========
    [stimuliLearn, ~, ~, ~, ~, ~, ~, ~, events, categoryMapping, ~, ~,~, ~, ... 
        ~] = NOloadDataOfBlock_release_NWB(sessionInfo, 2, basepathData ); %2 mode learn
    
    %In case 100 trials are not recorded
    if ~(length(stimuliLearn) == 100)
        stimuliCategoriesLearn = categoryMapping(stimuliLearn(1:length(stimuliLearn)), 2);
        stimuliCategoriesLearn(length(stimuliCategoriesLearn)+1:100) = 0;  %No trials 
    else 
        stimuliCategoriesLearn = categoryMapping( stimuliLearn, 2 );
    end 
    
    
    indsLearn_ON = find(events(:,2)==1 ); 
    
    start_times_Learn=[];
    stop_times_Learn=[];
    delay1_times_Learn=[];
    response_times_Learn=[];
    response_values_Learn=[];
    delay2_times_Learn=[];
    expIDs_Learn=[];
    
    
    for k=1:length(indsLearn_ON)
        % asserts (check expected TTLs are there)
        TTLs_observed = events(indsLearn_ON(k):indsLearn_ON(k)+4, 2);
        
        if TTLs_observed(1)==1 & TTLs_observed(2)==2 & TTLs_observed(3)==3 & TTLs_observed(4)<=26 &  TTLs_observed(4)>=20 & TTLs_observed(5)==6
            %usable
            
            % for each trial, collect all info to later assign into trials structure of NWB
            start_times_Learn(k) = events(indsLearn_ON(k), 1);     % TTL=STIMULUS_ON =1
            stop_times_Learn(k)  = events(indsLearn_ON(k)+1, 1);   % TTL=STIMULUS_OFF = 2
            delay1_times_Learn(k) = events(indsLearn_ON(k)+2, 1);   % TTL=STIMULUS_OFF = 3
            response_times_Learn(k) = events(indsLearn_ON(k)+3, 1);   % TTL=31-36 (response)
            response_values_Learn(k) = events(indsLearn_ON(k)+3, 2)-20;   % 1-6, button pressed
            delay2_times_Learn(k) = events(indsLearn_ON(k)+4, 1);   % TTL=3
            expIDs_Learn(k) =   sessionInfo.EXPERIMENTIDLearn;
        else
            warning(['TTL structure not as expected for trial=' num2str(k) ' ==need to check/fix']);
            logging(i).learn = [NOsessions(i).session, '_', NOsessions(i).taskDescr]; 
        end
    end
    
    
    % ======== Get Events Recog =============================
    [~, stimuliRecog, newOldRecogLabels, ~, ~, ~, ~, ~, eventsRecog, categoryMapping, ~, ~,~, ...
     ~, ~] = NOloadDataOfBlock_release_NWB(sessionInfo, 1, basepathData ); %1 mode recog
    
    
    %Stimuli Categories are the Categories of Stimuli (such as animal, car,
    %etc)
    stimuliCategoriesRecog = categoryMapping( stimuliRecog, 2 );
    
    %when stim is presented
    indsRecog_ON = find(eventsRecog(:,2)==1 );
    
    start_times_Recog=[];
    stop_times_Recog=[];
    delay1_times_Recog=[];
    response_times_Recog=[];
    response_values_Recog=[];
    delay2_times_Recog=[];
    expIDs_recog=[];
    
    for k=1:length(indsRecog_ON)
        % asserts (check expected TTLs are there)
        TTLs_observed = eventsRecog(indsRecog_ON(k):indsRecog_ON(k)+4, 2);
        
        if TTLs_observed(1)==1 & TTLs_observed(2)==2 & TTLs_observed(3)==3 & TTLs_observed(4)<=36 & TTLs_observed(4)>=31 & TTLs_observed(5)==6
            %usable
            
            % for each trial, collect all info to later assign into trials structure of NWB
            start_times_Recog(k) = eventsRecog(indsRecog_ON(k), 1);     % TTL=STIMULUS_ON =1
            stop_times_Recog(k)  = eventsRecog(indsRecog_ON(k)+1, 1);   % TTL=STIMULUS_OFF = 2
            delay1_times_Recog(k) = eventsRecog(indsRecog_ON(k)+2, 1);   % TTL=STIMULUS_OFF = 3
            response_times_Recog(k) = eventsRecog(indsRecog_ON(k)+3, 1);   % TTL=31-36 (response)
            response_values_Recog(k) = eventsRecog(indsRecog_ON(k)+3, 2)-30;   % 1-6, button pressed
            delay2_times_Recog(k) = eventsRecog(indsRecog_ON(k)+4, 1);   % TTL=3
            expIDs_recog(k) =   sessionInfo.EXPERIMENTIDRecog;
        else
            warning(['TTL structure not as expected for trial=' num2str(k) ' ==need to check/fix']);
        end
    end
    
    %Assign values 
    start_times = [start_times_Learn, start_times_Recog].*TIME_SCALING;
    stop_times = [stop_times_Learn, stop_times_Recog].*TIME_SCALING;
    delay1_times = [delay1_times_Learn, delay1_times_Recog].*TIME_SCALING;
    response_times = [response_times_Learn, response_times_Recog].*TIME_SCALING;
    response_values = [response_values_Learn, response_values_Recog];
    delay2_times = [delay2_times_Learn, delay2_times_Recog].*TIME_SCALING;
    expIDs = [expIDs_Learn, expIDs_recog];
    stimuliCategories = [stimuliCategoriesLearn', stimuliCategoriesRecog'];
    
    
    %Add New/Old Recog Labels 
    new_old = {}; 
    for na = 1:100 
        new_old{na} = 10; 
    end 
    new_old = new_old'; 
    newOldRecogLabels = newOldRecogLabels';  
    new_old_labels_recog = [cell2mat(new_old); (newOldRecogLabels(1:100, 1))]; 
    
    %make sure columns are the same length 
    if ~(length(new_old_labels_recog) == length(expIDs))
        
        %Check for 100 trials  (Learning)
        if ~(length(expIDs_Learn) == 100)
            new_old_labels_recog(length(expIDs_Learn)+1:100) = [];
        end     
        
        %Check for 100 trials (Recognition)
        if ~(length(expIDs_recog) == 100)
            new_old_labels_recog(length(expIDs_recog)+1:100) = [];
        end
    end 
    
    if ~(length(stimuliCategories) == length(expIDs))
        
        if ~(length(expIDs_Learn) == 100)
            stimuliCategories(length(expIDs_Learn)+1:100) = [];
        end     
        
        %Check for 100 trials (Recognition)
        if ~(length(expIDs_recog) == 100)
            stimuliCategories(length(expIDs_recog)+1:100) = [];
        end
        
    end 
    
    %Get Category Name of Stimuli
    [categoryName] = getCategoryName(stimuliCategories, variant);
    %Add Learning and Recog tags 
    [stimPhase] = getLearnRecogTags(expIDs, NOsessions(i).EXPERIMENTIDLearn, ...
        NOsessions(i).EXPERIMENTIDRecog); 
    
    
    
    
    
    %% import trial info into NWB
    
    %Create initial trials constructor
    trials = types.core.TimeIntervals( ...
        'colnames', {'start_time','stop_time', 'delay1_time','response_time', ... 
        'response_value','delay2_time','ExperimentID', 'stimCategory', ... 
        'new_old_labels_recog', 'category_name', 'stim_phase'}, 'description', 'events ttls');    % start_time is a standard column; also has stop_time, which we don't use. TTL / ExperimentID are custom columns
    

    %Add trials information 
    trials.id = types.core.ElementIdentifiers('data', 0:length(start_times)-1);
    trials.start_time = types.core.VectorData('data', start_times, 'description', ...
        'start time in us (original) for TTL=1');
    trials.stop_time = types.core.VectorData('data', stop_times, 'description', ...
        'stop time in us (original) for TTL=2');
    trials.vectordata.set('delay1_time', types.core.VectorData('data',...
        delay1_times, 'description', ' time in us (original) for TTL=3')); 
    trials.vectordata.set('response_time', types.core.VectorData('data', ... 
        response_times, 'description', ' time in us (original) for TTL=31-36')); 
    trials.vectordata.set('response_value', types.core.VectorData('data', response_values, ...
        'description', 'response TTL=31-36'));
    trials.vectordata.set('delay2_time', types.core.VectorData('data', .... 
        delay2_times, 'description', ' time in us (original) for TTL=6')); 
    trials.vectordata.set('ExperimentID', types.core.VectorData('data', ... 
        expIDs, 'description', 'EXPERIMENT_ID')); 
     trials.vectordata.set('stimCategory', types.core.VectorData('data', .... 
        stimuliCategories, 'description', 'visual category of stimulus')); 
    trials.vectordata.set('new_old_labels_recog', types.core.VectorData('data', ...
        (new_old_labels_recog), 'description', 'New/Old Recognition Labels')); 
    trials.vectordata.set('category_name', types.core.VectorData('data', ...
        (categoryName), 'description', 'Category Name of Stimuli'));
    trials.vectordata.set('stim_phase', types.core.VectorData('data', ...
        (stimPhase), 'description', 'Learning and Recog Labels'));
%     
    %Assign trials to NWB file 
     nwb.intervals_trials = trials;

    %== Use following to get/set values of the dynamic table custom columns post-hoc
    %trials.vectordata.get('ABC')
    %trials.vectordata.set('ABC', types.core.VectorData('data', [false,true,false]))
    
    
    
    %% load info on the cells of this session; based on this, electrode table and units table is later constructed
    
        %Get brainArea file for each session 
        brainAreafile = [basepathData, filesep, 'events', filesep, NOsessions(i).session, filesep ,NOsessions(i).taskDescr, ...
            filesep, 'brainArea.mat'];
        
        if ~exist(brainAreafile)
            error('This file does not exist: %s', brainAreafile)
        else
            load([brainAreafile]);
        end
    
        %Get sorted sessions
        basepathSorted = [basepathData, 'sorted', filesep, NOsessions(i).session, filesep, ...
            NOsessions(i).taskDescr, filesep];
        if ~exist(basepathData)
            error('This file does not exist: %s', basepathSorted)
        end
  
    
    dataAll = runForAllCellsInSession( basepathSorted,  brainArea, sessionID, @NWBexport_accumulateCells, [] );
    electrodeTable_raw=[];  % all channels that have cells
    timestamps_all=[];
    timestamps_IDs_all=[];
    
    channel_ofCells = [];
    uniqueCellID=10000; % start with 10000 to differentiate with OSort-IDs and Cell IDs
    
    spike_times_allCells =[];
    
    for k=1:length(dataAll.cellStats)
        dataOfCell = dataAll.cellStats(k);
        
        channel_ofCells(k) = dataOfCell.channel;
        
        electrodeTable_raw = [ electrodeTable_raw; [ dataOfCell.channel dataOfCell.cellNr dataOfCell.brainAreaOfCell dataOfCell.origClusterID]];
        
        timestamps_all = [ timestamps_all dataOfCell.timestamps'];
        
        uniqueCellID = uniqueCellID+1;
        timestamps_IDs_all = [ timestamps_IDs_all repmat(uniqueCellID,1,length(dataOfCell.timestamps)) ];
        
        spike_times_allCells{k} = dataOfCell.timestamps';
    end
    
    %% Add info on the electrodes in this session that had cells to NLX file

    variables = {'x', 'y', 'z', 'imp', 'location', 'filtering', 'group', 'group_name','origChannel'};
    device_description = ['Recordings were performed with Macro-Micro Hybrid ' ...
        'Depth Electrodes with Behnke Fried/Micro Inner Wire Bundle in which ' ...
        'each individual microwire has a diameter of 40 microns. ' ...
        'Likwise, each Depth Electrode has 8 microwires.']; 
        
    
    
    elec_nums = unique(electrodeTable_raw(:,1)); % each channel that has at least one unit
    filterStr='300-3000Hz';
    
    tbl=[];
    %create an empty table. Has to be done this way because columns need to be named for later conversion
    for i_elec=elec_nums'
        % get brain area code of this electrode and translate to area string
        inds = find( electrodeTable_raw(:,1)==i_elec );
        brainAreaStr = translateArea( electrodeTable_raw(inds(1),3) );
        %Set the Device Label for the Microwires 
        device_label=['NLX-microwires-', num2str(i_elec)];
        ov = types.untyped.ObjectView(['/general/extracellular_ephys/' device_label]);
        %Add full name of brain area from the abbrevation
        if strcmp(brainAreaStr,'LA')
            brainArea_name = 'Left Amygdala';
            if strcmp('NaN', NOsessions(i).LA) 
                xPos = 'NaN'; 
                yPos = 'NaN'; 
                zPos = 'NaN';
            else
                MNI_coordinates = str2num(NOsessions(i).LA);
                xPos = num2str(MNI_coordinates(1));
                yPos = num2str(MNI_coordinates(2));
                zPos = num2str(MNI_coordinates(3));
            end 
        elseif strcmp(brainAreaStr,'RA')
            brainArea_name = 'Right Amygdala';
            if strcmp('NaN', NOsessions(i).RA)
                xPos = 'NaN'; 
                yPos = 'NaN'; 
                zPos = 'NaN';
            else 
                MNI_coordinates = str2num(NOsessions(i).RA);
                xPos = num2str(MNI_coordinates(1));
                yPos = num2str(MNI_coordinates(2));
                zPos = num2str(MNI_coordinates(3));
            end 
        elseif strcmp(brainAreaStr,'LH')
            brainArea_name = 'Left Hippocampus'; 
            if strcmp('NaN', NOsessions(i).LH)
                xPos = 'NaN'; 
                yPos = 'NaN'; 
                zPos = 'NaN';
            else
                MNI_coordinates = str2num(NOsessions(i).LH);
                xPos = num2str(MNI_coordinates(1));
                yPos = num2str(MNI_coordinates(2));
                zPos = num2str(MNI_coordinates(3));
            end
        elseif strcmp(brainAreaStr, 'RH')
            brainArea_name = 'Right Hippocampus';
            if strcmp('NaN', NOsessions(i).RH)
                xPos = 'NaN'; 
                yPos = 'NaN'; 
                zPos = 'NaN';
            else
                MNI_coordinates = str2num(NOsessions(i).RH);
                xPos = num2str(MNI_coordinates(1));
                yPos = num2str(MNI_coordinates(2));
                zPos = num2str(MNI_coordinates(3));
            end
        end 
        
        %Add the Impedance of the microwires
        imp=NaN;
        
        channelNr = electrodeTable_raw(inds(1), 1);
        
        if isempty(tbl)
            %create table
            tbl = table( {xPos}, {yPos}, {zPos}, imp, {brainArea_name}, {filterStr}, ov, {'micros'},channelNr, 'VariableNames', variables);
        else
            %append to existing table
            tbl = [tbl; { {xPos}, {yPos}, {zPos}, imp, brainArea_name, filterStr, ov, 'micros', channelNr} ];
        end
        
       
       %Set the Devices() Group
       nwb.general_devices.set(device_label, types.core.Device('help', device_description));
       %Set the Electrode() Group
       nwb.general_extracellular_ephys.set(device_label,...
        types.core.ElectrodeGroup(...
        'description', 'Microwire', ...
        'location', brainArea_name, ...
        'device', types.untyped.SoftLink(['/general/devices/' device_label])));
        
        
        end 
   
    electrode_table = util.table2nwb(tbl);
    electrode_table.description='microwire electrodes table';
    nwb.general_extracellular_ephys_electrodes = electrode_table;
    
   
    %% Export units (clusters)
    % see this helpful chart: https://github.com/NeurodataWithoutBorders/matnwb/blob/master/tutorials/html/UnitTimes.png
  
      nwb.units = types.core.Units('colnames', {'spike_times',  ... 
          'waveform_mean_encoding', 'waveform_mean_recognition', 'electrodes', 'origClusterID', ... 
          'IsolationDist', 'SNR', 'waveform_mean_sampling_rate'}, 'description','units table');
    
    %== Add spike times to the unit table
    %Add all spike times to the spike_times_vector, indexed by
    %spike_times_vector
    [spike_times_vector, spike_times_index] = create_indexed_column(spike_times_allCells, '/units/spike_times');
    nwb.units.spike_times = spike_times_vector; 
    nwb.units.spike_times_index = spike_times_index;  
    
    nrUnits = length(spike_times_index.data);  % entire session across all
    % units has so many spikes
    nwb.units.id = types.core.ElementIdentifiers('data', int64([1:length(spike_times_index.data)]-1));
    
    
    %== link each unit to entry in electrode table (which will identify channel
    %it was recorded on, brain area etc.
    link_toElectrode_table=[];
    for k=1:length(channel_ofCells)
        link_toElectrode_table(k) = find( elec_nums == channel_ofCells(k)); 
    end
    link_toElectrode_table = link_toElectrode_table-1;  %id in
    % electrode_table is zero based
    %
    %
    ov_elTable = types.untyped.ObjectView('/general/extracellular_ephys/electrodes');
    %
    link_toElectrode_table_Cells = num2cell( link_toElectrode_table);
    [electrodes, electrodes_index] = create_indexed_column(link_toElectrode_table_Cells, [], [], [], ov_elTable );
     %nwb.units.electrodes = electrodes; 
     %nwb.units.electrodes_index = electrodes_index;
    nwb.units.electrodes = types.core.DynamicTableRegion('table',ov_elTable, ... 
        'description', 'single electrodes', 'data', electrodes.data); 
    
     
    %% ==  Assign Waveform Means, ClusterIDs, Isolation Distance ,SNR ==== 
    
    %Get all sorted channels each session
    dataAll = runForAllCellsInSession( basepathSorted,  brainArea, sessionID, @NWBexport_accumulateCells, [] ); 
    %Only get channels once
    sortedCells = unique([dataAll.cellStats.channel]); 
    
    waveform_mean_encoding = [];
    waveform_mean_recogntion = [];
    originalClusterIDs = [];
    IsolationDist = [];
    SNR = [];
    for n = 1:length(sortedCells)
           %Load Each Channel 
           channel = [basepathSorted,filesep,'A', num2str(sortedCells(n)), '_cells.mat'];
           
           if exist(channel) 
                load(channel);
           else 
               error('This file does not exist: %s',channel)
           end
           
           n = length(waveform_mean_encoding) + 1;
           
           % ----Get Waveform Means, OriginalClustID's, IsoDist, SNR -----
           if length(meanWaveform_learn) > 1
               %Assign Multiple Clusters 
               for wv = 1:length(meanWaveform_learn(:))
                   waveform_mean_encoding{n, 1} = meanWaveform_learn(wv).m_waveform;
                   waveform_mean_recogntion{n, 1} = meanWaveform_recog(wv).m_waveform; 
                   originalClusterIDs{n, 1} = meanWaveform_learn(wv).clust;
                   IsolationDist{n, 1} = IsolDist_SNR(wv).IsolDist;
                   SNR{n, 1} = IsolDist_SNR(wv).SNR;
                   n = n + 1;
               end
           else
               %Assign Single Cluster
               waveform_mean_encoding{n, 1} = meanWaveform_learn.m_waveform;
               waveform_mean_recogntion{n, 1} = meanWaveform_recog.m_waveform; 
               originalClusterIDs{n, 1} = meanWaveform_learn.clust;
               IsolationDist{n, 1} = IsolDist_SNR.IsolDist;
               SNR{n, 1} = IsolDist_SNR.SNR;
           end
      
           % -----------------------------------------------
    end
    
   
    %Check correct # of waveform means are added
    if ~(length(waveform_mean_encoding) == length(electrodes.data)) 
        error('Error in assigning waveform clusters, need to check/fix manually')
    end 
   
    %If no waveform_mean was recorded, add empty matrix 
    for k=1:length(waveform_mean_encoding)
        if length(cell2mat(waveform_mean_encoding(k, 1))) < 10
              waveform_mean_encoding{k, 1} = zeros(1, 256);
        end
    end 
    
    %If no waveform_mean was recorded, add empty matrix 
    for k=1:length(waveform_mean_recogntion)
        if length(cell2mat(waveform_mean_recogntion(k, 1))) < 10
              waveform_mean_recogntion{k, 1} = zeros(1, 256);
        end
    end 
    
    %Assign Waveform Clusters (Learning + Recog)
    nwb.units.vectordata.set('waveform_mean_encoding', types.core.VectorData('data', cell2mat(waveform_mean_encoding)', ...
        'description', ['Mean Waveforms of Learning']));
    nwb.units.vectordata.set('waveform_mean_recognition', types.core.VectorData('data', cell2mat(waveform_mean_recogntion)', ...
        'description', ['Mean Waveforms of Recognition']));

    sampling_rate_waveform = (98.4.*10.^3); %98.4 kHz
    sampling_rate_waveform_matrix = [ones(length(waveform_mean_recogntion))].*sampling_rate_waveform;
    nwb.units.vectordata.set('waveform_mean_sampling_rate', types.core.VectorData('data', ... 
        sampling_rate_waveform_matrix(:, 1), 'description', 'Sampling Rate of Waveform'));
    
   %Assign Cluster ID's 
   nwb.units.vectordata.set('origClusterID', types.core.VectorData('data', ...
       (cell2mat(originalClusterIDs)), 'description', 'Cluster IDs of units'));
   
   %Assign IsolationDist
   nwb.units.vectordata.set('IsolationDist', types.core.VectorData('data', ...
       cell2mat(IsolationDist), 'description', 'Isolation Distance of units'));
   
   %Assign SNR 
   nwb.units.vectordata.set('SNR', types.core.VectorData('data', ...
       cell2mat(SNR), 'description', 'SNR of units'));
   
    
   %% Add Stimuli to NWB file 
   
   if exportStimInfo
       %Get the path to stimuli
       stimuliPath = [basepath, filesep,'Stimuli', filesep];
       
       %validation
       if ~exist(stimuliPath)
           error('This file does not exiss: %s', stimuliPath)
       end
       mode = 2; %mode 2
       % ============================================================
       [stimuliLearn, stimuliRecog, ~, ~, ~, ~, ~, ...
           ~, ~, ~, ~, ~, ~] = NOloadDataOfBlock_release_NWB( sessionInfo, mode,basepathData );
       
       %Get stimuli mapping
       [stimuliMapping] = getStimuliMapping(basepath, variant) ;
       %transpose stimuli
       stimuliLearn = stimuliLearn';
       stimuliRecog = stimuliRecog';
       
       stimuli_presentation_learn = {};
       % === Get Stimuli for learning
       for st = 1:length(stimuliLearn)
           
           %(e.g.,\Stimuli\newolddelay\houses)
           stimuliPath = fullfile(basepath, 'Stimuli', cell2mat(stimuliMapping(stimuliLearn(st), 1)) , ...
               cell2mat(stimuliMapping(stimuliLearn(st), 2)), ...
               cell2mat(stimuliMapping(stimuliLearn(st), 3)));
           
           %validation
           if ~exist(stimuliPath)
               error('This file does not exist: %s', stimuliPath)
           end
           
           %Load Stimuli
           img = imread(stimuliPath);
           resize_img = imresize(img,[300 400]);
           stimuli_presentation_learn{st, 1} = resize_img;
           %Add Stimuli Learn to NWB file
           stimulusTag = ['stimuli_learn_', num2str(st)];
           
           
       end
       
       % === Get Stimuli for Recog
       stimuli_presentation_recog = {};
       for st = 1:length(stimuliRecog)
           
           %(e.g.,\Stimuli\newolddelay\houses)
           stimuliPath = fullfile(basepath, 'Stimuli', cell2mat(stimuliMapping(stimuliRecog(st), 1)) , ...
               cell2mat(stimuliMapping(stimuliRecog(st), 2)), ...
               cell2mat(stimuliMapping(stimuliRecog(st), 3)));
           
           %validation
           if ~exist(stimuliPath)
               error('This file does not exist: %s', stimuliPath)
           end
           
           %Load Stimuli
           img = imread(stimuliPath);
           %Resize Pixels
           resize_img = imresize(img,[300 400]);
           stimuli_presentation_recog{st, 1} = resize_img;
           
           %Add Stimuli Learn to NWB file
           stimulusTag = ['stimuli_recog_', num2str(st)];
           
           
       end
       
       stimuli_presentation = [stimuli_presentation_learn; stimuli_presentation_recog ];
       
       %== add all raw images into a large datastructure to load into OpticalSeries
       % all_stimli is  (r,g,b) x Y x X x # frames.    so 3,nrPixelsY,nrPixelsX,nrFrames
       nrFrames = length(stimuli_presentation);
       all_stimuli = uint8(nan(3, 300, 400, nrFrames));
       for u = 1:length(stimuli_presentation)
           image_ofTrial_raw = stimuli_presentation{u};
           if ndims(image_ofTrial_raw) == 2
               % need to convert greyscale to RGB to make uniform
               image_ofTrial_raw = cat(3, image_ofTrial_raw, image_ofTrial_raw, image_ofTrial_raw);
           end
           
           all_stimuli(:,:,:,u) = permute( image_ofTrial_raw, [3 1 2] );   % re-arrange dimenions so they are (r,g,b) x Y x X
       end
        
        % test to see that images can be plotted
        %testImg = all_stimuli(:,:,:,155);
        %figure; imshow(  permute(testImg, [2 3 1]))
          
       %Add stimulus information
       stimulus = types.core.OpticalSeries('data', all_stimuli, 'timestamps',  [start_times'], 'orientation', 'lower left', ...
           'format', 'raw', 'distance', 0.7, 'field_of_view', [0.3, 0.4, 0.7], 'dimension', [300,400, 3], ...
           'data_unit', 'meters');
       nwb.stimulus_presentation.set('StimulusPresentation', stimulus);
       
   end
   
   
%% Export the NWB file
NWBfilename = NOsessions(i).filename;

exportFileName = [basepath_NWBsave, filesep, NWBfilename]; 

disp(['Exporting: ' exportFileName]);
nwbExport(nwb, exportFileName); 

end 






