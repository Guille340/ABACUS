%  UPDATEACOUSTICDATABASES(root)
%
%  DESCRIPTION
%  Reads the content of 'channelToReceiver.json' and 'resampleRateToSource.json' 
%  files in '<ROOT.BLOCK>\configdb' and verifies that the Acoustic Databases in 
%  directory '<ROOT.BLOCK>\acousticdb' show the same CHANNEL/RECEIVERNAME and
%  RESAMPLERATE/SOURCENAME relationships as established in the two JSON files.
%
%  UPDATEACOUSTICDATABASES loops through all elements each Acoustic Database 
%  and extracts the CHANNEL, RECEIVERNAME, RESAMPLERATE and SOURCENAME. It
%  then takes the following actions:
%  1. If CHANNEL in the element of the Acoustic Database does not exist in
%     'channelToReceiver.json', it deletes the element.
%  2. If CHANNEL in the element of the Acoustic Database does exist in the  
%     'channelToReceiver.json' but the RECEIVERNAME does not match that
%     in the JSON file, RECEIVERNAME in the Acoustic Database is renamed
%     to that in the JSON file.
%  3. If SOURCENAME in the element of the Acoustic Database does not exist
%     in 'resampleRateToSource.json', it deletes the element.
%  4. If SOURCENAME in the element of the Acoustic Database does exits in
%     'resampleRateToSource.json', but the RESAMPLERATE does not match that
%     in the JSON file, it deletes the element.
%
%  To put these actions in perspective, here are some examples of changes
%  applied to 'channelToReceiver.json' and 'resampleRateToSource.json' and
%  how these will affect the Acoustic Database. Let's consider an Acoustic
%  Database with the following elements and its CHANNEL/RECEIVERNAME and
%  RESAMPLERATE/SOURCENAME relationships agree with those in the JSON files:
%
%    Parameter        Element 1        Element 2
%    --------------------------------------------
%    RECEIVERNAME    'Buoy1_H1'       'Buoy1_H2'
%    CHANNEL                  1                2          
%    SOURCENAME        'Airgun'         'Airgun'          
%    RESAMPLERATE         48000            48000
%
%  But now changes are applied to the JSON files. The changes and their 
%  effects on the Acoustic Database are described below:
%  - Add new element to 'channelToReceiver.json' with RECEIVERNAME = 'Buoy1_H3'
%    and CHANNEL = 3. No effect on the Acoustic Database.
%  - Change RECEIVERNAME = 'Buoy1_H1' to 'ARU1_H1' and RECEIVERNAME = 'Buoy2_H2'
%    to 'ARU1_H2'. The RECEIVERNAME in the Acoustic Database is updated to
%    'ARU1_H1' (element 1) and 'ARU1_H2' (element 2).
%  - Remove RECEIVERNAME = 'Buoy1_H1' and CHANNEL = 1. The element in the
%    Acoustic Database associated with CHANNEL = 1 (i.e. element 1) is deleted.
%  - Change RECEIVERNAME = 'Buoy1_H2' to 'Buoy1_H3' and CHANNEL = 2 to 1.
%    The element in the Acoustic Database associated with CHANNEL = 2 (i.e.
%    element 2) is deleted. This is effectively the same as deleting 
%    RECEIVERNAME = 'Buoy1_H2' and CHANNEL = 2 and then adding RECEIVERNAME
%    = 'Buoy1_H3' and CHANNEL = 3.
%  - Add new element to 'resampleRateToSource.json' with SOURCENAME = 'Sparker'
%    and RESAMPLERATE = 96000. No effect on the Acoustic Database.
%  - Change RESAMPLERATE = 48000 to 24000. The element in the Acoustic Database 
%    associated with SOURCENAME = 'Airgun' (i.e. elements 1 and 2) is deleted.
%  - Remove SOURCENAME = 'Airgun' and RESAMPLERATE = 48000. The element in the
%    Acoustic Database associated with SOURCENAME = 'Airgun' (i.e. elements 1
%    and 2) is deleted.
%  - Change RESAMPLERATE = 48000 to 96000 and SOURCENAME = 'Airgun' to 'Pile'. 
%    The element in the Acoustic Database associated with SOURCENAME = 'Airgun'
%    (i.e. elements 1 and 2) is deleted. This is effectively the same as 
%    deleting RESAMPLERATE = 48000 and SOURCENAME = 'Airgun' and then adding
%    RESAMPLERATE = 96000 and SOURCENAME = 'Pile'.
%
%  To sum up, changing RECEIVERNAME in 'channelToReceiver.json' only updates
%  RECEIVERNAME in the Acoustic Database. Any other changes in the two JSON
%  files will result in the deletion of elements from the Acoustic Database.
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
%  updateAcousticDatabases(root)
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

function updateAcousticDatabases(root)

% Get Names of Acoustic Databases in '<ROOT.BLOCK>\acousticdb'
Directory = dir(strcat(root.block,'\acousticdb','\*.mat'));
acousticdbNames = {Directory.name}';
acousticdbPaths = fullfile(root.block,'acousticdb',acousticdbNames);

% Read CHANNEL/RECEIVERNAME and RESAMPLERATE/SOURCENAME Link Files
ch2recPath = fullfile(root.block,'configdb','channelToReceiver.json');
fr2souPath = fullfile(root.block,'configdb','resampleRateToSource.json');
ch2rec = readChannelToReceiver(ch2recPath);
fr2sou = readResampleRateToSource(fr2souPath);

