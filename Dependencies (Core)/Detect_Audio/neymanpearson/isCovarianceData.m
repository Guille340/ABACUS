%  isTrue = ISCOVARIANCEDATA(S)
% 
%  DESCRIPTION
%  TRUE if the input structure S is a COVARIANCEDATA structure, FALSE otherwise.
% 
%  For further details about the fields in the COVARIANCEDATA structure see
%  INITIALISECOVARIANCEDATA function.
% 
%  INPUT ARGUMENTS 
%  - S: input structure
% 
%  OUTPUT ARGUMENTS
%  - isTrue: TRUE if S is a RAWSCOREDATA structure
% 
%  FUNCTION CALL
%  isTrue = ISCOVARIANCEDATA(S)
% 
%  FUNCTION DEPENDENCIES
%  - None
% 
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
% 
%  See also INITIALISECOVARIANCEDATA, COVARIANCE
% 
%  VERSION 1.0
%  Date: 04 Mar 2022
%  Author: Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com

function isTrue = isCovarianceData(S)

isTrue = false;

if isstruct(S)
    CovarianceFields_valid = fieldnames(initialiseCovarianceData);
    CovarianceFields = fieldnames(S);
    if all(ismember(CovarianceFields_valid,CovarianceFields)) ...
        && all(ismember(CovarianceFields,CovarianceFields_valid))
        isTrue = true;
    end
end
    