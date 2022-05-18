%  audioDatabaseNames = GETAUDIODATABASENAMES(root,channel,resampleRate)
%
%  DESCRIPTION
%  Returns a filtered list of the names of the Audio Database (.mat) files
%  stored in directory '<ROOT.BLOCK>/audiodb'. 
%
%  Audio Database files are named as '<AUDIONAME>_ch<CHANNEL>_fr<RESAMPLERATE>, 
%  where AUDIONAME is the name of the audio file the database is linked to.
%  GETAUDIODATABASENAMES returns the Audio Database names with main name 
%  <AUDIONAME> matching the names of the audio files listed in 'audioPaths.json' 
%  and with the suffix string '_ch<CHANNEL>_fr<RESAMPLERATE>' matching the input 
%  CHANNEL and RESAMPLERATE.
% 
%  If CHANNEL or RESAMPLERATE are empty ([]), the function returns the paths 
%  of the Audio Databases associated with all channels or resampling rates, 
%  respectively.
%  
%  INPUT ARGUMENTS
%  - root: structure containing the root directories where the audio data
%    (ROOT.AUDIO), position data (ROOT.POSITION) and block data (ROOT.BLOCK)
%    are stored. ROOT.BLOCK contains the directories where the Configuration 
%    Files ('configdb'), Resampled Audio ('audiodb'), Detection Database
%    ('detectiondb), Navigation Database ('navigationdb'), and Acoustic 
%    Databases ('acousticdb') are stored.
%  - channel: audio channel common to all AUDIODATABASENAMES.
%  - resampleRate: resampling rate common to all AUDIODATABASENAMES.
%
%  OUTPUT ARGUMENTS
%  - audioDatabaseNames: names of the Audio Database files in directory
%    '<ROOT.BLOCK>\audiodb' with suffix '_ch<CHANNEL>_fr_<RESAMPLERATE>'. Only 
%    the existing files are returned (AUDIODATABASENAMES = [] if no matching 
%    Audio Database files are found).
%
%  FUNCTION CALL
%  audioDatabaseNames = GETAUDIODATABASENAMES(root,channel,resampleRate)
%
%  FUNCTION DEPENDENCIES
%  - readAudioPaths
%  - getFilePaths
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  CONSIDERATIONS & LIMITATIONS
%  - The function returns names rather than absolute paths for simplicity.
%    The directory is the same for all the files: '<ROOT.BLOCK>\audiodb\'.
%
%  See also UPDATEAUDIODETECTCONFIG, UPDATEAUDIOPROCESSCONFIG

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  17 Jul 2021

function audioDatabaseNames = getAudioDatabaseNames(root,channel,resampleRate)

% Obtain Audio Absolute Paths from 'audioPaths.json'
filePath = fullfile(root.block,'configdb','audioPaths.json');
audioPaths = getFilePaths(readAudioPaths(root,filePath),...
    {'.wav','.raw2int16','.raw','.pcm'});

% Obtain Audio Names
[~,audioNames] = cellfun(@(x) fileparts(x),audioPaths,'Uniform',false);

% Obtain Audio Database Names from <ROOT.BLOCK>/audiodb
Directory = dir(strcat(root.block,'\audiodb','\*.mat'));
audioDatabaseNames = {Directory.name}';

% Separate Main Name, Channel and Resampling Rate
nFiles = numel(audioDatabaseNames);
audioDatabase_name = repmat({''},nFiles,1);
audioDatabase_ch = zeros(nFiles,1);
audioDatabase_fr = zeros(nFiles,1);
for n = 1:nFiles
    audioDatabaseName = audioDatabaseNames{n};
    iCh = strfind(audioDatabaseName,'_ch');
    iFr = strfind(audioDatabaseName,'_fr');
    iDot = strfind(audioDatabaseName,'.mat');
    audioDatabase_name{n} = audioDatabaseName(1:iCh-1);
    audioDatabase_ch(n) = str2double(audioDatabaseName(iCh+3:iFr-1));
    audioDatabase_fr(n) = str2double(audioDatabaseName(iFr+3:iDot-1));
end

% Filter Audio Database Names by Main Name
iValid_name = ismember(audioDatabase_name,audioNames);

% Filter Audio Database Names by Channel
iValid_ch = true(nFiles,1);
if ~isempty(channel)   
    iValid_ch = audioDatabase_ch == channel;
end
    
% Filter Audio Database Names by Resampling Rate
iValid_fr = true(nFiles,1);
if ~isempty(resampleRate)   
    iValid_fr = audioDatabase_fr == resampleRate;
end

% Filtered Audio Database Names
audioDatabaseNames = audioDatabaseNames(iValid_name & iValid_ch & iValid_fr);

