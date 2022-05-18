%  Performance = estimatorCorrelatorPerformance(lambdan,signalVar,...
%      noiseVar,noiseType,cutoffFreqns,varargin)
% 
%  DESCRIPTION
%  Calculates the detection performance parameters of the Neyman-Pearson
%  estimator-correlator detector for a target signal in white (WGN) or coloured
%  (CGN) Gaussian noise.
%
%  ESTIMATORCORRELATORPERFORMANCE analyses the performance of the estimator-
%  correlator given the mean variances of the target signal (SIGNALVAR) and
%  background noise (NOISEVAR). The function does not require the original
%  symmetric, positive-definite matrix over which the eigendata is computed,
%  only its normalised eigenvalues LAMBDAN.
%  
%  ESTIMATORCORRELATORPERFORMANCE returns a structure containing the probability 
%  density function (PDF), the right-tail probability (RTP), and the axis (test
%  statistic) of detection and false alarm. The structure includes additional
%  contextual information such as the type of detector, the signal and noise 
%  variance, the signal-to-noise ratio (SNR), the number of variables and the
%  normalised cutoff frequencies of the detection filter.
%
%  INPUT ARGUMENTS (Fixed)
%  - lambdan: normalised vector of eigenvalues from a symmetric, positive-
%    definite matrix. The mean of LAMBDAN must be equal to 1 (or very close
%    to it). LAMBDAN corresponds to the variable signalEigenValuesNorm from
%    the EigenData structure generated with function EIGENEQUATION. For the 
%    estimator-correlator in white Gaussian noise (NOISETYPE = 'wgn'), LAMBDAN 
%    is the vector of normalised eigenvalues of the covariance matrix of the
%    target signal Cs. For the estimator-correlator in coloured Gaussian noise 
%    (NOISETYPE = 'cgn'), LAMBDAN is the vector of normalised eigenvalues of 
%    the compound signal-noise matrix B = A'*Cs*A, where is the A = Vn*Dn^-0.5 
%    and (Vn,Dn) are the modal and diagonal matrices of the background noise 
%    covariance matrix Cn (see EIGENEQUATION for details).
%  - signalVar: mean variance of the target signal.
%  - noiseVar: mean variance of the background noise.
%  - noiseType: type of background noise according to its spectral response.
%    ¬ 'wgn': white Gaussian noise. Use it with the estimator-correlator in 
%       white Gaussian noise. LAMBDAN = EigenData.signalEigenValuesNorm with 
%       EigenData = EIGENEQUATION(CovarianceSignal,[],...).
%    ¬ 'cgn': coloured Gaussian noise. Use it with the Estimator-Correlator 
%       in coloured Gaussian noise. LAMBDAN = EigenData.signalEigenValuesNorm 
%       with EigenData = EIGENEQUATION(CovarianceSignal,CovarianceNoise,...).
%  - cutoffFreqns: two-element numeric vector containing the normalised 
%    cutoff frequencies of the detection filter (bandpass = [fn1 fn2], 
%    highpass = [fn1 0], lowpass = [0 fn2]). The values must be between 0 
%    and 1. CUTOFFFREQNS = 2*cutoffFreqs/resampleRate, where cutoffFreqs and
%    resampleRate are fields in the configuration file 'audioDetectConfig_
%    NeymanPearson.json'.
%
%  INPUT ARGUMENTS (Variable, Property/Valule Pairs)
%  In a function call: 1. Every property (string) must be followed (separated
%  by comma) by its corresponding value, 2. Property/value pairs are variable
%  input arguments and must be introduced last, 3. Any number of supported 
%  properties can be specified. The function accepts two input properties. 
%  - 'Interpolate': TRUE for the probability curves to be interpolated to a 
%    common x-axis vector. Having a common x-axis is useful for comparing
%    the values of the probability curves at common axis points (e.g., for 
%    generating a Receiver Operating Curve ROC). The property is set to FALSE
%    as default.
%  - 'DisplayProgress': TRUE for displaying the progress of the calculations
%    on a wait bar. The property is set to FALSE as default.
%    
%  OUTPUT ARGUMENTS
%  - Performance: structure containing the following fields.
%    ¬ detectorType: type of detector ('ecw' and 'ecc' for estimator-correlator
%      in "white" and "coloured" Gaussian noise).
%    ¬ signalVariance: mean variance of the target signal.
%    ¬ noiseVariance: mean variance of the background noise.
%    ¬ snrLevel: selected signal-to-noise ratio, in decibels, calculated as 
%      10*log10(SIGNALVARIANCE/NOISEVARIANCE)
%    ¬ nVariables: number of variables (samples) in the data segment (= NDOF).
%    ¬ cutoffFreqns: two-element numeric array specifying the normalised cutoff
%      frequencies of the detection filter (bandpass = [fn1 fn2], highpass = 
%      [fn1 0], lowpass = [0 fn2]). 
%    ¬ axisFalseAlarm: test-statistic axis for the false alarm probability
%      curves PDFFALSEALARM and RTPFALSEALARM.
%    ¬ axisDetection: test-statistic axis for the detection probability curves
%      PDFDETECTION and RTPDETECTION.
%    ¬ pdfFalseAlarm: false alarm probability density function (PDF) curve.
%    ¬ pdfDetection: detection probability density function (PDF) curve.
%    ¬ rtpFalseAlarm: false alarm right-tail probability (RTP) curve.
%    ¬ rtpDetection: detection right-tail probability (RTP) curve.
%
%  CONSIDERATIONS & LIMITATIONS
%  - LAMBDAN can be easily calculated by applying MATLAB's EIG function to the 
%    normalised symmetric, positive-definite matrix (Cs for NOISETYPE = 'wgn', 
%    or B for NOISETYPE = 'cgn'). The normalised matrix is generated from 
%    signal observations and noise observations that have been previously 
%    normalised by their standard deviation. This is equivalent to dividing
%    the covariances matrices of the target signal and background noise by
%    the mean of the entries in their respective diagonals. This normalisation
%    step is currently done twice, in the RAWSCORES and COVARIANCE functions.
%
%  FUNCTION DEPENDENCIES
%  - estimatorCorrelatorFreqLimit
%  - estimatorCorrelatorTimeLimit
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  FUNCTION CALL
%  1. Performance = estimatorCorrelatorPerformance(lambdan,signalVar,...
%        noiseVar,noiseType,cutoffFreqns)
%  2. Performance = estimatorCorrelatorPerformance(...,PROPERTY,VALUE)

