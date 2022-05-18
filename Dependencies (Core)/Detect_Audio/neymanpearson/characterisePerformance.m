%  PerformanceData = CHARACTERISEPERFORMANCE(detectorType,...
%      cutoffFreqns,varargin)
% 
%  DESCRIPTION
%  Calculates the detection performance parameters of the Neyman-Pearson 
%  detector of category DETECTORTYPE for signal-to-noise ratios (SNR) from 
%  -50 dB to 50 dB in 1 dB steps. The function returns a multi-element matrix
%  with as many elements as SNR values (i.e., 101). Each element is generated
%  with function ENERGYDETECTORPERFORMANCE or ESTIMATORCORRELATORPERFORMANCE
%  and contains the detection parameters for one SNR.
%
%  The Energy Detector (DETECTORTYPE = 'ed') requires the number of degrees
%  of freedom (NDOF) and the non-centrality parameter (NCP) for the calculation
%  of the probabilities (density and right-tail) using the non-central Chi-
%  Squared function. The NDOF and NCP correspond to the number of samples 
%  and mean value of the signal to be processed. The Estimator-Correlator
%  (DETECTORTYPE = {'ecw','ecc'}) requires the normalised eigenvalues (LAMBDAN) 
%  derived from the normalised covariance matrices of the target signal and
%  (for 'ecc') the background noise.
%
%  The performance parameters are calculated for a reference background noise
%  variance of 1. Due to the formulation used (Kay, 1998), the probability 
%  curves of DETECTORTYPE = {'ed','ecw'} depend on the noise variance. If the
%  PDF of 'ed' or 'ecw' need to be calculated for noise variances other than 1, 
%  this can easily be done by scaling the PDF. Scaling to other noise variances
%  is done by simply multiplying the x-axis (test statistic) by the noise 
%  variance and dividing the probability density (amplitude of PDF curve)by the 
%  noise variance.
%
%  The normalised cutoff frequencies CUTOFFFREQNS must be specified, as the
%  filtering process alters the performance curves of all three detectors.
%
%  For further details about the computation of detector performance curves,
%  refer to ENERGYDETECTORPERFORMANCE and ESTIMATORCORRELATORPERFORMANCE.
% 
%  INPUT ARGUMENTS (Fixed)
%  - detectorType: character vector specifying the type of Neyman-Pearson
%    detector. There are two options:
%    ¬ 'ed': energy detector. The signal and background noise are assumed to 
%       be White Gaussian Noise (WGN) processes.
%    ¬ 'ecw': estimator-correlator in white Gaussian noise. The signal is 
%       characterised by its covariance matrix and the background noise is 
%       considered a White Gaussian Noise (WGN) process.
%    ¬ 'ecc': estimator-correlator in coloured Gaussian noise. The signal and 
%       the noise are characterised by their respective covariance matrices.
%       The background noise is a Coloured Gaussian Noise (CGN) process.
%  - cutoffFreqns: two-element vector with the normalised cutoff frequencies 
%    of the digital filter used for detection. The values must be between 0 
%    and 1. CUTOFFFREQNS = 2*cutoffFreqs/resampleRate, where cutoffFreqs and 
%    resampleRate are fields in the configuration file 'audioDetectConfig_
%    NeymanPearson.json'.
%
%  INPUT ARGUMENTS (Variable)
%  - ndof (varargin{1}): number of degrees of freedom. This is number of 
%    samples of the signal to be processed. Only for DETECTORTYPE = 'ed'.
%  - ncp (varargin{2}): non-centrality parameter. This is the mean value of
%    the signal to be processed. Only for DETECTORTYPE = 'ed'.
%  - lambdan (varargin{1}): normalised vector of eigenvalues. Computed from
%    the normalised covariance matrix of the target signal. Only for 
%    DETECTORTYPE = {'ecw','ecc'}.
%
%  INPUT ARGUMENTS (Variable, Property/Value Pairs)
%  In the function call, type the property string followed by its value 
%  (comma-separated). Property/value pairs are variable input arguments, and 
%  must be specified after the fixed arguments. The following properties are
%  available.
%  - 'DisplayProgress': TRUE for displaying the function progress. By default, 
%     DISPLAYPROGRESS = TRUE.
%    
%  OUTPUT VARIABLES
%  - PerformanceData: multi-element structure containing the following fields.
%    Each element corresponds to a signal-to-noise ratio from -50 dB to 50 dB
%    calculated in 1 dB steps (101 elements).
%    ¬ detectorType: type of detector ('ed' for energy detector, 'ecw' for
%      estimator-correlator in "white" Gaussian noise, and 'ecc' for estimator-
%      correlator in "coloured" Gaussian noise).
%    ¬ signalVariance: variance of the signal.
%    ¬ noiseVariance: variance of the background noise.
%    ¬ snrLevel: selected signal-to-noise ratio, in decibels, calculated as 
%      10*log10(SIGNALVARIANCE/NOISEVARIANCE).
%    ¬ nVariables: number of variables (samples) in the data segment (= NDOF).
%    ¬ cutoffFreqns: two-element numeric vector containing the normalised 
%      cutoff frequencies of the detection filter (bandpass = [fn1 fn2], 
%      highpass = [fn1 0], lowpass = [0 fn2]). The values must be between 0 
%      and 1. CUTOFFFREQNS = 2*cutoffFreqs/resampleRate, where cutoffFreqs and 
%      resampleRate are fields in the configuration file 'audioDetectConfig_
%      NeymanPearson.json'.
%    ¬ axisFalseAlarm: test-statistic axis for the null hypothesis probability
%      curves PDFFALSEALARM and RTPFALSEALARM.
%    ¬ axisDetection: test-statistic axis for the alternative hypothesis 
%      probability curves PDFDETECTION and RTPDETECTION.
%    ¬ pdfFalseAlarm: null hypothesis probability density function (PDF).
%    ¬ pdfDetection: alternative hypothesis probability density function (PDF).
%    ¬ rtpFalseAlarm: false alarm right-tail probability (RTP) function.
%    ¬ rtpDetection: detection right-tail probability (RTP) function.
%
%  FUNCTION DEPENDENCIES
%  - energyDetectorPerformance
%  - estimatorCorrelatorPerformance
%
%  FUNCTION CALL
%  1. PerformanceData = characterisePerformance('ed',cutoffFreqns,ndof,ncp)
%  2. PerformanceData = characterisePerformance('ecw',cutoffFreqns,lambdan)
%  3. PerformanceData = characterisePerformance('ecc',cutoffFreqns,lambdan)
%  3. PerformanceData = characterisePerformance(...,PROPERTY,VALUE)
%     PROPERTIES: 'DisplayProgress'

