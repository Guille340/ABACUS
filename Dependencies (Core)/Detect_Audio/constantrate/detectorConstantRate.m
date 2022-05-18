%  AudDetData = DETECTORCONSTANTRATE(root,audiodbName,AudDetConfig)
%
%  DESCRIPTION
%  Algorithm for the detection of sound events in the AudioDatabase 
%  AUDIODBNAME stored in '<ROOT.BLOCK>\audiodb' based on a Pulse Table (.csv)
%  stored in '<ROOT.BLOCK>\configdb' and general detection parameters from
%  AUDDETCONFIG.DETECTPARAMETERS. The Pulse Table contains the name of 
%  the audio file, the time of the first pulse, and the pulse interval for
%  each audio file to be processed. 
%
%  The function returns a structure AUDDETDATA containing the exact time of 
%  the detections, and the start and end times of the 'target' and 'noise' 
%  windows. All times are expressed in seconds relative to the start of the 
%  file (see INITIALISEAUDIODETECTDATA for further information about the 
%  fields in AUDDETDATA structure).
%
%  DETECTPARAMETERS is a substructure contained in the Audio Detect Config
%  structure generated from the corresponding .json file stored in folder
%  '<ROOT.BLOCK>\configdb' (see READAUDIODETECTCONFIG). The fields vary
%  according to the type of detector. For the Constant Rate detector,
%  DETECTPARAMETERS includes: WINDOWDURATION, duration of the processing
%  window; WINDOWOFFSET, backward displacement for the procssing window;
%  and FILENAME, name of the Pulse Table (.csv) in '<ROOT.BLOCK>\configdb'.
%
%  DETECTIONCONSTANTRATE determines the location of the processing windows 
%  of duration WINDOWDURATION for both the target pulse and associated 
%  background noise by assuming a constant pulse rate. The noise window,
%  relevant for assessing the signal to noise ratio of the target event,
%  is placed immediately before the target window. This method is
%  particularly useful in those cases where the target signal is emitted
%  at a steady rate (e.g. sparker, sub-bottom profiler) and a conventional 
%  detection algorithm fails to accurately detect the target events (small
%  SNR).
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
%  AudDetData = DETECTORCONSTANTRATE(root,audiodbName,AudDetConfig)
%
%  FUNCTION DEPENDENCIES
%  - readPulseTable
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  See also AUDIODETECTFUN, READAUDIODETECTCONFIG

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  13 Aug 2021

function AudDetData = detectorConstantRate(root,audiodbName,AudDetConfig)

% Display Initialisation Message
audiodbPath = fullfile(root.block,'audiodb',audiodbName);
[~,audiodbName,audiodbExt] = fileparts(audiodbPath); % name of audio database (no extension)
fprintf('RUNNING DETECTION ALGORITHM (''%s'') [%s]\n',...
    strcat(audiodbName,audiodbExt),datestr(clock,'dd-mmm-yyyy HH:MM:SS'))

% Load Detection Parameters
windowDuration = AudDetConfig.DetectParameters.windowDuration; % window duration [ms]
windowOffset = AudDetConfig.DetectParameters.windowOffset; % window offset [ms]
fileName = AudDetConfig.DetectParameters.fileName;

% Load AUDIMPCONFIG Parameters
Structure = load(audiodbPath,'AudImpConfig');
audioLength = Structure.AudImpConfig.audioLength;
channel = Structure.AudImpConfig.channel;
resampleRate = Structure.AudImpConfig.resampleRate;

% Initialise Indices of Detection Windows
iWindowSample_signal = [];
iWindowSample1_signal = [];
iWindowSample2_signal = [];
iWindowSample1_noise = [];
iWindowSample2_noise = []; 
        
filePath = fullfile(root.block,'configdb',fileName); % path of pulse table file
PulseTable = readPulseTable(filePath);
if ~isempty(PulseTable)
    % Load Parameters from Pulse Table
    audioNames = PulseTable.audioName;
    firstPulses = PulseTable.firstPulse; % vector of first pulses (s]
    pulseIntervals = PulseTable.pulseInterval; % vector of pulse intervals [ms]
    
    % Calculate Detection Intervals
    audioName = strrep(audiodbName,sprintf('_ch%d_fr%d',channel,...
        resampleRate),'');
    [~,audioNames] = cellfun(@(x) fileparts(x),audioNames,'Uniform',false); % audio names in pulse table (no extension)
    iFile = find(ismember(audioNames,audioName));
    if ~isempty(iFile) % if at least one 
        fprintf('# Calculating detection intervals ')
        % Vector Lengths
        windowLength = round(windowDuration*resampleRate);
        windowOffsetLength = round(windowOffset*resampleRate);
        firstPulseSample = round(firstPulses(iFile)*resampleRate) + 1;
        pulseIntervalLength = round(pulseIntervals(iFile)*1e-3 ...
            * resampleRate);
    
        % Start and End Indices of Windows
        nWindows = floor((audioLength - firstPulseSample + 1 ...
            + pulseIntervalLength - windowLength)/pulseIntervalLength);
        iWindowSample1_signal = firstPulseSample + (0:nWindows-1)...
            * pulseIntervalLength - windowOffsetLength;
        iWindowSample2_signal = iWindowSample1_signal + windowLength - 1;
        iWindowSample_signal = iWindowSample1_signal + round(windowLength/2);
        iWindowSample1_noise = iWindowSample1_signal - windowLength;
        iWindowSample2_noise = iWindowSample1_signal - 1;
        
        % Remove Detections with Windows Out of Bounds
        isDelete = iWindowSample1_noise < 1 ...
            | iWindowSample2_signal > audioLength;
        iWindowSample_signal(isDelete) = [];
        iWindowSample1_signal(isDelete) = [];
        iWindowSample2_signal(isDelete) = [];
        iWindowSample1_noise(isDelete) = [];
        iWindowSample2_noise(isDelete) = [];  
        fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
    else   
        fprintf('[!] No detection parameters available for audio file\n')
    end
end

% Build Output Structure
AudDetData.signalTime = (iWindowSample_signal - 1)/resampleRate;
AudDetData.signalTime1 = (iWindowSample1_signal - 1)/resampleRate;
AudDetData.signalTime2 = (iWindowSample2_signal - 1)/resampleRate;
AudDetData.noiseTime1 = (iWindowSample1_noise - 1)/resampleRate;
AudDetData.noiseTime2 = (iWindowSample2_noise - 1)/resampleRate;
