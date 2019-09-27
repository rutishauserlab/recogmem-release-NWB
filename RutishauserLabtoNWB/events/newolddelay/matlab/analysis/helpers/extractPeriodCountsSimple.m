%returns the spike counts for each trial in periods, for [from..to]. from/to are in ms and
%relative to the trial onset in periods
%
%from/to: in ms, relative to the timestamps in periods (timestamp in periods is t=0)
%doNormalize: 0 -> no (returns nr spikes), 1-> yes (returns Hz). this does not normalize against baseline,just to the length of the bin.
%
%
%urut/aug06
function [count] = extractPeriodCountsSimple( timestampsOfCell, periods,from, to, doNormalize, pos )
if nargin<5
    doNormalize=0;
end
if nargin<6
    pos=2;
end

count=zeros(1,size(periods,1));

from=from*1000;
to=to*1000;

% % time optimization
% if ~isempty(periods)
%     timestampsOfCell_use = timestampsOfCell(find( timestampsOfCell>min(periods(:,2)) & timestampsOfCell<=max(periods(:,2)+to)));
% else
%     timestampsOfCell_use=timestampsOfCell;
% end
% 

%edges = [ periods(:,pos) periods(:,pos)+to ]';  
%n=histc( timestampsOfCell_use, edges(:));
% cant use histc because the bins might overlap (non-monotonic)

for i=1:size(periods,1)
    count(i) = length( find ( timestampsOfCell > periods(i,pos) + from & timestampsOfCell <= periods(i,pos)+to ) ); 

    %count(i) = sum(timestampsOfCell > (periods(i,pos) + from) & timestampsOfCell <= (periods(i,pos)+to) ); 
end

if doNormalize
   count = count ./ ( (to-from)/1e6 ); 
end