%  AudProConfigOne = UPDATEAUDIOPROCESSCONFIG(root,AudProConfigFile)
%
%  DESCRIPTION
%  Returns a full one-element audio processing configuration structure 
%  AUDPROCONFIGONE populated with the information given in the audio process 
%  configuration structure AUDPROCONFIGFILE. 
%
%  UPDATEAUDIOPROCESSCONFIG checks for any non-valid input values. It also 
%  checks whether Audio Database (.mat) and Acoustic Database (.mat) files are 
%  available for the specified RECEIVERNAME/SOURCENAME combination; processing 
%  of the acoustic metrics cannot be performed if either type of database is
%  not found for a given audio file. Warnings are not displayed; instead, any 
%  error is flagged on the relevant structure field by setting it as empty ([]).
%
%  AUDPROCONFIGFILE is extracted directly from an audio process config file 
%  'audioProcessConfig*.json' stored in '<ROOT.BLOCK>\configdb'. Function
%  READAUDIOPROCESSCONFIG generates the structure AUDPROCONFIGFILE and calls 
%  UPDATEAUDIOPROCESSCONFIG immediately after.
%    
%  INPUT ARGUMENTS
%  - root: structure containing the root directories where the audio data
%    (ROOT.AUDIO), position data (ROOT.POSITION) and block data (ROOT.BLOCK)
%    are stored. ROOT.BLOCK contains the directories where the Configuration 
%    Files ('configdb'), Resampled Audio ('audiodb'), Detection Database
%    ('detectiondb), Navigation Database ('navigationdb'), and Acoustic 
%    Databases ('acousticdb') are stored.
%  - AudProConfigFile: partial audio process configuration structure extracted 
%    from an 'audioProcessConfig*.json' configuration file stored in folder
%    '<ROOT.BLOCK>\configdb'. It contains only a fraction of the fields of 
%    AUDDETCONFIGONE.
%
%  OUTPUT ARGUMENTS
%  - AudDetConfigOne: populated audio process configuration structure.
%    For details about its fields see INITIALISEAUDIOPROCESSCONFIG.
%
%  FUNCTION CALL
%  AudProConfigOne = UPDATEAUDIOPROCESSCONFIG(root,AudProConfigFile)
%
%  FUNCTION DEPENDENCIES
%  - initialiseAudioProcessConfig
%  - readChannelToReceiver
%  - readResampleRateToSource
%  - getAudioDatabaseNames
%  - getAcousticDatabaseNames
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  See also READAUDIOPROCESSCONFIG

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  28 Jul 2021

function AudProConfigOne = updateAudioProcessConfig(root,AudProConfigFile)

narginchk(2,2) % check number of input arguments

% Retrieve Field Names
fieldNames = fieldnames(AudProConfigFile); % field names of temporal structure

% Sort Properties by Priority Order
fieldNames_valid = {'receiverName','sourceName','bandsPerOctave',...
    'freqLimits','cumEnergyRatio','audioTimeFormat','timeOffset','tags'};
[iMember,iOrder] = ismember(fieldNames,fieldNames_valid);
fieldNames = fieldNames_valid(unique(iOrder(iMember)));

% Initialise Full Audio Process Configuration Structure
AudProConfigOne = initialiseAudioProcessConfig();

% Read 'channelToReceiver.json'
ch2recPath = fullfile(root.block,'configdb','channelToReceiver.json');
ch2rec = readChannelToReceiver(ch2recPath);
if isempty(ch2rec)
    AudProConfigOne(1).channel = [];
end

% Read 'resampleRateToSource.json'
fr2souPath = fullfile(root.block,'configdb','resampleRateToSource.json');
fr2sou = readResampleRateToSource(fr2souPath);
if isempty(fr2sou)
    AudProConfigOne(1).resampleRate = [];
end

% Error Control(Structure Fields)
nFields = numel(fieldNames); % number of fields in temporal structure
for m = 1:nFields
    fieldName = fieldNames{m}; % current field name
    fieldValue = [AudProConfigFile.(fieldName)]; % current field value

    switch fieldName 
        case 'receiverName'
            if ~isempty(fieldValue)
                % If RECEIVERNAME is a character vector
                if ischar(fieldValue)
                    % Verify Channel and Receiver Name
                    if ~isempty(ch2rec)
                        isReceiver = ismember(ch2rec.receiverName,fieldValue);
                        if any(isReceiver)
                            AudProConfigOne(1).channel = ...
                                ch2rec.channel(isReceiver);
                        else
                            fieldValue = [];
                            warning(['RECEIVERNAME could not be found in '...
                                'the ''channelToReceiver.json'' file. '...
                                'The Audio Databases (.mat) to be used '...
                                'for processing cannot be identified'])
                        end
                    else
                        fieldValue = [];
                    end 
                % If RECEIVERNAME is not a character vector
                else
                    fieldValue = [];
                    warning('RECEIVERNAME must be a character vector')
                end
            end
            
        case 'sourceName'
            if ~isempty(fieldValue)
                % If SOURCENAME is a character vector
                if ischar(fieldValue)
                    % Verify Resample Rate and Source Name
                    if ~isempty(fr2sou)
                        isSource = ismember(fr2sou.sourceName,fieldValue);
                        if any(isSource)
                            AudProConfigOne(1).resampleRate = ...
                                fr2sou.resampleRate(isSource);
                        else
                            fieldValue = [];
                            warning(['SOURCENAME could not be found in '...
                                'the ''resampleRateToSource.json'' file. '...
                                'The Audio Databases (.mat) to be used '...
                                'for processing cannot be identified'])
                        end
                    else
                        fieldValue = [];
                    end 
                % If SOURCENAME is not a character vector
                else
                    fieldValue = [];
                    warning('SOURCENAME must be a character vector')
                end
            end
            
        case 'bandsPerOctave'
            if ~isempty(fieldValue)
                if ~isnumeric(fieldValue) || ~isscalar(fieldValue) ...
                        || fieldValue < 1 || rem(fieldValue,1)
                    fieldValue = 3;
                    warning(['BANDSPEROCTAVE must be a non-decimal number '
                        'equal to or higher than 1. BANDSPEROCTAVE = 3 '...
                        'will be used'])
                end
            end
            
        case 'freqLimits'
            if ~isempty(fieldValue)
                resampleRate = AudProConfigOne.resampleRate;
                bandsPerOctave = AudProConfigOne.bandsPerOctave;
                if isnumeric(fieldValue) && numel(fieldValue) == 2
                    freqMin = min(fieldValue);
                    freqMax = max(fieldValue);
                    if freqMin < 0
                        freqMin = 0;
                        warning(['MIN(FREQLIMITS) must be higher than 0. '...
                            'MIN(FREQLIMITS) = 0 will be used'])
                    end
                    if ~isempty(resampleRate) ...
                            && freqMax > resampleRate/2
                        freqMax = resampleRate/2;
                        warning(['MAX(FREQLIMITS) must be lower than  or '...
                            'equal to RESAMPLERATE/2. MAX(FREQLIMITS) = '...
                            'RESAMPLERATE/2 will be used'])
                    end
                        
                    if freqMax/freqMin < 2^(1/bandsPerOctave)
                        freqMin = 0;
                        freqMax = resampleRate/2;
                        warning(['The ratio MAX(FREQLIMITS)/MIN(FREQLIMITS) '...
                            'must be higher than 2^(1/BANDSPEROCTAVE) times'])
                    end
                    fieldValue = [freqMin freqMax];
                else
                    fieldValue = [0 resampleRate/2];
                    warning(['RESAMPLERATE must be a two-element numeric '...
                        'vector'])
                end
            end

        case 'audioTimeFormat'
            if ~ischar(fieldValue)
                if ~isTstampFormat(fieldValue)
                    fieldValue = [];
                end
            end
        
        case 'cumEnergyRatio'
        if ~isempty(fieldValue)
            if ~isnumeric(fieldValue) ...
                    || ~isscalar(fieldValue) ...
                    || fieldValue < 0 ...
                    || fieldValue > 1 %#ok<*BDSCI>
                fieldValue = 0.9;
                warning(['CUMENERGYRATIO must be a scalar number between '...
                    '0 and 1. CUMENERGYRATIO = %0.2f will be used'],fieldValue)
            end
        end
            
        case 'timeOffset'
            if ~isempty(fieldValue)
                if ~isnumeric(fieldValue) || ~isscalar(fieldValue)
                    fieldValue = 0;
                    warning(['TIMEOFFSET must be a scalar number. '...
                        'TIMEOFFSET = 0 will be used'])
                end
            else
                filePath = fullfile(root.block,'configdb','timeOffset.csv');
                if exist(filePath,'file') ~= 2
                    fieldValue = 0;
                    warning(['The time offset file ''timeOffset.csv'' '...
                        'could not be found at <ROOT.BLOCK>\\configdb '...
                        'TIMEOFFSET = 0 will be used'])
                end
            end
            
        case 'tags'
            if ischar(fieldValue)
                fieldValue = {fieldValue};
            end
            if ~iscell(fieldValue) || ~all(cellfun(@(x) ischar(x),fieldValue))
                fieldValue = {''};
                warning(['TAGS must be a character vector or a cell '...
                    'array of character vectors'])
            end
    end

    % Update Current Field ('fieldName') with Current Value ('fieldValue')
    AudProConfigOne(1).(fieldName) = fieldValue;
end

% Verify CHANNEL and RESAMPLERATE
channel = AudProConfigOne.channel;
resampleRate = AudProConfigOne.resampleRate;
isChannel = ~isempty(channel) && isnumeric(channel) && isscalar(channel) ...
        && channel >= 1 && ~rem(channel,1); % true for valid channel
isResampleRate = ~isempty(resampleRate) && isnumeric(resampleRate) ...
    && isscalar(resampleRate); % true for valid resample rate

% Verify Audio Database Files
if isChannel && isResampleRate
    audiodbNames = getAudioDatabaseNames(root,channel,resampleRate);
    if isempty(audiodbNames)
        AudProConfigOne(1).channel = [];
        AudProConfigOne(1).resampleRate = [];
        warning(['No Audio Database file was found in <ROOT.BLOCK>\\audiodb '...
            'for the specified CHANNEL and RESAMPLERATE.'])
    end
end

% Verify Acoustic Database Files
receiverName = AudProConfigOne.receiverName;
sourceName = AudProConfigOne.sourceName;
if ~isempty(receiverName) && ~isempty(sourceName)
    acousticdbNames = getAcousticDatabaseNames(root);
    acousticdbPaths = fullfile(root.block,'acousticdb',acousticdbNames);
    % If no Acoustic Databases found
    if isempty(acousticdbNames)
        AudProConfigOne(1).receiverName = [];
        AudProConfigOne(1).sourceName = [];
        warning(['No Acoustic Database file was found in <ROOT.BLOCK>\\'...
            'acousticdb'])
    % If one or more Acoustic Databases found
    else
        nFiles = numel(acousticdbNames);
        isValidFile = false(nFiles,1);
        for m = 1:nFiles
            Structure = load(acousticdbPaths{m},'AcoConfig');
            AcoConfig = Structure.AcoConfig;
            nElements = numel(AcoConfig);
            receiverNames_AudDet = repmat({''},nElements,1); % receivers in AudDetConfig
            sourceNames_AudDet = repmat({''},nElements,1); % sources in AudDetConfig
            for n = 1:nElements
                receiverNames_AudDet{n} = AcoConfig(n).AudDetConfig.receiverName;
                sourceNames_AudDet{n} = AcoConfig(n).AudDetConfig.sourceName;
            end
            isRecInAudDet = ismember(receiverNames_AudDet,receiverName);
            isSouInAudDet = ismember(sourceNames_AudDet,sourceName);
            isValidFile(m) = any(isRecInAudDet & isSouInAudDet);
        end

        % Warn if RECEIVERNAME/SOURCENAME combo not found in Acoustic Databases
        if ~all(isValidFile)
            warning(['One or more of the Acoustic Database files in '...
                '<ROOT.BLOCK>\\acousticdb do not match the RECEIVERNAME/'...
                'SOURCENAME combination specified in the '...
                '''audioProcessConfig.json'' file. No processing will be '...
                'performed on those Acoustic Databases. '...
                'NOTE: Run the detection function AUDIODETECTFUN for the '...
                'RECEIVERNAME/SOURCENAME combination given in '...
                '''audioProcessConfig.json'' before attempting to process '...
                'the audio data'])
        end
    end
end
