%  isTrue = ISRAWSCOREDATA(S)
%
%  DESCRIPTION
%  TRUE if the input structure S is a RAWSCOREDATA structure, FALSE otherwise.
%
%  For further details about the fields in the RAWSCOREDATA structure see
%  INITIALISERAWSCOREDATA function.
%
%  INPUT ARGUMENTS 
%  - S: input structure
%
%  OUTPUT ARGUMENTS
%  - isTrue: TRUE if S is a RAWSCOREDATA structure
%
%  FUNCTION CALL
%  isTrue = ISRAWSCOREDATA(S)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  See also INITIALISERAWSCOREDATA, RAWSCORES

%  VERSION 1.0
%  Date: 04 Mar 2022
%  Author: Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com

function isTrue = isRawScoreData(S)

isTrue = false;

if isstruct(S)
    RawScoreFields_valid = fieldnames(initialiseRawScoreData);
    RawScoreFields = fieldnames(S);
    if all(ismember(RawScoreFields_valid,RawScoreFields)) ...
        && all(ismember(RawScoreFields,RawScoreFields_valid))
        isTrue = true;
    end
end
    