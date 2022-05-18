%  [AudDetData,InternalData] = DETECTORNEYMANPEARSON(root,...
%     audiodbName,AudDetConfig)
% 
%  DESCRIPTION
%  Neyman-Pearson algorithm for the detection of sound events in the 
%  AudioDatabase AUDIODBNAME stored in '<ROOT.BLOCK>\audiodb' using the 
%  detection parameters in AUDDETCONFIG.DETECTPARAMETERS. The function 
%  returns a structure AUDDETDATA containing the exact time of the detections, 
%  and the start and end times of the 'target' and 'noise' windows. All times
%  are expressed in seconds relative to the start of the file (see
%  INITIALISEAUDIODETECTDATA for further information about the fields
%  in AUDDETDATA structure).
%
%  DETECTPARAMETERS is a substructure contained in the Audio Detect Config
%  structure generated from the corresponding .json file stored in folder
%  '<ROOT.BLOCK>\configdb' (see READAUDIODETECTCONFIG). The fields vary
%  according to the type of detector. For the Neyman-Pearson detector,
%  DETECTPARAMETERS includes: DETECTORTYPE, class of Neyman-Pearson detector
%  ('ed' for Energy Detector, 'ecw' for Estimator-Correlator in white Gaussian
%  noise, and 'ecc' for Estimator-Correlator in Coloured Gaussian noise); 
%  KERNELDURATION, duration of the processing sub-window; WINDOWDURATION, 
%  duration of the processing window; WINDOWOFFSET, backward displacement for 
%  the procssing window; RTPFALSEALARM, target right-tail probability of false 
%  alarm; DETECTORSENSITIVITY, sensitivity of the detector; MINSNRLEVEL, 
%  minimum signal-to-noise ratio to consider for detections; CUTOFFFREQS, 
%  two-element vector containing the bottom and top cutoff (-3 dB) frequencies 
%  of the detection bandpass filter; TRAINFOLDER, directory where the training 
%  audio segments of the target signal and noise are stored, used for building
%  the corresponding covariance matrices (for 'ecw' and 'ecc'); RESAMPLERATE, 
%  sampling rate of the covariance matrix in Hz.
%
%  DETECTORNEYMANPEARSON divides the audio file into segments of duration
%  KERNELDURATION, resamples each segment to RESAMPLERATE and filters it with 
%  a bandpass filter of half-power frequencies CUTOFFFREQS, to then compute
%  the test statistic and the threshold. If the test statistic exceeds the 
%  threshold, that segment is classified as a "detection". The detection
%  segments are then grouped into windows of duration WINDOWDURATION. Note that 
%  WINDOWDURATION is a multiple of KERNELDURATION. For details about the
%  grouping scheme see function GROUPKERNELS.
%
%  The threshold is computed from the right-tail probability curves stored in 
%  'PerformanceData_<SOURCE>_<DETECTORTYPE>_fa<CUTOFFFREQ(1)>_fb<CUTOFFFREQ(2)
%  _fs<RESAMPLERATE>_t<KERNELDURATION>.mat' under folder '<ROOT.BLOCK>\
%  detectiondb' and previously generated with PREPROCESSNEYMANPEARSON. The 
%  threshold is a value of the test statistic associated with a particular 
%  target probability. In particular
%
%      <THRESHOLD> = <THRESHOLD1> * DETECTORSENSITIVITY + <THRESHOLD2>
%          *(1 - DETECTORSENSITIVITY)
%
%  where <THRESHOLD1> is the threshold associated with the probability of false 
%  alarm RTPFALSEALARM and <THRESHOLD2> is the threshold associated with a 
%  detection probability of 0.99999. Therefore, using DETECTORSENSITIVITY = 1 
%  is the same as defining the threshold by the maximum accepted probability 
%  of false alarm (standard method). The reason for including a sensitivity 
%  parameter is that a Neyman-Pearson detector can be very sensitive to any 
%  signal (target or not) that has a large enough SNR. Hence, to avoid non-
%  target signals to be detected, the sensitivity of the detector can be 
%  reduced with DETECTORSENSITIVITY. 
% 
%  The test statistic is calculated in a different way depending on the class
%  of detector. In the Energy Detector, the test statistic is simply the sum
%  of the squared amplitudes of the audio segment of duration KERNELDURATION. 
%  In the Estimator-Correlator, the test statistic is the weighted sum of the 
%  squared amplitudes of the uncorrelated version of the audio segment.
%
%  INPUT ARGUMENTS
%  - root: structure containing the root directories where the audio data
%    (ROOT.AUDIO), position data (ROOT.POSITION) and block data (ROOT.BLOCK)
%    are stored. ROOT.BLOCK contains the directories where the Configuration 
%    Files ('configdb'), Resampled Audio ('audiodb'), Detection Database
%    ('detectiondb), Navigation Database ('navigationdb'), and Acoustic 
%    Databases ('acousticdb') are stored.
%  - audiodbName: name of the Acoustic Database to be processed.
%  - AudDetConfig: single-element audio detect configuration structure.
%  
%  OUTPUT ARGUMENTS
%  - AudDetData: single-element audio detect data structure.
%  - InternalData: single-element structure with useful data for analysis and
%    testing the detection algorithm. This output is provisional.
%
%  FUNCTION CALL
%  [AudDetData,InternalData] = detectorNeymanPearson(root,...
%     audiodbName,AudDetConfig)
%
%  FUNCTION DEPENDENCIES
%  - digitalSingleFilterDesign
%  - noiseVariance
%  - digitalSingleFilter
%  - getDcOffset
%  - testStatistics
%  - detectionThresholds
%  - groupKernels
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%  - Digital Filtering (Single)
%
%  See also NOISEVARIANCE, DETECTIONTHRESHOLD

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  13 Aug 2021

function [AudDetData,InternalData] = detectorNeymanPearson(root,...
    audiodbName,AudDetConfig)

% Load Detection Parameters
sourceName = AudDetConfig.sourceName;
detectorType = AudDetConfig.DetectParameters.detectorType;
kernelDuration = AudDetConfig.DetectParameters.kernelDuration;
windowDuration = AudDetConfig.DetectParameters.windowDuration;
windowOffset = AudDetConfig.DetectParameters.windowOffset;
rtpFalseAlarmTarget = AudDetConfig.DetectParameters.rtpFalseAlarm;
detectorSensitivity = AudDetConfig.DetectParameters.detectorSensitivity;
minSnrLevel = AudDetConfig.DetectParameters.minSnrLevel;
cutoffFreqs = AudDetConfig.DetectParameters.cutoffFreqs;
estimator = AudDetConfig.DetectParameters.estimator;
sampleRateForDetection = AudDetConfig.DetectParameters.resampleRate;

% General Variables
warnFlag = false;
detectiondbDir = fullfile(root.block,'detectiondb');

% Error Control: Performance Data
performanceName = sprintf(['PerformanceData_%s_%s_fa%0.0f_fb%0.0f_'...
    'fs%0.0f_t%0.0f_%s.mat'],sourceName,upper(detectorType),cutoffFreqs(1),...
    cutoffFreqs(2),sampleRateForDetection,kernelDuration*1000,estimator);
performancePath = fullfile(detectiondbDir,performanceName);
if exist(performancePath,'file') ~= 2
    warnFlag = true;
    warning(['The performance data file ''%s'' could not be found under '...
        'directory ''%s''. The audio dabase ''%s'' will not be processed '...
        'for detections'],performanceName,detectiondbDir,audiodbName) %#ok<*SPWRN>
end

% Error Control: Eigen Data
eigenName = sprintf('EigenData_%s_%s_fa%0.0f_fb%0.0f_fs%0.0f_t%0.0f_%s.mat',...
    sourceName,upper(detectorType),cutoffFreqs(1),cutoffFreqs(2),...
    sampleRateForDetection,kernelDuration*1000,estimator);
eigenPath = fullfile(detectiondbDir,eigenName);
if ismember(detectorType,{'ecw','ecc'}) && exist(eigenPath,'file') ~= 2
    warnFlag = true;
    warning(['The eigen data file ''%s'' could not be found under '...
        'directory ''%s''. The audio dabase ''%s'' will not be processed '...
        'for detections'],performanceName,detectiondbDir,audiodbName) %#ok<*SPWRN>  
end

% Initialise AudDetData and InternalData Structures
AudDetData = initialiseAudioDetectData();
InternalData = struct('audiodbPath',[],'isDetections',[],'thresholds',[],...
    'testStats',[],'signalVars',[],'noiseVars',[],'snrLevels',[],...
    'rtpFalseAlarms',[],'rtpDetections',[]);
    
if ~warnFlag    
    % Load Audio Database and Parameters
    fprintf('# Loading audio database ')
    audiodbPath = fullfile(root.block,'audiodb',audiodbName);
    AudioDatabase = load(audiodbPath);
    AudImpConfig = AudioDatabase.AudImpConfig;
    audioData = AudioDatabase.AudImpData.audioData;
    audioData = audioData(:);
    sampleRateAudio = AudImpConfig.resampleRate;
    clear AudioDatabase
    fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))

    % Vector Lengths
    audioLength = length(audioData);
    windowDuration = ceil(windowDuration/kernelDuration)*kernelDuration;
    offsetLength_aud = round(windowOffset*sampleRateAudio);
    windowLength_aud = round(windowDuration*sampleRateAudio);
    kernelLength_aud = round(kernelDuration*sampleRateAudio);
    kernelLength_det = round(kernelDuration*sampleRateForDetection);
    nKernelsPerWindow = round(windowLength_aud/kernelLength_aud);  
    nKernels = floor(audioLength/kernelLength_aud);

    % Design Filter
    DigitalFilter = digitalSingleFilterDesign(sampleRateForDetection,cutoffFreqs);

    % Calculate DC-Offset In Ten-Second Intervals
    dcWindowLength = min(round(10*sampleRateAudio),audioLength); % length of DC-processing window
    [dcOffsets,iDcOffsets] = getDcOffset(audioData,dcWindowLength);

    % Process Audio Segments (kernels) for Detection
    h = waitbar(0,'','Name','detectorNeymanPearson.m'); % open waitbar
    fprintf('# Processing audio segments for detection ')
    xsn = zeros(kernelLength_det,nKernels);
    for m = 1:nKernels
        % Display Progress
        messageString = sprintf(['Processing audio segments for detection '...
            '(%d/%d)'],m,nKernels);
        waitbar(m/nKernels,h,messageString);

        % Start and End Indices for Windows
        iKernelSample1 = kernelLength_aud*(m-1) + 1;
        iKernelSample2 = kernelLength_aud*m;

        % DC Offset
        iKernelSample = round(mean([iKernelSample1;iKernelSample2]));
        dcOffset = interp1(iDcOffsets,dcOffsets,iKernelSample,...
            'nearest','extrap');

        % Audio Segment (Resampled and DC Offset Corrected)
        xsn_temp = double(audioData(iKernelSample1:iKernelSample2) - dcOffset); % signal + noise
        k = gcd(sampleRateAudio,sampleRateForDetection);
        xsn_temp = resample(xsn_temp,sampleRateForDetection/k,sampleRateAudio/k);
        xsn_temp = xsn_temp(1:kernelLength_det); % trim observation to fixed duration
        xsn_temp = digitalSingleFilter(DigitalFilter,xsn_temp,'MetricsOutput',false,...
            'FilterMode','filtfilt','DataWrap',true); % filter observation
        xsn(:,m) = xsn_temp;
    end
    close(h) % close waitbar
    fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))

    % Compute Variance of Background Noise
    fprintf('# Computing background noise variance ')
    noiseVar = noiseVariance(xsn); % original noise variance
    fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
    
    % Estimate Signal Variance and SNR
    signalVars(:,1) = std(xsn).^2 - noiseVar;
    signalVars(signalVars < 0) = 0;
    noiseVars = noiseVar * ones(nKernels,1);
    snrLevels(:,1) = 10*log10(signalVars/noiseVar);
    
    % Load Eigenvectors and Eigenvalues
    if ismember(detectorType,{'ecw','ecc'})
        fprintf('# Loading eigen data ')
        EigenData = load(eigenPath);
        fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
    end
                
    % Process Decision Statistic
    fprintf('# Processing decision statistic ')
    if strcmp(detectorType,'ed')
        testStats = testStatistics(xsn,detectorType,'DisplayProgress',true);
    else % detectorType = {'ecw','ecc'}
        testStats = testStatistics(xsn,detectorType,noiseVar,...
            EigenData,'DisplayProgress',true);
    end
    testStats = testStats(:);
    fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
    
    % Load Detector Performance    
    fprintf('# Loading detector performance ')
    Struct = load(performancePath);
    Performance = Struct.PerformanceData;
    fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
    
    % Process Detection Thresholds
    fprintf('# Processing detection thresholds ')
    [thresholds,rtpFalseAlarms,rtpDetections] = detectionThresholds(...
        Performance,rtpFalseAlarmTarget,detectorSensitivity,signalVars,...
        noiseVar);
    fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS')) 
    
    % Determine which Segments are Detections
    isDetections = testStats > thresholds & snrLevels >= minSnrLevel;   
    
    % Group Kernels into Windows
    fprintf('# Grouping kernels into windows ')
    [is1,is2,in1,in2] = groupKernels(isDetections,nKernelsPerWindow);
    fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
    
    % Determine Noise Segments (start, end)
    iWindowSample1_noise = kernelLength_aud * (in1 - 1) + 1;
    iWindowSample2_noise = kernelLength_aud * in2;
    
    % Determine Signal Segments (start, end)
    iWindowSample1_signal = kernelLength_aud * (is1 - 1) + 1;
    iWindowSample2_signal = kernelLength_aud * is2;
    
    % Locate Peak Energy
    fprintf('# Locating peak within windows ')
    nWindows = length(is1);
    iWindowSample_signal = zeros(1,nWindows);
    for m = 1:nWindows
        % Locate Pulse Peak
        xsn_win = audioData(iWindowSample1_signal(m):iWindowSample2_signal(m));
        xsn_win = xsn_win - mean(xsn_win);
        smoothLength = ceil(length(xsn_win)/30);
        [~,iPeak1] = max(abs(xsn_win));
        [~,iPeak2] = max(smoothma(xsn_win,smoothLength,'rms','copy'));
        iPeak = round(mean([iPeak1 iPeak2]));
        
        % Determine Absolute Sample Position for Peak
        if iPeak <= kernelLength_aud
            iWindowSample_signal(m) = iWindowSample1_signal(m) + iPeak - 1;
        else
            iWindowSample_signal(m) = iWindowSample1_signal(m) + iPeak1 - 1;
        end
    end
    fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
    
    % Adjust windows
    if ~isempty(offsetLength_aud)
        fprintf('# Adjusting position of windows ')
        for m = 1:nWindows
            nSamplesInWindow = kernelLength_aud * (is2(m) - is1(m) + 1);
            iWindowSample1_signal(m) = iWindowSample_signal(m) ...
                - offsetLength_aud;
            iWindowSample2_signal(m) = iWindowSample1_signal(m) ...
                + nSamplesInWindow - 1;
        end
        fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
    end
    
    % Remove Out-Of-Bounds Detections
    isOob = iWindowSample1_signal < 1 | iWindowSample1_noise < 1 | ...
        iWindowSample2_signal > audioLength | ...
        iWindowSample2_noise > audioLength; % TRUE for elements out of bounds
    iWindowSample_signal = iWindowSample_signal(~isOob);
    iWindowSample1_signal = iWindowSample1_signal(~isOob);
    iWindowSample1_noise = iWindowSample1_noise(~isOob);
    iWindowSample2_signal = iWindowSample2_signal(~isOob);
    iWindowSample2_noise = iWindowSample2_noise(~isOob);
          
    % Build Output Structure
    AudDetData.signalTime = (iWindowSample_signal - 1)/sampleRateAudio;
    AudDetData.signalTime1 = (iWindowSample1_signal - 1)/sampleRateAudio;
    AudDetData.signalTime2 = (iWindowSample2_signal - 1)/sampleRateAudio;
    AudDetData.noiseTime1 = (iWindowSample1_noise - 1)/sampleRateAudio;
    AudDetData.noiseTime2 = (iWindowSample2_noise - 1)/sampleRateAudio;

    % Build Internal Data Structure
    InternalData.audiodbPath = audiodbPath;
    InternalData.isDetections = isDetections;
    InternalData.thresholds = thresholds;
    InternalData.testStats = testStats;
    InternalData.signalVars = signalVars;
    InternalData.noiseVars = noiseVars;
    InternalData.snrLevels = snrLevels;
    InternalData.rtpFalseAlarms = rtpFalseAlarms;
    InternalData.rtpDetections = rtpDetections;
