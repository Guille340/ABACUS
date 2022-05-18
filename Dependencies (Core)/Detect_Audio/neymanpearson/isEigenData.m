%  isTrue = ISEIGENDATA(S)
%
%  DESCRIPTION
%  TRUE if the input structure S is a EIGENDATA structure, FALSE otherwise.
%
%  For further details about the fields in the EIGENDATA structure see
%  INITIALISEEIGENDATA function.
%
%  INPUT ARGUMENTS 
%  - S: input structure
%
%  OUTPUT ARGUMENTS
%  - isTrue: TRUE if S is a RAWSCOREDATA structure
%
%  FUNCTION CALL
%  isTrue = ISEIGENDATA(S)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  See also INITIALISEEIGENDATA, EIGENEQUATION

%  VERSION 1.0
%  Date: 04 Mar 2022
%  Author: Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com

function isTrue = isEigenData(S)

isTrue = false;

if isstruct(S)
    EigenFields_valid = fieldnames(initialiseEigenData);
    EigenFields = fieldnames(S);
    if all(ismember(EigenFields_valid,EigenFields)) ...
        && all(ismember(EigenFields,EigenFields_valid))
        isTrue = true;
    end
end
    