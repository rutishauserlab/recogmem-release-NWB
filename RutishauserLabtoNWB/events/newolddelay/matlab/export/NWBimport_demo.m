%NWBimport_demo
%
% loads files exported by NWBexport_demo and plots the data 
% (for demonstration purposes only; much less comprehensive then the full release code)
%
%urut/Jan'19

%% parameters
%NOID=105;

fName_NWB = ['C:\Users\chandravadn1\Desktop\code\test2\P19HMH_062708.nwb'] ;  




%% read NWB
nwb_in = nwbRead(fName_NWB);

%% locate events of interest
nwb_in.intervals_trials.colnames;    % see available variables

start_time = nwb_in.intervals_trials.start_time.data.load;    % stim onset
%For Python Output NWB files use ('category_id'), else use ('stimCategory')

%Matlab export
stimuliCategories = nwb_in.intervals_trials.vectordata.get('stimCategory').data.load;      % visual category of stimulus shown

%Python export
%stimuliCategories = nwb_in.intervals_trials.vectordata.get('category_id').data.load;      % visual category of stimulus shown

%response_value = nwb_in.intervals_trials.vectordata.get('response_value').data.load;       % response given

indCat1 = find(stimuliCategories==1);
indCat2 = find(stimuliCategories==2);
indCat3 = find(stimuliCategories==3);
indCat4 = find(stimuliCategories==4);
indCat5 = find(stimuliCategories==5);

baseline_period=1000;
after_stim_length=3000;

%== create periods from trial info
periods=[];
for i=1:length(start_time)
    periods(i,1:3) = [ i start_time(i)-baseline_period*1000 start_time(i)+after_stim_length*1000 ];
end

%% locate spikes of cell of interest
clToPlot = 5;   %  clToPlot=18 is cell shown in Fig 3c in Faraut et al. 2018.
clusterIDs = nwb_in.units.id.data.load;   %all available id's (clusters)
unitInd = find(clusterIDs == clToPlot-1);   %-1 is because id's are zero based

%== locate spikes that belong to this cluster
%spiketimes_ofCell = util.read_indexed_column(nwb_in.units.spike_times_index, nwb_in.units.spike_times, unitInd);
spiketimes_ofCell = nwb_read_unit(nwb_in.units.spike_times_index, nwb_in.units.spike_times, unitInd);

readElectrode_info = 1;   % disable for python since not implemented yet

if readElectrode_info
    %== locate which electrode this cell is on
    electrodes = nwb_in.units.electrodes.data.load;
    electrodeInd = electrodes(unitInd);
    
    %load info from electrode table
    electrodeTable_id = nwb_in.general_extracellular_ephys_electrodes.id.data.load;
    origChannel_all = nwb_in.general_extracellular_ephys_electrodes.vectordata.get('origChannel').data.load;  % custom column, so load
    cellLocation_all = nwb_in.general_extracellular_ephys_electrodes.vectordata.get('location').data;         % a standard value, dont need to load
    
    %now locate correct electrode
    electrodeTable_index_ofCluster = find( electrodeTable_id == electrodeInd);
    cellLocation = cellLocation_all(electrodeTable_index_ofCluster);
    channelNr = origChannel_all(electrodeTable_index_ofCluster);
else
    %== if not known
    cellLocation{1}='Nan';
    channelNr=nan;
    
end

% read waveform
waveform_mean_allUnits = nwb_in.units.waveform_mean.data.load;
SNR_allUnits = nwb_in.units.vectordata.get('SNR').data.load;
IsolationDist_allUnits = nwb_in.units.vectordata.get('IsolationDist').data.load;
origClusterIDs_allUnits = nwb_in.units.vectordata.get('origClusterID').data.load;

waveform_ofUnit = waveform_mean(unitInd,:);
SNR_ofUnit = SNR_allUnits(unitInd);
IsolDist_ofUnit = IsolationDist_allUnits(unitInd);
origClusterID_ofUnit = origClusterIDs_allUnits(unitInd);


%% plot cell
alphaLim=0.05;
figNr=1;
binsizePlotting=250;
normalize=0;

stimOnset=1000; %relative to begin of trial,when does the stimulus come on.
stimLength=1000;
trialLength=3000;
countPeriod = [ stimOnset stimOnset+stimLength ];
labelStr = ['NWB: ' nwb_in.general_session_id ' C:' num2str(channelNr) '-' cellLocation{1} ' ' ];

subplotSize = plotRasters(binsizePlotting, alphaLim, figNr, labelStr, spiketimes_ofCell, trialLength+500, [stimOnset stimOnset+stimLength], countPeriod, normalize, {'C1','C2','C3','C4','C5'},  periods(indCat1,:),periods(indCat2,:),periods(indCat3,:),periods(indCat4,:),periods(indCat5,:)); 

waveform_Learn = waveform_ofUnit{1, 1}(1, 1:256);
subplot(subplotSize,subplotSize,16)
figure(100), plot( [1:256]./100, waveform_Learn );
xlabel('[ms]');
ylabel('[uV]');
title(['origID=' num2str(origClusterID_ofUnit) ' SNR=' num2str(SNR_ofUnit) ' IsolDist=' num2str(IsolDist_ofUnit) ]);
