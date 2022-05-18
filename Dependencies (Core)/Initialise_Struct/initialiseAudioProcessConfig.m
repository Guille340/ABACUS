%  AudProConfig = INITIALISEAUDIOPROCESSCONFIG()
%
%  DESCRIPTION
%  Initialises the audio process configuration structure AUDPROCONFIG. All 
%  the fields in this structure are set as empty ([]).
%
%  The fields in AUDPROCONFIG are described below.
%
%  AUDIMPCONFIG
%  ============
%  - inputStatus: TRUE if the audio process configuration is valid. This field 
%    is updated by function VERIFYAUDIOPROCESSCONFIG.
%  - configFileName: name of the audio process configuration file from which
%    AUDPROCONFIG comes from.
%  - channel: channel to import and resample.
%  - resampleRate: sampling rate after resampling [Hz]
%  - receiverName: name of the receiver to be processed.
%  - sourceName: name of the primary source to be processed.
%  - freqLimits: two-element array representing the bottom and top frequency
%    limits for processing, in Hertz.
%  - bandsPerOctave: number of bands per octave (e.g. 3 for third-octave).
%  - cumEnergyRatio: ratio of the total energy of an audio segment that is
%    expected to correspond to the signal of interest. Value between 0 and 1.
%  - audioTimeFormat: timestamp format string. Typical formats are:
%    ¬ 'yyyymmdd_HHMMSS_FFF*' for SeicheSSV
%    ¬ '*yyyymmdd_HHMMSS_FFF' for PamGuard
%    ¬ '*yyyymmdd_HHMMSS' for Wildlife Acoustics SM4M
%  - timeOffset: PC clock offset, in seconds.
%  - tags: cell vector of tag names. These names will be available in the
%    revision module to identify specific sections of the data.
%
%  INPUT ARGUMENTS
%  - None
%
%  OUTPUT ARGUMENTS
%  - AudProConfig: initialised audio process configuration structure.
%
%  FUNCTION CALL
%  AudProConfig = initialiseAudioProcessConfig()
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

function AudProConfig = initialiseAudioProcessConfig()

AudProConfig = struct('inputStatus',[],'configFileName',[],...
    'channel',[],'resampleRate',[],'receiverName',[],'sourceName',[],...
    'freqLimits',[],'bandsPerOctave',[],'cumEnergyRatio',[],...
    'audioTimeFormat',[],'timeOffset',[],'tags',[]);
