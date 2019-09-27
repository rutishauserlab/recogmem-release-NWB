%% get Category Name of stimili 


function [categoryName] = getCategoryName(stimuliCategories, variant) 

%variant is the variant of the task (e.g, var1, var2, var3)

categoryName = {};
switch variant 
    
    case 1 
        
        %CategoryMapping (var1)
        % 1 = houses, 2 = landscapes, 3 = mobility, 4 = phones, 5 =
        % smallAnimal
        for i=1:length(stimuliCategories)
            
            if stimuliCategories(i) == 1 
                categoryName{i} = 'houses';
            elseif stimuliCategories(i) == 2
                categoryName{i} = 'landscapes';
            elseif stimuliCategories(i) == 3
                categoryName{i} = 'mobility';
            elseif stimuliCategories(i) == 4
                categoryName{i} = 'phones';
            elseif stimuliCategories(i) == 5
                categoryName{i} = 'smallAnimal';
            elseif stimuliCategories(i) == 0 %No stimuli
                categoryName{i} = 'N/A';
            else
                error(['This stimuli category does not exist ', ... 
                    num2str(stimuliCategories(i)) ,' for this variant: ', ...
                    num2str(variant)])
            end 
        end  
        
        
    case 2 
        
        %CategoryMapping (var1)
        % 1 = fruit, 2 = kids, 3 = military, 4 = space, 5 = zzanimal
        for i=1:length(stimuliCategories)
            
            if stimuliCategories(i) == 1 
                categoryName{i} = 'fruit';
            elseif stimuliCategories(i) == 2
                categoryName{i} = 'kids';
            elseif stimuliCategories(i) == 3
                categoryName{i} = 'military';
            elseif stimuliCategories(i) == 4
                categoryName{i} = 'space';
            elseif stimuliCategories(i) == 5
                categoryName{i} = 'zzanimal';
            elseif stimuliCategories(i) == 0 %No stimuli
                categoryName{i} = 'N/A';
            else
                error(['This stimuli category does not exist ', ... 
                    num2str(stimuliCategories(i)) ,' for this variant: ', ...
                    num2str(variant)])
            end 
        end
        
    case 3
        
        %CategoryMapping (var3)
        % 1 = cars,	2 = food, 3 = people, 4 = spatial, 5 = animals
        for i=1:length(stimuliCategories)
            
            if stimuliCategories(i) == 1 
                categoryName{i} = 'cars';
            elseif stimuliCategories(i) == 2
                categoryName{i} = 'food';
            elseif stimuliCategories(i) == 3
                categoryName{i} = 'people';
            elseif stimuliCategories(i) == 4
                categoryName{i} = 'spatial';
            elseif stimuliCategories(i) == 5
                categoryName{i} = 'animals';
            elseif stimuliCategories(i) == 0 %No stimuli
                categoryName{i} = 'N/A';
            else
                error(['This stimuli category does not exist: ', ... 
                    num2str(stimuliCategories(i)) ,', for this variant: ', ...
                    num2str(variant)])
            end 
        end
        
        
    otherwise 
        error('This variant does not exist: %s', variant)
end 
