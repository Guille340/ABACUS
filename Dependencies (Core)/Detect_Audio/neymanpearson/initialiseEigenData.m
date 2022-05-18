%  EigenData = INITIALISEEIGENDATA()
%
%  DESCRIPTION
%  Initialises the eigen data structure EIGENDATA. All the fields in this 
%  structure are set as empty ([]). Function EIGENEQUATION generates a 
%  populated version of EIGENDATA (i.e., with non-empty values).
%
%  The fields in EIGENDATA are described below.
%
%  EIGENDATA
%  =========
%  - 'kernelDuration': duration of the observations used to build the
%     covariance matrices COVARIANCESIGNAL and COVARIANCENOISE [s]. The
%     number of variables is equal to ROUND(KERNELDURATION*SAMPLERATE).
%  - 'sampleRate': sample rate of the observations used to build the
%     covariance matrices COVARIANCESIGNAL and COVARIANCENOISE [Hz].
%  - 'noiseType': type of background noise. NOISETYPE = 'wgn' for the 
%     estimator-correlator in white Gaussian noise ('ecw') and NOISETYPE = 
%     'cgn' for the estimator-correlator in coloured Gaussian noise ('ecc').
%  - 'signalEigenVectors': matrix of eigenvectors, organised in columns.
%     For 'ecw', this is the modal matrix of COVARIANCESIGNAL. For 'ecc', 
%     this is the modal matrix of B = A'*COVARIANCESIGNAL*A.
%  - 'signalEigenValuesNorm': vector of normalised eigenvalues of the 
%     eigenvectors in SIGNALEIGENVECTORS. For 'ecw', this is the vector of 
%     normalised eigenvalues of COVARIANCESIGNAL. For 'ecc', this is the 
%     vector of normalised eigenvalues of B = A'*COVARIANCESIGNAL*A.
%  - 'noiseEigenVectors': matrix of eigenvectors, organised in columns.
%     For 'ecw', 'noiseEigenVectors' = []. For 'ecc', this is the modal 
%     matrix of COVARIANCENOISE.
%  - 'noiseEigenValuesNorm': vector of normalised eigenvalues of the
%     eigenvectors in NOISEEIGENVECTORS. For 'ecw', 'noiseEigenValuesNorm' =
%     []. For 'ecc', this is the vector of normalised eigenvalues of 
%     COVARIANCENOISE.
%
%  INPUT ARGUMENTS
%  - None
%
%  OUTPUT ARGUMENTS
%  - EigenData: initialised eigen data structure
%
%  FUNCTION CALL
%  EigenData = initialiseEigenData()
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  02 Mar 2022

function EigenData = initialiseEigenData()

EigenData = struct('kernelDuration',[],'sampleRate',[],'noiseType',[],...
    'signalEigenVectors',[],'signalEigenValuesNorm',[],...
    'noiseEigenVectors',[],'noiseEigenValuesNorm',[]);

