%
% convert numerical brain area code to string
% this convention is used in brainArea.mat to assign each channel/cell to a brain area
%
%
function descr = translateArea(areaCode)
descr=[];

if length(areaCode)==1
    descr = translateOneArea(areaCode);
else
    for i=1:length(areaCode)
        descr{i}= translateOneArea(areaCode(i));        
    end
end


%-- internal functions
%1=RH, 2=LH, 3=RA, 4=LA
function descr = translateOneArea(areaCode)
switch (areaCode)
    case 1 
        descr='RH';
    case 2
        descr='LH';
    case 3
        descr='RA';
    case 4
        descr='LA';  
    case 13 
        descr='LH';
    case 18 
        descr ='RH';
    otherwise
        descr='N/A';
end