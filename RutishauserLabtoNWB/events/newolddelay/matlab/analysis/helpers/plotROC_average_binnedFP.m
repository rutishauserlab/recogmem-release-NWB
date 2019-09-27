%
%
% vertical averaging of ROC, according to  section 6.2. in Fawcett 2004
%
%
%urut/oct13
function [AUC_fromAverage,h] = plotROC_average_binnedFP(All_AUC_FP, All_AUC_TP, colCode, errToPlot)

% only valid ROCs
indsValid = find( All_AUC_FP(:,end)==1 & All_AUC_TP(:,end)==1 );   % the last point has to be (1,1) for this to be a valid ROC

All_AUC_FP = All_AUC_FP(indsValid,:);
All_AUC_TP = All_AUC_TP(indsValid,:);

FPs=[0:0.1:1]; 


mROC_TP=[];
seROC_TP=[];
sROC_TP=[];

nrROCs = size(All_AUC_FP,1);
for k=1:length(FPs)
    
    targetFP = FPs(k);
    
    % for each bin, find the closest for each ROC
    
    TP_to_use=[];
    for j=1:nrROCs
        d = All_AUC_FP(j,:)-targetFP;
        
        indsFP = find ( min(abs(d)) == abs(d) );
        indsFP=indsFP(1);
        
        TP_to_use(j) = All_AUC_TP(j,indsFP);
    end
    
    [mTP,sTP,seTP,nTP] = calcMeanSEOfSample( TP_to_use' );
    

    mROC_TP(k) = mTP;
    seROC_TP(k) = seTP;
    sROC_TP(k) = sTP;
    
end

if errToPlot==1
    errTP=seROC_TP;
else
    errTP=sROC_TP;
end

h=errorbar( FPs, mROC_TP, errTP, colCode);

xlim([0 1]);
ylim([0 1]);

% chance line
line([0 1],[0 1],'color','k');

[AUC_fromAverage] = calcROC_AUC(mROC_TP,FPs);