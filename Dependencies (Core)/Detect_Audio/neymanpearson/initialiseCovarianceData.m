%  CovarianceData = initialiseCovarianceData()
%
%  DESCRIPTION
%  Initialises the covariance data structure COVARIANCEDATA. All the fields 
%  in this structure are set as empty ([]). Function COVARIANCE generates a 
%  populated version of COVARIANCEDATA (i.e., with non-empty values).
%
%  The fields in COVARIANCEDATA are described below.
%
%  COVARIANCEDATA
%  ==============
%  ¬ 'kernelDuration': duration of raw score observations used to build the
%     covariance matrix [s].
%  ¬ 'sampleRate': sampling rate, after resampling, of the raw score
%     observations used to build the covariance matrix [Hz].
%  ¬ 'covarianceMatrix': normalised covariance matrix built from the raw
%     scores training data. This is a square matrix with as many rows and 
%     columns as variables (audio samples). The values are single-precision.
%
%  INPUT ARGUMENTS
%  - None
%
%  OUTPUT ARGUMENTS
%  - CovarianceData: initialised covariance data structure.
%
%  FUNCTION CALL
%  CovarianceData = initialiseCovarianceData()
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  04 Mar 2022

function CovarianceData = initialiseCovarianceData()

CovarianceData = struct('kernelDuration',[],'sampleRate',[],...
    'covarianceMatrix',[]);
