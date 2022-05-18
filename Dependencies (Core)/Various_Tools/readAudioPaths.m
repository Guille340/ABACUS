%  audioPaths = READAUDIOPATHS(root,filePath)
%
%  DESCRIPTION
%  Reads the absolute paths and parent directories listed in the JSON file
%  in FILEPATH. These paths and directories refer to the audio files to be 
%  processed.
%
%  The paths and directories are added manually into the JSON file with the
%  specific format of an "array of strings". The file must start and end with
%  square brackets ([ ... ]); within the square brackets, the directories 
%  and paths are delimited by double quotation and separated by comma ("...",
%  "..."). The slash symbol (/) has to be replaced with double slash (//) to 
%  stop MATLAB from interpreting the slash as a special character. 
%
%  An additional functionality has been included to ignore any of the
%  listed paths or directories without having to delete them. This is
%  particularly useful for tests or to avoid reprocessing files that have
%  already been processed. To ignore an entrance, simply add one of the
%  three supported special characters (!, #, %) to the start of the string, 
%  just after the opening quotation mark.
%
%  An example of an 'audioPaths.json' file is shown below:
%
%   [
%    "C:\\Audio\\raw (SeicheSsv, Run 1)",
%    "C:\\Audio\\raw (SeicheSsv, Run 2)",
%    "!C:\\Audio\\wav (PamGuard, Run 1)"
%   ]
%  
%  Note that the last entrance will be ignored.
%
%  INPUT ARGUMENTS
%  - root: structure containing the root directories where the audio data
%    (ROOT.AUDIO), position data (ROOT.POSITION) and block data (ROOT.BLOCK)
%    are stored. ROOT.BLOCK contains the directories where the Configuration 
%    Files ('configdb'), Resampled Audio ('audiodb'), Detection Database
%    ('detectiondb), Navigation Database ('navigationdb'), and Acoustic 
%    Databases ('acousticdb') are stored.
%  - filePath: absolute path of audio paths file.
%
%  OUTPUT ARGUMENTS
%  - audioPaths: cell array of character vectors containing the absolute 
%    paths and directories listed in 'audioPaths.json' under directory
%    '<ROOT.BLOCK>/configdb'. Commented (#,%,!) paths or directories are 
%    discarded.
%
%  FUNCTION CALL
%  audioPaths = READAUDIOPATHS(filePath)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  16 Jul 2021

function audioPaths = readAudioPaths(root,filePath)

% Error Control
if ~ischar(filePath)
    error('FILEPATH must be a character vector') 
end
if exist(filePath,'file') ~= 2
    error('FILEPATH file not found')
end

% Read Audio Paths from File
audioPaths = '';
if exist(filePath,'file') == 2
    % Read Paths
    audioPaths = jsondecode(fileread(filePath)); % relative audio paths
    audioPaths = fullfile(root.audio,audioPaths); % absolute audio paths

    % Remove "commented" Entries
    iValid = cellfun(@(x) ~any(ismember('!#%',x)),audioPaths);
    audioPaths = audioPaths(iValid);
    
    % Remove Paths that Do Not Exist
    isDirectory = cellfun(@(x) exist(x,'dir') == 7,audioPaths);
    isPath = cellfun(@(x) exist(x,'file') == 2,audioPaths);
    isValid = isDirectory | isPath;
    if ~all(isValid)
        audioPaths = audioPaths(isValid);
        warning(['One or more of the specified audio directories or paths '...
                'in FILEPATH do not exist and will be ignored']);
    end
else
    warning(['File ''audioPaths.json'' could not be found in directory '...
        '''<ROOT.BLOCK>\configdb'''])
end
