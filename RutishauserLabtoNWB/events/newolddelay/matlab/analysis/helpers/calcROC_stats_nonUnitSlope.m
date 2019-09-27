%
% calculate metrics of the ROC that are valid for non-unit slope ROCs
% d_a
% c_e
%
%urut/oct13
function [d_a, c_e] = calcROC_stats_nonUnitSlope( zTP1, zFP1)
[Rsquare, pValSlope, slope, intercept, bint] = getZROC_slope(zFP1, zTP1);

d_a = sqrt(2/(1+slope^2)) .* (zTP1-slope*zFP1);   % d_a, Eq 3.5 pp62;  d prime measure for when slope ~=1

c_e = (-2*slope)/(1+slope)^2 .* ( zTP1+zFP1); % c_e, Eq 3.14, pp 67; bias measure for slope ~= 1
