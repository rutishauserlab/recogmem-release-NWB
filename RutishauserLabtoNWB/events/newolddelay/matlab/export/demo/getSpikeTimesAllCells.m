%% Demo Code to Demonstrate Export of Spike Times to NWB 
%
%
%--------------------------------------------------------------------------
%         Rutishauser Lab, Cedars-Sinai Medical Center/Caltech, 2019.  
%                    http://www.rutishauserlab.org/
% -------------------------------------------------------------------------
%  Overview:
%     Concatnetate all spike_times from all channels 
%     from a session into a cell array.  
%     
% =========================================================================

function [spike_times_allCells] = getSpikeTimesAllCells(basepath, inifileName, sessionID)

% 
%       Purpose:
%            To enumerate the spike_times of all cells (A*_cells.mat) 
%            recorded in a session. 
% 
%        Inputs:
%            - basepath(str): Base path to the sessions with the sorted 
%            cells (e.g., C:\Users\chandravadn1\Desktop\code\data\Faraut et
%            al 2018\) 
%           - iniFileName (str): path to ini file with session info. 
%           - sessionID (str): session ID of interest (e.g.,  'P9S1')(see
%           iniFileName)
% 
%        Returns:
%            - spike_times_allCells (cell): Ragged Array of spike_times for all 
%            cells 

if ~exist(basepath)
    error('This file path does not exist: %s', basepath)
end 

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

%Match the session ID with NOsessions
for k = 1:length(NOsessions)
    if strcmpi(NOsessions(k).sessionID, sessionID)
        %Get path to sorted session 
        basepathSorted = [basepath, filesep, 'Data', filesep, 'sorted', ...
            filesep, NOsessions(k).session, filesep, NOsessions(k).taskDescr, filesep]; 
        
        %Load Brain Area
        brainAreaFile = [basepath, filesep, 'Data', filesep, 'events', ...
            filesep, NOsessions(k).session, filesep, NOsessions(k).taskDescr, ...
            filesep, 'brainArea.mat'];
        if exist(brainAreaFile) 
            load(brainAreaFile); 
        else 
            error('This file does not exist %s', brainAreaFile)
        end 
    end 
end 


%main function to get all spike times from session
dataAll = runForAllCellsInSession( basepathSorted,  brainArea, sessionID, @NWBexport_accumulateCells, [] );

%Input all Spike Times into ragged array 
spike_times_allCells =[];

for i=1:length(dataAll.cellStats)
    dataOfCell = dataAll.cellStats(i);
    spike_times_allCells{i} = dataOfCell.timestamps';
end

end

  