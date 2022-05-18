%  tmax = ENERGYDETECTORTIMELIMIT(ndof,ncp,signalVar,noiseVar,...
%     rtpType,varargin)
%
%  DESCRIPTION
%  Computes the top time limit for the computation of the probability density 
%  curves of a Neyman-Pearson "energy" detector. The "time" term is used here 
%  to draw a parallelism between the frequency and the time variable, but note 
%  the "time" actually refers to the test statistic.
%
%  The detection performance of an Neyman-Pearson "energy" for white Gaussian 
%  noise (WGN) signals and background noise is given by the non-central Chi-
%  Squared probability function calculated over a scaled test statistic (see
%  Kay 1998, Example 5.1 Energy Detector, pp. 142-146).
%
%  In order to compute the detection performance curves and the Receiver 
%  Operating Characteristic (ROC), the infinite axis of the probability curves
%  must be limited to a maximum x-axis value TMAX that provides reasonable 
%  accuracy. TMAX is computed as test statistic value at which the right-tail
%  probability last-exceeds value AMPRATIO times lower than 1. AMPRATIO = 1e4
%  is used by default.
%
%  The calculations are performed on the "detection" or the "false alarm" RTP 
%  curve depending on the values used for the WEIGHT input vector.
%
%  INPUT VARIABLES
%  - ndof: number of degrees of freedom (DOF) of the signal and noise segment.
%    This is equivalent to their number of samples.
%  - ncp: non-centrality parameter (NCP) of the signal and noise segment.
%    This is equivalent to their mean value.
%  - signalVar: variance of the signal.
%  - noiseVar: variance of the background noise.
%  - rtpType: string specifying the type of probability curve. There are two
%    options: 'Detection' and 'FalseAlarm'.
%
%  INPUT PROPERTIES
%  In a function call: 1. Every property (string) must be followed (separated
%  by comma) by its corresponding value, 2. Property/value pairs are variable
%  input arguments and must be introduced last, 3. Any number of supported 
%  properties can be specified. The function accepts two input properties. 
%  - 'DisplayProgress': TRUE to display the progress of TIMELIMIT. FALSE 
%    otherwise (DEFAULT).
%  - 'AmplitudeRatio': numeric value between 0 and 1. This is the relative 
%    amplitude betweeen the maximum of the RTP (= 1) and the amplitude at which
%    the top time integration limit is defined. AMPRATIO = 1e4 (DEFAULT).
%   
%  OUTPUT VARIABLES
%  - tmax: top time limit of the probability density function with parameter
%    WEIGHT (WEIGHT = LAMBDA for Probability of Detection, or WEIGHT = ALPHA 
%    for Probability of False Alarm). Use TMAX as the limit of the infinite 
%    time integral in the function of the performance curves of an estimator- 
%    correlator detector with arbitrary covariance matrix and white gaussian 
%    noise.
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  FUNCTION CALL
%  1. tmax = energyDetectorTimeLimit(weight)
%  2. tmax = energyDetectorTimeLimit(...,PROPERTY,VALUE)
%     Properties: 'DisplayProgress', 'AmplitudeRatio'
%
%  REFERENCES
%  - Kay, S.M. (1998). Fundamentals of Statistical Signal Processing - 
%    Volume II, Detection Theory. Prentice Hall.

% VERSION 1.0
% Date: 16 Sep 2021
% Author: Guillermo Jimenez Arranz
% Email: gjarranz@gmail.com

function tmax = energyDetectorTimeLimit(ndof,ncp,signalVar,noiseVar,...
    rtpType,varargin)

% INPUT ARGUMENTS
% Verify number of Input Arguments
narginchk(5,9)
if rem(nargin-5,2)
    error('Variable input arguments must come in pairs (PROPERTY,VALUE)')
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

% CALCULATE WEIGHT
if strcmp(rtpType,'detection') % 'detection' RTP
    weight = (signalVar + noiseVar);
else % 'false alarm' RTP
    weight = noiseVar;
end

% PROCESSING PARAMETERS
nTime = 11; % no. time samples for slicing
pdfMean = ndof + ncp; % mean of non-central Xi2 PDF
pdfStd = sqrt(2*ndof + 4*ncp); % standard deviation of non-central Xi2 PDF
tmax = 1.5*pdfMean + 10*pdfStd; % approximation based on mean and stdev
maxIter = 100;

% FIND TIME FOR SPECIFIC AMPLITUDE (RELATIVE TO MAXIMUM)
rtpMax = 1; % maximum absolute amplitude of product-over-set
rtpMin = rtpMax/ampRatio; % target amplitude of product-over-set
t1 = 0; % initialise start frequency (frequency at kMax)
t2 = tmax*weight; % initialise top time limit
tolFactor = 1e-5; % tolerance factor
err = Inf; % error value
nIter = 1;
if displayProgress, fprintf('Finding frequency integration interval '); end
while err > tolFactor && nIter < maxIter 
    
    t = (0:nTime-1)*(t2-t1)/(nTime-1) + t1; % time vector
    rtp = ncx2cdf(t/weight,ndof,ncp,'upper');
          
    % Find Closest Value and Right/Left Boundaries
    vec = rtp - rtpMin; 
    [~,iMin] = min(abs(vec));
    rtpMin0 = rtp(iMin); % minimum of current right-tail probability
    i1 = max(iMin-1,1);
    i2 = min(iMin+1,nTime);
    t1 = t(i1);
    t2 = t(i2);

    % Error
    err = abs(rtpMin - rtpMin0);
    nIter = nIter + 1;
end
if displayProgress, fprintf('[%s]\n',datestr(now,'dd-mmm-yyyy HH:MM:SS')); end

if nIter == maxIter
    warning(['The maximum number of iterations has been reached. The '...
        'computed time limit TMAX may not be accurate'])
end

tmax = t(iMin); % top time integration limit
