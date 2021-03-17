function reset(obj)
%reset will "reset" the class without forcing user to create new instance.
% This method is meant to delete all new information in obj that the user
% may have entered, without actually deleting the class (which would
% require the user to create a new instance of the class).  In other words,
% this method will reset all properties of the class instance obj.  This is
% done by creating a new instance of the class and then copying over all of
% its properties.

% Created by:
%   David J. Schodt (Lidke Lab, 2020)


% Create a new instance of the MIC_Triggerscope class.
TS = MIC_Triggerscope;

% Overwrite class properties in obj with those in TS.
DefaultFields = fieldnames(TS);
ObjFields = fieldnames(obj);
ValidFields = DefaultFields(ismember(DefaultFields, ObjFields));
for ff = 1:numel(ValidFields)
    obj.(ValidFields{ff}) = TS.(ValidFields{ff});
end


end