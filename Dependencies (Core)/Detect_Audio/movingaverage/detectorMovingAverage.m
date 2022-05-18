%  AudDetData = DETECTORMOVINGAVERAGE(root,audiodbName,AudDetConfig)
%
%  DESCRIPTION
%  Moving average algorithm for the detection of sound events in the 
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
%  according to the type of detector. For the Moving Average detector,
%  DETECTPARAMETERS includes: WINDOWDURATION, duration of the processing
%  window; WINDOWOFFSET, backward displacement for the procssing window;
%  THRESHOLD, ratio of RMS amplitudes from the target and noise windows;
%  CUTOFFFREQS, two-element vector containing the bottom and top cutoff
%  (-3 dB) frequencies of the detection bandpass filter.
%
%  DETECTORMOVINGAVERAGE divides the audio file into segments of duration
%  WINDOWDURATION, filters the signal from each window with a bandpass
%  filter of half-power frequencies CUTOFFFREQS, calculates the RMS amplitude 
%  of each filtered window and obtains the ratio of RMS amplitudes for every 
%  two consecutive windows (forth window divided by back window). Windows 
%  with a ratio higher than THRESHOLD are assumed to contain a target event 
%  (detection). For a window classified as 'detection', that ratio is 
%  effectively the signal plus noise to noise ratio (SNNR).For every two
%  consecutive windows with detections, the one with the lowest RMS value
%  (typically the earliest one) is removed. As final step, the windows with
%  detection are then adjusted to start WINDOWOFFSET milliseconds before the 
%  maximum RMS value wihin the window.
%
%  The detection THRESHOLD is calculated automatically when specified as
%  an empty parameter in AUDDETCONFIG. The automatic thresholding assumes
%  that the noise accounts for most of the energy in the audio file and
%  that the SNNR of the target signal is always larger than most of the 
%  SNNR of noise segments. Specifically, the histogram of the SNNR is
%  calculated; the maximum count typically occurs at a ratio of 1, and has
%  a Gauss-type distribution with its width being related to the variance of 
%  background noise in the file. The THRESHOLD is then calculated as twice
%  the ratio at which the maximum noise bell's count falls to 5% of its
%  value.
%
%  DETECTORMOVINGAVERAGE performs extremelly well with transient signals
%  with small duty cycles and reasonable SNNR (> 1 dB). That is generally
%  the case for airgun and piling noise
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
%
%  FUNCTION CALL
%  AudDetData = DETECTORMOVINGAVERAGE(root,audiodbName,AudDetConfig)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  See also AUDIODETECTFUN, READAUDIODETECTCONFIG

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  13 Aug 2021

function [AudDetData,threshold] = detectorMovingAverage(root,...
    audiodbName,AudDetConfig)

% Load Detection Parameters
windowDuration = AudDetConfig.DetectParameters.windowDuration;
windowOffset = AudDetConfig.DetectParameters.windowOffset;
threshold = AudDetConfig.DetectParameters.threshold;
cutoffFreqs = AudDetConfig.DetectParameters.cutoffFreqs;

% Load Audio Database and Parameters
fprintf('# Loading audio database ')
audiodbPath = fullfile(root.block,'audiodb',audiodbName);
AudioDatabase = load(audiodbPath);
AudImpConfig = AudioDatabase.AudImpConfig;
audioData = AudioDatabase.AudImpData.audioData;
audioData = audioData(:);
resampleRate = AudImpConfig.resampleRate;
clear AudioDatabase
fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))

% Vector Lengths
windowLength = round(windowDuration*resampleRate);
audioLength = length(audioData);

% Calculate DC-Offset In Ten-Second Intervals
dcWindowLength = min(round(10*resampleRate),audioLength); % length of DC-processing window
[dcOffsets,iDcOffsets] = getDcOffset(audioData,dcWindowLength);

