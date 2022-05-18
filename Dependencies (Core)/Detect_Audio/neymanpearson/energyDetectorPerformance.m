%  Performance = ENERGYDETECTORPERFORMANCE(ndof,ncp,signalVar,noiseVar,...
%      cutoffFreqns,varargin)
% 
%  DESCRIPTION
%  Calculates the detection performance parameters of the Neyman-Pearson energy 
%  detector for white-Gaussian target signals (WGS) and white Gaussian 
%  background noise (WGN) with variances SIGNALVAR and NOISEVAR.
%
%  ENERGYDETECTORPERFORMANCE analyses the performance of a WGS with variance 
%  SIGNALVAR over WGN of variance NOISEVAR. The function does not require 
%  covariance information, only the number of degrees of freedom NDOF (or
%  number of samples), the non-centrality parameter NCP (or mean), and the 
%  variances of the signal and noise segments.
%  
%  ENERGYDETECTORPERFORMANCE returns a structure containing the probability 
%  density function (PDF), the right-tail probability (RTP), and the axis (test
%  statistic) of detection and false alarm. The structure includes additional
%  contextual information such as the type of detector, the signal and noise 
%  variance, the signal-to-noise ratio (SNR), the number of variables and the
%  normalised cutoff frequencies of the detection filter.
%
%  INPUT ARGUMENTS (Fixed)
%  - ndof: number of degrees of freedom (DOF) of the data segment. This is 
%    equivalent to their number of variables or samples.
%  - ncp: non-centrality parameter (NCP) of the signal and noise segment.
%    This is equivalent to their mean value.
%  - signalVar: mean variance of the target signal.
%  - noiseVar: mean variance of the background noise.
%  - cutoffFreqns: two-element numeric vector containing the normalised 
%    cutoff frequencies of the detection filter (bandpass = [fn1 fn2], 
%    highpass = [fn1 0], lowpass = [0 fn2]). The values must be between 0 
%    and 1. CUTOFFFREQNS = 2*cutoffFreqs/resampleRate, where cutoffFreqs and
%    resampleRate are fields in the configuration file 'audioDetectConfig_
%    NeymanPearson.json'.
%
%  INPUT ARGUMENTS (Variable, Property/Value Pairs)
%  In a function call: 1. Every property must be followed by its corresponding 
%  value, and 2. Any number of supported properties can be specified. The 
%  function accepts two input properties. 
%  - 'Interpolate': TRUE for the probability curves to be interpolated to a 
%    common x-axis vector. Having a common x-axis is useful for comparing
%    the values of the probability curves at common axis points (e.g., for 
%    generating a Receiver Operating Curve ROC). The property is set to FALSE
%    as default.
%  - 'DisplayProgress': TRUE for displaying the progress of the calculations
%    on a wait bar. The property is set to FALSE as default.
%    
%  OUTPUT VARIABLES
%  - Performance: structure containing the following fields.
%    ¬ detectorType: type of detector ('ed' for the energy detector).
%    ¬ signalVariance: variance of the signal.
%    ¬ noiseVariance: variance of the background noise.
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
%  FUNCTION DEPENDENCIES
%  - energyDetectorTimeLimit
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  FUNCTION CALL
%  1. Performance = energyDetectorPerformance(ndof,ncp,signalVar,noiseVar,...
%         cutoffFreqns)
%  2. Performance = energyDetectorPerformance(...,PROPERTY,VALUE)

%  VERSION 1.1
%  Date: 24 Feb 2022
%  Author: Guillermo Jimenez Arranz
%  - Small update to the help.
%
%  VERSION 1.0
%  Date: 06 Sep 2021
%  Author: Guillermo Jimenez Arranz
%  Email: gjarranz@gmail.com

function Performance = energyDetectorPerformance(ndof,ncp,signalVar,...
    noiseVar,cutoffFreqns,varargin)

% INPUT ARGUMENTS
% Verify number of Input Arguments
nFixArg = 5;
nProArg = 4;
narginchk(nFixArg,nFixArg + nProArg)
if rem(nargin - nFixArg,2)
    error('Variable input arguments must come in pairs (PROPERTY,VALUE)')
end

% Error Control: ndof
if ~isnumeric(ndof) || ~isscalar(ndof) || rem(ndof,1) || ndof < 1
    error('NDOF must be a positive non-decimal number larger than 0')
end

% Error Control: ncp
if ~isnumeric(ncp) || ~isscalar(ndof) || ndof < 0
    error('NCP must be a positive number higher than or equal to 0')
end

% Error Control: signalVar
if ~isnumeric(signalVar) || ~isscalar(signalVar) || signalVar < 0
    error('SIGNALVAR must be a positive number higher than or equal to 0')
end

% Error Control: noiseVar
if ~isnumeric(noiseVar) || ~isscalar(noiseVar) || noiseVar < 0
    error('NOISEVARVAR must be a positive number higher than or equal to 0')
end

