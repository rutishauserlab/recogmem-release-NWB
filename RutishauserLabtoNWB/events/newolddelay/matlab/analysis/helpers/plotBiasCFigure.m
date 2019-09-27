%
% calculates and plots the bias, eq 2.1 pp 29 in Macmillan&Creelman.
%
%urut/march09
%
function [biasC, zH,zF] = plotBiasCFigure(typeCountersSame, typeCountersOvernight, sessionID, doPlot)
if nargin<4
    doPlot=1;
end

dS = calcCumulativeD( typeCountersSame );

%y = [ dS(1, 1:3) ];

zH=dS(2,1:5);
zF=dS(3,1:5);

biasC = calcCriterion(zH, zF);

if doPlot
    bar(1:length(biasC),biasC);
    %set(gca,'XTickLabel',{'Same Day', 'Overnight'});
    ylabel('bias [C] ');
    
    set(gca, 'XTickLabel', {'Conf 1', 'Conf <=2', 'Conf <=3',  'Conf <=4',  'Conf <=5'} );
    
    title(['bias c'' ' sessionID]);
end
