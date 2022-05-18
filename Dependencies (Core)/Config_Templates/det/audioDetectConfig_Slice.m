%  AUDIODETECTCONFIG (Script, detection algorithm 'Slice')
%
%  DESCRIPTION
%  Input configuration script for the detection stage stage using a 'Slice'
%  detection algorithm. 
%
%  The 'Slice' detector splits the audio file in segments of equal SIGNALLENGTH 
%  duration. This method is particularly useful for background noise analysis.
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
%  - detector: character vector specifying the detection algorithm ('Slice'
%    for this template).
%  - DetectParameters: structure containing the detection parameters specific 
%    for the selected algorithm. For DETECTOR = 'Slice' this structure contains 
%    the following fields:
%    ¬ windowDuration: duration of the detection window, in seconds.
%      Set it to fit the entire signal to be processed (long enough to
%      accomodate the longest signal duration, but as short as possible to
%      minimise background noise contribution).
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
%  See also READAUDIOPROCESSCONFIG, AUDIOPROCESSFUN

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  16 Jul 2021

AudDetConfigFile.receiverName = '';
AudDetConfigFile.sourceName = '';
AudDetConfigFile.detector = 'Slice';
AudDetConfigFile.DetectParameters.windowDuration = [];
