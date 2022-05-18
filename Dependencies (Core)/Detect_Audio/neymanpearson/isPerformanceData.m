%  isTrue = ISPERFORMANCEDATA(S)
%
%  DESCRIPTION
%  TRUE if the input structure S is a PERFORMANCEDATA structure, FALSE otherwise.
%
%  For further details about the fields in the PERFORMANCEDATA structure see
%  INITIALISEPERFORMANCEDATA function.
%
%  INPUT ARGUMENTS 
%  - S: input structure
%
%  OUTPUT ARGUMENTS
%  - isTrue: TRUE if S is a RAWSCOREDATA structure
%
%  FUNCTION CALL
%  isTrue = ISPERFORMANCEDATA(S)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  See also INITIALISEPERFORMANCEDATA, ENERGYDETECTORPERFORMANCE,
%  ESTIMATORCORRELATORPERFORMANCE

%  VERSION 1.0
%  Date: 04 Mar 2022
%  Author: Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com

function isTrue = isPerformanceData(S)

isTrue = false;

if isstruct(S)
    PerformanceFields_valid = fieldnames(initialisePerformanceData);
    PerformanceFields = fieldnames(S);
    if all(ismember(PerformanceFields_valid,PerformanceFields)) ...
        && all(ismember(PerformanceFields,PerformanceFields_valid))
        isTrue = true;
    end
end
    