%
%
% plot a pairwise histogram, one mirrored (negative)
% useful to plot tuning curves of units or to compare visually two populations
%
%
%urut/may2014
%urut/aug2016 - change to new bar syntax
function plotPairedMirrorHistogram(data1, data2, bins, col1, col2, legendText)
if nargin<6
    legendText=[];
end

[N1,x1] = hist(data1,bins);
h1=bar(x1,N1);
h1.FaceColor=col1;
h1.EdgeColor=col1;

hold on
[N,x]=hist(data2,bins);
h2=bar(x,N*-1);
h2.FaceColor=col2;
h2.EdgeColor=col2;
hold off

if ~isempty(legendText)
    legend(legendText);
end