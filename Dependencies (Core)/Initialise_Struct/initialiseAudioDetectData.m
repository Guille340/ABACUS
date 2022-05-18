%  AudDetData = INITIALISEAUDIODETECTDATA()
%
%  DESCRIPTION
%  Initialises the audio detect data structure AUDDETDATA. All the fields in 
%  this structure are set as empty ([]).
%
%  The fields in AUDDETDATA are described below.
%
%  AUDDETDATA
%  ============
%  - signalTime: vector of exact times for the detections, in seconds referred 
%    to the beginning of the audio file. The reference point for the exact time 
%    can be the highest pulse energy (for 'MovingAverage' detector) or the 
%    centre of the detection window.
%  - signalTime1: vector of times for the start of the detection windows, in
%    seconds referred to the beginning of the audio file. 
%  - signalTime2: vector of times for the end of the detection windows, in
%    seconds referred to the beginning of the audio file. 
%  - noiseTime1: vector of times for the start of the noise windows, in
%    seconds referred to the beginning of the audio file.
%  - noiseTime2: vector of times for the end of the noise windows, in
%    seconds referred to the beginning of the audio file. 
%
%  NOTE: the noise window is placed immediately before the signal (detection)
%  window and both have the same duration. There is the same number of signal
%  and noise windows.
%
%  INPUT ARGUMENTS
%  - None
%
%  OUTPUT ARGUMENTS
%  - AudDetData: initialised audio detect data structure.
%
%  FUNCTION CALL
%  AudDetData = initialiseAudioDetectData()
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  18 Jun 2021

function AudDetData = initialiseAudioDetectData()

AudDetData = struct('signalTime',[],'signalTime1',[],...
    'signalTime2',[],'noiseTime1',[],'noiseTime2',[]);
