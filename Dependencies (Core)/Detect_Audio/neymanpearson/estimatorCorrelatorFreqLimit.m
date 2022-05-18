%  fmax = ESTIMATORCORRELATORFREQLIMIT(lambdan,signalVar,noiseVar,...
%     noiseType,pdfType,varargin)
%
%  DESCRIPTION
%  Calculates the top frequency limit for the computation of the probability
%  density curves of a Neyman-Pearson "estimator-correlator" detector in
%  white or "coloured" Gaussian noise (NOISETYPE = 'wgn' or NOISETYPE = 'ecc').
%
%  The detection performance of an Neyman-Pearson "estimator-correlator"
%  detector for signals of specific covariance in white Gaussian noise (WGN) 
%  or in coloured Gaussian noise (CGN) is given by two infinite double-
%  integrals (time and frequency integration): one for the probability of false
%  alarm (Pfa) and one for the probability of detection (Pd). 
%
%  In order to compute the detection performance curves and the Receiver 
%  Operating Characteristic (ROC), the infinite integrals must be approximated 
%  to a finite sum. Results show that probability curves can be accurately 
%  computed with defined integrals. 
%
%  FREQLIMIT calculates the top frequency integration limit for the probability
%  density function (PDF) that results in a minimum error in the right-tail 
%  probability. The bottom limit of the integral is FMIN = -FMAX. FREQLIMIT 
%  calculates the frequency at which the PDF amplitude last-exceeds a value 
%  AMPRATIO times lower than its maximum. The maximum amplitude is always 1. 
%  A relative amplitude AMPRATIO = 1e4 is used by default.
%
%  The calculations are performed on the "detection" or the "false alarm" PDF 
%  depending on the type of PDF selected with PDFTYPE ('d' or 'fa').
%
%  INPUT ARGUMENTS
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
%    covariance matrix Cn (see EIGENEQUATION for details). For further details,
%    see Kay (1998), Ex 5.3 (p. 147-151), Ex 5.11 (p. 178) and Appendix 5A 
%   (p. 183-185).
%  - signalVar: mean variance of the target signal.
%  - noiseVar: mean variance of the background noise.
%  - noiseType: type of background noise according to its spectral response.
%    ¬ 'wgn': white Gaussian noise. Use it with the estimator-correlator in 
%       white Gaussian noise. LAMBDAN = EigenData.signalEigenValuesNorm with 
%       EigenData = EIGENEQUATION(CovarianceSignal,[],...).
%    ¬ 'cgn': coloured Gaussian noise. Use it with the Estimator-Correlator 
%       in coloured Gaussian noise. LAMBDAN = EigenData.signalEigenValuesNorm 
%       with EigenData = EIGENEQUATION(CovarianceSignal,CovarianceNoise,...).
%  - pdfType: type of probability density function for which FMAX is computed.
%    ¬ 'd': detection PDF
%    ¬ 'fa': false alarm PDF.
%
%  INPUT PROPERTIES
%  In a function call: 1. Every property (string) must be followed (separated
%  by comma) by its corresponding value, 2. Property/value pairs are variable
%  input arguments and must be introduced last, 3. Any number of supported 
%  properties can be specified. The function accepts two input properties. 
%  - 'DisplayProgress': TRUE to display the progress of FREQLIMIT. FALSE 
%      otherwise (DEFAULT).
%  - 'AmplitudeRatio': numeric value between 0 and 1. This is the relative 
%    amplitude betweeen the maximum of the PDF (1) and the amplitude at which 
%    the top frequency integration limit is defined. AMPRATIO = 1e4 (DEFAULT). 
%    It is recommended to use the default value of 1e4. A lower value may 
%    result in a function error, and a larger value will affect the accuracy 
%    of the right-tail probability.
%   
%  OUTPUT ARGUMENTS
%  - fmax: top frequency limit of the probability density PDFTYPE. Use -FMAX 
%    and FMAX as the bottom and top limits of the infinite time integral in 
%    the estimator-correlator's formula for the PDF.
%
%  CONSIDERATIONS & LIMITATIONS
%  - The property 'AmplitudeRatio' is an advanced parameter that affects the 
%    performance and accuracy of the results. This property has been included 
%    for test purposes. Using the DEFAULT value is strongly recommended.
%  - Finding an optimal value for the frequency limits is critical. A value 
%    that is too large will increase the computation time of the PDF 
%    considerably. A low value will remove a significant portion of the vector 
%    to which the Fourier transform is applied, resulting in spurious secondary
%    lobes accompanying the main lobe in the PDF. This effect can be seen as 
%    the sync-like response in time that results from applying an ideal filter 
%    in frequency (rectancular window).
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  FUNCTION CALL
%  1. fmax = freqLimit(lambdan,signalVar,noiseVar,noiseType,pdfType)
%  2. fmax = freqLimit(...,PROPERTY,VALUE)
%     Properties: 'DisplayProgress', 'AmplitudeRatio'
%
%  REFERENCES
%  Kay, S.M. (1998). Fundamentals of Statistical Signal Processing - Volume II, 
%   Detection Theory". Prentice Hall

