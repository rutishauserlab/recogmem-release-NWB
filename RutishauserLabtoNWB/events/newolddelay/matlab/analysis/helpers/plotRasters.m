%plot raster with histogram and gaussian fit for an arbitrary number of
%conditions
%
%
%markerPos(1): stimulus onset
%markerPos(2): stimulus offset
%triallength: total trial length, incl before/after baseline period
%
%normalizeToBaseline: 0 or 1. If 1, 
%
% testPeriod: portion of stimuls ON part to be used for significance tests
%
%returns:
%subplotSize: how many subplots (square)
%exportRasters: input to plotrastersTest, to replot rasters later without re-computing them.
%
%urut/aug05
function [subplotSize, exportRasters] = plotRasters( binsize,significanceLevel,figNr, plabel, timestampsOfCell, triallength, markerPos, testPeriods, normalizeToBaseline, rasterLabels, varargin )


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

figure(figNr);
%Plot the Raster Plot of the Spikes
for i=1:nrRasters
    subplot( subplotSize, subplotSize, i);
    
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

    range=1;
    if size(spikesToPlot,1)>1
        range=1:max(spikesToPlot(:,1));
    end
    exportRasters{i} = spikesToPlot;
    
	plotspikerasterTest( spikesToPlot, 'range', range, 'spikewidth', 1.0 , 'spikeheight', 1);
	xlim([0 triallength]);			
	title([plabel rasterLabels{i}],'interpreter','none');
	ylabel('Trial #');

    %   drawTestPeriods(testPeriods,ylim,[]);

    for i=1:length(markerPos)
        maxY=ylim;
        h=line([markerPos(i) markerPos(i)],[0 maxY(2)]);
        
        uistack(h,'bottom');
        
        set(h,'color',trialMarkerColor);
        set(h','linewidth',2.5);
    end    
    
    hold on
end


%histograms
% for i=1:nrRasters
%     if length(rasters{i})==0
%         continue;
%     end
%     subplot( subplotSize, subplotSize, i+4);
% 
%     plot(edges, binnedRasters{i},['-' colors{mod(i,length(colors))+1}], 'linewidth',2);
% end


mSpikeCounts=[];
seSpikeCounts=[];
for i=1:nrRasters
    mSpikeCounts(i) = mean(spikeCounts{i});
    seSpikeCounts(i) = std(spikeCounts{i})/sqrt(length(spikeCounts{i}));
end


%spikecounts for each condition
subplot(subplotSize,subplotSize,(subplotSize*subplotSize)-6)
bar(1:nrRasters,mSpikeCounts);
hold on
errorbar(1:nrRasters,mSpikeCounts,seSpikeCounts,'.r');
hold off
maxYBars=max(mSpikeCounts+seSpikeCounts);
if maxYBars>0
    ylim([0 maxYBars*1.1]);
end

%statistical tests
for i=1:2:nrRasters   
    if length(spikeCounts{i})==0 || length(spikeCounts{i+1})==0
        continue;
    end
    
    [h,p]=ttest2(spikeCounts{i},spikeCounts{i+1});
    if p<0.05
       h=line([i i+1],[maxYBars maxYBars] );
       set(h,'color','r');
    end
end
ylabel(['# spikes/s ' num2str(testPeriods(1)) '-' num2str(testPeriods(2))] );

%% PLOT PSTH 

%raw histograms
subplot(subplotSize,subplotSize,(subplotSize*subplotSize)-5)
maxY=0;
for i=1:nrRasters
    if length(binnedRasters)<i
        continue;
    end
    if length( binnedRasters{i} ) == 0
        continue;
    end
    
    colorInd = mod(i,length(colors))+1;
    plot(edges+binsize/2, binnedRasters{i},[ styles{colorInd} 'x' colors{colorInd}], 'linewidth',2);
    
    if max(binnedRasters{i})>maxY
        maxY=max(binnedRasters{i});
    end
    
    hold on
end
hold off
if maxY>0
    ylim([0 maxY]);
end
legend(rasterLabels);

ylabel('[Hz]');

maxY2=ylim;
for i=1:length(markerPos)
    h=line([markerPos(i) markerPos(i)],[0 maxY2(2)]);

    uistack(h,'bottom'); %make sure they are behind the data

    set(h,'color',trialMarkerColor);
    set(h','linewidth',2.5);
end
xlim([0 triallength]);			

%smoothened histograms
subplot(subplotSize,subplotSize,(subplotSize*subplotSize)-4 )
for i=1:nrRasters
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
hold off
legend(rasterLabels);
if maxY>0
    ylim([0 maxY]);
end
ylabel('[Hz]');

maxY=ylim;
for i=1:length(markerPos)
    h=line([markerPos(i) markerPos(i)],[0 maxY(2)]);
    uistack(h,'bottom'); %make sure they are behind the data
    set(h,'color',trialMarkerColor); 
    set(h','linewidth',2.5);
end
xlim([0 triallength]);			


%----





%----internal functions;

function drawTestPeriods(testPeriod,maxY,whichIsSig)

for i=1:size(testPeriod,1)
    fact=0.9 + 0.02*i;
    h=line([testPeriod(i,1) testPeriod(i,2)],[maxY(2)*fact maxY(2)*fact]);
    %if length(find(i==whichIsSig))>0
    %    set(h,'color','r');
    %else
        set(h,'color','g');
    %end
    
    set(h','linewidth',2.5);
end


function pop = getCountsInBin(trialTimestamps, trialStartStop, bin)
pop=[];
for i=1:length(trialTimestamps)
    timestampsOneTrial = trialTimestamps{i};
    timestampsOneTrial = timestampsOneTrial - trialStartStop(i,1); %subtract such that beginning of trail has t=0
    timestampsOneTrial = timestampsOneTrial/1000;  %convert to ms
    
    pop(i) = length ( find( timestampsOneTrial >= bin(1) & timestampsOneTrial < bin(2) ) );
end