%  VERSION 1.2
%  Date: 24 Feb 2022
%  Author: Guillermo Jimenez Arranz
%  - Updated help
%  - Added input argument NOISETYPE to extend the calculation of the detection 
%    performance to the Estimator-Correlator in coloured Gaussian noise ('cgn').
%    Before, only the performance of the Estimator-Correlator in white Gaussian
%    noise ('wgn') was allowed.
%
%  VERSION 1.1
%  Date: 04 May 2021
%  Author: Guillermo Jimenez Arranz
%  - Independent treatment of the detection and false alarm curves and addition
%    of 'Interpolation' property. This new approach reduces the number of 
%    operations needed for the calculation of the false alarm probability 
%    curves. The increases efficiency now permits calculations for any SNR.
%
%  VERSION 1.0
%  Date: 04 May 2021
%  Author: Guillermo Jimenez Arranz
%  Email: gjarranz@gmail.com

function Performance = estimatorCorrelatorPerformance(lambdan,signalVar,...
    noiseVar,noiseType,cutoffFreqns,varargin)

% INPUT ARGUMENTS
% Verify number of Input Arguments
nFixArg = 5;
nProArg = 4;
narginchk(nFixArg,nFixArg + nProArg)
if rem(nargin-5,2)
    error('Variable input arguments must come in pairs (PROPERTY,VALUE)')
end

% Error Control: lambdan
if ~isnumeric(lambdan) || ~isvector(lambdan)
    error('LAMBDAN must be a numeric vector')    
end
if any(lambdan < 0)
    warning(['LAMBDAN contains negative values. The matrix it originates '...
        'from is not positive definite'])
end

% Error Control: signalVar
if ~isnumeric(signalVar) || ~isscalar(signalVar) || signalVar < 0
    error('SIGNALVAR must be a positive number higher than or equal to 0')
end

% Error Control: noiseVar
if ~isnumeric(noiseVar) || ~isscalar(noiseVar) || noiseVar < 0
    error('NOISEVARVAR must be a positive number higher than or equal to 0')
end

% Error Control: noiseType
if ~ischar(noiseType) || ~ismember(lower(noiseType),{'wgn','cgn'})
    error('NOISETYPE is not a valid character string (''wgn'' or ''cgn'')')   
end

% Error Control: cutoffFreqns
if ~isnumeric(cutoffFreqns) || ~isvector(cutoffFreqns) ...
        || numel(cutoffFreqns) ~= 2 || any(cutoffFreqns < 0) ...
        || any(cutoffFreqns > 1)
    error(['CUTOFFFREQNS must be a two-element numeric vector with values '...
        'between 0 and 1'])
end 

% Extract and Verify Input Properties
properties_valid = {'interpolate','displayprogress'};
properties = lower(varargin(1:2:end));
if any(~ismember(properties,properties_valid))
    error('PROPERTY not recognised')
