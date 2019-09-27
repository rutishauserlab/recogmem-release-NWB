%
%
% see if a session needs to be excluded based on inappropriate behavior (bad performance, inability to judge confidence
%
%urut/oct13
function indsOfArea_toUse = NO_behavioralExclusionCriteria(enforceBehaviorExclusions, indsOfArea, cellStatsAll)

if enforceBehaviorExclusions
    
        excludeList=[];
        for jj=1:length(indsOfArea)
            
            cellStatsTmp = cellStatsAll( indsOfArea(jj) );
        
            [isIncluded,AUC,percAccuracy_high, percAccuracy_low, TP, FP] = NO_behavior_evaluateSessionStatus(cellStatsTmp.recogResponses, cellStatsTmp.newOldRecogLabels,enforceBehaviorExclusions);
            
            if ~isIncluded
                excludeList = [ excludeList indsOfArea(jj) ];
           
            end
        end
        
        indsOfArea_toUse = setdiff( indsOfArea, excludeList' );
      
else
    indsOfArea_toUse = indsOfArea;
end
    
 
        
      