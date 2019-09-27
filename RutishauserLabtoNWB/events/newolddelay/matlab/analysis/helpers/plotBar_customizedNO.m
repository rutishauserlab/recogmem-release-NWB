%
% plot bar plot comparing conditions for NO paper
%
%
function plotBar_customizedNO(xPos, yVals, errVals, cols, labelStrs, barWidth)

for k=1:length(xPos)
    %call bar twice to allow setting individual color
    
    if length(yVals)<k
        continue;
    end
    h=bar( xPos(k) , yVals(k), barWidth );
    set(h, 'FaceColor', cols{k});
    set(h, 'EdgeColor', cols{k});

    hold on
    if ~isempty(errVals)
        hErr = errorbar(xPos(k), yVals(k), errVals(k),'.');
        set(hErr, 'linewidth',2);
        set(hErr, 'color', cols{k});
    end
    
end
hold off


set(gca,'XTick', xPos );
set(gca,'XTickLabel', labelStrs);


xlim( [ xPos(1)-barWidth*4/3 xPos(end)+barWidth*4/3 ]);