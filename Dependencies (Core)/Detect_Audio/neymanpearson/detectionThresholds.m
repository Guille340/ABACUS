%  [thresholds,rtpFalseAlarms,rtpDetections] = detectionThresholds(...
%      PerformanceData,rtpFalseAlarmTarget,detectorSensitivity,...
%      signalVars,noiseVars)
% 
%  DESCRIPTION
%  Calculates the detection THRESHOLDS (test statistics) and the corresponding
%  right-tail probabilities RTPFALSEALARMS and RTPDETECTIONS for each pair of
%  signal and noise variances in SIGNALVARS and NOISEVARS, given the multi-
%  element structure PERFORMANCEDATA and the target false alarm probability 
%  RTPFALSEALARMTARGET. PERFORMANCEDATA is created with CHARACTERISEPERFORMANCE 
%  and contains the probability curves for several signal-to-noise ratios (SNR).
%
%  The DETECTORSENSITIVITY parameter allows the user to control how close each
%  threshold in THRESHOLDS is to the specified target probability of false 
%  alarm RTPFALSEALARMTARGET or to a probability of detection of 0.99999. With 
%  DETECTORSENSITIVITY = 1 the thresholds are determined by RTPFALSEALARMTARGET; 
%  with DETECTORSENSITIVITY = 0 the thresholds are determined by a detection 
%  probability of 0.99999. Whichever value of DETECTORSENSITIVITY is used, the 
%  threshold cannot be lower than that for DETECTORSENSITIVITY = 1.
%
%  SIGNALVARS and NOISEVARS determine the SNR values and therefore the curves 
%  from PERFORMANCEDATA to be used for the calculations. NOISEVARS is also used
%  to scale the probability curves for detector types 'ed' (energy detector)
%  and 'ecw' (estimator-correlator in white Gaussian noise), calculated for a 
%  noise variance of 1 (see function CHARACTERISEPERFORMANCE). Note that due to
%  the formulation used for the estimator-correlator in coloured Gaussian noise
%  (DETECTORTYPE = 'ecc'), its PDF curves are not affected by NOISEVAR, 
%  therefore they don't need scaling.
% 
%  INPUT ARGUMENTS (Fixed)
%  - PerformanceData: multi-element structure containing detectiong performance
%    information. Each element corresponds to a SNR from -50 dB to 50 dB in 1 
%    dB steps (101 elements). Generated with CHARACTERISEPERFORMANCE.
%  - rtpFalseAlarmTarget: target right-tail probability of false alarm. This
%    is a value between 0 and 1. A value of 0.01 or lower is recommended.
%  - detectorSensitivity: value between 0 and 1. With DETECTORSENSITIVITY = 0
%    the THRESHOLD is computed from a detection probability of 0.99999. With
%    DETECTORSENSITIVITY = 1 the threshold is computed from the false alarm
%    probability RTPFALSEALARMTARGET. Any value in between is allowed.
%  - signalVars: vector of variances of the signal to be processed. Note that 
%    this is not the variance of the signal plus noise, hence background noise
%    correction may be needed to estimate this value. Same length as NOISEVARS.
%    If SIGNALVARS is a scalar, a vector the same length as NOISEVARS with all 
%    elements equal to SIGNALVARS is assumed.
%  - noiseVars: vector of variances of the background noise. Same length as
%    SIGNALVARS. If NOISEVARS is a scalar, a vector the same length as 
%    SIGNALVARS with all elements equal to NOISEVARS is assumed.
%    
%  OUTPUT VARIABLES
%  - thresholds: vector of thresholds of the test statistic for the specified 
%    pairs of signal and noise variances SIGNALVARS and NOISEVARS, for the 
%    given detector performance curves in PERFORMANCEDATA, target probability 
%    of false alarm RTPFALSEALARMTARGET and sensitivity DETECTORSENSITIVITY.
%  - rtpFalseAlarm: vector of right-tail probabilities of false alarm 
%    associated with THRESHOLDS.
%  - rtpDetection: vector of right-tail probabilities of detection associated
%    with THRESHOLDS.
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  FUNCTION CALL
%  1. [thresholds,rtpFalseAlarms,rtpDetections] = detectionThresholds(...
%      PerformanceData,rtpFalseAlarmTarget,detectorSensitivity,...
%      signalVars,noiseVars)
%
%  CONSIDERATIONS & LIMITATIONS
%  - DETECTORSENSITIVITY is a correction parameter introduced to address
%    the limitation of the Neyman-Pearson (NP) detector when detecting non-
%    target signals with large SNR. The standard NP detectors use a value of
%    1, but when the audio data contains large amplitude non-target signals,
%    selecting a value lower than 1 can be beneficial to reject some of them.

%  VERSION 1.1
%  - Vectors are now allowed for inputs SIGNALVARS and NOISEVARS. This change
%    dramatically improves the speed of the function as there is a large
%    section of the code that didn't need to be looped through.
%  - Added error control to the inputs.
%  
%  VERSION 1.0
%  Date: 23 Sep 2021
%  Author: Guillermo Jimenez Arranz
%  Email: gjarranz@gmail.com

