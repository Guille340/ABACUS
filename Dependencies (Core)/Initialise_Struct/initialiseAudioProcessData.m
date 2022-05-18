%  AudProData = INITIALISEAUDIOPROCESSDATA()
%
%  DESCRIPTION
%  Initialises the audio process data structure AUDPRODATA. All the fields in 
%  this structure are set as empty ([]).
%
%  The fields in AUDPRODATA are described below.
%
%  AUDPRODATA
%  =========== 
%  - signalPcTick: vector of detection PC ticks, in seconds referred to '00 
%    Jan 0000'. SIGNALPCTICK = FILETICK + SIGNALTIME.
%  - signalUtcTick: vector of detection PC ticks, in seconds referred to '00 
%    Jan 0000'. SIGNALUTCTICK = FILETICK + SIGNALTIME - TIMEOFFSET.
%  - timeOffset: vector of time offsets at each detection instant. TIMEOFFSET
%    = SIGNALPCTICK - SIGNALUTCTICK.
%  - fileTimestamp: cell array of FILETICK timestamps with format 'yyyy-mmm-dd 
%    HH:MM:SS.FFF'.
%  - fileTick: tick of the start of the audio file, in seconds referred to '00 
%    Jan 0000'. The value is computed with AUDIOFILETICK from the name of the
%    audio file, which contains the timestamp of its first sample.
%  - signalTime1: vector of times for the start of the detection windows, in
%    seconds referred to the beginning of the audio file. 
%  - signalTime2: vector of times for the end of the detection windows, in
%    seconds referred to the beginning of the audio file. 
%  - signalEnergyTime1: vector of times for the start of the cumulative energy
%    window for the detections, in seconds referred to the beginning of the 
%    audio file. 
%  - signalEnergyTime2: vector of times for the end of the cumulative energy
%    window for the detections, in seconds referred to the beginning of the 
%    audio file. 
%  - noiseTime1: vector of times for the start of the noise windows, in
%    seconds referred to the beginning of the audio file.
%  - noiseTime2: vector of times for the end of the noise windows, in
%    seconds referred to the beginning of the audio file. 
%  - noiseEnergyTime1: vector of times for the start of the cumulative energy
%    window for the background noise, in seconds referred to the beginning of 
%    the audio file. 
%  - noiseEnergyTime2: vector of times for the end of the cumulative energy
%    window for the background noise, in seconds referred to the beginning of 
%    the audio file. 
%  - signalZ2p: vector of zero-to-peak amplitudes of detections, calculated 
%    over the cumulative energy windows. Single-precision values ranging from
%    -2^(nbits-1) to 2^(nbits-1)-1, where nbits is the bit depth of the ADC.
%  - signalP2p: vector of peak-to-peak amplitudes of detections, calculated 
%    over the cumulative energy windows. Single-precision values ranging from
%    -2^(nbits-1) to 2^(nbits-1)-1, where nbits is the bit depth of the ADC.
%  - signalRms: vector of broadband RMS amplitudes of detections, calculated
%    over the cumulative energy windows. Single-precision values ranging from 
%    -2^(nbits-1) to 2^(nbits-1)-1, where nbits is the bit depth of the ADC.
%  - signalExp: vector of broadband exposures of detections, calculated over 
%    the cumulative energy windows. Single-precision values ranging from 
%    -2^(nbits-1) to 2^(nbits-1)-1, where nbits is the bit depth of the ADC.
%  - noiseZ2p: vector of zero-to-peak background noise amplitudes, calculated 
%    over the cumulative energy windows. Single-precision values ranging from
%    -2^(nbits-1) to 2^(nbits-1)-1, where nbits is the bit depth of the ADC.
%  - noiseP2p: vector of peak-to-peak background noise amplitudes, calculated 
%    over the cumulative energy windows. Single-precision values ranging from
%    -2^(nbits-1) to 2^(nbits-1)-1, where nbits is the bit depth of the ADC.
%  - noiseRms: vector of broadband backgroud noise RMS amplitudes, calculated
%    over the cumulative energy windows. Single-precision values ranging from 
%    -2^(nbits-1) to 2^(nbits-1)-1, where nbits is the bit depth of the ADC.
%  - noiseExp: vector of broadband background noise exposures, calculated over 
%    the cumulative energy windows. Single-precision values ranging from 
%    -2^(nbits-1) to 2^(nbits-1)-1, where nbits is the bit depth of the ADC.
%  - signalRmsBand: array of band RMS amplitudes of detections, calculated
%    over the cumulative energy windows. As many rows as frequency bands and
%    as many columns as detections. Single-precision values ranging from 
%    -2^(nbits-1) to 2^(nbits-1)-1, where nbits is the bit depth of the ADC.
%  - signalExpBand: array of band exposures of detections, calculated over the 
%    cumulative energy windows. As many rows as frequency bands and as many 
%    columns as detections. Single-precision values ranging from -2^(nbits-1) 
%    to 2^(nbits-1)-1, where nbits is the bit depth of the ADC.
%  - noiseRmsBand: array of band background noise RMS amplitudes, calculated
%    over the cumulative energy windows. As many rows as frequency bands and
%    as many columns as detections. Single-precision values ranging from 
%    -2^(nbits-1) to 2^(nbits-1)-1, where nbits is the bit depth of the ADC.
%  - noiseExpBand: array of band background noise exposures, calculated over 
%    the cumulative energy windows. As many rows as frequency bands and as many 
%    columns as detections. Single-precision values ranging from -2^(nbits-1) 
%    to 2^(nbits-1)-1, where nbits is the bit depth of the ADC.
%  - nominalFreq: vector of nominal band frequencies, in Hertz.
%  - centralFreq: vector of central band frequencies, in Hertz.
%  - cutoffFreq1: vector of band low cutoff frequencies, in Hertz.
%  - cutoffFreq2: vector of band high cutoff frequencies, in Hertz.
%
%  INPUT ARGUMENTS
%  - None
%
%  OUTPUT ARGUMENTS
%  - AudProData: initialised audio process data structure.
%
%  FUNCTION CALL
%  AudProData = initialiseAudioProcessData()
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

function AudProData = initialiseAudioProcessData()

AudProData = struct('signalPcTick',[],'signalUtcTick',[],'timeOffset',[],...
    'fileTimestamp',[],'fileTick',[],'signalTime1',[],'signalTime2',[],...
    'signalEnergyTime1',[],'signalEnergyTime2',[],'noiseTime1',[],...
    'noiseTime2',[],'noiseEnergyTime1',[],'noiseEnergyTime2',[],...
    'signalZ2p',[],'signalP2p',[],'signalRms',[],'signalExp',[],...
    'noiseZ2p',[],'noiseP2p',[],'noiseRms',[],'noiseExp',[],...
    'signalRmsBand',[],'signalExpBand',[],'noiseRmsBand',[],...
    'noiseExpBand',[],'nominalFreq',[],'centralFreq',[],...
    'cutoffFreq1',[],'cutoffFreq2',[]);
