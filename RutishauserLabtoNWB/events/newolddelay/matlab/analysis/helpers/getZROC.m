%
% z-transform an ROC
% 
% moved out of plotRecallRoc.m
%
%urut/aug13
function [TP1,FP1,dP]=getZROC(TP1,FP1,nOLD,nNEW)
[TP1,FP1] = adjustHF(TP1, FP1, nOLD, nNEW);

FP1 = norminv(FP1);
TP1 = norminv(TP1);

dP = mean( TP1 - FP1 );