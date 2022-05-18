%  tstats = TESTSTATISTICS(X,detectorType,varargin)
%
%  DESCRIPTION
%  Computes the decision statistic for each of the NTESTS audio observations
%  of length NVARIABLES given in the input matrix X using the Neyman-Pearson 
%  (NP) detector DETECTORTYPE. The function returns a NTESTS vector of decision 
%  ("test") statistics.
%  
%  TESTSTATISTICS accepts three types of NP detector: Energy Detector ('ed'),
%  Estimator-Correlator in White Gaussian noise ('ecw'), and Estimator-
%  Correlator in Coloured Gaussian noise ('ecc'). The number of required input
%  variables depends on the type of detector: for 'ed', no extra arguments are
%  necessary; for 'ecw' and 'ecc', the noise variance and the eigen data 
%  structure (generated with EIGENEQUATION) need to be specified.
%
%  The function also includes the property 'DisplayProgress' to show or hide
%  the progress of the calculations, displayed in a wait bar.
%
%  INPUT ARGUMENTS (Fixed)
%  - X: matrix of dimensions [NVARIABLES,NTESTS] containing NTESTS audio data 
%    observations over which the test statistic is to be calculated.
%  - detectorType: type of Neyman-Pearson detector.
%    ¬ 'ed': energy detector.
%    ¬ 'ecw': estimator-correlator in white Gaussian noise.
%    ¬ 'ecc': estimator-correlator in coloured Gaussian noise.
%
%  INPUT ARGUMENTS (Variable, Detector-Dependent)
%  - noiseVars (varargin{1}): vector of expected noise variances. If a scalar,
%    the value is used for all the observations in X.
%  - EigenData (varargin{2}): eigen data structure. Output from EIGENEQUATION.
%
%  INPUT ARGUMENTS (Variable, Property/Value Pairs)
%  - 'DisplayProgress': TRUE for displaying the progress of the calculations.
%     FALSE by default.
%  
%  OUTPUT ARGUMENTS
%  - tstats: vector of test statistics. One value per column in X.
%
%  FUNCTION CALL
%  1. tstats = testStatistics(X,'ed')
%  2. tstats = testStatistics(X,'ecw',noiseVars,EigenData)
%  3. tstats = testStatistics(X,'ecc',noiseVars,EigenData)
%  4. tstats = testStatistics(...,PROPERTYNAME,PROPERTYVALUE)
%     ¬ 'DisplayProgress'
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  See also EIGENEQUATION

%  VERSION 1.1
%  Date: 07 Mar 2022
%  Author: Guillermo Jimenez Arranz
%  - Input NOISEVARS (before NOISEVAR) can be a vector.
%
%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  02 March 2022

function tstats = testStatistics(X,detectorType,varargin)

% Error Control: X
if ~isnumeric(X) || ~ismatrix(X)
    warning('X must be a numeric matrix') 
end

if strcmpi(detectorType,'ed') % "energy" detector (ED)
    % Check Number of Input Arguments
    nFixArg = 2; % number of detector-independent arguments (fixed)
    nDetArg = 0; % number of detector-dependent arguments (variable)
    nProArg = 2; % number of property/value arguments (variable)
    narginchk(nFixArg,nFixArg + nDetArg + nProArg)
    
else % "estimator-correlator" (ECW, ECC)
    nFixArg = 2; % number of detector-independent arguments (fixed)
    nDetArg = 2; % number of detector-dependent arguments (variable)
    nProArg = 2; % number of property/value arguments (variable)
    narginchk(nFixArg,nFixArg + nDetArg + nProArg)
    
    % Error Control: noiseVars
    noiseVars = varargin{1};
    if ~isnumeric(noiseVars) || ~isvector(noiseVars) ...
            || (length(noiseVars) ~= 1 && length(noiseVars) ~= size(X,2))
        error(['NOISEVAR must be a scalar or a numeric vector with as '...
            'many elements as columns in X'])
    end

    % Error Control: EigenData
    EigenData = varargin{2};
    if ~isEigenData(EigenData)
        error('EIGENDATA must be a valid EigenData structure')
    end
    
    % Signal Variances
    signalVars = std(X).^2 - noiseVars;
end

% Verify Number of Property/Value Input Arguments
if rem(nargin - nFixArg - nDetArg,2)
    error('Property/value arguments must come in pairs')
end

% Extract and Verify Input Properties
validProperties = {'displayprogress'};
properties = lower(varargin(nDetArg + 1:2:end));
if any(~ismember(properties,validProperties))
    error('PROPERTY is not recognised')
end

% Default Input Values
displayProgress = false;

% Extract and Verify Input Values
values = varargin(nDetArg + 2:2:end);
nPairs = (nargin - nFixArg - nDetArg)/2; % number of (PROPERTY,VALUE) pairs
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

% General
nTests = size(X,2);
tstats = nan(1,nTests);

% Display Progress (open)
if displayProgress
    h = waitbar(0,'','Name','testStatistics.m'); 
end

switch detectorType
    case 'ed'
        for m = 1:nTests
            % Process Current Test Statistic
            tstats(1,m) = sum(X(:,m).^2);
            
            % Display Progress (if applicable)
            if displayProgress
                messageString = sprintf(['Processing test statistics '...
                    '(%d/%d)'],m,nTests);
                waitbar(m/nTests,h,messageString);
            end
        end
    
    case 'ecw'
        signalEigenValuesNorm = EigenData.signalEigenValuesNorm(:);
        signalEigenVectors = EigenData.signalEigenVectors;
        clear EigenData
        for m = 1:nTests
            % Process Current Test Statistic
            signalEigenValues = signalEigenValuesNorm * signalVars(m);
            weights = signalEigenValues./(signalEigenValues + noiseVars);
            y = signalEigenVectors' * X(:,m); % decorrelated audio segment
            tstats(1,m) = sum(y.^2 .* weights); % decision statistic
            
            % Display Progress (if applicable)
            if displayProgress
                messageString = sprintf(['Processing test statistics '...
                    '(%d/%d)'],m,nTests);
                waitbar(m/nTests,h,messageString);
            end
        end
        
    case 'ecc'
        signalEigenValuesNorm = EigenData.signalEigenValuesNorm(:);
        noiseEigenValues = EigenData.noiseEigenValuesNorm(:) .* noiseVars;
        A = EigenData.noiseEigenVectors * diag(noiseEigenValues.^-0.5);
        D = A * EigenData.signalEigenVectors;
        clear EigenData
        for m = 1:nTests
            % Process Current Test Statistic
            signalEigenValues = signalEigenValuesNorm * signalVars(m);
            weights = signalEigenValues./(signalEigenValues + noiseVars);
            y = D' * X(:,m);
            tstats(1,m) = sum(y.^2 .* weights); 
            
            % Display Progress (if applicable)
            if displayProgress
                messageString = sprintf(['Processing test statistics '...
                    '(%d/%d)'],m,nTests);
                waitbar(m/nTests,h,messageString);
            end
        end
end

if displayProgress
	close(h)
end