end

% Plot Waveform & Detections (PROVISIONAL TEST)
% figure
% hold on
% t = (0:kernelLength_aud*nKernels-1)/sampleRateAudio;
% h(1) = plot(t,audioData(1:kernelLength_aud*nKernels),'Color',[0.8 0.8 0.8]);
% for m = 1:nWindows
%     i1 = iWindowSample1_signal(m);
%     i2 = iWindowSample2_signal(m);
%     t_pulse = ((i1:i2) - 1)/sampleRateAudio;
%     h(2) = plot(t_pulse,audioData(i1:i2),'Color',[0.4 0.4 0.4]);
% end
% xlabel('Time [s]')
% ylabel('Amplitude')
% title({sprintf(['Detector = ''%s'', Sensitivity = %0.1f, Min SNR = %d dB, '...
%     '%d-%d Hz'],detectorType,detectorSensitivity,minSnrLevel,...
%     cutoffFreqs(1),cutoffFreqs(2));''})
% legend(h,{'Rejected','Detected'},'location','southeast')
% box on
% set(gcf,'PaperPositionMode','auto')
% set(gcf,'units','normalized','outerposition',[0.1 0.1 0.8 0.8])
% set(gcf,'PaperPositionMode','auto')
% pbaspect([1 1 1])
% figureName = sprintf(['Waveform (%s,%s,sensit%0.0f,minSnr%0.0fdB,f%0.0f'...
%     '-%0.0f)'],detectorType,estimator,detectorSensitivity*100,minSnrLevel,...
%     cutoffFreqs(1),cutoffFreqs(2));
% print(figureName,'-dpng','-r250')

