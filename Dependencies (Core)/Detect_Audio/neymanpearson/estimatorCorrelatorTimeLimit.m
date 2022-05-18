%  tmax = ESTIMATORCORRELATORTIMELIMIT(lambdan,signalVar,noiseVar,...
%     noiseType,pdfType,varargin)
%
%  DESCRIPTION
%  Calculates the top time limit for the computation of the probability density 
%  curves of a Neyman-Pearson "estimator-correlator" in white or "coloured" 
%  Gaussian noise (NOISETYPE = 'wgn' or NOISETYPE = 'ecc'). The "time" term is 
%  used here to draw a parallelism between the frequency and the time variable, 
%  but note that the "time" actually refers to the test statistic.
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
%  TIMELIMIT calculates the top time integration limit of the probability 
%  density function (PDF) that results in a minimum error in the total right-
%  tail probability. The bottom limit of the integral is TMIN = 0. TIMELIMIT 
%  first finds the maximum of the time-dependent PDF, to then calculate the 
%  time at which the amplitude last-exceeds a value AMPRATIO times lower than 
%  the maximum. A relative amplitude AMPRATIO = 1e4 is used by default.
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
%  - 'DisplayProgress': TRUE to display the progress of TIMELIMIT. FALSE 
%    otherwise (DEFAULT).
%  - 'TopFrequency': number higher than 0. TOPFREQUENCY represents the top 
%    limit for the double-sided infinite frequency integral of the detection
%    performance formulas, as defined in Kay (1998, p.157). The bottom limit 
%    is -FMAX. A value FMAX = 5/(MEAN(WEIGHT)*LENGTH(WEIGHT)^0.78) is used by 
%    default. Use the output from FREQLIMIT or the default value. If a 
%    different value is used, make sure it is not much larger than the default 
%    (that will increase the computation time considerably) or much lower than 
%    the default (that will affect the accuracy of the PDF curve).
%  - 'AmplitudeRatio': numeric value between 0 and 1. This is the relative 
%    amplitude betweeen the maximum of the PDF and the amplitude at which the 
%    top time integration limit is defined. AMPRATIO = 1e4 (DEFAULT). It is 
%    recommended to use the default value of 1e4. A lower value may result in 
%    a function error, and a larger value will affect the accuracy of the 
%    right-tail probability.
%   
%  OUTPUT ARGUMENTS
%  - tmax: top time limit of the probability density PDFTYPE. Use TMAX as the
%    limit of the infinite time integral in the estimator-correlator's formula
%    for the PDF.
%
%  CONSIDERATIONS & LIMITATIONS
%  - The property 'AmplitudeRatio' is an advanced parameter that affects the 
%    performance and accuracy of the results. This property has been included 
%    for test purposes. Using the DEFAULT value is strongly recommended.
%  - The property 'TopFrequency' is an advanced parameter that affects the 
%    performance and accuracy of the results. Using the DEFAULT value or the 
%    output from FREQLIMIT is strongly recommended.
%  - Finding an optimal value for the top time limit is critical. A value that 
%    is too large will increase the computation time of the PDF considerably. 
%    A low value will remove a significant portion of the PDF, resulting in 
%    considerable time aliasing. 
%  - Time aliasing is an unavoidable effect that appears when trying to compute
%    the infinite frequency integral over a Gaussian PDF of infinite width. 
%    There are two main causes for noticeable time aliasing: 1. Large frequency 
%    resolution step, and 2. Small time integration limit. Time aliasing from 
%    the first cause can be avoided by choosing a frequency resolution step 
%    that is lower than or equal to the inverse of the top time integration 
%    limit (FRES <= 1/TMAX); in TIMELIMIT and ESTIMATORCORRELATORPERFORMANCE, 
%    the frequency resolution step is set to FRES = 1/TMAX. The time-aliasing 
%    from the second cause is minimised by choosing an AMPRATIO = 1e4, meaning 
%    that any error in the PDF associated with time aliasing will be of the 
%    magnitude of AMPRATIO.
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  FUNCTION CALL
%  1. tmax = estimatorCorrelatorTimeLimit(lambdan,signalVar,noiseVar,...
%        noiseType,pdfType)
%  2. tmax = estimatorCorrelatorTimeLimit(...,PROPERTY,VALUE)
%     Properties: 'DisplayProgress', 'TopFrequency', 'AmplitudeRatio'
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
%    PDF. Before, TMAX was calculated as 50*k, where k = (mean(WEIGHT) * 
%    ndof^0.78). That gave inaccurate results when the covariance matrix
%    from which LAMBDAN is obtained was badly conditioned.
%
%  VERSION 1.1
%  Date: 24 Feb 2022
%  Author: Guillermo Jimenez Arranz
%  - Small update to the help.
%
%  VERSION 1.0
%  Date: 04 May 2021
%  Author: Guillermo Jimenez Arranz
%  Email: gjarranz@gmail.com

function tmax = estimatorCorrelatorTimeLimit(lambdan,signalVar,noiseVar,...
    noiseType,pdfType,varargin)

% INPUT ARGUMENTS
% Verify number of Input Arguments
narginchk(5,11)

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
validProperties = {'displayprogress','topfrequency','amplituderatio'};
properties = lower(varargin(1:2:end));
if any(~ismember(properties,validProperties))
    error('One or more PROPERTY is not recognised')
end

