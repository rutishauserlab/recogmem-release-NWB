%
% This demo file exports a single session of new/old (loaded manually, for demonstration purposes)
%
%urut/Jan'19

%% 

%% 
%addpath('C:\svnwork\nwbsharing\3rdParty\matnwb-0.2.1\+types\+util');  % this contains the matnwb release to be used

%run following if release was updated from repository
%generateCore(fullfile('schema','core','nwb.namespace.yaml'));

%%
basepath = 'E:/dataRelease/Data/';   % unzipped version of released dataset
outDir = 'E:/dataRelease/';


basepath = 'C:\Users\chandravadn1\Desktop\code\data\Faraut et al 2018\Data\';

NOID=5;

NOsessions = defineNOsessions_release();
sessionInfo = NOsessions(NOID);

sessionID = sessionInfo.session;
subjectID = sessionInfo.sessionID;

basepathEvents = [ basepath filesep 'events' filesep sessionInfo.session filesep  sessionInfo.taskDescr filesep];
basepathData = [ basepath filesep 'sorted' filesep  sessionInfo.session filesep sessionInfo.taskDescr filesep];

%%
nwb = nwbfile();

%From documentation. Those that dont =None are required (no default value)
% class pynwb.file.NWBFile(session_description, identifier, session_start_time, file_create_date=None, timestamps_reference_time=None, experimenter=None, experiment_description=None, session_id=None, institution=None, keywords=None, notes=None, pharmacology=None, protocol=None, related_publications=None, slices=None, source_script=None, source_script_file_name=None, data_collection=None, surgery=None, virus=None, stimulus_notes=None, lab=None, acquisition=None, stimulus=None, stimulus_template=None, epochs=None, epoch_tags=set(), trials=None, invalid_times=None, time_intervals=None, units=None, modules=None, electrodes=None, electrode_groups=None, ic_electrodes=None, sweep_table=None, imaging_planes=None, ogen_sites=None, devices=None, subject=None)

nwb.identifier = sessionID;
nwb.session_description = 'new/old variant 3';

%TBD: We need to put session date/time into NOsessions to provide this
date = datetime(2018, 3, 1, 12, 0, 0);
nwb.session_start_time = datetime(date,'Format','yyyy-MM-dd''T''HH:mm:SSZZ', 'TimeZone','local');

nwb.general_lab = 'Rutishauser';
nwb.general_institution = ['CSMC'];
nwb.general_related_publications = ['Faraut et al 2018, Scientific Data; Rutishauser et al. 2015, Nat Neurosci;'];
nwb.general_source_script = 'NWBexport_demo.m';
nwb.general_source_script_file_name = 'NWBexport_demo';
nwb.general_session_id = ['NOID=' num2str(NOID)];

%%
nwb.general_subject = types.core.Subject(...
    'species', 'Human', ...
    'subject_id', subjectID, ... 
    'sex', '?', 'age', 'tbd');   % TODO: get this stuff from subjects table

%% load stimulus info for this session
[stimuliLearn, stimuliRecog, newOldRecogLabels, recogResponses, responsesEventfile, recallResponses, recallEventfile, ...
    newOldRecall, eventsRecog, categoryMappingRecog, ~, RTRecog_raw, RTRecog_vsQ] = NOloadDataOfBlock( sessionInfo, 1,basepath ); %1 mode recog

stimuliCategories = categoryMappingRecog( stimuliRecog, 2 );

indsRecog_ON = find(eventsRecog(:,2)==1 );

start_times=[];
stop_times=[];
delay1_times=[];
response_times=[];
response_values=[];
delay2_times=[];
expIDs=[]; 
for k=1:length(indsRecog_ON)
    % asserts (check expected TTLs are there)   
    TTLs_observed = eventsRecog(indsRecog_ON(k):indsRecog_ON(k)+4, 2);
    
    if TTLs_observed(1)==1 & TTLs_observed(2)==2 & TTLs_observed(3)==3 & TTLs_observed(4)<=36 & TTLs_observed(4)>=31 & TTLs_observed(5)==6
        %usable
        
        % for each trial, collect all info to later assign into trials structure of NWB            
        start_times(k) = eventsRecog(indsRecog_ON(k), 1);     % TTL=STIMULUS_ON =1
        stop_times(k)  = eventsRecog(indsRecog_ON(k)+1, 1);   % TTL=STIMULUS_OFF = 2
        delay1_times(k) = eventsRecog(indsRecog_ON(k)+2, 1);   % TTL=STIMULUS_OFF = 3    
        response_times(k) = eventsRecog(indsRecog_ON(k)+3, 1);   % TTL=31-36 (response)
        response_values(k) = eventsRecog(indsRecog_ON(k)+3, 2)-30;   % 1-6, button pressed
        delay2_times(k) = eventsRecog(indsRecog_ON(k)+4, 1);   % TTL=3
        expIDs(k) =   sessionInfo.EXPERIMENTIDRecog;      
    else
        error(['TTL structure not as expected for trial=' num2str(k) ' ==need to check/fix']);
    end
end

