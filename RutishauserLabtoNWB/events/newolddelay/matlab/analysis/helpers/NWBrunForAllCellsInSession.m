%
%generic function
%
%loops over all cells of a channel and calls a custom function for evaluation. 
%
%input arguments:
% evalFunc is a function pointer. it can be an internal function of the calling function or a function defined in a separate file.
% its arguments are: evalFunc( timestampsOfCell, figNr, brainAreaOfCell, plabel, params, varargin )
%
% if params.isMUA=1, this function clusters als SUA as one MUA and runs the function once per channel.
% if params.onlyChannels -> only these channels will be processed. Otherwise,all (1-64).
% if params.onlyCells -> only these cells will be processed. Otherwise,all.
% onlyChannels/onlyCells can be used to request processing of only subsets of channels/cells
% onlyAreas: if set,only areas listed here
%
%urut/april06
function params = NWBrunForAllCellsInSession( basedirData, ind, brainArea, input_session, evalFunc, params, varargin )

prefix='A';
spikes=[];
pannelNr=0; %a running index so the callback function knows how many times it has been called so far.


sessionID = input_session.sessionID;

%import parameters; set to default if not set
isMUA = copyFieldIfExists( params, 'isMUA', 0);
channelsToProcess = copyFieldIfExists( params, 'onlyChannels', [1:256]);
if isempty(channelsToProcess)
    channelsToProcess=1:256;
end

onlyCells = copyFieldIfExists( params, 'onlyCells', []);
onlyAreas = copyFieldIfExists( params, 'onlyAreas', []);

fname = [basedirData input_session.filename];

nwb = nwbRead(fname);


all_spike_data = nwb.units.spike_times.data.load();
spike_data_indexes = nwb.units.spike_times_index.data.load();
channel_ids_index = nwb.general_extracellular_ephys_electrodes.vectordata.get('origChannel').data.load();
cell_electrodes = nwb.units.electrodes.data.load();
brain_areas_index = nwb.general_extracellular_ephys_electrodes.vectordata.get('location').data.load;
original_clusters = nwb.units.vectordata.get('origClusterID').data.load();
mean_waveform_recog = nwb.units.vectordata.get('waveform_mean_recognition').data.load();
mean_waveform_learn = nwb.units.vectordata.get('waveform_mean_encoding').data.load();
start_index = 1;
elec_index = [nwb.units.electrodes.data.load()]+1;
channel_ids = channel_ids_index(elec_index); 
brain_areas = brain_areas_index(elec_index); 

for i = 1:length(spike_data_indexes)
    spike_length = spike_data_indexes(i);
    end_index = spike_length;
    
    timestampsOfCell = all_spike_data(start_index:end_index);
    channelid =  channel_ids(i);
    cellNr = cell_electrodes(i);
    brainAreaOfCell = brain_areas{i};
    origClusterID = original_clusters(i);
    mean_waveform_learn_ind = mean_waveform_learn(:, i);
    mean_waveform_recog_ind = mean_waveform_recog(:, i);
    currentCell = cellNr;
    
    
% 
%     if isMUA
%         disp('MUA mode enabled. pool all cells to one (cellNr=0)');
%         cells=[0];
%     end

%     for i=1:length(cells)
%         currentCell=cells(i);
% 
%         origClusterIDs = spikes(find(spikes(:,1)==currentCell),1);
%         origClusterIDs = unique(origClusterIDs);
%         
%         if currentCell>0
%             %SUA
%             timestampsOfCell = spikes( find(spikes(:,1)==currentCell), 2);
%         else
%             %MUA
%             timestampsOfCell=[];
%             for tmpCellNr=1:length(unique(spikes(:,1)))
%                 timestampsOfCell = [timestampsOfCell; spikes( find(spikes(:,1)==tmpCellNr), 2)];
%             end
%         end

        if size(timestampsOfCell,1)==0
            continue;
        end

        
        figNr = channelid*100+i;
        
        
        plabel = [sessionID ' ' prefix 'C' num2str(channelid) '-' num2str(currentCell)];
        
        pannelNr=pannelNr+1;
        params.pannelNr = pannelNr;
        params.channel=channelid;
        params.cellNr=currentCell;
        params.brainAreaOfCell = brainAreaOfCell;
        params.sessionID = sessionID;
        params.origClusterID = origClusterID;
%         disp(origClusterIDs);
        params.meanWaveform_recog = mean_waveform_recog_ind;
        params.meanWaveform_learn = mean_waveform_learn_ind;
        params.taskVariant = input_session.variant;
        %call the callback function that processes this cell
        params = evalFunc( timestampsOfCell, figNr, brainAreaOfCell, plabel, params, varargin );  
        
        drawnow; %make sure figures continously update so results can be observed while this loops through all cells
%     end  
    start_index = end_index + 1;
end
