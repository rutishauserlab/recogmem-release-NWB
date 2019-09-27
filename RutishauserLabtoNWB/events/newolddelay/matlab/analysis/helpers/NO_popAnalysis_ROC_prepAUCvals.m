%
%
% determine AUC values for high/low for different cell types
%
%
function [slopesType0,slopesType1, AUCType0,AUCType0_high,AUCType0_low, AUCType0_errFN, AUCType0_errFNhigh, AUCType0_errFNlow, ...
    AUCType1,AUCType1_high,AUCType1_low, AUCType1_errFN, AUCType1_errFNhigh, AUCType1_errFNlow,AUCType0_FN_vs_FP,AUCType1_FN_vs_FP,...
    AUCType0_errFP, AUCType1_errFP, AUCType0_errFPhigh, AUCType1_errFPhigh, AUCType0_errFPlow, AUCType1_errFPlow] = NO_popAnalysis_ROC_prepAUCvals( All_AUCstats, ROCstats )

indsValid = find( All_AUCstats(:,1)>0 & All_AUCstats(:,2)>0 & All_AUCstats(:,3)~=0 & All_AUCstats(:,4)~=0)
mean( All_AUCstats(indsValid,:) )

%[h,p]=ttest( All_AUCstats(indsValid,1), All_AUCstats(indsValid,2) )   % compare d_a high vs low
%[h,p]=ttest( All_AUCstats(indsValid,3), All_AUCstats(indsValid,4) ) % compare c_e

slopesType0 = ROCstats( find(ROCstats(:,4)==0),1);
slopesType1 = ROCstats( find(ROCstats(:,4)==1),1);

AUCType0 = ROCstats( find(ROCstats(:,4)==0),5);
AUCType1 = ROCstats( find(ROCstats(:,4)==1),5);

AUCType0_high = ROCstats( find(ROCstats(:,4)==0),8);
AUCType1_high = ROCstats( find(ROCstats(:,4)==1),8);
AUCType0_low = ROCstats( find(ROCstats(:,4)==0),9);
AUCType1_low = ROCstats( find(ROCstats(:,4)==1),9);

AUCType0_errFN = ROCstats( find(ROCstats(:,4)==0),12);
AUCType1_errFN = ROCstats( find(ROCstats(:,4)==1),12);

AUCType0_errFNhigh = ROCstats( find(ROCstats(:,4)==0),13);
AUCType1_errFNhigh = ROCstats( find(ROCstats(:,4)==1),13);

AUCType0_errFNlow = ROCstats( find(ROCstats(:,4)==0),14);
AUCType1_errFNlow = ROCstats( find(ROCstats(:,4)==1),14);

AUCType0_FN_vs_FP = ROCstats( find(ROCstats(:,4)==0),15);
AUCType1_FN_vs_FP = ROCstats( find(ROCstats(:,4)==1),15);

AUCType0_errFP = ROCstats( find(ROCstats(:,4)==0),16);
AUCType1_errFP = ROCstats( find(ROCstats(:,4)==1),16);

AUCType0_errFPhigh = ROCstats( find(ROCstats(:,4)==0),17);
AUCType1_errFPhigh = ROCstats( find(ROCstats(:,4)==1),17);

AUCType0_errFPlow = ROCstats( find(ROCstats(:,4)==0),18);
AUCType1_errFPlow = ROCstats( find(ROCstats(:,4)==1),18);

% some are nan if there are no trials of this type
AUCType0_high = AUCType0_high( find(~isnan(AUCType0_high)) );
AUCType1_high = AUCType1_high( find(~isnan(AUCType1_high)) );
AUCType0_low = AUCType0_low( find(~isnan(AUCType0_low)) );
AUCType1_low = AUCType1_low( find(~isnan(AUCType1_low)) );

AUCType0 = AUCType0(find(~isnan(AUCType0) & AUCType0>0  ));
AUCType1 = AUCType1(find(~isnan(AUCType1) & AUCType1>0 ));

AUCType0_errFN = getValidAUCs( AUCType0_errFN);
AUCType1_errFN = getValidAUCs( AUCType1_errFN);

AUCType0_errFP = getValidAUCs( AUCType0_errFP);
AUCType1_errFP = getValidAUCs( AUCType1_errFP);

AUCType0_errFNhigh = getValidAUCs( AUCType0_errFNhigh);
AUCType1_errFNhigh = getValidAUCs( AUCType1_errFNhigh);
AUCType0_errFNlow = getValidAUCs( AUCType0_errFNlow);
AUCType1_errFNlow = getValidAUCs( AUCType1_errFNlow);

AUCType0_errFPhigh = getValidAUCs( AUCType0_errFPhigh);
AUCType1_errFPhigh = getValidAUCs( AUCType1_errFPhigh);
AUCType0_errFPlow = getValidAUCs( AUCType0_errFPlow);
AUCType1_errFPlow = getValidAUCs( AUCType1_errFPlow);


AUCType0_FN_vs_FP = getValidAUCs( AUCType0_FN_vs_FP);
AUCType1_FN_vs_FP = getValidAUCs( AUCType1_FN_vs_FP);

%====
function AUCVals = getValidAUCs( AUCVals)
AUCVals = AUCVals(find(~isnan(AUCVals) & AUCVals>0  ));