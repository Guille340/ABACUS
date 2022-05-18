%  EigenData = EIGENEQUATION(CovarianceSignal,CovarianceNoise,varargin)
% 
%  DESCRIPTION
%  Calculates the matrix of eigenvectors (modal matrix) and the normalised
%  eigenvalues from one or two symmetric, positive-definite matrices. These 
%  matrices are derived from the input covariance structures of the target 
%  signal (COVARIANCESIGNAL) and background noise (COVARIANCENOISE). The eigen 
%  information is returned in the structure EIGENDATA.
%
%  The content of EIGENDATA depends on what covariance structures are given as
%  input, and this is determined by the type of estimator-correlator that will 
%  use EIGENDATA for detection, that is, the estimator-correlator in white 
%  ('ecw') or coloured ('ecc') Gaussian noise. In  particular, for 'ecw',
%  EIGENDATA contains the eigenvalues and eigenvectors of COVARIANCESIGNAL. 
%  For 'ecc', EIGENDATA contains the eigenvalues and eigenvectors of 
%  COVARIANCENOISE and the eigenvalues and eigenvectors of the compound 
%  signal-noise matrix B = A'*COVARIANCESIGNAL*A, where A = Vn*Dn^-0.5 and 
%  (Vn,Dn) are the modal and diagonal matrices of COVARIANCENOISE. Thus,
%  EIGENDATA contains all the information that, according to Kay's formulation
%  of 'ecw' and 'ecc', is needed to compute the detection performance curves,
%  decorrelate each observation and calculate its test statistic (see Kay, 
%  1998).
%
%  The function includes the option to display the progress with property 
%  'DisplayProgress'.
% 
%  INPUT ARGUMENTS (Fixed)
%  - CovarianceSignal: structure containing the normalised covariance matrix
%    of the target signal (field 'covarianceMatrix'), its duration (field 
%    'kernelDuration') and sampling rate (field 'sampleRate'). Generated with 
%    function COVARIANCE. Always specify COVARIANCESIGNAL ('ecw' and 'ecc').
%  - CovarianceNoise: structure containing the normalised covariance matrix
%    of the background noise (field 'covarianceMatrix'), its duration (field 
%    'kernelDuration') and sampling rate (field 'sampleRate'). Generated with 
%    function COVARIANCE. COVARIANCENOISE only needs to be specified for 'ecc'. 
%    For the 'ecw', set COVARIANCENOISE = [].
%
%  INTPUT ARGUMENTS (Variable, Property/Value Pairs)
%  - 'DisplayProgress': TRUE for displaying the progress of TIMELIMIT. By 
%     default, DISPLAYPROGRESS = TRUE.
%
%  OUTPUT ARGUMENTS
%  - EigenData: structure containing the eigendata required by the estimator
%    correlator in white ('ecw') and coloured ('ecc') Gaussian noise to
%    estimate the performance curves and carry out the detection, as per its
%    formulation.
%    ¬ 'kernelDuration': duration of the observations used to build the
%       covariance matrices COVARIANCESIGNAL and COVARIANCENOISE [s]. The
%       number of variables is equal to ROUND(KERNELDURATION*SAMPLERATE).
%    ¬ 'sampleRate': sample rate of the observations used to build the
%       covariance matrices COVARIANCESIGNAL and COVARIANCENOISE [Hz].
%    ¬ 'noiseType': type of background noise. NOISETYPE = 'wgn' for the 
%       estimator-correlator in white Gaussian noise ('ecw') and NOISETYPE = 
%      'cgn' for the estimator-correlator in coloured Gaussian noise ('ecc').
%    ¬ 'signalEigenVectors': matrix of eigenvectors, organised in columns.
%       For 'ecw', this is the modal matrix of COVARIANCESIGNAL. For 'ecc', 
%       this is the modal matrix of B = A'*COVARIANCESIGNAL*A.
%    ¬ 'signalEigenValuesNorm': vector of normalised eigenvalues of the 
%       eigenvectors in SIGNALEIGENVECTORS. For 'ecw', this is the vector of 
%       normalised eigenvalues of COVARIANCESIGNAL. For 'ecc', this is the 
%       vector of normalised eigenvalues of B = A'*COVARIANCESIGNAL*A.
%    ¬ 'noiseEigenVectors': matrix of eigenvectors, organised in columns.
%       For 'ecw', 'noiseEigenVectors' = []. For 'ecc', this is the modal 
%       matrix of COVARIANCENOISE.
%    ¬ 'noiseEigenValuesNorm': vector of normalised eigenvalues of the
%       eigenvectors in NOISEEIGENVECTORS. For 'ecw', 'noiseEigenValuesNorm' =
%       []. For 'ecc', this is the vector of normalised eigenvalues of 
%       COVARIANCENOISE.
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  FUNCTION CALL
%  1. EigenData = eigenEquation(CovarianceSignal,[])
%  2. EigenData = eigenEquation(CovarianceSignal,CovarianceNoise)
%  2. EigenData = eigenEquation(...,PROPERTY,VALUE)
%     ¬ Properties: 'DisplayProgress'
%
%  REFERENCES
%  - Kay, S.M. (1998). Fundamentals of Statistical Signal Processing - 
%    Volume II, Detection Theory. Prentice Hall.

