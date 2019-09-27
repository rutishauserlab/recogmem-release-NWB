%used by plotting functions that plot a raster; converts from timestamps to
%the representation used by the raster plotting functions.
%
%mT0: mean of 1sec interval
%sT0: std
%
function [spikesToPlot, binnedTotal,edges, mT0, mT1, mT2] = convertSpikesForPlotting(trialTimestamps, eventTimestamps, triallength, binsize)


spikesToPlot=[];
allTimestamps=[];
for j=1:length(trialTimestamps)
    newtimestamps =[];
    newtimestamps = trialTimestamps{j};
    
    %subtract beginning of event
    newtimestamps = newtimestamps-eventTimestamps(j,1);
    newtimestamps = newtimestamps/1000;
    
    newtimestamps = newtimestamps(find(newtimestamps<triallength));
    
    newSize=length(newtimestamps);
    oldSize=size(spikesToPlot,1);
    spikesToPlot( oldSize+1:oldSize+newSize,1:2) = [ repmat(j,newSize,1) newtimestamps];
    
    
    allTimestamps = [allTimestamps; newtimestamps(find(newtimestamps<triallength))];
    
    %singleSpiketrain = zeros(1,triallength);
    %singleSpiketrain( round( newtimestamps(find(newtimestamps<triallength)) ) ) = 1;
    
    %totSpikes =  totSpikes + singleSpiketrain;
end

%spikesToPlot(:,2) = spikesToPlot(:,2)/1000; %to ms
%spikesToPlot(:,2) = spikesToPlot(:,2) - min(spikesToPlot(:,2)); %subtract offset
edges=0:binsize:triallength; %+binsize; %1 bin more for trash

mT0=0;
mT1=0;
binnedTotal=[];
if size(allTimestamps,1)==0  %if no spikes
    binnedTotal=zeros(1,length(edges)-1);
    edges=edges(1:end-1);
    return;
end


binnedTotal = histc(allTimestamps, edges);
binnedTotal = binnedTotal/length(trialTimestamps);
binnedTotal=1000/binsize*binnedTotal;

binnedTotal=binnedTotal(1:end-1); %remove last element produced by histc because it contains 0 which falsifies our significance calculation.
edges=edges(1:end-1);

%calculate T0
edgesT0 = (triallength-1000):binsize:triallength;

binnedT0 = histc(allTimestamps, edgesT0);
binnedT0 = binnedT0/length(trialTimestamps);
binnedT0=1000/binsize*binnedT0; %convert to freq

binnedT0=binnedT0(1:end-1);
edgesT0=edgesT0(1:end-1);

mT0 = binnedT0;

%calculate T1 (stimulus)
%edgesT1 = (triallength-800):binsize:(triallength-0);  %period end-900:end  (eg, 100:1000)

edgesT1 = 200:binsize:3000;

binnedT1 = histc(allTimestamps, edgesT1);
binnedT1 = binnedT1/length(trialTimestamps);
binnedT1=1000/binsize*binnedT1; %convert to freq
binnedT1=binnedT1(1:end-1);
edgesT1=edgesT1(1:end-1);
mT1 = binnedT1;

%calculateT2 (baseline from beginning)
edgesT2 = 200:binsize:2000;
binnedT2 = histc(allTimestamps, edgesT2);
binnedT2 = binnedT2/length(trialTimestamps);
binnedT2=1000/binsize*binnedT2; %convert to freq
binnedT2=binnedT2(1:end-1);
edgesT2=edgesT2(1:end-1);
mT2 = binnedT2;