% Moving Average
fprintf('# Applying moving average detection algorithm to audio data ')
maxBlockSize = 50; % maximum processing block size (MB)
nWindowsPerBlock = floor(maxBlockSize*1024^2/(windowLength*8));
nWindows = floor(audioLength/windowLength); % number of detection windows
nBlocks = ceil(nWindows/nWindowsPerBlock); % number of processing blocks
xrms = nan(1,nWindows);
for m = 1:nBlocks
    % Start and End Indices for Windows and Blocks
    iWindow1 = (m-1)*nWindowsPerBlock + 1; % start index of detection window
    iWindow2 = min(m*nWindowsPerBlock,nWindows); % end index of detection window 
    iWindowSample1 = windowLength*(iWindow1:iWindow2)- windowLength + 1; % start samples of detection windows
    iWindowSample2 = windowLength*(iWindow1:iWindow2); % end samples of detection windows
    iBlockSample1 = windowLength*((m-1)*nWindowsPerBlock) + 1; % start sample of block
    iBlockSample2 = windowLength*min(m*nWindowsPerBlock,nWindows); % end sample of block
    
    % DC Offset
    iWindowSample = round(mean([iWindowSample1;iWindowSample2])); % sample position of detection windows (centre)
    dcOffsetsInBlock = dcOffsets;
    if length(dcOffsets) > 1
        dcOffsetsInBlock = interp1(iDcOffsets,dcOffsets,iWindowSample,...
            'nearest','extrap');
    end 
    
    % Reshape Block into Windows and Correct DC Offset
    nWindowsInThisBlock = iWindow2 - iWindow1 + 1; 
    xr = reshape(audioData(iBlockSample1:iBlockSample2),windowLength,...
        nWindowsInThisBlock) - dcOffsetsInBlock;
    
    % Bandpass Filter
    fn1 = 2*cutoffFreqs(1)/resampleRate;
    fn2 = 2*cutoffFreqs(2)/resampleRate;
    xrms(1,iWindow1:iWindow2) = fftFilter(xr,fn1,fn2);
end
fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))

% Automatic Threshold (if empty)
xrmsRatio = xrms(2:end)./xrms(1:end-1);
if isempty(threshold)
    % Histogram of XRMSRATIO amplitudes
    xrmsRatio_step = 0.01;
    xrmsRatio_max = 10;
    edges = 0:xrmsRatio_step:xrmsRatio_max;
    counts = histcounts(xrmsRatio,edges);
    [maxCounts,iMaxCounts] = max(counts);
    
    % Adjust Edges (by making sure MAXCOUNTS is large enough)
    cnt = 1;
    edges_temp = edges;
    counts_temp = counts;
    while maxCounts < 10 && cnt < 10
        nCounts = cnt + 1; % number of counts to group
        nGroups = ceil(length(counts)/nCounts); % number of groups
        zpad = nGroups*nCounts - length(counts);
        edges_temp = edges(1:nCounts:end);
        counts_temp = sum(reshape([counts, zeros(1,zpad)],nCounts,nGroups));
        [maxCounts,iMaxCounts] = max(counts_temp);
        cnt = cnt + 1;
    end
    edges = edges_temp;
    counts = counts_temp;
    
    % Determine Half Width of Main (Noise) Lobe
    % NOTE: use 0.2 > halfWidthRatio > 0.02 (lower = higher threhsold, more 
    % misses; higher = lower threshold, more false alarms)
    halfWidthRatio = 0.05; % the lower the larger the threshold
    iBotCounts = length(counts) - find(fliplr(counts) > ceil(halfWidthRatio*...
        maxCounts),1,'first') + 1;
    
    % Calculate Threshold as Lobe Width after Lobe Peak
    iThres = (iBotCounts - iMaxCounts  + 1)*2 + iMaxCounts;
    iThres = min(iThres,floor(mean([iBotCounts, length(edges)]))); % adjust if exceeds LENGTH(EDGES)
    threshold = edges(iThres);
end

% Identify Detections (iDetections = index of windows with a detection)
iDetections = find(xrmsRatio > threshold) + 1;

% Determine Noise Segments (start, end)
iWindowSample1_noise = windowLength*(iDetections - 2) + 1;
iWindowSample2_noise = windowLength*(iDetections - 1);

% Determine Signal Segments (start, end)
iWindowSample1_signal = windowLength*(iDetections - 1) + 1;
iWindowSample2_signal = windowLength*iDetections;
iWindowSample_signal = mean([iWindowSample1_signal; iWindowSample2_signal]);

