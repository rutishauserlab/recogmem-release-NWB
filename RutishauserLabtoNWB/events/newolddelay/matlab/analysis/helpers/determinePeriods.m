%determines the timestamp for all trials specified with inds from the event file
%
%inds is onset of stimulus
%inds+1 is offset of stimulus
%
%
%before/after Offset is in ms. it determines the length of the trial, relative to the timepoint specified by ind
%
%urut/jan07
function periods = determinePeriods( inds, events, beforeOffset, afterOffset )

for i=1:length(inds)
   periods(i,1:3) = [ i events(inds(i),1)-beforeOffset*1000 events(inds(i)+1,1)+afterOffset*1000 ];
end

