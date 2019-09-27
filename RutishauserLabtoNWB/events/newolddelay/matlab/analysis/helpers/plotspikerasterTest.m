%
%calls plotSpikeRasterMain; 
%for compatibility reasons (legacy code).
%
%urut/dec07.
function h=plotspikerasterTest(spikes, varargin)

h=plotSpikeRasterMain(spikes,varargin{:} );  %note that {:} of a cell array converts to a list of variables!