function [thresholds,rtpFalseAlarms,rtpDetections] = detectionThresholds(...
    PerformanceData,rtpFalseAlarmTarget,detectorSensitivity,...
    signalVars,noiseVars)

% Error Control: Performance Data
if ~isPerformanceData(PerformanceData)
    warning('PERFORMANCEDATA is not a valid performance data structure')
end

% Error Control: rtpFalseAlarmTarget
if ~isnumeric(rtpFalseAlarmTarget) || ~isscalar(rtpFalseAlarmTarget) ...
        || rtpFalseAlarmTarget <= 0 || rtpFalseAlarmTarget > 1
    warning(['RTPFALSEALARMTARGET must be a scalar between 0 '...
        '(not included) and 1'])
end

% Error Control: rtpFalseAlarmTarget
if ~isnumeric(detectorSensitivity) || ~isscalar(detectorSensitivity) ...
        || detectorSensitivity < 0 || detectorSensitivity > 1
    warning('DETECTORSENSITIVITY must be a scalar between 0 and 1')
end

% Error Control: signalVars
if ~isnumeric(signalVars) || ~isvector(signalVars)
    error('SIGNALVARS must be a numeric vector')
end

% Error Control: noiseVars
if ~isnumeric(noiseVars) || ~isvector(noiseVars)
    error('NOISEVARS must be a numeric vector')
end

% Error Control: signalVars and noiseVars
if ~isequal(size(signalVars),size(noiseVars)) && length(noiseVars) ~= 1 ...
        && length(signalVars) ~= 1
    error(['SIGNALVARS and NOISEVARS must be same-length vectors, unless '...
        'one (or both) of them is a scalar'])
end

% Vectorise signalVars and noiseVars
signalVars = signalVars(:);
if isscalar(signalVars)
    signalVars = signalVars * ones(length(noiseVars),1);
end
noiseVars = noiseVars(:);
if isscalar(noiseVars)
    noiseVars = noiseVars * ones(length(signalVars),1);
end

% General Variables
snrLevelTargets = 10*log10(signalVars./noiseVars); % target signal to noise ratio
snrLevels = [PerformanceData.snrLevel];
rtpDetectionTarget = 0.99999;
detectorType = PerformanceData(1).detectorType;

% Calculate Thresholds for All SNR
nSnr = length(snrLevels);
thresholds_temp = nan(nSnr,1);
rtpDetections_temp = nan(nSnr,1);
rtpFalseAlarms_temp = nan(nSnr,1);
for m = 1:nSnr
    % Calculate False Alarm and Detection Threshold for Current SNR
    [~,iUnique] = unique(PerformanceData(m).rtpFalseAlarm);
    threshold1 = interp1(PerformanceData(m).rtpFalseAlarm(iUnique),...
        PerformanceData(m).axisFalseAlarm(iUnique),rtpFalseAlarmTarget);
    [~,iUnique] = unique(PerformanceData(m).rtpDetection);
    threshold2 = interp1(PerformanceData(m).rtpDetection(iUnique),...
        PerformanceData(m).axisDetection(iUnique),rtpDetectionTarget);
    
    % Calculate Thresholds and Right-Tail Probabilities
    thresholds_temp(m) = max(threshold1*detectorSensitivity ...
        + threshold2*(1 - detectorSensitivity),threshold1);
    rtpFalseAlarms_temp(m) = interp1(PerformanceData(m).axisFalseAlarm,...
        PerformanceData(m).rtpFalseAlarm,thresholds_temp(m));
    rtpDetections_temp(m) = interp1(PerformanceData(m).axisDetection,...
        PerformanceData(m).rtpDetection,thresholds_temp(m)); 
end

% Calculate Threshold (unscaled) and Right-Tail Probabilities for Target SNR 
thresholds = interp1(snrLevels,thresholds_temp,snrLevelTargets,'pchip','extrap');
rtpFalseAlarms = interp1(snrLevels,rtpFalseAlarms_temp,snrLevelTargets,'linear');
rtpDetections = interp1(snrLevels,rtpDetections_temp,snrLevelTargets,'linear');

% Limit Inf Values of Detection and False Alarm Probabilities
nKernels = length(snrLevelTargets);
for m = 1:nKernels
    if isnan(rtpDetections(m))
        rtpDetections(m) = interp1(snrLevels,rtpDetections_temp,...
            snrLevelTargets(m),'nearest','extrap');
    end
    if isnan(rtpFalseAlarms(m))
        rtpFalseAlarms(m) = interp1(snrLevels,rtpFalseAlarms_temp,...
            snrLevelTargets(m),'nearest','extrap');
    end
end

% Scale Thresholds by Background Noise Variance
if ismember(detectorType,{'ed','ecw'})
    thresholds = thresholds .* noiseVars;
end
thresholds(isinf(thresholds)) = 0; % set THRESHOLD = -Inf to 0
