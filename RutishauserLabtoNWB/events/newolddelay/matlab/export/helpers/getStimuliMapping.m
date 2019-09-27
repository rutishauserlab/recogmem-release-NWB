%% Get Stimuli Mapping for Correct variant

function [stimuliMapping] = getStimuliMapping(basepath, variant) 


   switch variant
       case 1 %variant 1
           stimuliMapping = [basepath, filesep, 'Code', filesep, 'dataRelease', ...
               filesep, 'stimFiles', filesep, 'newOldDelayStimuli.mat'];
           if ~exist(stimuliMapping) 
               error('This file does not exist: %s', stimuliMapping)
           else 
               load(stimuliMapping);
           end 
           
       case 2 %variant 2
           stimuliMapping = [basepath, filesep, 'Code', filesep, 'dataRelease', ...
               filesep, 'stimFiles', filesep, 'newOldDelayStimuli2.mat'];
           if ~exist(stimuliMapping) 
               error('This file does not exist: %s', stimuliMapping)
           else 
               load(stimuliMapping);
           end 
           
       case 3 %variant 3
           stimuliMapping = [basepath, filesep, 'Code', filesep, 'dataRelease', ...
               filesep, 'stimFiles', filesep, 'newOldDelayStimuli3.mat'];
           if ~exist(stimuliMapping) 
               error('This file does not exist: %s', stimuliMapping)
           else 
               load(stimuliMapping);
           end 
           
       otherwise
           error(['Incorrect variant, check variant. This was the variant:  ', num2str(variant)])
   end 
   
       fileMapping = fileMapping';
       
       %Modify stimuliMapping
       for st = 1:length(fileMapping)
       
           %C:\Users\chandravadn1\Desktop\code\data\Faraut et al 2018\Stimuli\newolddelay\houses
           stimDefaultDirect = cell2mat(fileMapping(st));
           IndexOfSlash = strfind(stimDefaultDirect, '\');
           
           %Get correct subdirectories 
           code = stimDefaultDirect((IndexOfSlash(end-2)):IndexOfSlash(end-1));
           removeSlash_code = strfind(code, '\');
           code(removeSlash_code) = [];
          
           
           
           newolddelay = stimDefaultDirect((IndexOfSlash(end-1)):IndexOfSlash(end));
           removeSlash_newolddelay = strfind(newolddelay, '\');
           newolddelay(removeSlash_newolddelay) = [];
           
           image = stimDefaultDirect(IndexOfSlash(end):end);
           removeSlash_image = strfind(image, '\');
           image(removeSlash_image) = [];
           
           %Assign subdirectories to fileMapping 
           fileMapping{st, 1} = code;
           fileMapping{st, 2} = newolddelay;
           fileMapping{st, 3} = image;
       end 
       
       stimuliMapping = fileMapping;
end 
  
   
   