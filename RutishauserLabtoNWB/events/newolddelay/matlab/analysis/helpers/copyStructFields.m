%
%copies a list of fields from a source to a target structure
%
%fields -> cell array of strings. entries in the cell array can also be an other cell array
%with two string entries: src and target. (to rename fields).
%
%i.e. fieldsSrc = {'a1',{'a2','a3'}, {'from','to'})
%
%will copy target.a1=src1 and target.a3=src2.
%
%if fieldsSrc is not supplied, copies all fields in src to target structure.
%
%
%urut/may07
function target = copyStructFields(src,target,fieldsSrc)
if ~isstruct(src)
    warning('src is not a struct - ignore. nothing is copied.');
    return;
end

if nargin==2 
    fieldsSrc=fieldnames(src);
end

for i=1:length(fieldsSrc)
    fieldSrc=fieldsSrc{i};
    
    if iscell(fieldSrc)
        fieldTarget=fieldSrc{2};
        fieldSrc=fieldSrc{1};
    else
        fieldTarget=fieldSrc;
    end
    
    eval([ 'target.' fieldTarget '=' 'src.' fieldSrc ';']);
end