% Estimate Mean Value of Test Statistic
ndof = length(lambdan); % no. of degrees of freedom (= no. weights)
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

% Default Input Values
fmax = 20/tmean;
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
                    '''DisplayProgress''. A value of 0 will be used'])
            end
        case 'topfrequency'
            fmax = values{m};
            if ~isnumeric(fmax) || numel(fmax) > 1 || fmax <= 0 
                fmax = 20/tmean;
                warning(['Non-supported value for PROPERTY = '...
                    '''topfrequency''. A value of %0.3e will be used'],fmax)
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

% PROCESSING PARAMETERS
nTime = 501; % number of time samples for slicing
% tmax = 50 * tmean; % estimated maximum test statistic
tmax = 1000/fmax; % estimated max test stat (tmax ~50*tmean, fmax ~20*tmean => fmax*tmax = 1000)
fres = 1/tmax; % frequency resolution step
nFreq = round(2*fmax/fres) + 1; % number of frequency points
maxBytes = 50 * 1024^2; % maximum size of processing block [Bytes]

% CALCULATE PRODUCT OVER SET
f1 = -fmax; % bottom limit of frequency integral
f2 = fmax; % top limit of frequency integral
f = (0:nFreq-1)*(f2-f1)/(nFreq-1) + f1; % frequency vector     
nFreqMax = round(maxBytes/(8*ndof)); % number frequency points in proc block
nFreqBlocks = ceil(nFreq/nFreqMax); % number of processing blocks
k = nan(1,nFreq); % initialise product over set
if displayProgress, fprintf('Calculating product over set '); end
for n = 1:nFreqBlocks
    iFreq1 = (n-1)*nFreqMax + 1;
    iFreq2 = min(n*nFreqMax,nFreq);
    k(iFreq1:iFreq2) = prod(1./sqrt(1 - 4*pi*1j*weight.*f(iFreq1:iFreq2)));
end
if displayProgress, fprintf('[%s]\n',datestr(now,'dd-mmm-yyyy HH:MM:SS')); end

% FIND AMPLITUDE OF MAXIMUM
t1 = 0; % bottom limit of time integral
t2 = tmax; % top limit of time integral
pMax0 = 0; % initialise maximum of PDF (temporal variable)
tolFactor = 1 + 1e-2; % tolerance factor
err = Inf; % initialise error
if displayProgress, fprintf('Finding maximum of PDF '); end
while err > tolFactor    
    % Calculate Vector of Detection Probability Densities (In MAXBYTES blocks)    
    t = (0:nTime-1)'*(t2-t1)/(nTime-1) + t1; % time vector
    nTimeMax = round(maxBytes/(8*nFreq)); % number of time points in proc block
    nTimeBlocks = ceil(nTime/nTimeMax); % number of processing blocks
    p = nan(nTime,1); % initialise PDF
    for n = 1:nTimeBlocks
        iTime1 = (n-1)*nTimeMax + 1;
        iTime2 = min(n*nTimeMax,nTime);
        p(iTime1:iTime2) = abs(sum(k * fres .* exp(-1j*2*pi*f.*t(iTime1:iTime2)),2));
    end
    
    % Find Maximum Value and Right/Left Boundaries
    [pMax,iMax] = max(p); % maximum of current sector of PDF
    i1 = max(iMax-1,1);
    i2 = min(iMax+1,nTime);
    t1 = t(i1);
    t2 = t(i2);

    % Error
    err = max(pMax/pMax0,pMax0/pMax);
    pMax0 = pMax;
end
if displayProgress, fprintf('[%s]\n',datestr(now,'dd-mmm-yyyy HH:MM:SS')); end

% FIND TIME FOR SPECIFIC AMPLITUDE RELATIVE TO MAXIMUM (Fine)
t1 = t(iMax); % time of PDF maximum
t2 = tmax; % initialise top integration time of PDF
pMin = pMax/ampRatio; % target amplitude
tolFactor = 1 + 1e-2; % tolerance factor
err = Inf; % initialise error
signCrossing = true; % sign crossing flag
if displayProgress, fprintf('Finding time integration interval '); end
while err > tolFactor && signCrossing
    % Calculate Vector of Detection Probability Densities (In MAXBYTES blocks)    
    t = (0:nTime-1)'*(t2-t1)/(nTime-1) + t1; % time vector
    nTimeMax = round(maxBytes/(8*nFreq)); % number of time points in proc block
    nTimeBlocks = ceil(nTime/nTimeMax); % number of processing blocks
    p = nan(nTime,1);
    for n = 1:nTimeBlocks
        iTime1 = (n-1)*nTimeMax + 1;
        iTime2 = min(n*nTimeMax,nTime);
        p(iTime1:iTime2) = abs(sum(k * fres .* exp(-1j*2*pi*f.*t(iTime1:iTime2)),2));
    end

    % Find Closest Value and Right/Left Boundaries
    vec = p - pMin;
    [~,iMin] = min(abs(vec));
    pMin0 = p(iMin); % minimum of current sector of PDF
    i1 = max(iMin-1,1);
    i2 = min(iMin+1,nTime);
    t1 = t(i1);
    t2 = t(i2);

    % Error
    err = max(pMin/pMin0,pMin0/pMin);
    signCrossing = length(unique(sign(vec))) > 1;
end
if displayProgress, fprintf('[%s]\n',datestr(now,'dd-mmm-yyyy HH:MM:SS')); end
tmax = t(iMin); % top time integration limit
