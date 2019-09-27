%% get BrainArea location from brainArea 



function [brainAreaLOC] = getBrainAreaLOC(brainAreaIDs)  

%brainArea = brainArea ID's 
brainAreaLOC = {};
for i = 1:length(brainAreaIDs) 
    
    brainAreaLOC{i} = translateArea(brainAreaIDs(i));
    
    if strcmp(brainAreaLOC{i}, 'LH')
        brainAreaLOC{i} = 'Left Hippocampus';
    elseif strcmp(brainAreaLOC{i}, 'RH')
        brainAreaLOC{i} = 'Right Hippocampus';
    elseif strcmp(brainAreaLOC{i}, 'RA')
        brainAreaLOC{i} = 'Right Amygdala';
    elseif strcmp(brainAreaLOC{i}, 'LA')
        brainAreaLOC{i} = 'Left Amygdala';
    end
    
end 

if ~(length(brainAreaLOC) == length(brainAreaIDs))
    error('error in assigning brain area locations, need to check/fix')
end 

brainAreaLOC = brainAreaLOC'; 

end 
