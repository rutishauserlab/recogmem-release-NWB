%
% return list of significant cells (category, NO, all) across all sessions
%
%urut/oct13
function [sigCellListMS, sigCellListVS, sigCellListVisResp, sigCellList_valid] = NO_selectSigCells_simple(areaToProcessList, totStats, minRateToUse, minNrTrials, cellStatsAll,enforceBehaviorExclusions, alphaLimBootstrap )

sigCellListMS = []; % index of cells considered significant; index into cellStatsAll / totStats
sigCellListVS = []; % VS cells
sigCellListVisResp =[]; % VS baseline cells
sigCellList_valid = []; % all valid cells

for areaToProcess = areaToProcessList    
    indsOfArea = find( totStats(:,4)==areaToProcess & totStats(:,11)>minRateToUse & totStats(:,9)>minNrTrials & totStats(:,10)>minNrTrials);

    % for all cells, decide if it is included for behavioral reasons
    indsOfArea = NO_behavioralExclusionCriteria(enforceBehaviorExclusions, indsOfArea, cellStatsAll);

    indsSigBaseline =  find( totStats(indsOfArea,5) <= alphaLimBootstrap  );
    indsSigMS =  find( totStats(indsOfArea,6) <= alphaLimBootstrap ); % MS cell
    indsSigVS =  find( totStats(indsOfArea,7) <=alphaLimBootstrap  ); % VS cell

    sigCellListMS = [ sigCellListMS; [ indsOfArea(indsSigMS) ]];
    sigCellListVS = [ sigCellListVS; [ indsOfArea(indsSigVS) ]];
    sigCellListVisResp = [ sigCellListVisResp; [ indsOfArea(indsSigBaseline) ]];
    sigCellList_valid = [ sigCellList_valid; indsOfArea ];
end



