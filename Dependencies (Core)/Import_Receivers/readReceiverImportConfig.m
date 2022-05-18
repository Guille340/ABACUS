%  RecImpConfig = READRECEIVERIMPORTCONFIG(root)
%
%  DESCRIPTION
%  Reads the information from the 'receiverImportConfig*.json' receiver 
%  configuration files stored in the '<ROOT.BLOCK>\configdb' folder. In the 
%  process, READRECEIVERIMPORTCONFIG verifies the configuration data
%  and uses it to populate the full multi-element receiver configuration 
%  structure RECIMPCONFIG. Each element in RECIMPCONFIG contains the 
%  configuration information from a 'receiverImportConfig*.json' file
%  linked to a specific receiver.
%
%  RECIMPCONFIG is later used by RECEIVERIMPORTFUN to import the receiver 
%  position information and save it in the Navigation Database (.mat) 
%  'navigationdb*.mat' in directory '<ROOT.BLOCK>\navigationdb'. 
%
%  Configuration files are named as 'receiverImportConfig<CHAR>_<NUM>, where 
%  <CHAR> is a descriptive character string (e.g. '_TKOWF') and <NUM> is the
%  order of the configuration file in the reading and processing queue. The 
%  '_<NUM>' suffix can be omitted if the reading and processing order is not 
%  important. There are two templates, one per receiver category ('Fixed' and
%  'Towed').
%
%  Multiple receiver import configuration files can be placed in '<ROOT.BLOCK>/
%  configdb'. A new configuration file should be created to process the
%  position data of a particular RECEIVERNAME. The results from each 
%  RECEIVERNAME are stored as one element in the RECIMPDATA structure in the 
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
%  - RecImpConfig: full multi-element receiver configuration structure.
%    For details about its fields see INITIALISERECEIVERIMPORTCONFIG.
%
%  FUNCTION CALL
%  RecImpConfig = READRECEIVERIMPORTCONFIG(root)
%
%  FUNCTION DEPENDENCIES
%  - initialiseReceiverImportConfig
%  - updateReceiverImportConfig
%  - verifyReceiverImportConfig
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%    
%  See also UPDATERECEIVERIMPORTCONFIG, VERIFYRECEIVERIMPORTCONFIG,
%  RECEIVERIMPORTFUN

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  09 Jul 2021

function RecImpConfig = readReceiverImportConfig(root)

% Receiver Configuration Filenames in root Folder
Directory = dir(strcat(root.block,'\configdb','\receiverImportConfig*.json'));
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

% Initialise Full Receiver Configuration Structure
RecImpConfig = initialiseReceiverImportConfig();

% Display Progress on Command Window
fprintf('\nREADING RECEIVER IMPORT SCRIPTS\n')

% Import Receiver Configuration
for m = 1:nScripts
    % Display Name of Current Script
    fprintf('Configuration File ''%s'' [%s]\n',scriptNames{m},...
        datestr(datenum(clock),'dd-mmm-yyyy HH:MM:SS'))
    
    % Read Script
    RecImpConfigFile = jsondecode(fileread(scriptPaths{m})); % load structure in config file
    RecImpConfigOne = updateReceiverImportConfig(root,RecImpConfigFile); % populate config structure
    RecImpConfigOne = verifyReceiverImportConfig(RecImpConfigOne); % update input status
    RecImpConfigOne(1).configFileName = scriptNames{m}; % store config filename
    RecImpConfig(m) = RecImpConfigOne; % add receiver configuration
    clear RecImpConfigFile
end
