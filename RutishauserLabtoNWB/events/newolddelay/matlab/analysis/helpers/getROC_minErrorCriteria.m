%
% this function returns the optimal decision threshold, as defined by the
% minimum error test. See Gabbiani&Cox, pp348
%
% TP and FP are expected to be ordered from low to high and paired, i.e.
% data points in the ROC (TP1,FP1), (TP2,FP2), ...
%
% the returned index minErrPoint identifies the point of the ROC (TPx,FPx)
% that is the optimal decision point.
%
%urut/aug13
function [minErrCurve, minErrPoint ] = getROC_minErrorCriteria(TP, FP)


minErrCurve = FP+1-TP;


minErrInds = find( minErrCurve==min(minErrCurve));

minErrPoint = minErrInds(1);  % take the one with lowest FP


