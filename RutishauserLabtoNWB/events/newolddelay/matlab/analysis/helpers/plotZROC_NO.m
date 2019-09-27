%
%plots z-transformed ROC for NO task
%
%bsame/bovernight: regression coefficients for fits through points
%
%according to Macmillan&creelman book
%
%urut/oct06
function plotZROC_NO(typeCountersSame, typeCountersOvernight, bSame, bOvernight, sessionID)

colors={'r','b'};

minMaxX=[0 0];
for i=1:2
   d=[];
   if i==1
       if isempty(typeCountersSame)
           continue;
       end

       counters=typeCountersSame;
       b=bSame;
   else
       if isempty(typeCountersOvernight)
           continue;
       end
       
       counters=typeCountersOvernight;
       b=bOvernight;
   end
   
   if i>1
       hold on
   end
   [h(i), x, y] = plotZROC(counters, b, colors{i});
   hold off
   
   if min(x)<minMaxX(1)
       minMaxX(1)=min(x);
   end
   if max(x)>minMaxX(2)
       minMaxX(2)=max(x);
   end
end

%draw chance line
h(3) = line(minMaxX,minMaxX,'color','k');

if ~isempty( typeCountersOvernight )
    legend(h, ['Same day s=' num2str(bSame(1),2)], ['Overnight s=' num2str(bOvernight(2),2)], 'Chance');
else
    legend(h([1 3]), ['Same day s=' num2str(bSame(2),2)], 'Chance', 'Location', 'SouthEast');    
end

xlabel('z(F)');
ylabel('z(H)');

%fit a line to calculate the slope


title(['z-ROC ' sessionID ],'interpreter','none');