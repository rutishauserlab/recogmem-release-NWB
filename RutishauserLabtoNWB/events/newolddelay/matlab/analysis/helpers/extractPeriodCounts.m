%
%returns the spike counts from two conditions (periodsOLDCorrect and
%periodsNEWCorrect), each in the window from...to with baseline being in
%....from. from/to is in ms.
%
%
%urut/march05
function [countOLD,countNEW, countBaselineOLD,countBaselineNEW] = extractPeriodCounts( timestampsOfCell, periodsOLDCorrect, periodsNEWCorrect, from, to )
countOLD=[];
countNEW=[];
countBaselineOLD=[];
countBaselineNEW=[];

from=from*1000;
to=to*1000;
for i=1:size(periodsOLDCorrect,1)
    countOLD (i) = length( find ( timestampsOfCell > periodsOLDCorrect(i,2) + from & timestampsOfCell <= periodsOLDCorrect(i,2)+to ) );
    countBaselineOLD(i) = length( find ( timestampsOfCell > periodsOLDCorrect(i,2)  & timestampsOfCell <= periodsOLDCorrect(i,2)+from ) );
end


for i=1:size(periodsNEWCorrect,1)
    countNEW (i) = length( find ( timestampsOfCell > periodsNEWCorrect(i,2) + from & timestampsOfCell <= periodsNEWCorrect(i,2)+to ) );
    countBaselineNEW(i) = length( find ( timestampsOfCell > periodsNEWCorrect(i,2)  & timestampsOfCell <= periodsNEWCorrect(i,2)+from ) );
end