end

% Default Input Values
displayProgress = false;
interpOption = false;

% Extract and Verify Input Values
values = varargin(2:2:end);
nPairs = (nargin - nFixArg)/2; % number of (PROPERTY,VALUE) pairs
for m = 1:nPairs
    property = properties{m};
    switch property % populate with more properties if needed
        case 'interpolate'
            interpOption = values{m};
            if ~islogical(interpOption) && ~any(interpOption == [0 1])
                interpOption = false;
                warning(['Non-supported value for PROPERTY = '...
                    '''Interpolate''. FALSE will be used'])
            end
        case 'displayprogress'
            displayProgress = values{m};
            if ~any(displayProgress == [0 1])
                displayProgress = false;
                warning(['Non-supported value for PROPERTY = '...
                    '''DisplayProgress''. FALSE will be used'])
            end
    end
end

% General
nWeights = length(lambdan); % number of variables
maxBytes = 50 * 1024^2; % maximum size of processing block [Bytes]
snrLevel = 10*log10(signalVar/noiseVar); % signal to noise ratio [dB]
precisionFactor = 2; % precision of probability curves 

% NOTE: for tolerances of 1e-5, 1e-8 and 1e-12 in the RTP curves use
% PRECISIONFACTOR = 1, 1.5 or 2. Those same factors result in a relative 
% amplitude error (max to min) in the PDF curves of 1e-5, 1e-10, 1e-14.

% Detector Type
if strcmpi(noiseType,'wgn')
    detectorType = 'ecw';
else % noiseType = 'cgn'
    detectorType = 'ecc';
end

% Weightings
if strcmpi(noiseType,'wgn')
    lambda = lambdan * signalVar;
    alpha = lambda*noiseVar./(lambda + noiseVar); % "false alarm" weightings
else % noiseType = 'cgn'
    lambda = lambdan * signalVar/noiseVar;
    alpha = lambda./(lambda + 1);
end

% Integration Limits
fmax_lambda = precisionFactor*estimatorCorrelatorFreqLimit(lambdan,...
    signalVar,noiseVar,noiseType,'d','DisplayProgress',false); 
fmax_alpha = precisionFactor*estimatorCorrelatorFreqLimit(lambdan,...
    signalVar,noiseVar,noiseType,'fa','DisplayProgress',false); 
tmax_lambda = precisionFactor*estimatorCorrelatorTimeLimit(lambdan,...
    signalVar,noiseVar,noiseType,'d','TopFrequency',fmax_lambda,...
    'DisplayProgress',false);
tmax_alpha = precisionFactor*estimatorCorrelatorTimeLimit(lambdan,...
    signalVar,noiseVar,noiseType,'fa','TopFrequency',fmax_alpha,...
    'DisplayProgress',false);
% NOTE: FMAX is larger for "false alarm" PDF. TMAX is larger for the
% "detection" PDF.

% Processing Parameters
fres_lambda = 1/tmax_lambda; % frequency resolution
fres_alpha = 1/tmax_alpha; % frequency resolution
tres_lambda = 1/(10*fmax_lambda); % "time" (test statistic) resolution
tres_alpha = 1/(10*fmax_alpha); % "time" (test statistic) resolution
nFreq_lambda = round(2*fmax_lambda/fres_lambda) + 1; % number of frequency points
nFreq_alpha = round(2*fmax_alpha/fres_alpha) + 1; % number of frequency points
nTime_lambda = round(tmax_lambda/tres_lambda) + 1; % number of "time" points
nTime_alpha = round(tmax_alpha/tres_alpha) + 1; % number of "time" points

fprintf('SNR = %0.0f, nFreq = [%d,%d], nTime = [%d,%d]\n',...
    10*log10(signalVar/noiseVar),nFreq_alpha,nFreq_lambda,nTime_alpha,...
    nTime_lambda)

% Display Progress (open)
if displayProgress
    h = waitbar(0,'','Name','estimatorCorrelatorPerformance.m'); 
end

% Calculate Product-Over-Set for LAMBDA (In MAXBYTES blocks)
fd = (0:nFreq_lambda-1)*fres_lambda - fmax_lambda;
nFreqMax = round(maxBytes/(8*nWeights)); % number of frequencies per block
nFreqBlocks = ceil(nFreq_lambda/nFreqMax); % number of frequency blocks
kd = nan(1,nFreq_lambda);
for n = 1:nFreqBlocks
    iFreq1 = (n-1)*nFreqMax + 1;
    iFreq2 = min(n*nFreqMax,nFreq_lambda);
    kd(iFreq1:iFreq2) = prod(1./sqrt(1 - 4*pi*1j*lambda*fd(iFreq1:iFreq2)));
    
    % Display Progress
    if displayProgress
        messageString = sprintf(['Frequency block \\lambda (SNR = '...
            '%0.1f dB, \\sigma_n^2 = %0.1e)'],snrLevel,noiseVar);
        waitbar(n/nFreqBlocks,h,messageString);
    end
end

% Calculate Product-Over-Set for ALPHA (In MAXBYTES blocks)
fa = (0:nFreq_alpha-1)*fres_alpha - fmax_alpha;
nFreqMax = round(maxBytes/(8*nWeights)); % number of frequencies per block
nFreqBlocks = ceil(nFreq_alpha/nFreqMax); % number of frequency blocks
kfa = nan(1,nFreq_alpha);
for n = 1:nFreqBlocks
    iFreq1 = (n-1)*nFreqMax + 1;
    iFreq2 = min(n*nFreqMax,nFreq_alpha);
    kfa(iFreq1:iFreq2) = prod(1./sqrt(1 - 4*pi*1j*alpha*fa(iFreq1:iFreq2)));
    
    % Display Progress
    if displayProgress
        messageString = sprintf(['Frequency block \\alpha (SNR = '...
            '%0.1f dB, \\sigma_n^2 = %0.1e)'],snrLevel,noiseVar);
        waitbar(n/nFreqBlocks,h,messageString);
    end
end

% Calculate Detection Probabilities (In MAXBYTES blocks)    
td = (0:nTime_lambda-1)'*tres_lambda;
nTimeMax = round(maxBytes/(8*nFreq_lambda)); % number of time points per block
nTimeBlocks = ceil(nTime_lambda/nTimeMax); % number of time blocks
pd = nan(nTime_lambda,1);
for n = 1:nTimeBlocks
    iTime1 = (n-1)*nTimeMax + 1;
    iTime2 = min(n*nTimeMax,nTime_lambda);
    pd(iTime1:iTime2) = abs(sum(kd * fres_lambda ...
        .* exp(-1j*2*pi*fd.*td(iTime1:iTime2)),2));    
    
    % Display Progress
    if displayProgress
        messageString = sprintf(['Time block \\lambda (SNR = %0.1f dB, '...
            '\\sigma_n^2 = %0.1e)'],snrLevel,noiseVar);
        waitbar(n/nTimeBlocks,h,messageString);
    end
end
Pd = cumsum(pd*tres_lambda,'reverse'); % right-tail probability (ICDF) of PDF curve

% Calculate False Alarm Probabilities (In MAXBYTES blocks)   
tfa = (0:nTime_alpha-1)'*tres_alpha;
nTimeMax = round(maxBytes/(8*nFreq_alpha)); % number of time points per block
nTimeBlocks = ceil(nTime_alpha/nTimeMax); % number of time blocks
pfa = nan(nTime_alpha,1);
for n = 1:nTimeBlocks
    iTime1 = (n-1)*nTimeMax + 1;
    iTime2 = min(n*nTimeMax,nTime_alpha);
    pfa(iTime1:iTime2) = abs(sum(kfa * fres_alpha ...
        .* exp(-1j*2*pi*fa.*tfa(iTime1:iTime2)),2));   
    
    % Display Progress
    if displayProgress
        messageString = sprintf(['Time block \\alpha (SNR = %0.1f dB, '...
            '\\sigma_n^2 = %0.1e)'],snrLevel,noiseVar);
        waitbar(n/nTimeBlocks,h,messageString);
    end
end
Pfa = cumsum(pfa*tres_alpha,'reverse'); % right-tail probability (ICDF) of PDF curve

% Interpolate Probability Curves to Common Time Vector
if interpOption
    t = [tfa; tfa(end) + tres_alpha; td(td > tfa(end)+tres_alpha)];
    pd = interp1(td,pd,t,'linear','extrap');
    pfa = interp1(tfa,pfa,t,'linear',0);
    Pd = interp1(td,Pd,t,'linear','extrap');
    Pfa = interp1(tfa,Pfa,t,'linear',0);
    
    td = t;
    tfa = t;
end

% Display Progress (close)
if displayProgress, close(h); end

% Build Structure
Performance.detectorType = detectorType;
Performance.signalVariance = signalVar;
Performance.noiseVariance = noiseVar;
Performance.snrLevel = snrLevel;
Performance.nVariables = nWeights;
Performance.cutoffFreqns = cutoffFreqns;
Performance.axisFalseAlarm = tfa;
Performance.axisDetection = td;
Performance.pdfFalseAlarm = pfa;
Performance.pdfDetection = pd;
Performance.rtpFalseAlarm = Pfa;
Performance.rtpDetection = Pd;