% Locate Peak Energy
fprintf('# Locating peak within windows ')
nDetections = length(iDetections);
rmsPeak = nan(nDetections,1);
for m = 1:nDetections
    % DC Offset
    dcOffsetInWindow = dcOffsets;
    if length(dcOffsets) > 1
        dcOffsetInWindow = interp1(iDcOffsets,dcOffsets,...
            iWindowSample_signal(m),'nearest','extrap');
    end 
    
    % Gate Detection Waveform, Correct DC Offset and Smooth
    xsn_win = audioData(iWindowSample1_signal(m):iWindowSample2_signal(m)) ...
        - dcOffsetInWindow;
    smoothLength = ceil(length(xsn_win)/30);
    xsn_smooth = smoothma(xsn_win,smoothLength,'rms','copy');
    
    % Re-Position Windows around Energy Peak
    [rmsPeak(m),iRmsPeak] = max(xsn_smooth);
    iWindowSample_signal(m) = iWindowSample1_signal(m) + iRmsPeak - 1;
end
fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))

% Adjust windows
offsetLength = round(windowOffset*resampleRate);
if ~isempty(offsetLength)
    fprintf('# Adjusting position of windows ')
    for m = 1:nDetections  
        iWindowSample1_signal(m) = iWindowSample_signal(m) - offsetLength;
        iWindowSample2_signal(m) = iWindowSample1_signal(m) + windowLength - 1;
        iWindowSample1_noise(m) = iWindowSample1_signal(m) - windowLength;
        iWindowSample2_noise(m) = iWindowSample1_signal(m) - 1;   
    end
    fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
end

% Remove Duplicate Detections (delete the one with lowest rmsPeak value)
fprintf('# Removing duplicated detections ')
isConsecutive = diff(iDetections) == 1; % logical vector of consecutive detections
ind = find(isConsecutive(1:end) == 1,1,'first'); % index of first two consecutive detections
iDelete = [];
if ~isempty(ind)
    [~,iMin] = min([rmsPeak(ind),rmsPeak(ind+1)]); % index of chosen detection window
    iDelete = ind + iMin - 1;
    ind = ind + 2; % update search index (skip next detection)
    cnt = 2; % initialise counter
    while ind < nDetections - 1
        ind = find(isConsecutive(ind:end) == 1,1,'first') + ind - 1;
        if ~isempty(ind)
            [~,iMin] = min([rmsPeak(ind),rmsPeak(ind+1)]); % index of detection to discard (1 or 2)
            iDelete(cnt) = ind + iMin - 1;
            ind = ind + 2;
            cnt = cnt + 1;
        end
    end
end
iWindowSample_signal(iDelete) = [];
iWindowSample1_signal(iDelete) = [];
iWindowSample2_signal(iDelete) = [];
iWindowSample1_noise(iDelete) = [];
iWindowSample2_noise(iDelete) = [];
fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))

% Build Output Structure
AudDetData.signalTime = (iWindowSample_signal - 1)/resampleRate;
AudDetData.signalTime1 = (iWindowSample1_signal - 1)/resampleRate;
AudDetData.signalTime2 = (iWindowSample2_signal - 1)/resampleRate;
AudDetData.noiseTime1 = (iWindowSample1_noise - 1)/resampleRate;
AudDetData.noiseTime2 = (iWindowSample2_noise - 1)/resampleRate;

% % TEST (Plot Detections)
% nDetections = length(iWindowSample_signal);
% for m = 1:nDetections
%     iWindowSample1 = windowLength*(iDetections(m) - 1) + 1;
%     iWindowSample2 = windowLength*iDetections(m);
%     
%     % DC Offset
%     iWindowSample = round(mean([iWindowSample1,iWindowSample2])); % sample position of detection windows (centre)
%     dcOffsetInWindow = interp1(iSampleInWindows_dc,dcOffsets,iWindowSample,...
%         'nearest','extrap');
%     
%     x = audioData(iWindowSample1_signal(m):iWindowSample2_signal(m)) - dcOffsetInWindow;
%     xs = smoothma(x,fix(length(x)/50),'rms','copy');
%     
%     figure
%     hold on
%     plot(x,'c')
%     plot(xs,'m','linewidth',2)  
% end
