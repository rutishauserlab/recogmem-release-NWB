%% Demo Code to Demonstrate Export of Spike Times to NWB 
%
%
%--------------------------------------------------------------------------
%         Rutishauser Lab, Cedars-Sinai Medical Center/Caltech, 2019.  
%                    http://www.rutishauserlab.org/
% -------------------------------------------------------------------------
%  Overview:
%     Demo code to demonstrate the export of spike_times from .mat files 
%     into NWB. 
%     
%==========================================================================


% get the NWB file object
nwb =  nwbfile(); 
nwb.identifier = 'Demo';
nwb.session_description = 'Demo';
nwb.session_start_time = datetime('04-June-2019','Format','yyyy-MM-dd');

%get session info. 
basepath = 'C:\Users\chandravadn1\Desktop\code\data\Faraut et al 2018\'; 
inifileName = 'C:\svnwork\nwbsharing\events\newolddelay\defineNOsessions_release.ini'; 
sessionID = 'P9S1'; 

%get all the spike times 
[spike_times_allCells] = getSpikeTimesAllCells(basepath, inifileName, sessionID); 

%Instantiate the units Dynamic Table
nwb.units = types.core.Units('colnames', 'spike_times', 'description','Units Table');

%== Add spike times to the unit table
%Add all spike times to the spike_times_vector, indexed by
%spike_times_vector
[spike_times_vector, spike_times_index] = create_indexed_column(spike_times_allCells, '/units/spike_times');
nwb.units.spike_times = spike_times_vector;
nwb.units.spike_times_index = spike_times_index;

%Add units ID to the units table
nwb.units.id = types.core.ElementIdentifiers('data', int64([1:length(spike_times_index.data)]-1));

%Export NWB file
nwbExport(nwb, 'demo.nwb');
