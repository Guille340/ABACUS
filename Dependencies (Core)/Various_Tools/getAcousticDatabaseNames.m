%  acousticdbNames = GETACOUSTICDATABASENAMES(root)
%
%  DESCRIPTION
%  Returns a filtered list of the names of the Acoustic Database (.mat) files
%  stored in directory '<ROOT.BLOCK>/acousticdb'. 
%
%  Acoustic Databases have the same name as the audio file they come from,
%  with the only difference of the extension (.mat). GETACOUSTICDATABASENAMES 
%  returns the Acoustic Database names with their name matching the names of 
%  the audio files listed in '<ROOT.BLOCK>\configdb\audioPaths.json'.
%  
%  INPUT ARGUMENTS
%  - root: structure containing the root directories where the audio data
%    (ROOT.AUDIO), position data (ROOT.POSITION) and block data (ROOT.BLOCK)
%    are stored. ROOT.BLOCK contains the directories where the Configuration 
%    Files ('configdb'), Resampled Audio ('audiodb'), Detection Database
%    ('detectiondb), Navigation Database ('navigationdb'), and Acoustic 
%    Databases ('acousticdb') are stored.
%
%  OUTPUT ARGUMENTS
%  - acousticdbNames: cell array of character vectors representing the names of
%    the Acoustic Database files stored in '<ROOT.BLOCK>\acousticdb' that match
%    the names of the target audio files in 'audioPaths.json'. Only existing 
%    files are returned (ACOUSTICDATABASENAMES = [] if no matching Audio 
%    Database files are found).
%
%  FUNCTION CALL
%  acousticdbNames = GETACOUSTICDATABASENAMES(root)
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
%    The directory is the same for all the files: '<ROOT.BLOCK>\acousticdb\'.
%
%  See also UPDATEAUDIODETECTCONFIG, UPDATEAUDIOPROCESSCONFIG,
%  UPDATENAVIGATIONPROCESSCONFIG

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  17 Jul 2021

function acousticdbNames = getAcousticDatabaseNames(root)

% Obtain Audio Absolute Paths from 'audioPaths.json'
filePath = fullfile(root.block,'configdb','audioPaths.json');
audioPaths = getFilePaths(readAudioPaths(root,filePath),...
    {'.wav','.raw2int16','.raw','.pcm'});

% Obtain Audio Names
[~,audioNames] = cellfun(@(x) fileparts(x),audioPaths,'Uniform',false);

% Obtain Acoustic Database Names (with extension) from <ROOT.BLOCK>/acousticdb
Directory = dir(strcat(root.block,'\acousticdb','\*.mat'));
acousticdbNames = {Directory.name}';

% Filter Acoustic Database Names by Main Name
[~,acousticdb_name] = cellfun(@(x) fileparts(x),acousticdbNames,...
    'Uniform',false); % cell of Acoustic DB names (without extension)
iValid_name = ismember(acousticdb_name,audioNames);
acousticdbNames = acousticdbNames(iValid_name);
