%  NavProConfig = READNAVIGATIONPROCESSCONFIG(root)
%
%  DESCRIPTION
%  Reads the information from the 'navigationProcessConfig*.json' navigation
%  process configuration files stored in the '<ROOT.BLOCK>\configdb' folder. 
%  In the process, READNAVIGATIONPROCESSCONFIG verifies the configuration data 
%  and uses it to populate the full multi-element configuration structure 
%  NAVPROCONFIG. Each element in NAVPROCONFIG contains the configuration 
%  information of the processing stage from a 'navigationProcessConfig*.json' 
%  file linked to a specific RECEIVERNAME/SOURCENAME combination.
%
%  The information in NAVPROCONFIG is later used by NAVIGATIONPROCESSFUN to 
%  process the navigation parameters for the audio events detected with 
%  AUDIODETECTFUN and saved in individual Acoustic Databases (.mat) under 
%  '<ROOT.BLOCK>\acousticdb' directory. The Acoustic Databases are selected 
%  based on the audio paths and folders in '<ROOT.BLOCK>\configdb\
%  audioPaths.json' and CHANNEL and RESAMPLERATE linked to the specified 
%  RECEIVERNAME and SOURCENAME (note that the CHANNEL/RECEIVERNAME and 
%  RESAMPLERATE/SOURCENAME link is established through the configuration files 
%  'channelToReceiver.json' and 'resampleRateToSource.json'). 
%
%  Configuration files are named as 'navigationProcessConfig<CHAR>_<NUM>, where
%  <CHAR> is a descriptive character string (e.g. '_TKOWF') and <NUM> is the 
%  order of the configuration file in the reading and processing queue. The 
%  '_<NUM>' suffix can be omitted if the reading and processing order is not 
%  important. There is only one template available for the processing stage.
%
%  Multiple navigation process configuration files can be placed in 
%  '<ROOT.BLOCK>/configdb'. A new configuration file should be created to 
%  process a particular RECEIVERNAME/SOURCENAME combination. The results from 
%  each unique RECEIVERNAME/SOURCENAME combination are stored as one element in 
%  the ACODATA.NAVPRODATA substructure in the corresponding Acoustic Database 
%  file.
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
%  - NavProConfig: full multi-element navigation process configuration 
%    structure. For details see INITIALISENAVIGATIONPROCESSCONFIG.
%
%  FUNCTION CALL
%  NavProConfig = READNAVIGATIONPROCESSCONFIG(root)
%
%  FUNCTION DEPENDENCIES
%  - initialiseNavigationProcessConfig
%  - updateNavigationProcessConfig
%  - verifyNavigationProcessConfig
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  CONSIDERATIONS & LIMITATIONS
%  - AUDIODETECTFUN and AUDIOPROCESSFUN must be run before the navigation 
%    parameters can be processed for each detected sound event using 
%    NAVIGATIONPROCESSFUN.
%  - The navigaiton process config files 'navigaitonProcessConfig*.json' must 
%    match one of the RECEIVERNAME/SOURCENAME combinations available in the 
%    Navigation Database (if any) and target Acoustic Database.If RECEIVERNAME/
%    SOURCENAME is not found in either database, the navigation parameters
%    will not be processed.
%    
%  See also UPDATENAVIGATIONPROCESSCONFIG, VERIFYNAVIGATIONPROCESSCONFIG, 
%  NAVIGATIONPROCESSFUN

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  10 Aug 2021

function NavProConfig = readNavigationProcessConfig(root)

% Navigation Configuration Filenames in root.block Folder
Directory = dir(strcat(root.block,'\configdb','\navigationProcessConfig*.json'));
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
NavProConfig = initialiseNavigationProcessConfig();

% Display Progress on Command Window
fprintf('\nREADING NAVIGATION PROCESSING SCRIPTS\n')

% Processing Audio Configuration
for m = 1:nScripts
    % Display Name of Current Script
    fprintf('Configuration File ''%s'' [%s]\n',scriptNames{m},...
        datestr(datenum(clock),'dd-mmm-yyyy HH:MM:SS'))
    
    % Read Script
    NavProConfigFile = jsondecode(fileread(scriptPaths{m})); % load structure in config file
    NavProConfigOne = updateNavigationProcessConfig(root,NavProConfigFile); % populate config structure
    NavProConfigOne = verifyNavigationProcessConfig(NavProConfigOne); % update input status
    NavProConfigOne(1).configFileName = scriptNames{m}; % store config filename
    NavProConfig(m) = NavProConfigOne; % add receiver configuration
    clear AudProConfigFile
end
