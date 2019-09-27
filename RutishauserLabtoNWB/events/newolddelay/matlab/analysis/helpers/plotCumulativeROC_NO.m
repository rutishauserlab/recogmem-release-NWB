%plots cumulative ROC (empirical) and fitted data using z-ROC slope
%
%for the NO task
%
%plotFit: 0/1 to enable plotting of fitted d' curve
%
%urut/oct06
function [h,x,y]=plotCumulativeROC_NO(typeCountersSame, typeCountersOvernight, sBoth, daBoth, sessionID, plotFit, addCorners )
if nargin<=5
    plotFit=0;
end
if nargin<=6
    addCorners=0;
end

h=[];
AUC=[];
x=[];
y=[];
colors={'b','r'};
for i=1:2
    if i==1
        counters = typeCountersSame;
    else
        counters = typeCountersOvernight;
    end
    
    if isempty(counters)
        continue;
    end
    
    if i>1
        hold on
    end
    
    [h(i),x{i},y{i}] = plotCumulativeROC(counters, sBoth(i), daBoth(i), colors{i}, plotFit, addCorners);
    hold off
    
    
    dS = calcCumulativeD( counters );
    d = dS( 4:5, :); %only H/F of interest here
    FP=d(2,:);
    TP=d(1,:);
    
    AUC(i) = calcROC_AUC(TP,FP);
    
end

%plot the chance line
h(3) = line([0 1],[0 1],'color','k');
%h(3) = line([0 0.5],[1 0.5],'color','k');

xlim([0 1]);
ylim([0 1]);

if ~isempty(typeCountersOvernight)
    legend(h, {['Same Day da=' num2str(daBoth(1),2)], ['Overnight da=' num2str(daBoth(2),2)] ,'Chance'});
else
    %legend(h([1 3]), {['Same Day da=' num2str(daBoth(1),2)], 'Chance'});    
    legend(h([1 3]), {['Average'], 'Chance'}, 'Location','SouthEast');    
end

xlabel('False alarm rate');
ylabel('Hit rate');

%title(['ROC ' sessionID ' AUC=' num2str(AUC)], 'interpreter','none');
end 

