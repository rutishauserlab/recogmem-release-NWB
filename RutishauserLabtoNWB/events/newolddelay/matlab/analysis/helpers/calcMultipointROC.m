%
%computes the cummulative ROC for all threshold levels listed in certainty
%nrTP/nrFP is the total number of stimuli that could be TP/FP (ground truth)
%answerTP/answerFP is what value in recogState constitutes a TP/FP
%
%urut/jan07
function [TP,FP] = calcMultipointROC(certainty, recogState, responses, nrTP, nrFP, answerTP, answerFP)

%are the certainty levels decending or ascending
if certainty(1)-certainty(2) > 0
    mode=1; %descening
else
    mode=2; %ascending
end

TP=[];
FP=[];
for i=1:length(certainty)
    
    if mode==1
        inds = find( responses >= certainty(i) );
    else
        inds = find( responses <= certainty(i) );        
    end
    
    TP(i) = length(find(recogState(inds)==answerTP))  / nrTP;
    FP(i) = length(find(recogState(inds)==answerFP))/ nrFP;
end
