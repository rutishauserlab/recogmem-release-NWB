%% Remove Empty Cells from NOsessions

    
function [NOsessions] = removeEmptyCells_NOsessions(NOsessions)
    
    indexOfEmptyCells = []; 
    for i = 1:length(NOsessions)
        if isempty(NOsessions(i).session)
            indexOfEmptyCells(i) = i; 
            
        end 

    end 
    
    emptyCells = find(indexOfEmptyCells > 0);
    NOsessions(emptyCells) = [];
    
end 