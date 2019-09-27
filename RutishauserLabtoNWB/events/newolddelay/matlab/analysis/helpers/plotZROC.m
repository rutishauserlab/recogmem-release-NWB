%
%plots z-transformed ROC
%
%bsame/bovernight: regression coefficients for fits through points
%
%according to Macmillan&creelman book
%
%urut/oct06
function [h, x, y] = plotZROC(counters, b, colorCode, plotMode)
if nargin<4
    plotMode=1;
end

d = calcCumulativeD( counters );

d = d(2:3,:); %remove d' value

x=[];
y=[];

%ignore the last point,because its at the same location
x = d(2,1:end-1);
y = d(1,1:end-1);

%plot data points
if plotMode==1
    h = plot(x, y , ['d' colorCode],'MarkerSize',8, 'MarkerFaceColor', colorCode);
else
    
    %no dots, line only
    
    %h = plot(x, y , ['.'],'color', colorCode, 'MarkerFaceColor', colorCode);
    h=[];
end


%plot the regression line
x1=x(1);
x2=x(end);
line([x1 x2], [ b(1)+b(2)*x1 b(1)+b(2)*x2 ], 'color', colorCode );


