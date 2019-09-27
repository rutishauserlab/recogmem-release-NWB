%
% This gets called for each cell. Here, simply store the data for later
%
%urut/Jan'19
function params = NWBexport_accumulateCells( timestampsOfCell, figNr, brainAreaOfCell, plabel, params, varargin )

% prepare data to return
cellStats=[];
cellStats.channel = params.channel;
cellStats.cellNr = params.cellNr;
cellStats.brainAreaOfCell = brainAreaOfCell;
cellStats.origClusterID = params.origClusterID;
cellStats.timestamps = timestampsOfCell;

%store spike counts for later analysis
runInd=params.pannelNr;
params.cellStats(runInd) = cellStats;