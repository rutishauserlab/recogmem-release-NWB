%
% determine for an NO session where the optimal decision threshold is to
% assign stimuli to TP/FN
%
% different optimization criteria can be applied:
% 0: fixed (3)
% 1: TP rate
% 2: criterion
%
% typeCounters: nr trials for each confidence level, see NObehaviorROC_prepare.m
%
% T: threshold for which T>=confidence means OLD.   confidence<T is NEW.
% 6-point scale, 6=OLD.....1=NEW
%
%urut/march09
function [T, goalUsed] = determineNODecisionThreshold( typeCounters, mode)
goalCriterion=0;
goalTP=0.7;

[C, zH, zF] = plotBiasCFigure(typeCounters, [], '', 0);
%nrTrials=typeCounters(1,:);

%typeCounters: each row is TP/FN/TN/FP, in this order
%dS: each row is d', zH, zF, H, F
dS = calcCumulativeD( typeCounters );
TP = dS(4,:);
 
switch(mode)
    case 0
        T=3;
        
        goalUsed=[];

    case 1
        %criterion        
        ind=find(abs(C-goalCriterion)==min(abs(C-goalCriterion)));
        ind=ind(1);
        
        T = ind; 
        
        goalUsed=goalCriterion;
    case 2
        %TP
        ind=find(abs(TP-goalTP)==min(abs(TP-goalTP)));
        ind=ind(1);
        
        T = ind;         
        goalUsed=goalTP;
end

T=6-T + 1;  %from point of view of OLD. +1 because of >= condition for OLD.




