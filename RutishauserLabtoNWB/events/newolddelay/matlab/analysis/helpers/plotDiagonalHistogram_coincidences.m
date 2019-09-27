%
% for a 2D scatter plot, compute and plot a histogram of coincidences along the diagonal.
% such histograms are often used to summarize a JPSTH or pairwise plot of two metrics of the same cell in two conditions.
%
% X, Y: pairs of data
%
%plotMode: 0 no plotting, 1 plot as histogram, 2 debug plots, 3 plot rotated histogram
%
% range = [0 xx]   
%
%urut/may14
function [diagHist, N,edges] = plotDiagonalHistogram_coincidences(X, Y, binsize, range, plotMode  )

data=[X;Y]';

edges{1}=range(1):binsize:range(2);
edges{2}=edges{1};
[N,C]=hist3(data, 'Edges', edges);



diagLength = sqrt(2)*range(2);   % length along the diagonal, in original units

diagStepsize = diagLength/ (length(N)*2-1);  % so many steps

%diagLength = sqrt(2)*sum(abs(range));
%stepsizeOnDiag = diagLength/length(N);

% count along the antidiagonal
diagHist = [];   

is = floor(length(N)/2);
c=0;
for i = -length(N)+1:length(N)-1
    
    % i is how many bins away from diagonal, i==0 is on diagonal
    
   actPos  = diagStepsize*i ;   % position on diagonal in real units
   
   
   summedVals = sum( diag((N),i*-1) );
   
   c=c+1;
   diagHist(c,:) = [i summedVals actPos];
end

xPos = diagHist(:,3);
yPos = diagHist(:,2);


if plotMode>0
    if plotMode==2
        subplot(2,2,1);
        imagesc(N);
        
        
        set(gca,'YDir','normal')
        
        spacing=3;
        set(gca,'XTick', 1:spacing:length(edges{1}));
        set(gca,'XTickLabel', edges{1}(1:spacing:end));
        
        set(gca,'YTick', 1:spacing:length(edges{2}));
        set(gca,'YTickLabel', edges{2}(1:spacing:end));
        
        
        subplot(2,2,3);
        plot(X, Y, 'o');
        xlim(range);
        ylim(range);
        
        line(range,range);
        
        
        line([range(1) range(2) ], [range(2) range(1)]   , 'color','k');   % line along which the histogram is plotted
        
        subplot(2,2,2);
    end
    
    %h = plot( diagHist(:,1), diagHist(:,2) );
    if plotMode==1 || plotMode==2
        bar( xPos, yPos);
        xlabel('position along diagonal');
        
        xlim([-range(2) range(2)]);
    else
       
        %rotated. need to use plot
        barwidth=binsize/sqrt(2);
        xPosAll=[];
        yPosAll=[];
        for k=1:length(xPos)
            xPosAll = [ xPosAll xPos(k)-barwidth/2 xPos(k)+barwidth/2 ];
            yPosAll = [ yPosAll yPos(k) yPos(k)];
        end
        h = plot( xPosAll, yPosAll, '-');
        %rotate([h ],[0, 90],-45,[0 0 0]);
        
        
        
        xtemp = get(h,'xdata');
        ytemp = get(h,'ydata');
        fc = [0 0 1];
        fill(xtemp,ytemp,fc,'EdgeColor',fc);        
        
        hold on
        h2 = plot( [0 0], [0 max(yPos)],'-', 'color','k'); %mark zero point
        hold off
       

        xPosMean = sum(xPosAll.*yPosAll)./sum(yPosAll);
        hold on
        h3 = plot( [xPosMean xPosMean],[0 max(yPos)],'-', 'color', 'r');
        hold off
    end
    
end