
function [ListOfCellsToUse, cellStatsAll_exclusion,totStats_exclusion ] = EpilepticSitesExclusion(cellStatsAll, totStats, epilepsyExclusionMode)
%% filter according to epilepsy diagnosis
for k=1:length(cellStatsAll)                                           
    NOind = cellStatsAll(k).NOind;                                      
    brainAreaOfCell = cellStatsAll(k).brainAreaOfCell;                  
    diagnosisCode = cellStatsAll(k).diagnosisCode;                      
    
    % diagnosisCode:
    % 0)  not localized
    % 1)  Right Mesial Temporal
    % 2)  Left Mesial Temporal
    % 3)  Right Neocortical Temporal
    % 4)  Left Neocortical Temporal
    % 5)  Right Lateral Frontal
    % 6)  Left Lateral Frontal
    % 7)  Bilateral Independent Temporal
    % 8)  Bilateral Independent Frontal
    % 9)  Right Other
    % 10) Left Other
    % Note on diagnosisCode:
    % for temporal: 'mesial' means hippocampus or amygdala, so where the micro-electrodes were implanted, 'neocortical' means in the cortex, where the micro-electrodes were never implanted
    % Bilateral Independent means that there were 2 independant foci, one on each side
    
    if isnan(diagnosisCode)
        error(['undefined diagnosis code for NOind=' num2str(NOind)]);
    end
    
    isEpiMTL=nan; % is neuron in same side as temporal focus
    isEpiFront=nan; % is neuron in same side as frontal focus
    switch( diagnosisCode )   % only defined for brainareas 1-4 for now
        case 0 %not localized
            isEpiMTL=2;
            isEpiFront=2;
        case 1 %Right Mesial Temporal
            isEpiFront=0;
            if ( brainAreaOfCell==1 || brainAreaOfCell==3 )
                %RH and RA
                isEpiMTL=1;
            else
                %LH and LA
                isEpiMTL=0;
            end
        case 2 % Left Mesial Temporal
            isEpiFront=0;
            if ( brainAreaOfCell==1 || brainAreaOfCell==3 )
                %RH and RA
                isEpiMTL=0;
            else
                %LH and LA
                isEpiMTL=1;
            end
        case 3 %Right Neocortical Temporal
            isEpiMTL=0;% the seizure focus is in the temporal lobe but not where the electrodes are. so, isEpiMTL=0;
            isEpiFront=0;
        case 4 %Left Neocortical Temporal
            isEpiMTL=0;
            isEpiFront=0;
        case 5 % PREV 3. Right Lateral Frontal
            isEpiMTL=0;
            isEpiFront=1;
        case 6 % PREV 4. Left Lateral Frontal
            isEpiMTL=0;
            isEpiFront=1;
        case 7 % Bilateral Independent Temporal
            isEpiMTL=1;
            isEpiFront=0;
        case 8 % Bilateral Independent Frontal
            isEpiMTL=0;
            isEpiFront=1;
        case 9 % Right Other
            isEpiMTL=0;
            isEpiFront=0;
        case 10 % Left Other
            isEpiMTL=0;
            isEpiFront=0;
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

disp(['Only use subset: ' num2str(length(indsUse)) ' cells over ' num2str(length(cellStatsAll) )]);

ListOfCellsToUse = indsUse;   % only use this subset
totStats_exclusion =  totStats( ListOfCellsToUse,:);
for ce = 1:length(ListOfCellsToUse)
    cellStatsAll_exclusion(ce).channel = cellStatsAll(ListOfCellsToUse(ce)).channel;
    cellStatsAll_exclusion(ce).cellNr = cellStatsAll(ListOfCellsToUse(ce)).cellNr;
    cellStatsAll_exclusion(ce).brainAreaOfCell = cellStatsAll(ListOfCellsToUse(ce)).brainAreaOfCell;
    cellStatsAll_exclusion(ce).origClusterID = cellStatsAll(ListOfCellsToUse(ce)).origClusterID;
    cellStatsAll_exclusion(ce).timestamps = cellStatsAll(ListOfCellsToUse(ce)).timestamps;
    cellStatsAll_exclusion(ce).diagnosisCode = cellStatsAll(ListOfCellsToUse(ce)).diagnosisCode;
    cellStatsAll_exclusion(ce).recogResponses = cellStatsAll(ListOfCellsToUse(ce)).recogResponses;
    cellStatsAll_exclusion(ce).newOldRecogLabels = cellStatsAll(ListOfCellsToUse(ce)).newOldRecogLabels;
    cellStatsAll_exclusion(ce).stimuliCategories = cellStatsAll(ListOfCellsToUse(ce)).stimuliCategories;
    cellStatsAll_exclusion(ce).stimuliRecog =cellStatsAll(ListOfCellsToUse(ce)).stimuliRecog;
    cellStatsAll_exclusion(ce).countBaseline = cellStatsAll(ListOfCellsToUse(ce)).countBaseline;
    cellStatsAll_exclusion(ce).countStimulus_long = cellStatsAll(ListOfCellsToUse(ce)).countStimulus_long;
    cellStatsAll_exclusion(ce).neuronType = cellStatsAll(ListOfCellsToUse(ce)).neuronType;
    cellStatsAll_exclusion(ce).indsOldUse = cellStatsAll(ListOfCellsToUse(ce)).indsOldUse;
    cellStatsAll_exclusion(ce).indsNewUse = cellStatsAll(ListOfCellsToUse(ce)).indsNewUse;
    cellStatsAll_exclusion(ce).pVals = cellStatsAll(ListOfCellsToUse(ce)).pVals;
    cellStatsAll_exclusion(ce).rate = cellStatsAll(ListOfCellsToUse(ce)).rate;
    cellStatsAll_exclusion(ce).periods = cellStatsAll(ListOfCellsToUse(ce)).periods;
    cellStatsAll_exclusion(ce).NOind = cellStatsAll(ListOfCellsToUse(ce)).NOind;
end

