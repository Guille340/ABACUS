%  AUDIOIMPORTCONFIG_RAW (Script)
%
%  DESCRIPTION
%  Input configuration script for the audio import stage for audio files
%  of format 'RAW'. 
%
%  This script is updated manually and executed with READAUDIOIMPORTCONFIG 
%  to create a structure AUDIMPCONFIGFILE that is used to populate a full 
%  audio configuration structure AUDIMPCONFIG. The latter is used by
%  AUDIOIMPORTFUN to import and resample (if applicable) the audio files in
%  the folders and paths listed in '<ROOTDIR>\configdb\audioPaths.json'. The 
%  configuration information and audio data from each audio file are saved 
%  as individual Audio Databases (.mat) in directory '<ROOTDIR>\audiodb'.
%
%  Audio import configuration scripts must follow the naming convention
%  'audioImportConfig<CHAR>_<NUM>.json', where <CHAR> is a character vector
%  and <NUM> is a number indicating the reading and processing order for the 
%  configuration files (e.g. audioImportConfig_TK_CH1_01). 
%
%  More than one AUDIOIMPORTCONFIG script can be created (e.g. for processing
%  a different audio channel or applying a different resampling rate). 
%  Configuration scripts must be saved in directory '<ROOTDIR>/configdb' for 
%  the software to be able to find and run them.
%
%  INPUT FIELDS
%  - 'audioFormat': format of the audio file ('RAW' always for this template)
%  - 'channel': channel to process.
%  - 'resampleRate': new sampling rate after resampling [Hz]
%  - 'sampleRate': sampling rate [Hz].
%  - 'bitDepth': bit resolution (i.e., bits per channel and sample)
%  - 'numChannels': number of channels.
%  - 'endianness': endianess ('l' = little endian, 'b' = big endian)
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
%  See also READAUDIOIMPORTCONFIG

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  05 Jul 2021

AudImpConfigFile.audioFormat = 'RAW';
AudImpConfigFile.channel = []; % channel number
AudImpConfigFile.resampleRate = []; % new sampling rate [Hz]
AudImpConfigFile.sampleRate = [];
AudImpConfigFile.bitDepth = [];
AudImpConfigFile.numChannels = [];
AudImpConfigFile.endianness = [];
