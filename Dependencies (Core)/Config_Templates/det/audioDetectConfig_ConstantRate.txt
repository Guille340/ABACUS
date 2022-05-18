%  AUDIODETECTCONFIG (Script, detection algorithm 'ConstantRate')
%
%  DESCRIPTION
%  Input configuration script for the detection stage using a 'ConstantRate' 
%  detection algorithm. The 'ConstantRate' detector identifies as "events"
%  segments of duration WINDOWDURATION spaced PULSEINTERVAL_MS, with the first 
%  pulse starting at FIRSTPULSE_S.
%
%  The PULSEINTERVAL_MS and FIRSTPULSE_S parameters are specified for each 
%  audio file AUDIONAME through the Pulse Table (.csv) with name FILENAME 
%  stored in '<ROOTDIR>\configdb\'. This method is specifically aimed at 
%  sources with a stable firing rate and low signal-to-noise ratio, such as 
%  sub-bottom profilers (SBP) and sparkers.
%
%  This script is updated manually and read by READAUDIODETECTCONFIG to create 
%  a structure AUDDETCONFIGFILE that is used to populate a full audio detect 
%  configuration structure AUDDETCONFIG. The latter is used by AUDIODETECTFUN 
%  to detect "sound events" from the audio files listed in '<ROOTDIR>\configdb\
%  audioPaths.json' and save the results into individual Acoustic Databases 
%  (.mat), stored in '<ROOTDIR>/acousticdb'.
%
%  Audio detect configuration scripts must follow the naming convention
%  'audioDetectConfig<CHAR>_<NUM>.json', where <CHAR> is a character vector 
%  and <NUM> is a number indicating the reading and processing order for the 
%  configuration files (e.g. acousticDetectConfig_TK_CH1_01). 
%
%  Create as many AUDIODETECTCONFIG scripts as RECEIVERNAME/SOURCENAME 
%  combinations you wish to process. Configuration scripts must be saved in 
%  directory '<ROOTDIR>/configdb' for the software to be able to find and run 
%  them. 
%
%  INPUT FIELDS
%  - receiverName: name of the receiver to be processed.
%  - sourceName: name of the primary source to be processed.
%  - detector: character vector specifying the detection algorithm
%    ('ConstantRate' for this template).
%  - DetectParameters: structure containing the detection parameters specific 
%    for the selected algorithm. For DETECTOR = 'ConstantRate' this structure 
%    contains the following fields:
%    ¬ windowDuration: duration of the detection window, in seconds.
%      Set it to fit the entire signal to be processed (long enough to
%      accomodate the longest signal duration, but as short as possible to
%      minimise background noise contribution). This same duration is applied 
%      to the front (signal) and the back (noise) windows.
%    ¬ windowOffset: backward displacement of the front window, in seconds, 
%      relative to the time where the maximum energy of the detection occurs. 
%      Must be a value between 0 and WINDOWDURATION. For best results, use a 
%      value between 0 and WINDOWDURATION/2. Set as [] for no window adjustement.
%    ¬ fileName: name of the Pulse Table (.csv) containing detection parameters 
%      specific for various audio files. The table must include a first line or 
%      header with the detection parameters FIRSTPULSE_MS, PULSEINTERVAL_MS, 
%      and AUDIOPATH (not necessarily in this order), followed by the 
%      corresponding values for each audio file (one row per audio file). 
%      Below is an example of what the CSV table may look like:
%
%       FirstPulse_s,PulseInterval_ms,AudioName
%       79,504.10,C:\Audio\PAM_20200117_012158_562.wav
%       394,504.07,C:\Audio\PAM_20200117_045345_295.wav
%       160,504.17,C:\Audio\PAM_20200117_050000_000.wav
%
%  SCRIPT DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - None
%
%  CONSIDERATIONS & LIMITATIONS
%  - This configuration script is now implemented as .json files. The .m
%    format is now obsolete (this help is still applicable and a useful
%    reference).
%
%  See also READAUDIODETECTCONFIG, AUDIODETECTFUN

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  16 Jul 2021

AudDetConfigFile.receiverName = '';
AudDetConfigFile.sourceName = '';
AudDetConfigFile.detector = 'ConstantRate';
AudDetConfigFile.DetectParameters.windowDuration = [];
AudDetConfigFile.DetectParameters.windowOffset = [];
AudDetConfigFile.DetectParameters.fileName = [];
