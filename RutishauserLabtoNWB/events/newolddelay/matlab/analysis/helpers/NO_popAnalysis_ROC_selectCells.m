%
% select groups of cells. Split-out from NO_popAnalysis_ROC.m to separate selection and plotting
%
%
function [sigCellListNO, sigCellListCat, sigCellList_valid,sigCellListVisResp] = NO_popAnalysis_ROC_selectCells(areaToProcessList, totStats, minRateToUse, minNrTrials, cellStatsAll, enforceBehaviorExclusions, alphaLimBootstrap, epilepsyExclusionMode )

%% select significant cells
[sigCellListNO, sigCellListCat, sigCellList_valid,sigCellListVisResp] = NO_selectSigCells(areaToProcessList, totStats, minRateToUse, minNrTrials, cellStatsAll, enforceBehaviorExclusions, alphaLimBootstrap );




%% filter according to epilepsy diagnosis
if epilepsyExclusionMode>0
    % get diagnosis code for each entry
    diagnosisCodes_forSigCellList =[]; %NOind diagnosisCode isEpi isNonEpi
    for k=1:length(sigCellListNO)
        NOind = cellStatsAll(sigCellListNO(k)).NOind;        
        brainAreaOfCell = cellStatsAll(sigCellListNO(k)).brainAreaOfCell;
        [~, diagnosisCode] = NOepilepsyStatus( NOind );

        if isnan(diagnosisCode)
           error(['undefined diagnosis code for NOind=' num2str(NOind)]);
        end
        
        %isEpiMTL: 0 in non-epi zone; 1 is in epi zone; 2 is in non-localized pt
        isEpiMTL=nan; % is neuron in same side as temporal focus
        isEpiFront=nan; % is neuron in same side as frontal focus
        switch( diagnosisCode )   % only defined for brainareas 1-4 for now
            case 0 
                isEpiMTL=2;
                isEpiFront=2;
            case 1 %RMTL
                isEpiFront=0;
                if ( brainAreaOfCell==1 || brainAreaOfCell==3 ) 
                    %RH and RA
                    isEpiMTL=1;
                else
                    %LH and LA
                    isEpiMTL=0;
                end
            case 2 %LMTL
                isEpiFront=0;
                if ( brainAreaOfCell==1 || brainAreaOfCell==3 )
                    %RH and RA
                    isEpiMTL=0;
                else
                    %LH and LA
                    isEpiMTL=1;
                end
            case 3 %RFront
                isEpiMTL=0;
                if ( brainAreaOfCell==1 || brainAreaOfCell==3 ) 
                    %RH and RA
                    isEpiFront=1;
                else
                    %LH and LA
                    isEpiFront=0;
                end
            case 4 %LFront
                isEpiMTL=0;
                if ( brainAreaOfCell==1 || brainAreaOfCell==3 )
                    %RH and RA
                    isEpiFront=0;
                else
                    %LH and LA
                    isEpiFront=1;
                end                
            case 7 %bilateral temporal
                isEpiMTL=1;
                isEpiFront=0;
            case 8 %bilateral frontal
                isEpiMTL=0;
                isEpiFront=1;            
        end
        diagnosisCodes_forSigCellList(k,:) = [NOind diagnosisCode isEpiMTL isEpiFront];
        
    end
    
    % subselect a set of NO neurons, based on diagnosis.
    % epilepsyExclusionMode=1 only in non-epileptic temporal, exclude non-localized
    % epilepsyExclusionMode=2 only in non-epileptic side (strict)
    % epilepsyExclusionMode=3 only in epileptic temporal (strict)
    % epilepsyExclusionMode=4 only in epileptic side 
    % epilepsyExclusionMode=5 only in non-epileptic temporal, include non-localized
    %
    % pts who are not localized are always excluded
    
    switch epilepsyExclusionMode
        case 1
            indsUse = find(diagnosisCodes_forSigCellList(:,3)==0);
        case 2
            indsUse = find(diagnosisCodes_forSigCellList(:,3)==0 & diagnosisCodes_forSigCellList(:,4)==0);
        case 3       
            indsUse = find(diagnosisCodes_forSigCellList(:,3)==1);
        case 4        
            indsUse = find(diagnosisCodes_forSigCellList(:,3)==1 | diagnosisCodes_forSigCellList(:,4)==1);
        case 5
            indsUse = find(diagnosisCodes_forSigCellList(:,3)==0 | diagnosisCodes_forSigCellList(:,3)==2 );
    end
    
    disp(['Only use epileptic subset, length ' num2str(length(indsUse)) ' original ' num2str(length(sigCellList))]);

    sigCellListNO = sigCellListNO(indsUse);   % only use this subset   
end



