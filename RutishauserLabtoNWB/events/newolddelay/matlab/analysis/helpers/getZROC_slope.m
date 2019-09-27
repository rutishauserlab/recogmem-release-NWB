%
% fit line to z-ROC transformed ROC plot
%
%urut/aug13
function [Rsquare, p, slope, intercept, bint] = getZROC_slope(zFP, zTP )

x = zFP;
y = zTP;

alpha=0.01; % for confidence intervals
[b,bint,R,Rint,stats]=regress(y', [ones(length(x),1) x' ], alpha);

Rsquare = stats(1);
p = stats(3);

intercept = b(1);
slope = b(2);