%% import trial info into NWB
trials = types.core.TimeIntervals( ...
    'colnames', {'start_time','stop_time', 'delay1_time','response_time','response_value','delay2_time','ExperimentID','stimCategory'},...      % start_time is a standard column; also has stop_time, which we don't use. TTL / ExperimentID are custom columns
    'description', 'events ttls', ...    
    'start_time', types.core.VectorData('data', start_times, 'description', 'start time in us (original) for TTL=1'),...
    'stop_time', types.core.VectorData('data', stop_times, 'description', 'stop time in us (original) for TTL=2'),...
    'delay1_time', types.core.VectorData('data', delay1_times, 'description', ' time in us (original) for TTL=3'),...
    'response_time', types.core.VectorData('data', response_times, 'description', ' time in us (original) for TTL=31-36'),...
    'response_value', types.core.VectorData('data', response_values, 'description', 'response TTL=31-36'),...
    'delay2_time', types.core.VectorData('data', delay2_times, 'description', ' time in us (original) for TTL=6'),...
    'ExperimentID', types.core.VectorData('data', expIDs, 'description', 'EXPERIMENT_ID'), ...
    'stimCategory', types.core.VectorData('data', stimuliCategories, 'description', 'visual category of stimulus'), ...
    'id', types.core.ElementIdentifiers('data', 0:length(start_times)-1));

%== Use following to get/set values of the dynamictable custom columns post-hoc
%trials.vectordata.get('ABC')
%trials.vectordata.set('ABC', types.core.VectorData('data', [false,true,false]))

nwb.intervals_trials = trials;

%% load info on the cells of this session; based on this, electrode table and units table is later constructed
load([basepathEvents '/brainArea.mat']);
dataAll = runForAllCellsInSession( basepathData,  brainArea, sessionID, @NWBexport_accumulateCells, [] );
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
device_label='NLX-microwires';
variables = {'x', 'y', 'z', 'imp', 'location', 'filtering', 'group', 'group_name','origChannel'};
nwb.general_devices.set(device_label, types.core.Device());

nwb.general_extracellular_ephys.set(device_label,...
    types.core.ElectrodeGroup(...
    'description', 'Microwire', ...
    'location', 'unknown', ...
    'device', types.untyped.SoftLink(['/general/devices/' device_label])));

ov = types.untyped.ObjectView(['/general/extracellular_ephys/' device_label]);

elec_nums = unique(electrodeTable_raw(:,1)); % each channel that has at least one unit
filterStr='300-3000Hz';

tbl=[];
%create an empty table. Has to be done this way because columns need to be named for lalter conversion
for i_elec=elec_nums'
    % get brain area code of this electrode and translate to area string
    inds = find( electrodeTable_raw(:,1)==i_elec );
    brainAreaStr = translateArea( electrodeTable_raw(inds(1),3) );
    
    %values that are unknown for this type of electrode
    xPos=NaN;
    yPos=NaN;
    zPos=NaN;
    imp=NaN;
    
    channelNr = electrodeTable_raw(inds(1), 1);
    
    if isempty(tbl)
        %create table
        tbl = table( xPos, yPos, zPos, imp, {brainAreaStr}, {filterStr}, ov, {'micros'},channelNr, 'VariableNames', variables);
    else
        %append to existing table
        tbl = [tbl; { xPos, yPos, zPos, imp, brainAreaStr, filterStr, ov, 'micros', channelNr} ];
    end
end
electrode_table = util.table2nwb(tbl);
electrode_table.description='microwire electrodes table';
nwb.general_extracellular_ephys_electrodes = electrode_table;



%% Export units (clusters)
% see this helpful chart: https://github.com/NeurodataWithoutBorders/matnwb/blob/master/tutorials/html/UnitTimes.png
nwb.units = types.core.Units('colnames', {'spike_times', 'spike_times_index', 'waveform_mean','electrodes', 'origClusterID'},...
    'description','units table');

%== Add spike times to the unit table

% Split the concatinated spiketimes up into individual units
% 
% % ==old version (works)
% [spike_times_vector, spike_times_index] = util.create_spike_times(timestamps_IDs_all, timestamps_all);
% nwb.units.spike_times = spike_times_vector;
% nwb.units.spike_times_index = spike_times_index;
%==end old version

% %==new version (testing)
[spike_times_vector, spike_times_index] = create_indexed_column(spike_times_allCells, '/units/spike_times');
nwb.units.spike_times = spike_times_vector; 
nwb.units.spike_times_index =spike_times_index;
% 
nrUnits = length(spike_times_index.data);  % entire session across all
% units has so many spikes 
nwb.units.id = types.core.ElementIdentifiers('data', 0:nrUnits-1);

%== link each unit to entry in electrode table (which will identify channel
%it was recorded on, brain area etc.
link_toElectrode_table=[]; 
for k=1:length(channel_ofCells)
     link_toElectrode_table(k) = find( elec_nums == channel_ofCells(k) )
end 
link_toElectrode_table = link_toElectrode_table-1;  %id in
% electrode_table is zero based
% 
% 
ov_elTable = types.untyped.ObjectView('/general/extracellular_ephys/electrodes');
% 
link_toElectrode_table_Cells = num2cell( link_toElectrode_table);
[electrodes, electrodes_index] = create_indexed_column(link_toElectrode_table_Cells, '/units/electrodes', [], [], ov_elTable );
nwb.units.electrodes = electrodes; nwb.units.electrodes_index = electrodes_index;

%=== TODO #1 - add mean waveform. Need to load these properly first for export. 
%waveform_mean = types.core.VectorData('data', randn(length(unit_ids),256), 'description', 'mean of waveform');
%nwb.units.waveform_mean = waveform_mean;

%=== TODO #2 - add custom columsn for origClisterID, orig Cell#, sorting quality, isolation distance. This would be done like this:
%nwb.units.vectordata.set('link_toElectrode',types.core.VectorData('data', link_toElectrode_table, 'description', 'row number in electrode_table(manual link)') ) ;
    
    

%% Export the NWB file

nwbExport(nwb, ['C:\Users\chandravadn1\Desktop\code\test2.nwb'] );  

