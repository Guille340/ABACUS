%  AudImpConfig = INITIALISEAUDIOIMPORTCONFIG()
%
%  DESCRIPTION
%  Initialises the audio import configuration structure AUDIMPCONFIG. All 
%  the fields in this structure are set as empty ([]).
%
%  The fields in AUDIMPCONFIG are described below.
%
%  AUDIMPCONFIG
%  ============
%  - inputStatus: TRUE if the audio import configuration is valid. This field 
%    is updated by function VERIFYAUDIOIMPORTCONFIG.
%  - configFileName: name of the audio import configuration file from which
%    AUDIMPCONFIG comes from.
%  - audioFormat: format of the audio files in 'audioPaths.json' that are
%    to be imported.
%    ¬ 'RAW': raw audio format (.raw, .pcm, .raw2int16)
%    ¬ 'WAV': wave audio format (.wav)
%  - channel: channel to import and resample.
%  - resampleRate: sampling rate after resampling [Hz]
%  - sampleRate: original sampling rate of the audio files [Hz]. 
%  - bitDepth: bit resolution (bits per sample).
%  - numChannels: number of channels in the audio files.
%  - endianness: endianess ('l' = little endian, 'b' = big endian).
%  - audioLength: number of samples in the audio file.
%
%  INPUT ARGUMENTS
%  - None
%
%  OUTPUT ARGUMENTS
%  - AudImpConfig: initialised audio import configuration structure.
%
%  FUNCTION CALL
%  AudImpConfig = initialiseAudioImportConfig()
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

function AudImpConfig = initialiseAudioImportConfig()

AudImpConfig = struct('inputStatus',[],'configFileName',[],...
    'audioFormat',[],'channel',[],'resampleRate',[],'sampleRate',[],...
    'bitDepth',[],'numChannels',[],'endianness',[],'audioLength',[]);