% Update Acoustic Databases
if ~isempty(ch2rec) && ~isempty(fr2sou) 
    channels_ch2rec = ch2rec.channel;
    receiverNames_ch2rec = ch2rec.receiverName;
    resampleRates_fr2sou = fr2sou.resampleRate;
    sourceNames_fr2sou = fr2sou.sourceName;

    % Loop Through the Acoustic Databases
    nFiles = numel(acousticdbNames);
    for m = 1:nFiles
        % Load Acoustic Database and General Parameters
        AcousticDatabase = load(acousticdbPaths{m});
        channels_acousticdb = [AcousticDatabase.AcoConfig.channel];
        receiverNames_acousticdb = {AcousticDatabase.AcoConfig.receiverName}';
        resampleRates_acousticdb = [AcousticDatabase.AcoConfig.resampleRate];
        sourceNames_acousticdb = {AcousticDatabase.AcoConfig.sourceName}';

        % Update Current Acoustic Database, Element by Element
        nElements = length(channels_acousticdb);
        isDelete = false(nElements,1);
        isRename = false(nElements,1);
        for n = 1:nElements
            AcoConfigOne = AcousticDatabase.AcoConfig(n); % current AcoConfig
            AcoDataOne = AcousticDatabase.AcoData(n); % current AcoData
            
            % Update Element Based on 'channelToReceiver.json'
            isDelete_ch2rec = false;
            iChannelInCh2Rec = find(channels_acousticdb(n) == channels_ch2rec);
            if ~isempty(iChannelInCh2Rec) % if channel found in 'channelToReceiver.json'
                receiverNameNew = receiverNames_ch2rec{iChannelInCh2Rec};
                isReceiver = isequal(receiverNames_acousticdb{n},receiverNameNew);
                % if receiver names are different, then rename them
                if ~isReceiver 
                    % Update RECEIVERNAME in Acoustic Database
                    AcoConfigOne.receiverName = receiverNameNew;
                    AcoDataOne.receiverName = receiverNameNew;
                    
                    % Update RECIMPCONFIG in Acoustic Database
                    RecImpConfig_empty = initialiseReceiverImportConfig();
                    if ~isequal(AcoConfigOne.RecImpConfig,RecImpConfig_empty)
                        AcoConfigOne.RecImpConfig.receiverName = receiverNameNew;
                    end
                    
                    % Update AUDDETCONFIG in Acoustic Database
                    AudDetConfig_empty = initialiseAudioDetectConfig();
                    if ~isequal(AcoConfigOne.AudDetConfig,AudDetConfig_empty)
                        AcoConfigOne.AudDetConfig.receiverName = receiverNameNew;
                    end
                    
                    % Update AUDPROCONFIG in Acoustic Database
                    AudProConfig_empty = initialiseAudioProcessConfig();
                    if ~isequal(AcoConfigOne.AudProConfig,AudProConfig_empty)
                        AcoConfigOne.AudProConfig.receiverName = receiverNameNew;
                    end
                    
                    % Update NAVPROCONFIG in Acoustic Database
                    NavProConfig_empty = initialiseNavigationProcessConfig();
                    if ~isequal(AcoConfigOne.NavProConfig,NavProConfig_empty)
                        AcoConfigOne.NavProConfig.receiverName = receiverNameNew;
                    end
                    
                    % Warning about Changes Made to Acoustic Database
                    isRename(n) = true; % TRUE is receiver is renamed
                    warning(['RECEIVERNAME = ''%s'' in Acoustic Database '...
                        '''%s'' has been changed to RECEIVERNAME = ''%s'' '...
                        'due to changes made to ''channelToReceiver.json'''],...
                        receiverNames_acousticdb{n},acousticdbNames{m},...
                        receiverNameNew)
                end
                % Update ACOCONFIG and ACODATA Structures in Acoustic Database
                AcousticDatabase.AcoConfig(n) = AcoConfigOne;
                AcousticDatabase.AcoData(n) = AcoDataOne;
            else 
                isDelete_ch2rec = true; % flag element for deletion
            end
            
            % Update Element Based on 'resampleRateToSource.json'
            isDelete_fr2sou = false;
            iSourceInFr2Sou = find(ismember(sourceNames_fr2sou,sourceNames_acousticdb(n)));
            if ~isempty(iSourceInFr2Sou) % if source found in 'resampleRateToSource.json'
                resampleRateNew = resampleRates_fr2sou(iSourceInFr2Sou);
                isResampleRate = isequal(resampleRates_acousticdb(n),resampleRateNew);
                % if resample rates are different, then remove element
                if ~isResampleRate
                    isDelete_fr2sou = true; % flag element for deletion
                end
            else
                isDelete_fr2sou = true; % flag element for deletion  
            end
            
            % Logical Vector of Elements to Delete
            isDelete(n) = isDelete_ch2rec || isDelete_fr2sou;
        end
        
        % Delete Elements from Acoustic Database with CHANNEL not in CH2REC
        if nElements ~= sum(isDelete)
            AcousticDatabase.AcoConfig(isDelete) = [];
            AcousticDatabase.AcoData(isDelete) = [];
        else % if all elements need to be deleted
            AcousticDatabase_empty = initialiseAcousticDatabase();
            AcousticDatabase.AcoConfig = AcousticDatabase_empty.AcoConfig;
            AcousticDatabase.AcoData = AcousticDatabase_empty.AcoData;
        end

        % Warning about Element Deletion
        if any(isDelete)
            warning(['One or more elements in Acoustic Database '...
                '''%s'' have been deleted due to changes made to '...
                '''channelToReceiver.json'' or '...
                '''resampleRateToSource.json'''],acousticdbNames{m})
        end
        
        % Save Updated Acoustic Database (if modified)
        if any(isRename | isDelete)
            save(acousticdbPaths{m},'-struct','AcousticDatabase')
        end
    end
end
           