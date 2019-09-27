%Plot Category PSTH and Raster



function [] = plotCatRasterPSTH(binsize,significanceLevel,figNr, plabel, timestampsOfCell, triallength, markerPos, testPeriods, normalizeToBaseline, rasterLabels, varargin)



%    Purpose: 
%        *To plot the Rasters and PSTH of each Neuron for each category
%   
%    Inputs: 
%        -binsize: Binsize of PSTH (e.g., 250 ms)
%        -significanceLevel: p-value to test Significance
%        -figNr: The label for the figure # 
%        -plabel: The title of the raster plot. 
%        -timestampsOfCell: The spike times 
%        -trialLength: The length of the trial to plot
%               a. stimOnset: 1000 ms, stimOffset: 2000 ms
%               b. Typical trial length: 3000 ms 
%       -markerPos: The position of the stimulusOnset, and stimulusOffset
%       -varargin: 
%           a. Column 1: The trial times for each trial (total of 20 trials
%           for this category) -- Category 1
%           b. Column 2: The trial times for each trial (total of 20 trials
%           for this category) -- Category 2
%           c. Column 3: The trial times for each trial (total of 20 trials
%           for this category) -- Category 3
% 
% 



colors={'y','r','g','b','k','m','c','r','g','b'};
styles={'-','-','-','-','-','-','-','-.','-.','-.'};

trialMarkerColor = [0.8 0.8 0.8]; %gray

%The trial times for each category (Column 1 - Column 5)
rasters=varargin;

%if it has an embedded cell array, unroll
if iscell( rasters{1} )
    tmp=rasters{1};
    
    tmpRasters=[];
    
    for j=1:length(tmp)
        tmpRasters{j} = tmp{j};
    end
    rasters = tmpRasters;    
end

nrRasters = length(rasters);
subplotSize = ceil(sqrt(nrRasters+7));

%Fit curve to histogram
kSize=10;
gaussKernel1 = getGaussianKernel(200/binsize, kSize);

histFits=[];
binnedRasters=[];
edges=[];

%Get the number of spikes (i.e., spikeCounts for each Category)
spikeCounts=[];
exportRasters=[];

%Plot the Raster Plot of the Spikes
for i=1:nrRasters
    %subplot( subplotSize, subplotSize, i);
    
    %count1 = the spikes that occur bewteen stimulus Onset (testPeriods(1))
    %and stimulus Offset (testPeriods(2))
    [count1] = extractPeriodCounts( timestampsOfCell, rasters{i}, [], testPeriods(1), testPeriods(2) );

    %normalize to frequency
    count1 = count1 ./ ((testPeriods(2)-testPeriods(1))/1000);
    
    spikeCounts{i} = count1;
    
    if length(rasters{i})==0
        continue;
    end
    
    %remove sequence numbers (i.e., trial numbers)
    rasters{i} = rasters{i}(:,2:3);
    
    %get the spikeStamps for each trial 
    trialsTimestamps = getTimestampsOfTrials( timestampsOfCell, rasters{i});
    %Convert the spikes to plot, binned = the frequency for each sample
    [spikesToPlot, binned, edges] = convertSpikesForPlotting(trialsTimestamps, rasters{i}, triallength, binsize);

    %normalize to baseline (1s baseline assumed)
    if normalizeToBaseline
        [baselineCount] = extractPeriodCounts( timestampsOfCell, rasters{i}, [], 0, testPeriods(1) );
        
        mBaseline = mean(baselineCount);
        binned = binned ./ mBaseline;
        spikeCounts{i} = spikeCounts{i} / mBaseline;

    end
    
    %binnedRasters: The frequency for each time point. 
    binnedRasters{i}=binned;
    histFits{i} = conv(binned, gaussKernel1);
    histFits{i} = histFits{i}(kSize:end-kSize);

  
end



% === Plot Category Rasters (1-5) =======
allSpikes = {};
for i=1:length(rasters(1:5))
    
    
    %count1 = the spikes that occur bewteen stimulus Onset (testPeriods(1))
    %and stimulus Offset (testPeriods(2))
    [count1] = extractPeriodCounts( timestampsOfCell, rasters{i}, [], testPeriods(1), testPeriods(2) );

    %normalize to frequency
    count1 = count1 ./ ((testPeriods(2)-testPeriods(1))/1000);
    
    spikeCounts{i} = count1;
    
    if length(rasters{i})==0
        continue;
    end
    
    %remove sequence numbers (i.e., trial numbers)
    %rasters{i} = rasters{i}(:,2:3);
    
    %get the spikeStamps for each trial 
    trialsTimestamps = getTimestampsOfTrials( timestampsOfCell, rasters{i});
    %Convert the spikes to plot, binned = the frequency for each sample
    [spikesToPlot, binned, edges] = convertSpikesForPlotting(trialsTimestamps, rasters{i}, triallength, binsize);
    allSpikes{i} = spikesToPlot;
    
end


%Concatnate all the spike_times
allSpikes_concatenated = []; 
allSpikes_concatenated(:, 2) = [allSpikes{1,1}(:, end);allSpikes{1,2}(:,end);allSpikes{1,3}(:,end);allSpikes{1,4}(:,end); allSpikes{1,5}(:,end) ];
allSpikes_concatenated(:, 1) = [allSpikes{1,1}(:, 1);allSpikes{1,2}(:, 1)+20;allSpikes{1,3}(:, 1)+40;allSpikes{1,4}(:, 1)+60;allSpikes{1,5}(:, 1)+80];

index = [0, 20, 40, 60, 80];
figure(figNr), subplot(2, 1, 1)


for i = 1:length(allSpikes)

     s = plot(allSpikes{1, i}(:, end),allSpikes{1, i}(:, 1)+index(i), '.');
     s.Color = colors{i+1};
     hold on
end
h = vline([1000]);
h.Color = trialMarkerColor;
h.LineWidth = 2;
h.LineStyle = '-';
uistack(h(1), 'bottom')
h = vline([2000]);
h.Color = trialMarkerColor;
h.LineWidth = 2;
h.LineStyle = '-';
uistack(h(1), 'bottom')
title(plabel)
xlabel('time (ms)')
ylim([0 105])
ylabel('trials (resorted)')
hold off

%Plot the PSTH
figure(figNr), subplot(2, 1, 2)
for i=1:5
    if length(histFits)<i
        continue;
    end
    if length(histFits{i})==0
        continue;
    end
    
    colIndToUse = mod(i,length(colors))+1;
    plot(edges+binsize/2, histFits{i}(2:end),[styles{colIndToUse} 'x' colors{colIndToUse}], 'linewidth',2);
    hold on
end
h = vline([1000]);
h.Color = trialMarkerColor;
h.LineWidth = 2;
h.LineStyle = '-';
uistack(h(1), 'bottom')
h = vline([2000]);
h.Color = trialMarkerColor;
h.LineWidth = 2;
h.LineStyle = '-';
uistack(h(1),'bottom')
hold on
legend(rasterLabels);
ylabel('firing rate [Hz]');
xlabel('time (ms)');
maxY=ylim;
xlim([0 triallength]);		
maxY=ylim;
if maxY>0
    ylim([maxY]);
end


% ==================================