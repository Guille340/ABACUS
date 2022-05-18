%  AudImpConfig = READAUDIOIMPORTCONFIG(root)
%
%  DESCRIPTION
%  Reads the information from the 'audioImportConfig*.json' audio import 
%  configuration files stored in the '<ROOT.BLOCK>\configdb' folder. In the 
%  process, READAUDIOIMPORTCONFIG verifies the configuration data and uses 
%  it to populate the full multi-element configuration structure AUDIMPCONFIG. 
%  Each element in AUDIMPCONFIG contains the configuration information of 
%  the audio import process from a 'audioImportConfig*.json' file, linked to 
%  a specific RECEIVERNAME/SOURCENAME combination.
%
%  The information in AUDIMPCONFIG is later used to import and resample 
%  (if applicable) the audio data and save it in individual Audio Databases 
%  (.mat) in '<ROOT.BLOCK>\audiodb' folder (one database pero audio file). The
%  audio files are selected by listing their absolute paths or parent
%  folders in the file 'audioPaths.json' in directory '<ROOT.BLOCK>\configdb'.
%
%  The configuration files are named as 'audioImportConfig<CHAR>_<NUM>, 
%  where <CHAR> is a descriptive character string (e.g. 'ARU_TKOWF') and 
%  <NUM> is the order of the configuration file in the reading and processing 
%  queue. The '_<NUM>' suffix can be omitted if the reading and processing 
%  order is not important. There are two templates available, one per
%  supported audio format (WAV, RAW).
%
%  Multiple audio import configuration files can be placed in '<ROOT.BLOCK>/
%  configdb'. A new configuration file should be created to import audio 
%  from a different channel (i.e. different receiver) or to resample at a 
%  different sampling rate (i.e. different source). It is advisable to
%  dedicate the ROOT.BLOCK folder to import and process data from a single
%  platform with one or more sensors (e.g. buoy with 2-channel array,
%  ch1 for shallow hydrophone and ch2 for deep hydrophone).
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
%  - None
%
%  FUNCTION CALL
%  AudImpConfig = READAUDIOIMPORTCONFIG(root)
%
%  FUNCTION DEPENDENCIES
%  - updateAudioImportConfig
%  - verifyAudioImportConfig
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  CONSIDERATIONS & LIMITATIONS
%  - Different audioImportConfig<CHAR>.json files can be created for the 
%    different channels and resampling rates to be processed. Create files
%    for as many channels as sensors to process (e.g. ch1 = top hydrophone, 
%    ch2 = bottom hydrophone), and as many sampling rates as source types 
%    to process (e.g. 96 kHz for sparker, 24 kHz for airgun). For example, 
%    to process an airgun and SBP on the top (ch1) and bottom (ch2) 
%    hydrophones, create four import configuration files with settings:
%    1. CHANNEL = 1, RESAMPLERATE = 250000 for Hyd1/SBP
%    2. CHANNEL = 2, RESAMPLERATE = 250000 for Hyd2/SBP
%    3. CHANNEL = 1, RESAMPLERATE = 24000 for Hyd1/Airgun
%    4. CHANNEL = 2, RESAMPLERATE = 24000 for Hyd2/Airgun
%
%  - For clarity, it is advisable not to mix in the same '<ROOT.BLOCK>/configdb' 
%    folder audio import files targeted at different audio formats (RAW and 
%    WAV), since there is only one 'audioPaths.json' (the 'audioPaths.json' 
%    file should include only files from one format). In general, an 
%    analysis block (i.e. content in <ROOT.BLOCK>) should always be focused on 
%    the receivers of one platform to avoid confusion with formats and origin 
%    of data.
%
%  - For clarity, it is also advisable not to mix in the same '<ROOT.BLOCK>/
%    configdb' folder audio import files from more than one platform (e.g. 
%    buoy 1 and buoy2). Although it is still possible to include in a single 
%    Acoustic Database data from multiple platforms and sensors, clarity 
%    and file size can be improved by dedicating a different ROOT.BLOCK for 
%    each receiver platform.
%    
%  See also UPDATEAUDIOIMPORTCONFIG, VERIFYAUDIOIMPORTCONFIG, AUDIOIMPORTFUN

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  18 Jul 2021 

function AudImpConfig = readAudioImportConfig(root)

% Audio Configuration Filenames in root Folder
Directory = dir(strcat(root.block,'\configdb','\audioImportConfig*.json'));
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

% Initialise Full Audio Import Configuration Structure
AudImpConfig_empty = initialiseAudioImportConfig();
AudImpConfig = AudImpConfig_empty;

% Display Progress on Command Window
fprintf('\nREADING AUDIO IMPORT SCRIPTS\n')

% Import Audio Configuration
for m = 1:nScripts
    % Display Name of Current Script
    fprintf('Configuration File ''%s'' [%s]\n',scriptNames{m},...
        datestr(datenum(clock),'dd-mmm-yyyy HH:MM:SS'))
    
    % Read Script
    AudImpConfigFile = jsondecode(fileread(scriptPaths{m})); % load structure in config file
    AudImpConfigOne = updateAudioImportConfig(root,AudImpConfigFile);
    AudImpConfigOne = verifyAudioImportConfig(AudImpConfigOne);
    AudImpConfigOne(1).configFileName = scriptNames{m}; % store config filename
    AudImpConfig(m) = AudImpConfigOne;
    clear AudImpConfigFile
end
