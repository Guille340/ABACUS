%  AUDIODETECTFUN(root,AudDetConfig)
%
%  DESCRIPTION
%  Detects the audio events in the Audio Databases ('<ROOT.BLOCK>\audiodb')
%  linked to the audio files in '<ROOT.BLOCK>\configdb\audioPath.json'. The
%  detection is done as specified in the multi-element audio detect 
%  configuration structure AUDDETCONFIG. 
%
%  AUDDETCONFIG is generated with READAUDIODETECTCONFIG. Each element in 
%  AUDDETCONFIG contains the information from an individual audio detect 
%  config script 'audioDetectConfig*.json' stored in '<ROOT.BLOCK>\configdb'.
%
%  Before running the detection algorithm, AUDIODETECTFUN removes from
%  AUDDETCONFIG any element that meets either of the next two conditions:
%  1. INPUTSTATUS = FALSE (see VERIFYAUDIODETECTCONFIG). A FALSE value
%     indicates that individual fields in the corresponding one-element 
%     structure AUDDETCONFIG(m) are incorrect or the selected Audio Databases 
%     do not exist to initiate the processing.
%  2. RECEIVERNAME/SOURCENAME combination already exists in other element
%     of AUDDETCONFIG.
%
%  AUDIODETECTFUN creates an Acoustic Database (.mat) for each audio file
%  in 'audioPath.json' and stores it in '<ROOT.BLOCK>\acousticdb'. Each
%  Acoustic Database contains two structures (ACOCONFIG and ACODATA),
%  each having as many elements as RECEIVERNAME/SOURCENAME combinations.
%  AUDIODETECTFUN stores the times of the detected sound events for the 
%  given RECEIVERNAME/SOURCENAME combinations in ACODATA.AUDDETDATA.
%
%  Acoustic Databases have the same name as the audio file they originate
%  from, with the only difference of the extension (<AUDIO>.mat).
%
%  If an Acoustic Database has already been created for a selected audio 
%  file, and an audio detect config file shares the same RECEIVERNAME/
%  SOURCENAME combination as any element in the  Acoustic Database, the 
%  detections will be reprocessed and the old content of the element 
%  overwritten.
%
%  During the detection, processing, and revision stages, the software needs 
%  to access the audio data. Currently, this is done by accessing the 
%  corresponding Audio Database. The software chooses the Audio Database based 
%  on the specified audio path ('audioPaths.json'),RECEIVERNAME and SOURCENAME. 
%  The last two are linked to a specific audio channel and sampling rate 
%  through the files 'channelToReceiver.json' and 'resampleRateToSource.json', 
%  stored in '<ROOT.BLOCK>\configdb'.
%
%  For details about the fields in an Acoustic Database refer to the help
%  from functions INITIALISEACOUSTICDATABASE, INITIALISEAUDIOIMPORTCONFIG,
%  INITIALISERECEIVERIMPORTCONFIG, INITIALISESOURCEIMPORTCONFIG, 
%  INITIALISEVESSELIMPORTCONFIG, INITIALISEAUDIODETECTCONFIG,
%  INITIALISEAUDIOPROCESSCONFIG, and INITIALISENAVIGATIONPROCESSCONFIG.
%
%  INPUT ARGUMENTS
%  - root: structure containing the root directories where the audio data
%    (ROOT.AUDIO), position data (ROOT.POSITION) and block data (ROOT.BLOCK)
%    are stored. ROOT.BLOCK contains the directories where the Configuration 
%    Files ('configdb'), Resampled Audio ('audiodb'), Detection Database
%    ('detectiondb), Navigation Database ('navigationdb'), and Acoustic 
%    Databases ('acousticdb') are stored.
%  - AudDetConfig: multi-element audio detect configuration structure.
%
%  OUTPUT ARGUMENTS
%  - None
%
%  FUNCTION CALL
%  AUDIODETECTFUN(root,AudDetConfig)
%
%  FUNCTION DEPENDENCIES
%  - discardRepeatedElements
%  - getAudioDatabaseNames
%  - initialiseAudioDetectData
%  - detectorSlice
%  - detectorMovingAverage
%  - detectorConstantRate
%  - detectorNeymanPearson
%  - initialiseAcousticDatabase
%  - findAcousticDatabaseElement
%  - findMirrorElement
%  - initialiseAudioProcessData
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  See also READAUDIODETECTCONFIG

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  18 Jun 2021

function audioDetectFun(root,AudDetConfig)

% Remove Scripts with 'inputStatus' = 0
AudDetConfig = AudDetConfig(logical([AudDetConfig.inputStatus]));

% Discard Scripts with Identical RECEIVERNAME/SOURCENAME combination
AudDetConfig = discardRepeatedElements(AudDetConfig);

% Display Progress on Command Window
fprintf('\nDETECTING AUDIO EVENTS\n')

% Import Audio Files
nScripts = numel(AudDetConfig);
for m = 1:nScripts
    
    % Audio Detect Config for Current Structure (AUDDETCONFIGONE)
    AudDetConfigOne = AudDetConfig(m);
    
    % Load Common Variables
    configFileName = AudDetConfigOne.configFileName;
    channel = AudDetConfigOne.channel;
    resampleRate = AudDetConfigOne.resampleRate;
    receiverName = AudDetConfigOne.receiverName;
    sourceName = AudDetConfigOne.sourceName;
    detector = AudDetConfigOne.detector;
    
    % Display Name of Current Script
    fprintf('Configuration File ''%s'' [%s]\n',configFileName,...
        datestr(datenum(clock),'dd-mmm-yyyy HH:MM:SS'))
    
    % Retrieve Names of Target Audio Databases
    audiodbNames = getAudioDatabaseNames(root,channel,resampleRate);  
    
    % Run Detection Algorithm on Files
    nFiles = numel(audiodbNames);
    for n = 1:nFiles
        audiodbName = audiodbNames{n};
        audiodbPath = fullfile(root.block,'audiodb',audiodbName);   
        AudDetDataOne = initialiseAudioDetectData(); 
        if ~isempty(detector)
            fprintf('Audio Database File ''%s''\n',audiodbName) % display file name
            switch detector
                case 'slice'
                    AudDetDataOne = detectorSlice(root,audiodbName,...
                        AudDetConfigOne);

                case 'movingaverage'
                    [AudDetDataOne,threshold] = detectorMovingAverage(...
                        root,audiodbName,AudDetConfigOne);
                    AudDetConfigOne.DetectParameters.threshold = threshold;

                case 'constantrate'
                    AudDetDataOne = detectorConstantRate(root,...
                        audiodbName,AudDetConfigOne);
                    
                case 'neymanpearson'
                    AudDetDataOne = detectorNeymanPearson(root,...
                        audiodbName,AudDetConfigOne);
            end            
        end
            
        % Load Acoustic Database and Find RECEIVERNAME/SOURCENAME Element
        acousticdbName = strrep(audiodbName,sprintf('_ch%d_fr%d',channel,...
            resampleRate),'');
        acousticdbPath = fullfile(root.block,'acousticdb',acousticdbName);
        if exist(acousticdbPath,'file') == 2
            % Load Acoustic Database
            AcousticDatabase = load(acousticdbPath);
            
            % Find RECEIVERNAME/SOURCENAME Index
            index = findAcousticDatabaseElement(acousticdbPath,receiverName,...
                sourceName);
            newElement = false;
            if isempty(index)
                % Point Index at New Element (last + 1)
                index = length([AcousticDatabase.AcoConfig.channel]) + 1;
                newElement = true;
                
                % Initialise ACOCONFIG and ACODATA Substructures
                AcousticDatabase_empty = initialiseAcousticDatabase();
                AcousticDatabase.AcoConfig(index) = AcousticDatabase_empty.AcoConfig; 
                AcousticDatabase.AcoData(index) = AcousticDatabase_empty.AcoData; 
            end
        else  
            % Initialise Acoustic Database
            AcousticDatabase = initialiseAcousticDatabase();
            
            % Set RECEIVERNAME/SOURCENAME Index
            index = 1; % set RECEIVERNAME/SOURCENAME index to 1
            newElement = true; % store in a new RECEIVERNAME/SOURCENAME element
        end
        
        % Find Mirroring Element and Populate AUDDETDATA (Mirror Method)
        mirrorReceiver = AudDetConfigOne.mirrorReceiver;
        if ~isempty(mirrorReceiver) && exist(acousticdbPath,'file') == 2
            fprintf('\nRUNNING DETECTION ALGORITHM (''%s'') [%s]\n',...
                strcat(audiodbName,'.mat'),...
                datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
            AcousticDatabase_temp = load(acousticdbPath);
            AudDetConfig_acodb = [AcousticDatabase_temp.AcoConfig.AudDetConfig];           
            iMirrorReceiver = findMirrorElement(AudDetConfig_acodb,...
                mirrorReceiver,sourceName);
            if ~isempty(iMirrorReceiver)
                fprintf('# Mirroring detections from receiver ''%s'' ',...
                    mirrorReceiver)
                AudDetDataOne = AcousticDatabase_temp.AcoData...
                    (iMirrorReceiver).AudDetData;
            else
                fprintf('# Mirroring receiver ''%s'' not found ',...
                    mirrorReceiver)
            end
            fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
        end
        
        % Populate ACOCONFIG with AUDIMPCONFIG from Audio Database
        if newElement % if RECEIVERNAME/SOURCENAME element does not exist
            Structure = load(audiodbPath,'AudImpConfig');
            AudImpConfig = Structure.AudImpConfig;
            AcousticDatabase.AcoConfig(index).AudImpConfig = AudImpConfig;         
        end
            
        % Populate ACOCCONFIG Substructure with General Variables
        AcousticDatabase.AcoConfig(index).audiodbName = audiodbName;
        AcousticDatabase.AcoConfig(index).channel = channel;
        AcousticDatabase.AcoConfig(index).resampleRate = resampleRate;
        AcousticDatabase.AcoConfig(index).receiverName = receiverName;
        AcousticDatabase.AcoConfig(index).sourceName = sourceName; 
        
        % Populate ACODATA Substructure with General Variables
        AcousticDatabase.AcoData(index).audiodbName = audiodbName;
        AcousticDatabase.AcoData(index).channel = channel;
        AcousticDatabase.AcoData(index).resampleRate = resampleRate;
        AcousticDatabase.AcoData(index).receiverName = receiverName;
        AcousticDatabase.AcoData(index).sourceName = sourceName; 
        
        % Populate Acoustic Database with Detection Information
        AcousticDatabase.AcoConfig(index).AudDetConfig = AudDetConfigOne; 
        AcousticDatabase.AcoData(index).AudDetData = AudDetDataOne;
        AcousticDatabase.AcoData(index).AudProData = initialiseAudioProcessData();
        
        % Create Acoustic Database Folder in Root Directory (if doesn't exist)
        if exist(strcat(root.block,'\acousticdb'),'dir') ~= 7
            mkdir(root.block,'acousticdb');
        end

        % Save Acoustic Database
        save(acousticdbPath,'-struct','AcousticDatabase')
    end
end