%  VERSION 1.0
%  Date: 23 Sep 2021
%  Author: Guillermo Jimenez Arranz
%  Email: gjarranz@gmail.com

function EigenData = eigenEquation(CovarianceSignal,CovarianceNoise,...
    varargin)

% INPUT ARGUMENTS
% Verify number of Input Arguments
nFixArg = 2;
nProArg = 2;
narginchk(nFixArg,nFixArg + nProArg)
if rem(nargin - nFixArg,2)
    error('Variable input arguments must come in pairs (PROPERTY,VALUE)')
end

% Extract and Verify Input Properties
validProperties = {'displayprogress'};
properties = lower(varargin(1:2:end));
if any(~ismember(properties,validProperties))
    error('One or more PROPERTY is not recognised')
end

% Default Input Values
displayProgress = false;

% Extract and Verify Input Values
values = varargin(2:2:end);
nPairs = (nargin - nFixArg)/2; % number of (PROPERTY,VALUE) pairs
for m = 1:nPairs
    property = properties{m};
    switch property % populate with more properties if needed
        case 'displayprogress'
            displayProgress = values{m};
            if ~islogical(displayProgress) && ~any(displayProgress == [0 1])
                displayProgress = false;
                warning(['Non-supported value for PROPERTY = '...
                    '''DisplayProgress''. A value of 0 will be used'])
            end
    end
end

% ERROR CONTROL: Covariance Structure
if ~isempty(CovarianceSignal) && ~isCovarianceData(CovarianceSignal)
    error('COVARIANCESIGNAL must be a valid covariance data structure')
end
if ~isempty(CovarianceNoise) && ~isCovarianceData(CovarianceNoise)
    error('COVARIANCENOISE must be a valid covariance data structure')
end

% ERROR CONTROL: Covariance Parameters
if ~isempty(CovarianceNoise)
    if CovarianceSignal.kernelDuration ~= CovarianceNoise.kernelDuration
        error(['KERNELDURATION must be the same for COVARIANCESIGNAL and '...
            'COVARIANCENOISE'])
    end
    if CovarianceSignal.sampleRate ~= CovarianceNoise.sampleRate
        error(['SAMPLERATE must be the same for COVARIANCESIGNAL and '...
            'COVARIANCENOISE'])
    end
end

% COMPUTE MODAL AND DIAGONAL MATRICES
EigenData = initialiseEigenData();

if isempty(CovarianceNoise) % Estimator-Correlator in WGN
    % Display Progress (open)
    if displayProgress
        h = waitbar(0,'Computing eigenvectors and eigenvalues from signal',...
            'Name','eigenEquation.m'); 
    end
    
    % Eigenvectors and Eigenvalues 
    EigenData.kernelDuration = CovarianceSignal.kernelDuration;
    EigenData.sampleRate = CovarianceSignal.sampleRate;
    EigenData.noiseType = 'wgn';
    [EigenData.signalEigenVectors,EigenData.signalEigenValuesNorm] = ...
        eig(CovarianceSignal.covarianceMatrix,'vector'); % modal matrix and vector of eigenvalues of Cs
    EigenData.signalEigenValuesNorm(EigenData.signalEigenValuesNorm < 1e-10) ...
        = 1e-10; % ensure positive-definiteness

    % Display Progress (close)
    if displayProgress
        waitbar(1,h,'Computing eigenvectors and eigenvalues from signal');
        close(h)
    end
else % Estimator-Correlator in CGN
    % Display Progress (open)
    if displayProgress
        h = waitbar(0,'Computing eigenvectors and eigenvalues from noise',...
            'Name','eigenEquation.m'); 
    end
    
    % Eigenvectors and Eigenvalues (noise)
    EigenData.kernelDuration = CovarianceNoise.kernelDuration;
    EigenData.sampleRate = CovarianceNoise.sampleRate;
    EigenData.noiseType = 'cgn';
    [EigenData.noiseEigenVectors,EigenData.noiseEigenValuesNorm] = ...
        eig(CovarianceNoise.covarianceMatrix,'vector'); % modal matrix and vector of eigenvalues of Cn
    EigenData.noiseEigenValuesNorm(EigenData.noiseEigenValuesNorm < 1e-10) = 1e-10; % ensure positive-definiteness
    
    % Display Progress (update)
    if displayProgress
        waitbar(0.5,h,'Computing eigenvectors and eigenvalues from signal');
    end

    % Eigenvectors and Eigenvalues (compound)
    A = EigenData.noiseEigenVectors * diag(EigenData.noiseEigenValuesNorm.^-0.5); % compound noise matrix
    B = A' * CovarianceSignal.covarianceMatrix * A; % compound signal-noise matrix
    B = (B + B')/2; % make matrix strictly symmetric
    [EigenData.signalEigenVectors,EigenData.signalEigenValuesNorm] = ...
        eig(B,'vector'); % modal matrix and vector of eigenvalues of B
    EigenData.signalEigenValuesNorm(EigenData.signalEigenValuesNorm < 1e-10) = 1e-10; % ensure positive-definiteness 
    
    % Display Progress
    if displayProgress
        waitbar(1,h,'Computing eigenvectors and eigenvalues from noise');
        close(h)
    end
end
