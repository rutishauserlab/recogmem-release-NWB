%
%area under the curve AUC of an ROC
%
%Following eq 3.9, pp 64 of Macmillan book.
%
%partly copied from novelty/ROC/calcAUC.m (thus overlaps)
%
%TP/FP are expected to be ordered (ascending), but are not automatically resorted as this
%might introduce artifacts in case of non-monotonic ROCs.
%
%if reverseOrder=1, TP and FP are expected in descending order
%
%automatically adds the (0,0) and (1,1) point if it does not exist yet
%
%
%urut/april08
%extended urut/aug11
%reverseOrder added urut/april12
function [AUC] = calcROC_AUC(TP,FP, reverseOrder)
if nargin<3
    reverseOrder=0;
end

if reverseOrder
    TP = TP(end:-1:1);
    FP = FP(end:-1:1);
end

if FP(1)~=0 || TP(1)~=1
    FP = [0 FP];
    TP = [0 TP];
end
if FP(end)~=1 || TP(end)~=1
    FP = [FP 1];
    TP = [TP 1];
end

if ~issorted(TP) || ~issorted(FP)
   warning('TP/FP need to be sorted ascending'); 
end

%calc AUC (integrate curve)
AUC=0;
assigned=0;
for i=2:length(TP)
    if FP(i-1) < FP(i) %only if it has slope for FP (if FP(i-1)==FP(i), no increase in area
        AUC = AUC + (FP(i)-FP(i-1))*TP(i-1);
        AUC = AUC + 1/2 * (TP(i)-TP(i-1))*(FP(i)-FP(i-1));
        assigned=1;
    end
end
