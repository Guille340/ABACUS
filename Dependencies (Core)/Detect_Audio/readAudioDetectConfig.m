%  AudDetConfig = READAUDIODETECTCONFIG(root)
%
%  DESCRIPTION
%  Reads the information from the 'audioDetectConfig*.json' audio detect 
%  configuration files stored in the '<ROOT.BLOCK>\configdb' folder. In the 
%  process, READAUDIODETECTCONFIG verifies the configuration data and uses 
%  it to populate the full multi-element configuration structure AUDDETCONFIG. 
%  Each element in AUDDETCONFIG contains the configuration information of 
%  the detection process from a 'audioDetectConfig*.json' file linked to a 
%  specific RECEIVERNAME/SOURCENAME combination.
%  
%  The information in AUDDETCONFIG is later used by AUDIODETECTFUN to detect
%  sound events on the Audio Database (.mat) files in '<ROOT.BLOCK>\audiodb' 
%  linked to the audio paths and folders in 'audioPaths.json' in directory
%  '<ROOT.BLOCK>\configdb'. The Audio Databases are selected based on the audio 
%  paths and folders in '<ROOT.BLOCK>\configdb\audioPaths.json' and the CHANNEL 
%  and RESAMPLERATE linked to the specified RECEIVERNAME and SOURCENAME (note 
%  that the CHANNEL/RECEIVERNAME and RESAMPLERATE/SOURCENAME link is 
%  established through the configuration files 'channelToReceiver.json' and 
%  'resampleRateToSource.json'). 
%
%  Configuration files are named as 'audioDetectConfig<CHAR>_<NUM>, where
%  <CHAR> is a descriptive character string (e.g. '_TKOWF') and <NUM> is the 
%  order of the configuration file in the reading and processing queue. The 
%  '_<NUM>' suffix can be omitted if the reading and processing order is not 
%  important. There is one template available per detection method ('Slice', 
%  'MovingAverage', 'ConstantRate', and 'NeymanPearson').
%
%  Multiple audio detect configuration files can be placed in '<ROOT.BLOCK>/
%  configdb'. A new configuration file should be created to process a 
%  particular RECEIVERNAME/SOURCENAME combination. The results from each 
%  unique RECEIVERNAME/SOURCENAME combination are stored as one element in 
%  the ACODATA.AUDDETDATA substructure in the corresponding Acoustic Database 
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
%  - AudDetConfig: full multi-element audio detect configuration structure. 
%    For details about its fields see INITIALISEAUDIODETECTCONFIG.
%
%  FUNCTION CALL
%  AudDetConfig = READAUDIODETECTCONFIG(root)
%
%  FUNCTION DEPENDENCIES
%  - initialiseAudioDetectConfig
%  - updateAudioDetectConfig
%  - verifyAudioDetectConfig
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  CONSIDERATIONS & LIMITATIONS
%  - READAUDIODETECTCONFIG and AUDIODETECTFUN must be run before the 
%    the audio metrics and navigation parameters can be processed for 
%    each detected sound event using AUDIOPROCESSFUN and NAVIGATIONPROCESSFUN.
%    
%  See also INITIALISEAUDIODETECTCONFIG, UPDATEAUDIODETECTCONFIG, 
%  VERIFYAUDIODETECTCONFIG, AUDIODETECTFUN

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  06 Aug 2021

function AudDetConfig = readAudioDetectConfig(root)

% Audio Detect Configuration Filenames in root.block Folder
Directory = dir(strcat(root.block,'\configdb','\audioDetectConfig*.json'));
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
AudDetConfig = initialiseAudioDetectConfig();

% Display Progress on Command Window
fprintf('\nREADING AUDIO DETECT SCRIPTS\n')

% Processing Audio Configuration
for m = 1:nScripts
    % Display Name of Current Script
    fprintf('Configuration File ''%s'' [%s]\n',scriptNames{m},...
        datestr(datenum(clock),'dd-mmm-yyyy HH:MM:SS'))
    
    % Read Script
    AudDetConfigFile = jsondecode(fileread(scriptPaths{m})); % load structure in config file
    AudDetConfigOne = updateAudioDetectConfig(root,AudDetConfigFile); % populate config structure
    AudDetConfigOne = verifyAudioDetectConfig(AudDetConfigOne); % update input status
    AudDetConfigOne(1).configFileName = scriptNames{m}; % store config filename
    AudDetConfig(m) = AudDetConfigOne; % add receiver configuration
    clear AudProConfigFile
end

% Move Mirror Detectors to the End
isMirrorDetector = cellfun(@(x) ~isempty(x),{AudDetConfig.mirrorReceiver});
nStandardDetector = sum(~isMirrorDetector);
AudDetConfig_temp(1:nStandardDetector) = AudDetConfig(~isMirrorDetector);
AudDetConfig_temp(nStandardDetector+1:nScripts) = AudDetConfig(isMirrorDetector);
AudDetConfig = AudDetConfig_temp;
