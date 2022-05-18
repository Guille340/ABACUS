%  SouImpConfig = READSOURCEIMPORTCONFIG(root)
%
%  DESCRIPTION
%  Reads the information from the 'sourceImportConfig*.json' source 
%  configuration files stored in the '<ROOT.BLOCK>\configdb' folder. In the 
%  process, READSOURCEIMPORTCONFIG verifies the configuration data
%  and uses it to populate the full multi-element source configuration 
%  structure SOUIMPCONFIG. Each element in SOUIMPCONFIG contains the 
%  configuration information from a 'sourceImportConfig*.json' file
%  linked to a specific source.
%
%  SOUIMPCONFIG is later used by SOURCEIMPORTFUN to import the source 
%  position information and save it in the Navigation Database (.mat) 
%  'navigationdb*.mat' in '<ROOT.BLOCK>\navigationdb'. 
%
%  Configuration files are named as 'sourceImportConfig<CHAR>_<NUM>, where 
%  <CHAR> is a descriptive character string (e.g. '_TKOWF') and <NUM> is the
%  order of the source in the reading and processing queue. The '_<NUM>' 
%  suffix can be omitted if the reading and processing order is not important. 
%  There are four templates, one per source category ('Fixed', 'Towed',
%  'Vessel' and 'Fleet').
%
%  Multiple source import configuration files can be placed in '<ROOT.BLOCK>/
%  configdb'. A new configuration file should be created to process the
%  position data of a particular SOURCENAME. The results from each 
%  SOURCENAME are stored as one element in the SOUIMPDATA structure in the 
%  Navigation Database file. 
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
%  - SouImpConfig: full multi-element source configuration structure.
%    For details about its fields see INITIALISESOURCEIMPORTCONFIG.
%
%  FUNCTION CALL
%  SouImpConfig = READSOURCEIMPORTCONFIG(root)
%
%  FUNCTION DEPENDENCIES
%  - initialiseSourceImportConfig
%  - updateSourceImportConfig
%  - verifySourceImportConfig
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%    
%  See also UPDATESOURCEIMPORTCONFIG, VERIFYSOURCEIMPORTCONFIG,
%  SOURCEIMPORTFUN

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  09 Jul 2021

function SouImpConfig = readSourceImportConfig(root)

% Source Configuration Filenames in root Folder
Directory = dir(strcat(root.block,'\configdb','\sourceImportConfig*.json'));
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

% Initialise Full Source Configuration Structure
SouImpConfig = initialiseSourceImportConfig();

% Display Progress on Command Window
fprintf('\nREADING SOURCE IMPORT SCRIPTS\n')

% Import Source Configuration
for m = 1:nScripts
    % Display Name of Current Script
    fprintf('Configuration File ''%s'' [%s]\n',scriptNames{m},...
        datestr(datenum(clock),'dd-mmm-yyyy HH:MM:SS'))
    
    % Read Script
    SouImpConfigFile = jsondecode(fileread(scriptPaths{m})); % load structure in config file
    SouImpConfigOne = updateSourceImportConfig(root,SouImpConfigFile); % populate config structure
    SouImpConfigOne = verifySourceImportConfig(SouImpConfigOne); % update input status
    SouImpConfigOne(1).configFileName = scriptNames{m}; % store config filename
    SouImpConfig(m) = SouImpConfigOne; % add source configuration
    clear SouImpConfigFile
end
