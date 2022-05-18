%  AUDIODETECTCONFIG (Script, mirror channel)
%
%  DESCRIPTION
%  Input configuration script for the detection stage using a "mirroring"
%  approach. The method simply copies the detection information from another 
%  channel. 
%
%  This method is intended for comparing source detections from two nearby 
%  hydrophones. Detecting the events separately for each channel may result in 
%  different events being detected, due to slight differences in the measured 
%  signal. Generally, selecting the channel with higher SNR will provide 
%  reliable detection intervals that can be accurately applied to the main 
%  and mirrored channels.
%
%  This script is updated manually and read by READAUDIODETECTCONFIG to create 
%  a structure AUDDETCONFIGFILE that is used to populate a full audio detect 
%  configuration structure AUDDETCONFIG. The latter is used by AUDIODETECTFUN 
%  to detect "sound events" from the audio files listed in '<ROOTDIR>\configdb\
%  audioPaths.json' and save the results into individual Acoustic Databases 
%  (.mat), stored in '<ROOTDIR>/acousticdb'. In this particular case, 
%  AUDIODETECTFUN will only copy the detection information already available 
%  on a channel into the mirrored channel.
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
%  - mirrorReceiver: name of the receiver to be mirrored (e.g. 'Buoy1_H1'
%    if RECEIVERNAME = 'Buoy1_H2').
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
AudDetConfigFile.mirrorReceiver = '';
