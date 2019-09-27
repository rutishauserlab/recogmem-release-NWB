%
% gets the value of a variable in a struct if the field exists; if not, the default value is assigned.
% helper function to read parameters from structs
%
% uses dynamic field names
%
%urut/sept08
function val = copyFieldIfExists( s, fieldname, default )

if isfield(s,fieldname) 
    val = s.(fieldname);   %a dynamic field name instead of eval
else
    val=default;
end