%  VERSION 1.0
%  Date: 23 Sep 2021
%  Author: Guillermo Jimenez Arranz
%  Email: gjarranz@gmail.com

function PerformanceData = characterisePerformance(detectorType,...
    cutoffFreqns,varargin)

% INPUT ARGUMENTS
% Error Control: detectorType
if ~ischar(detectorType) || ~ismember(lower(detectorType),{'ed','ecw','ecc'})
    error('Non-supported string for DETECTORTYPE.')
end

% Error Control: cutoffFreqns
if ~isnumeric(cutoffFreqns) || ~isvector(cutoffFreqns) ...
        || length(cutoffFreqns) ~= 2 || any(cutoffFreqns < 0) ...
        || any(cutoffFreqns > 1)
    cutoffFreqns = [0 1];
    warning(['CUTOFFFREQNS must be a two-element numeric vector '...
        'with values between 0 and 1. CUTOFFFREQNS = [0 1] will be used']) 
end

if strcmpi(detectorType,'ed') % "energy" detector (ED)
    % Check Number of Input Arguments
    narginchk(4,6)
    nFixArg = 2; % number of detector-independent arguments (fixed)
    nDetArg = 2; % number of detector-dependent arguments (variable)
    nProArg = nargin - nFixArg - nDetArg; % number of property/value arguments (variable)
    
    % Error Control: ndof
    ndof = varargin{1};
    if ~isnumeric(ndof) || ~isscalar(ndof) || ndof < 1 || rem(ndof,1)
        error(['NDOF must be a non-decimal number larger than 0. '...
            'The detector performance will not be processed'])
    end
    
    % Error Control: ncp
    ncp = varargin{2};
    if ~isnumeric(ncp) || ~isscalar(ncp) || ncp < 0
        ncp = 0;
        warning(['NCP must be a positive number higher than or equal to 0. '...
            'NCP = %0.1f will be used'],ncp)
    end
    
else % "estimator-correlator" (ECW, ECC)
    narginchk(3,5)
    nFixArg = 2; % number of detector-independent arguments (fixed)
    nDetArg = 1; % number of detector-dependent arguments (variable)
    nProArg = nargin - nFixArg - nDetArg; % number of property/value arguments (variable)
        
    % Error Control: lambdan
    lambdan = varargin{1};
    if ~isnumeric(lambdan) || ~isvector(lambdan)
        error('LAMBDAN must be a numeric vector.')
    end
    
    % Determine Noise Type
    if strcmpi(detectorType,'ecw')
        noiseType = 'wgn';
    else % detectorType == 'ecc'
        noiseType = 'cgn';
    end
end

% Verify Number of Property/Value Input Arguments
if rem(nProArg,2)
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
nPairs = nProArg/2; % number of (PROPERTY,VALUE) pairs
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

% DETECTION PERFORMANCE CURVES
% Display Progress (open)
if displayProgress
    h = waitbar(0,'','Name','detectorPerformance.m'); 
end

% Initialise Detector Performance Structure
Performance_empty = initialisePerformanceData();

% Compute Detector Performance for the Specified SNR Levels
noiseVar_ref = 1;
noiseStd_ref = 1;
snrLevels = -50:1:50;
nSnr = length(snrLevels);
PerformanceData = repmat(Performance_empty,1,nSnr);
for n = 1:nSnr    
    % Signal and Noise Variance
    signalStd = noiseStd_ref * 10^(snrLevels(n)/20); % obtain this value from the processed segment
    signalVar = signalStd^2;

    % Detector Performance
    switch detectorType
        case 'ed' % "energy" detector (ED)
            PerformanceData(n) = energyDetectorPerformance(ndof,ncp,...
                signalVar,noiseVar_ref,cutoffFreqns,'Interpolate',true);
            
        case {'ecw','ecc'} % "estimator-correlator" (EC)
            PerformanceData(n) = estimatorCorrelatorPerformance(lambdan,...
                signalVar,noiseVar_ref,noiseType,cutoffFreqns,...
                'Interpolate',true);
    end
    
    % Display Progress
    if displayProgress
        messageString = sprintf(['Computing detector performance (SNR = '...
            '%0.1f dB)'],snrLevels(n));
        waitbar(n/nSnr,h,messageString);
    end
end

% Display Progress (close)
if displayProgress, close(h); end
