%plots cumulative ROC (empirical) and fitted data using z-ROC slope
%
% addCorners: 0 plot as is; 1 add the 0/0 point manually; -1 dont add 0/0 point and also remove the 1/1 point
%
%
function [h,x,y] = plotCumulativeROC(counters, s, da, colorCode, plotFit,addCorners)
if nargin<=4
    plotFit=0;
end
if nargin<6
    addCorners=0;
end

d = calcCumulativeD( counters );

h=[];

d = d( 4:5, :); %only H/F of interest here

x=d(2,:);
y=d(1,:);
    
% if addCorners==1
%    % manually add 0/0 point
%    x=[0 x];
%    y=[0 y];
% end
if addCorners==-1
   % manually remove the 1/1 point
   x=x(1:end-1);
   y=y(1:end-1);
end

h = plot( x, y, ['d--' colorCode],'MarkerSize',8, 'MarkerFaceColor', colorCode);
%hold on
%legend(h, {'Individual Sessions'}, 'Location','SouthEast');   

%=== enable following to plot fit
if plotFit==1
    F=0:0.05:1;
    H = fitROC(F, s, da);
    hold on
    plot(F,H,colorCode);
    hold off
end

%chance line
%h(3) = line([0 1],[0 1],'color','k');