% Plot Test Statistics and Thresholds (PROVISIONAL TEST)
% snrLevels_temp = -30:0.2:30;
% signalVars_temp = noiseVar*10.^(snrLevels_temp/10);
% thresholds_temp = detectionThresholds(Performance,rtpFalseAlarmTarget,...
%     detectorSensitivity,signalVars_temp,noiseVar);
% iValid = testStats >= thresholds;
% snrLevels_val = snrLevels(iValid);
% testStats_val = testStats(iValid);
% snrLevels_wro = snrLevels(~iValid);
% testStats_wro = testStats(~iValid);
% figure
% hold on
% scatter(snrLevels_wro,testStats_wro,10,'b','filled','Marker','o',...
%     'MarkerFaceColor',[0.8 0.8 0.8],'MarkerEdgeColor','none');
% scatter(snrLevels_val,testStats_val,10,'b','filled','Marker','o',...
%     'MarkerFaceColor',[0.4 0.4 0.4],'MarkerEdgeColor','none');
% plot(snrLevels_temp,thresholds_temp,'k','linewidth',1.5)
% xlabel('SNR [dB]')
% ylabel('\gamma''')
% axis([-30 30 1e0 1e7])
% set(gca,'YScale','log')
% legend({'T (Rejected)','T (Detected)','\gamma_{FA}'},...
%     'Location','SouthEast')
% title({sprintf(['Detector = ''%s'', Sensitivity = %0.1f, Min SNR = %d dB, '...
%     '%d-%d Hz'],detectorType,detectorSensitivity,minSnrLevel,...
%     cutoffFreqs(1),cutoffFreqs(2));''})
% box on
% grid on
% set(gcf,'PaperPositionMode','auto')
% set(gca,'XTick',[-30 -20 -10 0 10 20 30])
% set(gca,'XTickLabel',{'-30','-20','-10','0','10','20','30'})
% set(gcf,'units','normalized','outerposition',[0.1 0.1 0.8 0.8])
% set(gcf,'PaperPositionMode','auto')
% pbaspect([1 1 1])
% figureName = sprintf(['Stats vs SNR (%s,%s,sensit%0.0f,minSnr%0.0fdB,f%0.0f'...
%     '-%0.0f)'],detectorType,estimator,detectorSensitivity*100,minSnrLevel,...
%     cutoffFreqs(1),cutoffFreqs(2));
% print(figureName,'-dpng','-r250')
% savefig(figureName)
