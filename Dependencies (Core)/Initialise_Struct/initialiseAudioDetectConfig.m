%  AudDetConfig = INITIALISEAUDIODETECTCONFIG()
%
%  DESCRIPTION
%  Initialises the audio detect configuration structure AUDDETCONFIG. All 
%  the fields in this structure are set as empty ([]).
%
%  The fields in AUDDETCONFIG are described below.
%
%  AUDDETCONFIG
%  ============
%  - inputStatus: TRUE if the audio detect configuration is valid. This field 
%    is updated by function VERIFYAUDIODETECTCONFIG.
%  - configFileName: name of the audio detect configuration file from which
%    AUDDETCONFIG comes from.
%  - channel: channel to be processed. 
%  - resampleRate: sample rate (after resampling) of the audio data [Hz]
%  - receiverName: name of the receiver to be processed.
%  - sourceName: name of the primary source to be processed.
%  - mirrorReceiver: name of the receiver to be mirrored. The current receiver
%    RECEIVERNAME copies the detection results from receiver MIRRORRECEIVER.
%    Useful for comparing the acoustic metrics between two adjacent sensors.
%  - detector: character vector specifying the detection algorithm.
%    ¬ 'Slice': the file is split into segments of equal duration. Suitable 
%      for ambient noise analysis.
%    ¬ 'MovingAverage': computes the RMS of consecutive windows of equal
%      duration and flags a detection when the RMS in the front window is a
%      specific number of times higher than the RMS in the window behind.
%    ¬ 'ConstantRate': audio data analysed with equally spaced windows of 
%      fixed duration and specific starting time. Suitable for sources with
%        steady pulse rate and low energy (e.g. SBP, sparker).
%    ¬ 'NeymanPearson': statistical approach for detecting sound events
%        with known covariance matrix.
%  - DetectParameters: structure containing the specific parameters for the 
%    selected detection algorithm. The fields vary depending on the detection
%    algorithm.
%
%  INPUT ARGUMENTS
%  - None
%
%  OUTPUT ARGUMENTS
%  - AudDetConfig: initialised audio detect configuration structure.
%
%  FUNCTION CALL
%  AudDetConfig = initialiseAudioDetectConfig()
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

function AudDetConfig = initialiseAudioDetectConfig()

AudDetConfig = struct('inputStatus',[],'configFileName',[],...
    'channel',[],'resampleRate',[],'receiverName',[],'sourceName',[],...
    'mirrorReceiver',[],'detector',[],'DetectParameters',[]);
