%  AudProConfig = READAUDIOPROCESSCONFIG(root)
%
%  DESCRIPTION
%  Reads the information from the 'audioProcessConfig*.json' audio process 
%  configuration files stored in the '<ROOT.BLOCK>\configdb' folder. In the 
%  process, READAUDIOPROCESSCONFIG verifies the configuration data and uses 
%  it to populate the full multi-element configuration structure AUDPROCONFIG. 
%  Each element in AUDPROCONFIG contains the configuration information of 
%  the processing stage from a 'audioProcessConfig*.json' file linked to a 
%  specific RECEIVERNAME/SOURCENAME combination.
%
%  The information in AUDPROCONFIG is later used by AUDIOPROCESSFUN to process
%  the acoustic metrics for the audio events detected with AUDIODETECTFUN and
%  saved in individual Acoustic Databases (.mat) under '<ROOT.BLOCK>\acousticdb'
%  directory. The Acoustic Databases and Audio Databases are selected based 
%  on the audio paths and folders in '<ROOT.BLOCK>\configdb\audioPaths.json' 
%  and the CHANNEL and RESAMPLERATE linked to the specified RECEIVERNAME and
%  SOURCENAME (note that the CHANNEL/RECEIVERNAME and RESAMPLERATE/SOURCENAME 
%  link is established through the configuration files 'channelToReceiver.json' 
%  and 'resampleRateToSource.json'). 
%
%  Configuration files are named as 'audioProcessConfig<CHAR>_<NUM>, where
%  <CHAR> is a descriptive character string (e.g. '_TKOWF') and <NUM> is the 
%  order of the configuration file in the reading and processing queue. The 
%  '_<NUM>' suffix can be omitted if the reading and processing order is not 
%  important. There is only one template available for the processing stage.
%
%  Multiple audio process configuration files can be placed in '<ROOT.BLOCK>/
%  configdb'. A new configuration file should be created to process a 
%  particular RECEIVERNAME/SOURCENAME combination. The results from each 
%  unique RECEIVERNAME/SOURCENAME combination are stored as one element in 
%  the ACODATA.AUDPRODATA structure in the corresponding Acoustic Database file.
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
%  - AudProConfig: full multi-element audio process configuration structure. 
%    For details about its fields see INITIALISEAUDIOPROCESSCONFIG.
%
%  FUNCTION CALL
%  AudProConfig = READAUDIOPROCESSCONFIG(root)
%
%  FUNCTION DEPENDENCIES
%  - initialiseAudioProcessConfig
%  - updateAudioProcessConfig
%  - verifyAudioProcessConfig
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  CONSIDERATIONS & LIMITATIONS
%  - AUDIODETECTFUN must be run before the audio metrics can be processed for 
%    each detected sound event using AUDIOPROCESSFUN.
%  - The audio process config files 'audioProcessConfig*.json' must match one
%    of the RECEIVERNAME/SOURCENAME combinations available in the target
%    Acoustic Database. If RECEIVERNAME/SOURCENAME is not found in the 
%    Acoustic Database, the acoustic metrics will not be processed.
%    
%  See also UPDATEAUDIOPROCESSCONFIG, VERIFYAUDIOPROCESSCONFIG, 
%  AUDIOPROCESSFUN

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  08 Aug 2021

function AudProConfig = readAudioProcessConfig(root)

% Receiver Configuration Filenames in root.block Folder
Directory = dir(strcat(root.block,'\configdb','\audioProcessConfig*.json'));
scriptNames = {Directory.name};

% File Paths
if ischar(scriptNames)
    scriptNames = {scriptNames};   
end
scriptPaths = fullfile(root.block,'\configdb',scriptNames);

% Sort Script Names by Suffix Number (unnumbered scripts first)
nScripts = numel(scriptPaths);
number = nan(nScripts,1);
for m = 1:nScripts
    scriptName = scriptNames{m};
    iUnderscores = strfind(scriptName,'_');
    iDots = strfind(scriptName,'.');
    if ~isempty(iUnderscores)
        number(m) = str2double(scriptName(iUnderscores(end)+1:iDots(end)-1));
    end
end
number(isnan(number)) = 0; % unnumbered scripts first
[~,ind] = sort(number);
scriptNames = scriptNames(ind);
scriptPaths = scriptPaths(ind);

% Initialise Full Audio Processing Configuration Structure 
AudProConfig = initialiseAudioProcessConfig();

% Display Progress on Command Window
fprintf('\nREADING AUDIO PROCESSING SCRIPTS\n')

% Processing Audio Configuration
for m = 1:nScripts
    % Display Name of Current Script
    fprintf('Configuration File ''%s'' [%s]\n',scriptNames{m},...
        datestr(datenum(clock),'dd-mmm-yyyy HH:MM:SS'))
    
    % Read Scripts
    AudProConfigFile = jsondecode(fileread(scriptPaths{m})); % load structure in config file
    AudProConfigOne = updateAudioProcessConfig(root,AudProConfigFile); % populate config structure
    AudProConfigOne = verifyAudioProcessConfig(AudProConfigOne); % update input status
    AudProConfigOne(1).configFileName = scriptNames{m}; % store config filename
    AudProConfig(m) = AudProConfigOne; % add receiver configuration
    clear AudProConfigFile
end