%  VERSION 2.0
%  Date: 16 Mar 2022
%  Author: Guillermo Jimenez Arranz
%  - Replaced the input WEIGHT with a more specific set of variables, including
%    LAMBDAN, SIGNALVAR, NOISEVAR, NOISETYPE and PDFTYPE. The purpose is to
%    use these parameters to make a more accurate estimate of the maximum
%    frequency, based on the mean value of the test statistic or "peak" in the
%    PDF. Before, FMAX was calculated as 20/k, where k = (mean(WEIGHT) * 
%    ndof^0.78). That gave inaccurate results when the covariance matrix
%    from which LAMBDAN is obtained was badly conditioned.
%
%  VERSION 1.0
%  Date: 04 May 2021
%  Author: Guillermo Jimenez Arranz
%  Email: gjarranz@gmail.com

function fmax = estimatorCorrelatorFreqLimit(lambdan,signalVar,noiseVar,...
    noiseType,pdfType,varargin)

% INPUT ARGUMENTS
% Verify number of Input Arguments
narginchk(5,9)

% Verify Number of Variable Input Arguments
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

% Error Control: pdfType
if ~ischar(pdfType) || ~ismember(lower(pdfType),{'fa','d'})
    error('PDFTYPE is not a valid character string (''fa'' or ''d'')')   
end

% Extract and Verify Input Properties
validProperties = {'displayprogress','amplituderatio'};
properties = lower(varargin(1:2:end));
if any(~ismember(properties,validProperties))
    error('One or more PROPERTY is not recognised')
end

% Default Input Values
displayProgress = false;
ampRatio = 1e4;

