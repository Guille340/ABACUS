%  AUDIOPROCESSCONFIG (Script)
%
%  DESCRIPTION
%  Input configuration script for the audio processing stage. 
%
%  This script is updated manually and read by READAUDIOPROCESSCONFIG to 
%  create a structure AUDPROCONFIGFILE that is used to populate a full 
%  audio process configuration structure AUDPROCONFIG. The latter is used 
%  by AUDIOPROCESSFUN to process the acoustic metrics of the audio segments 
%  or "sound events" identified by the detection algorithm and save the 
%  results into individual Acoustic Databases (.mat), stored in '<ROOTDIR>/
%  acousticdb'.
%
%  Audio process configuration scripts must follow the naming convention
%  'audioProcessConfig<CHAR>_<NUM>.json', where <CHAR> is a character 
%  vector and <NUM> is a number indicating the reading and processing order 
%  for the configuration files (e.g. acousticProcessConfig_TK_CH1_01). 
%
%  Create as many AUDIOPROCESSCONFIG scripts as RECEIVERNAME/SOURCENAME 
%  combinations you wish to process. Configuration scripts must be saved 
%  in directory '<ROOTDIR>/configdb' for the SPLToolbox to be able to find 
%  and run them. 
%
%  INPUT FIELDS
%  - receiverName: name of the receiver to be processed.
%  - sourceName: name of the primary source to be processed.
%  - freqLimits: two-element array representing the bottom and top frequency
%    limits for processing, in Hertz.
%  - bandsPerOctave: number of bands per octave (e.g. 3 for third-octave).
%  - cumEnergyRatio: ratio of the total energy of an audio segment that
%    delimits the signal of interest. Value between 0 and 1.
%    For example, CUMENERGYRATIO = 0.9 for T90.
%  - audioTimeFormat: timestamp format string. Typical formats are:
%    ? 'yyyymmdd_HHMMSS_FFF*' for SeicheSSV
%    ? '*yyyymmdd_HHMMSS_FFF' for PamGuard
%    ? '*yyyymmdd_HHMMSS' for Wildlife Acoustics SM4M
%  - timeOffset: PC clock offset, in seconds (UTC = PC - TIMEOFFSET).
%  - tags: cell vector of tag names. These names will be available in the
%    revision module to identify specific sections of the data.
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

AudProConfigFile.receiverName = '';
AudProConfigFile.sourceName = '';
AudProConfigFile.freqLimits = [];
AudProConfigFile.bandsPerOctave = [];
AudProConfigFile.cumEnergyRatio = [];
AudProConfigFile.audioTimeFormat = '';
AudProConfigFile.timeOffset = [];
AudProConfigFile.tags = {''};
