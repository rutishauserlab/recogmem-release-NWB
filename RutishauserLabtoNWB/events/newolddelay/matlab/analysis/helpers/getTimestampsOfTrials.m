%returns timestamps of trials in a cell array
%
%stimuliTimestamps: first column is begin timestamp, second column is end
%timestamp of trial
%
%returns a cell array of trials
%
%urut/may04
function [trials, indsAll, indsOrigPerTrial] = getTimestampsOfTrials(timestampsOfCell, stimuliTimestamps )

trials=[];
indsAll=[];
indsOrigPerTrial=[];
for i=1:size(stimuliTimestamps,1)
    inds = find ( timestampsOfCell >= stimuliTimestamps(i,1) & stimuliTimestamps(i,2)>= timestampsOfCell );
    indsOrigPerTrial{i}=inds;
    trials{i} = timestampsOfCell(inds);
    indsAll = [indsAll; inds];
end
