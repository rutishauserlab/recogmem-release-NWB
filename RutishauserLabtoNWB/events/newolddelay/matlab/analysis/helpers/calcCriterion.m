%
% calculates the bias (criterion), based on zH and zF  (z-transformed H/F)
% eq 2.1, creelman
%
% if there are several in zH/zF, calculates for each independently
%urut/march09
function c = calcCriterion(zH, zF)
for i=1:length(zH)
    c(i) = -1/2*sum(zH(i)+zF(i));  % EQ 2.1, pp29
end