% Extract and Verify Input Values
values = varargin(2:2:end);
nPairs = (nargin - 5)/2; % number of (PROPERTY,VALUE) pairs
for m = 1:nPairs
    property = properties{m};
    switch property % populate with more properties if needed
        case 'displayprogress'
            displayProgress = values{m};
            if ~islogical(displayProgress) && ~any(displayProgress == [0 1])
                displayProgress = 0;
                warning(['Non-supported value for PROPERTY = '...
                    '''DisplayProgress''. ''DisplayProgress'' = 0 '...
                    '0 will be used'])
            end
        case 'amplituderatio'
            ampRatio = values{m};
            if ~isnumeric(ampRatio) || numel(ampRatio) > 1 || ...
                    ampRatio <= 0 || ampRatio > 1
                ampRatio = 1e4;
                warning(['Non-supported value for PROPERTY = '...
                    '''AmplitudeRatio''. A value of 1e4 will be used'])
            end
    end 
end

% Compute LAMBDA and ALPHA for PDF Calculation
if strcmpi(noiseType,'wgn')
    lambda = lambdan * signalVar;
    alpha = lambda*noiseVar./(lambda + noiseVar); % "false alarm" weightings
else % noiseType = 'cgn'
    lambda = lambdan * signalVar/noiseVar;
    alpha = lambda./(lambda + 1);
end

% Select Appropriate Weights
if strcmpi(pdfType,'fa')
    weight = alpha(:);
else
    weight = lambda(:);
end

% Estimate FMAX
ndof = length(weight); % no. of degrees of freedom (= no. weights)
if strcmp(noiseType,'wgn') % 'ecw' detector
    if strcmp(pdfType,'fa') % false alarm PDF ('fa')
        tmean = ndof * signalVar*noiseVar/(signalVar + noiseVar);  
    else % detection PDF ('d')
        tmean = ndof * signalVar;
    end 
else % 'ecc' detector
    if strcmp(pdfType,'fa') % false alarm PDF ('fa')
        tmean = ndof * signalVar/(signalVar + noiseVar);  
    else % detection PDF ('d')
        tmean = ndof * signalVar/noiseVar;
    end 
end
fmax = 20/tmean;

% PROCESSING PARAMETERS
nFreq = 501; % no. frequencies samples for slicing 
maxBytes = 50 * 1024^2; % maximum size of processing block [Bytes]

% FIND MAXIMUM FREQUENCY (Rough)
kMax = 1; % maximum absolute amplitude of product-over-set
f1 = 0; % initialise start frequency (frequency at kMax)
f2 = fmax; % initialise top frequency limit
minReached = false;
cnt = 0;
if displayProgress, fprintf('Finding frequency integration interval (rough) '); end
while ~minReached
    % Calculate Product-Over-Set
    f = (0:nFreq-1)*(f2-f1)/(nFreq-1) + f1; % frequency vector     
    nFreqMax = round(maxBytes/(8*ndof)); % number of freq points in proc block
    nFreqBlocks = ceil(nFreq/nFreqMax); % number of processing blocks
    k = nan(1,nFreq); % initialise product-over-set
    for n = 1:nFreqBlocks
        iFreq1 = (n-1)*nFreqMax + 1;
        iFreq2 = min(n*nFreqMax,nFreq);
        k(iFreq1:iFreq2) = abs(prod(1./sqrt(1 - 4*pi*1j*weight.*f(iFreq1:iFreq2))));
    end

    % Error
    kMin = k(end);
    minReached = kMax/kMin > ampRatio;
    f2 = f2 * 5^cnt; % increase fmax in power-of-five steps
    cnt = cnt + 1;
end
if displayProgress, fprintf('[%s]\n',datestr(now,'dd-mmm-yyyy HH:MM:SS')); end

% FIND FREQUENCY FOR SPECIFIC AMPLITUDE RELATIVE TO MAXIMUM (Fine)
kMin = kMax/ampRatio; % target amplitude of product-over-set
tolFactor = 1e-5; % tolerance factor
err = Inf; % error value
if displayProgress, fprintf('Finding frequency integration interval (fine) '); end
while err > tolFactor
    % Calculate Product-Over-Set
    f = (0:nFreq-1)*(f2-f1)/(nFreq-1) + f1; % frequency vector     
    nFreqMax = round(maxBytes/(8*ndof)); % number of freq points in proc block
    nFreqBlocks = ceil(nFreq/nFreqMax); % number of processing blocks
    k = nan(1,nFreq); % initialise product-over-set
    for n = 1:nFreqBlocks
        iFreq1 = (n-1)*nFreqMax + 1;
        iFreq2 = min(n*nFreqMax,nFreq);
        k(iFreq1:iFreq2) = abs(prod(1./sqrt(1 - 4*pi*1j*weight.*f(iFreq1:iFreq2))));
    end

    % Find Closest Value and Right/Left Boundaries
    vec = k - kMin; 
    [~,iMin] = min(abs(vec));
    kMin0 = k(iMin); % minimum of current sector of product-over-set
    i1 = max(iMin-1,1);
    i2 = min(iMin+1,nFreq);
    f1 = f(i1);
    f2 = f(i2);

    % Error
    err = abs(kMin - kMin0);
end
if displayProgress, fprintf('[%s]\n',datestr(now,'dd-mmm-yyyy HH:MM:SS')); end
fmax = f(iMin); % top frequency integration limit
