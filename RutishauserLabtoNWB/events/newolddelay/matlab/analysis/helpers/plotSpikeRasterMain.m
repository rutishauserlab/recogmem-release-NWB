%== main function for plotting rasters.
%
% SPIKERASTER - Spike raster of multiple neurons
%    SPIKERASTER(spikes, options), plot spike trains given in variable
%    SPIKES, which is in format [neuron time] or in a sparse matrix
%    with time down columns and neuron number across rows.  If
%    there are no spikes (SPIKES is empty) then a plot is created,
%    with the dimensions specified by the 'Range' and 'EndTime'
%    variables.
%    
%    Optional arguments: 
% 
%    'Range', RANGE  Plot only neurons specified in the vector
%                    RANGE.  If neurons are specified that have no
%                    spikes a line will still be made for them in
%                    the raster.
%    'EndTime', ET   Plot up until ET
%    'Fs', fs        Set the sampling frequncy to FS.  This scales
%                    the TIME by 1/FS and is especially useful for
%                    sparse matrix spiketrains.
%    'Lines'         Make a line for each spike to sit on
%    'Xlabel'        Set the x-axis label.  The default is 'time'.
%    'Ylabel'        Set the y-axis label.  The default is no label.
%
%    'spikeheight'   height of spike (line)
%
%    'colortill': array of numbers that indicate the color scheme for a
%    particular trial. First entry: till when should the first color be
%    used (including this trial). second and further entries: trials
%    smaller this number (but bigger or equal the previous) have the next color. 
%    for example,to switch colors every two trials, colortill=[2 5 7 9 ...]
%    (this odd scheme is for compatibility reasons with legacy code).
%    coloring starts at trial nr 1 (bottom of plot).
%
%    'colors': list of color codes. if more colors are needed then
%    available, this code cycles through the available once in sequential
%    order.
%
%    'spikewidth' -> with of line of spike
%
%    returns: array of handles of lines. only the handle of the first spike
%    in each trial (line) is returned.
%
%    modified extensively by: ueli rutishauser <urut@caltech.edu>
%    Original Author:     David Sterratt <David.C.Sterratt@ed.ac.uk>
%
function handles = plotSpikeRasterMain(spikes, varargin)
handles=[];

%% defaults
colors={};
colorTill=0;
colorMode=false;
endtime = [];				% The final time to plot.
linesflag = 0;				% Line for each spike to sit on?
spikeheight = 0.7;			% height of spikes
xlabelstr = 'time [ms]';			% xlabel
ylabelstr = '';				% ylabel
fs = [];				% Sampling frequency for sparse

spikewidth=0.5;

%% Read in arguments.  
for i=1:(nargin-1)
  if ischar(varargin{i})		
    switch lower(varargin{i})
     case 'range', range = varargin{i+1};
     case 'lines', linesflag = 1;
     case 'endtime', endtime = varargin{i+1};
     case 'xlabel', xlabelstr = varargin{i+1};
     case 'ylabel', ylabelstr = varargin{i+1};
     case 'fs', fs = varargin{i+1};
     case 'colors', colors = varargin{i+1};
     case 'colortill', colorTill = varargin{i+1};
     case 'spikeheight', spikeheight = varargin{i+1};
     case 'spikewidth', spikewidth = varargin{i+1};
    end
  end
end

% TODO % this still needed?
%% Check to see if the input is a sparse matrix with time down rows and neurons across columns
if issparse(spikes)
  [t, n] = find(spikes);
  spikes = [n t];
end

%% make sure that there is at least 1 spike for each neuron, add one before
% 0 to make sure. this is important!! otherwise lines are skipped in the plot.
if ~isempty(spikes)
    if exist('range')~=1  %if it hasn't been set externally already (~=1 tests for a variable)
        range = min(spikes(:,1)):max(spikes(:,1)); % Neurons to plot
    end

    for i=1:length(range)
        spikes(size(spikes,1)+1,1:2)=[i -10000];
    end
else
    range = 1;
    endtime = 1;
end

%see if coloring mode is on
if length(colors)>0
    colorMode=true;
end

% Divide by the sampling frequency, if set
if ~isempty(spikes)
  if fs, spikes(:,2) = spikes(:,2)/fs ; end
end

% If endtime hasn't been specified in the arguments, set it to the
% time of the last spike of the neurons we want to look at (that is
% those specified by range).
if isempty(endtime)
  endtime = max(spikes(find(ismember(spikes(:,1),range)),2));
end

%% plot 
% Prepare the axes
h = newplot;

% Save existing properties
oldls = get(h,'LineStyleOrder');
oldco = get(h,'ColorOrder');

% Full, Black lines
set(h,'LineStyleOrder', ['-'])   
set(h,'ColorOrder', [0 0 0])   

% Do the plotting one neuron at a time
if ~isempty(spikes)
  for n = 1:length(range)
    s = spikes((spikes(:,1)==range(n))&(spikes(:,2)<=endtime),2);
    lineHandle = line([s'; s'], [(n-spikeheight/2)*ones(1,size(s,1)); (n+spikeheight/2)*ones(1,size(s,1))]);
    set(lineHandle,'lineWidth',spikewidth);
    
    handles(n) = lineHandle(1);
    
    %if flags are set, change color of the spike
    if colorMode
            if range(n) <= colorTill(1)
                set(lineHandle,'color', colors{ 1 } );
            else
                ind = find( colorTill > range(n) );
                
                if length(ind)==0
                    ind=length(colors);
                end
                             
                set(lineHandle,'color', colors{ mod(ind(1)-1,length(colors))+1});
            end
    end
  end
end

% Make the plot the right length but only when we're not adding to
% a plot
if ~strcmp(get(h,'NextPlot'),'add')
  if endtime>0
      set(h, 'Xlim', [0 endtime])
    end
  set(h, 'Ylim', [0.5 size(range,2)+0.5])
end

% Add lines for the spikes to sit on if required
if linesflag
  xline=get(gca,'XLim');
  for n=1:size(range,2)
    line(xline, [n n]);
  end
end

xlabel(xlabelstr)
ylabel(ylabelstr)
      
% Restore existing properties
set(h,'LineStyleOrder',oldls);
set(h,'ColorOrder',oldco);
