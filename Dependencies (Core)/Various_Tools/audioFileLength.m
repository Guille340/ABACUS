%  fileLength = AUDIOFILELENGTH(filePath,outputMode,varargin)
%
%  DESCRIPTION
%  Calculates the duration in seconds (OUTPUTMODE = 'Seconds') or the number of 
%  samples (OUTPUTMODE = 'Samples') of the audio file in FILEPATH. 
%
%  If the audio file has a non-supported extension, or if the extension has not 
%  been included, AUDIOFILELENGTH will assume RAW format for the file and the 
%  sampling rate, bit resolution and number of channels will have to be 
%  specified. Supported extensions are: WAVE (.wav), OGG (.ogg), FLAC (.flac), 
%  AU (.au), AIFF (.aiff, .aif), AIFC (.aifc), MP3 (.mp3), and MPEG-4 AAC 
%  (.m4a, .mp4).
%
%  INPUT ARGUMENTS
%  - filePath: absolute path of the audio file, with extension.
%  - outputMode: string indicating the content of the output argument.
%    ¬ 'Samples': FILELENGTH represents the length of the file, in samples.
%    ¬ 'Seconds': FILELENGTH represents the length of the file, in seconds.
%  - sampleRate (varargin{1}): sampling rate, in samples per second (Hz)
%  - numChannels (varargin{2}): number of channels.
%  - bitDepth (varargin{3}): number of bits per sample and channel.
%
%  OUTPUT ARGUMENTS
%  - fileDuration: duration of the audio file, in seconds
%
%  INTERNALLY CALLED FUNCTIONS
%  - None
%
%  CONSIDERATIONS & LIMITATIONS
%  - There will be ocassions when the audio file is corrupt, due to a
%    sudden closure of the recording software. That will result in the
%    header not having reliable information about the total number of
%    audio samples. In those cases, the function will interpret the header
%    as part of the audio data, and FILEDURATION will be somewhat larger
%    than it should due to the inability of AUDIOFILEDURATION to determine
%    where the audio data starts. A warning will be issued when a file is
%    found to be corrupt.
%
%  FUNCTION CALLS
%  1) fileDuration = audioFileLength(filePath,outputMode)
%     Only for audio files with the following formats: .wav, .ogg, .flac, 
%     .au, .aiff, .aif, .aifc, .mp3, .m4a, and .mp4. 
%  2) fileDuration = audioFileLength(filePath,outputMode,...
%       sampleRate,numChannels,bitDepth)
%     For audio files in RAW format

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  19 Mar 2021

function fileLength = audioFileLength(filePath,outputMode,varargin)

supportedFormats = {'.wav','.ogg','.flac','.au','.aiff','.aif','.aifc',...
    '.mp3','.m4a','.mp4'};
[~,~,fileExtension] = fileparts(filePath);

% Variable Input Arguments & Error Control
if any(nargin == [3 4])
    error('Wrong number of input arguments')
elseif nargin == 5
    sampleRate = varargin{1};
    numChannels = varargin{2};
    bitsPerSample = varargin{3};
end
  
% Error Control
if isempty(fileExtension)
    error('Missing extension in FILEPATH')
end

isSupportedFormat = ismember(fileExtension,supportedFormats);
if ~isSupportedFormat && nargin ~= 4
    error('Wrong number of input arguments')
end

if ~any(strcmpi(outputMode,{'samples','seconds'}))
    error('Non-supported OUTPUTMODE string')    
end

% Processing
if isSupportedFormat
    % Extract Header Info
    info = audioinfo(filePath); % information structure from audio file
    sampleRate = info.SampleRate; % sampling rate [Hz]
    numChannels = info.NumChannels; % number of channels
    bitsPerSample = info.BitsPerSample; % bits per sample and channel 
    fileSamples = info.TotalSamples; % total number of audio samples
    
    % Process Duration
    if fileSamples ~= 0 % valid audio file
        fileDuration = fileSamples/sampleRate;
    else % corrupt file
        warning(['Corrupt audio file. The value of FILEDURATION is '... 
            'approximate (header interpreted as audio data)'])
        fileData = dir(filePath); % file information structure
        fileSizeInBytes = fileData.bytes; % file size [bytes]
        bitsPerByte = 8;
        fileSamples = round(bitsPerByte*fileSizeInBytes / ...
            (numChannels*bitsPerSample));
        fileDuration = fileSamples/sampleRate;
    end    
else % RAW Format
    fileData = dir(filePath); % file information structure
    fileSizeInBytes = fileData.bytes; % file size [bytes]
    bitsPerByte = 8; 
    fileSamples = round(bitsPerByte*fileSizeInBytes / ...
            (numChannels*bitsPerSample));
    fileDuration = fileSamples/sampleRate;
end

switch outputMode
    case 'samples'
        fileLength = fileSamples;
    case 'seconds'
        fileLength = fileDuration;
end

    
