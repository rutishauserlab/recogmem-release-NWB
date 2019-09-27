%% Add Learn and Recog Tags 
%
%
%
%

function [stimPhase] = getLearnRecogTags(expIDs, expIDLearn, expIDRecog)

stimPhase = {}; 

for i = 1:length(expIDs) 
    
    if expIDs(i) == expIDLearn
        stimPhase{i} = 'learn'; 
    elseif expIDs(i) == expIDRecog
        stimPhase{i} = 'recog';
    elseif expIDs(i) == 0 
        stimPhase{i} = 'n/a'; 
    else 
        error('This experiment ID does not exist: %s', expIDs(i))
    end 
    
end 