% Error Control: cutoffFreqns
if ~isnumeric(cutoffFreqns) || ~isvector(cutoffFreqns) ...
        || numel(cutoffFreqns) ~= 2 || any(cutoffFreqns < 0) ...
        || any(cutoffFreqns > 1)
    error(['CUTOFFFREQNS must be a two-element numeric vector with values '...
        'between 0 and 1'])
end 

% Extract and Verify Input Properties
validProperties = {'interpolate','displayprogress'};
properties = lower(varargin(1:2:end));
if any(~ismember(properties,validProperties))
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

% Correct signalVar, noiseVar and ndof to Account for Filter Effect
q_fa = abs(diff(cutoffFreqns)); % correction factor to account for filter effect
signalVar_orig = signalVar;
signalVar = signalVar/q_fa;
noiseVar_orig = noiseVar;
noiseVar = noiseVar/q_fa;
ndof_orig = ndof;
ndof = round(ndof*q_fa);

% General
snrLevel = 10*log10(signalVar/noiseVar); % signal to noise ratio [dB]
precisionFactor = 1.5; % precision of probability curves 
weight_d = (signalVar + noiseVar);
weight_fa = noiseVar;

% NOTE: for tolerances of 1e-5, 1e-8 and 1e-12 in the RTP curves use
% PRECISIONFACTOR = 1, 1.5 or 2. Those same factors result in a relative 
% amplitude error (max to min) in the PDF curves of 1e-5, 1e-10, 1e-14.

% Integration Limits
tmax_d = precisionFactor*energyDetectorTimeLimit(ndof,ncp,signalVar,...
    noiseVar,'detection','DisplayProgress',false);
tmax_fa = precisionFactor*energyDetectorTimeLimit(ndof,ncp,signalVar,...
    noiseVar,'falsealarm','DisplayProgress',false);

% Processing Parameters
nPointsInLobe = round(precisionFactor * 250); % number of samples within main lobe
pdfStd = sqrt(2*ndof + 4*ncp); % standard deviation of Chi2 PDF for std(x) = 1
tres_d = weight_d * 10*pdfStd/nPointsInLobe; % time resolution
tres_fa = weight_fa * 10*pdfStd/nPointsInLobe; % time resolution
nTime_d = round(tmax_d/tres_d) + 1; % number of time points
nTime_fa = round(tmax_fa/tres_fa) + 1; % number of time points

% Display Progress (open)
if displayProgress
    h = waitbar(0,'','Name','energyDetectorPerformance.m'); 
end

% CALCULATE DETECTION PROBABILITIES (PDF and RTP) 
% Display Progress
if displayProgress
    messageString = sprintf(['Computing probability of detection '...
        '(SNR = %0.1f dB, \\sigma_n^2 = %0.1e)'],snrLevel,noiseVar);
    waitbar(0,h,messageString);
end

% Calculate Probabilities
td = (0:nTime_d-1)'*tres_d; % axis of test statistic
pd = ncx2pdf(td/weight_d,ndof,ncp) * 1/weight_d; % detection PDF
Pd = cumsum(pd*tres_d,'reverse'); % right-tail probability (ICDF) of PDF curve

% CALCULATE FALSE ALARM PROBABILITIES (PDF and RTP)
% Display Progress
if displayProgress
    messageString = sprintf(['Computing probability of detection '...
        '(SNR = %0.1f dB, \\sigma_n^2 = %0.1e)'],snrLevel,noiseVar);
    waitbar(0.5,h,messageString);
end

% Calculate Probabilities
tfa = (0:nTime_fa-1)'*tres_fa; % axis of test statistic
pfa = ncx2pdf(tfa/weight_fa,ndof,ncp) * 1/weight_fa; % false alarm PDF
Pfa = cumsum(pfa*tres_fa,'reverse'); % right-tail probability (ICDF) of PDF curve

% Display Progress (close)
if displayProgress
    messageString = sprintf(['Computing probability of detection '...
        '(SNR = %0.1f dB, \\sigma_n^2 = %0.1e)'],snrLevel,noiseVar);
    waitbar(1,h,messageString);
end

% INITERPOLATE PROBABILITY CURVES TO COMMON TIME VECTOR
if interpOption
    t = [tfa; tfa(end)+tres_fa; td(td > tfa(end)+tres_d)];
    pd = interp1(td,pd,t,'linear','extrap');
    pfa = interp1(tfa,pfa,t,'linear',0);
    Pd = interp1(td,Pd,t,'linear','extrap');
    Pfa = interp1(tfa,Pfa,t,'linear',0);
    
    td = t;
    tfa = t;
end

% Display Progress (close)
if displayProgress, close(h); end

% BUILD STRUCTURE
Performance.detectorType = 'ed';
Performance.signalVariance = signalVar_orig;
Performance.noiseVariance = noiseVar_orig;
Performance.snrLevel = snrLevel;
Performance.nVariables = ndof_orig;
Performance.cutoffFreqns = cutoffFreqns;
Performance.axisFalseAlarm = tfa;
Performance.axisDetection = td;
Performance.pdfFalseAlarm = pfa;
Performance.pdfDetection = pd;
Performance.rtpFalseAlarm = Pfa;
Performance.rtpDetection = Pd;
