%  AudDetData = DETECTORCONSTANTRATE(root,audiodbName,AudDetConfig)
%
%  DESCRIPTION
%  Algorithm for the detection of sound events in the AudioDatabase 
%  AUDIODBNAME stored in '<ROOT.BLOCK>\audiodb' based on general detection 
%  parameters from AUDDETCONFIG.DETECTPARAMETERS. The function returns
%  a structure AUDDETDATA containing the exact time of the detections, and 
%  the start and end times of the 'target' and 'noise' windows. All times
%  are expressed in seconds relative to the start of the file (see
%  INITIALISEAUDIODETECTDATA for further information about the fields
%  in AUDDETDATA structure).
%
%  DETECTPARAMETERS is a substructure contained in the Audio Detect Config
%  structure generated from the corresponding .json file stored in folder
%  '<ROOT.BLOCK>\configdb' (see READAUDIODETECTCONFIG). The fields vary
%  according to the type of detector. For the Constant Rate detector,
%  DETECTPARAMETERS includes: WINDOWDURATION, duration of the processing
%  window.
%
%  DETECTIONSLICE slices the audio data into segments of duration
%  WINDOWDURATION. This approach is particularly aimed at analysing
%  continuous noise or general soundscapes with no focus on a particular
%  source. For that reason, and unlike other detection algorithms in this 
%  software, no difference is made between a 'target' and 'noise' window
%  (see DETECTORMOVINGAVERAGE, DETECTORCONSTANTRATE). 
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
%  AudDetData = DETECTORSLICE(root,audiodbName,AudDetConfig)
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

function AudDetData = detectorSlice(root,audiodbName,DetectParameters)

% Display Initialisation Message
audiodbPath = fullfile(root.block,'audiodb',audiodbName);
[~,audiodbName,audiodbExt] = fileparts(audiodbPath);
fprintf('RUNNING DETECTION ALGORITHM (''%s'') [%s]\n',...
    strcat(audiodbName,audiodbExt),datestr(clock,'dd-mmm-yyyy HH:MM:SS'))

% Load Detection Parameters
windowDuration = DetectParameters.windowDuration;

% Load AUDIMPCONFIG Parameters
Structure = load(audiodbPath,'AudImpConfig');
audioLength = Structure.AudImpConfig.audioLength;
resampleRate = Structure.AudImpConfig.resampleRate;

% Calculate Start and End Indices of Detection Windows
fprintf('# Slicing audio data ')
windowLength = round(windowDuration*resampleRate);
nWindows = floor(audioLength/windowLength);
iWindowSample = (0:nWindows-1)*windowLength + 1 + round(windowLength/2);
iWindowSample1 = (0:nWindows-1)*windowLength + 1;
iWindowSample2 = (1:nWindows)*windowLength;
fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))

% Build Output Structure
AudDetData.signalTime = (iWindowSample - 1)/resampleRate;
AudDetData.signalTime1 = (iWindowSample1 - 1)/resampleRate;
AudDetData.signalTime2 = (iWindowSample2 - 1)/resampleRate;
AudDetData.noiseTime1 = [];
AudDetData.noiseTime2 = [];
