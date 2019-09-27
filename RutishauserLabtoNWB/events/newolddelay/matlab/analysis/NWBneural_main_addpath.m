%
% add all needed subdirectories to path
%
function NWBneural_main_addpath(baseCodePath, basepath)

%  Purpose: 
%         To add export code, analysis code, and New/Old Dataset to 
%         MATLAB path. 
% 
%  Inputs: 
%       - baseCodePath (str) = base path of analysis + export code (e.g.,
%       'C:\svnwork\nwbsharing') 
%       - basepath (str) = base path to New-Old Dataset (e.g.,
%       'C:\Users\chandravadn1\Desktop\code\data\Faraut et al 2018') 
%

% =========================================================================
% =========================================================================

%Check arguments
if ~exist(baseCodePath)
    error('This path does not exist: %s', baseCodePath)
end 

if nargin == 2
    if ~exist(basepath)
        error('This path does not exist: %s', basepath)
    end
end

% ========= Add main code path ======= 
 addpath([baseCodePath]); 

% ========= Add matNWB API to path ===== 
 addpath([baseCodePath, filesep, '3rdParty',filesep, 'matnwb']); 
 
 
 % ==== Add Export Code to path ==== 
 addpath([baseCodePath, filesep, 'events', filesep]); 
 addpath([baseCodePath, filesep, 'events', filesep, 'newolddelay', filesep, 'matlab']); 
 addpath([baseCodePath, filesep, 'events', filesep, 'newolddelay', filesep, 'matlab', filesep, 'export']);
 addpath([baseCodePath, filesep, 'events', filesep, 'newolddelay', filesep, 'matlab', filesep, 'export', filesep, 'helpers']);

 % ==== Add Analysis Code to path ====
 addpath([baseCodePath, filesep, 'events', filesep, 'newolddelay', filesep, ...
     'matlab', filesep, 'analysis']);
  addpath([baseCodePath, filesep, 'events', filesep, 'newolddelay', filesep, ...
     'matlab', filesep, 'analysis', filesep, 'helpers']);
 
 if nargin == 2
     % ==== Add New/Old Dataset to path (native data) =======
     addpath(basepath);
     addpath([basepath, filesep, 'Stimuli']);
     addpath([basepath, filesep, 'Data', filesep, 'events']);
     addpath([basepath, filesep, 'Data', filesep, 'sorted']);
     addpath([basepath, filesep, 'Data']);
     addpath([basepath, filesep, 'Code']);
     addpath([basepath, filesep, 'Code', filesep, 'dataRelease']);
     addpath([basepath, filesep, 'Code', filesep, 'dataRelease',filesep, 'stimFiles']);
 end
 
 

