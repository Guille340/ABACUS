%  AudDetConfigOne = UPDATEAUDIODETECTCONFIG(root,AudDetConfigFile)
%
%  DESCRIPTION
%  Returns a full one-element audio processing configuration structure 
%  AUDDETCONFIGONE populated with the information given in the audio detect 
%  configuration structure AUDDETCONFIGFILE. 
%
%  UPDATEAUDIOODETECTCONFIG checks for any non-valid input values. It also
%  checks whether Audio Database (.mat) files are available for the specified 
%  RECEIVERNAME/SOURCENAME combination; detection of sound events cannot be 
%  performed if no Audio Database is found. Warnings are not displayed;
%  instead, any error is flagged on the relevant structure field by setting 
%  it as empty ([]).
%
%  AUDDETCONFIGFILE is extracted directly from an audio detect config file 
%  'audioDetectConfig*.json' stored in '<ROOT.BLOCK>\configdb'. Function
%  READAUDIODETECTCONFIG generates the structure AUDDETCONFIGFILE and calls 
%  UPDATEAUDIODETECTCONFIG immediately after.
%    
%  INPUT ARGUMENTS
%  - root: structure containing the root directories where the audio data
%    (ROOT.AUDIO), position data (ROOT.POSITION) and block data (ROOT.BLOCK)
%    are stored. ROOT.BLOCK contains the directories where the Configuration 
%    Files ('configdb'), Resampled Audio ('audiodb'), Detection Database
%    ('detectiondb), Navigation Database ('navigationdb'), and Acoustic 
%    Databases ('acousticdb') are stored.
%
%  - AudDetConfigFile: partial audio detect configuration structure extracted 
%    from an 'audioDetectConfig*.json' configuration file stored in folder
%    '<ROOT.BLOCK>\configdb'. It contains only a fraction of the fields of 
%    AUDDETCONFIGONE.
%
%  OUTPUT ARGUMENTS
%  - AudDetConfigOne: populated audio detect configuration structure.
%    For details about its fields see INITIALISEAUDIODETECTCONFIG.
%
%  FUNCTION CALL
%  AudDetConfigOne = UPDATEAUDIOPROCESSCONFIG(root,AudDetConfigFile)
%
%  FUNCTION DEPENDENCIES
%  - initialiseAudioDetectConfig
%  - getAudioDatabaseNames
%  - getAcousticDatabaseNames
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  See also READAUDIODETECTCONFIG

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  20 Jul 2021

function AudDetConfigOne = updateAudioDetectConfig(root,AudDetConfigFile)

narginchk(2,2) % check number of input arguments

% Retrieve Field Names
fieldNames = fieldnames(AudDetConfigFile); % field names of temporal structure

% Sort Properties by Priority Order
fieldNames_valid = {'receiverName','sourceName','mirrorReceiver',...
    'detector','DetectParameters'};
[iMember,iOrder] = ismember(fieldNames,fieldNames_valid);
fieldNames = fieldNames_valid(unique(iOrder(iMember)));

% Initialise Full Audio Process Configuration Structure
AudDetConfigOne = initialiseAudioDetectConfig();

% Read 'channelToReceiver.json'
ch2recPath = fullfile(root.block,'configdb','channelToReceiver.json');
ch2rec = readChannelToReceiver(ch2recPath);
if isempty(ch2rec)
    AudDetConfigOne(1).channel = [];
end

% Read 'resampleRateToSource.json'
fr2souPath = fullfile(root.block,'configdb','resampleRateToSource.json');
fr2sou = readResampleRateToSource(fr2souPath);
if isempty(fr2sou)
    AudDetConfigOne(1).resampleRate = [];
end

% Error Control(Structure Fields)
nFields = numel(fieldNames); % number of fields in temporal structure
for m = 1:nFields
    fieldName = fieldNames{m}; % current field name
    fieldValue = [AudDetConfigFile.(fieldName)]; % current field value

    switch fieldName             
        case 'receiverName'
            if ~isempty(fieldValue)
                % If RECEIVERNAME is a character vector
                if ischar(fieldValue)
                    % Verify Channel and Receiver Name
                    if ~isempty(ch2rec)
                        isReceiver = strcmp(fieldValue,ch2rec.receiverName);
                        if any(isReceiver)
                            AudDetConfigOne(1).channel = ...
                                ch2rec.channel(isReceiver);
                        else
                            fieldValue = [];
                            warning(['RECEIVERNAME must be listed in file '...
                                '''<ROOT.BLOCK>\\configdb\\channelToReceiver.'...
                                'json. Ensure that ''channelToReceiver.'...
                                'json'' and ''resampleRateToSource.json'' '...
                                'have been created before proceeding further'])
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
                        isSource = strcmp(fieldValue,fr2sou.sourceName);
                        if any(isSource)
                            AudDetConfigOne(1).resampleRate = ...
                                fr2sou.resampleRate(isSource);
                        else
                            fieldValue = [];
                            warning(['SOURCENAME must be listed in file '...
                                '''<ROOT.BLOCK>\\configdb\\'...
                                'resampleRateToSource.json. Ensure that '...
                                '''channelToReceiver.json'' and '...
                                '''resampleRateToSource.json'' have been '...
                                'created before proceeding further'])
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
        case 'mirrorReceiver'
            if ~isempty(fieldValue)
                % If MIRRORRECEIVER is a character vector
                if ischar(fieldValue)
                    % Read 'channelToReceiver.json'
                    ch2recPath = fullfile(root.block,'configdb',...
                        'channelToReceiver.json');
                    ch2rec = readChannelToReceiver(ch2recPath);
                    if ~isempty(ch2rec)
                        isReceiver = strcmp(fieldValue,ch2rec.receiverName);
                        if any(isReceiver)
                            if strcmp(fieldValue,AudDetConfigOne.receiverName)
                                fieldValue = [];
                                warning(['MIRRORRECEIVER must be different '...
                                    'from RECEIVERNAME']) 
                            end
                        else
                            fieldValue = [];
                            warning(['MIRRORRECEIVER must be listed in file '...
                                '''<ROOT.BLOCK>\\configdb\\channelToReceiver.'...
                                'json. Ensure that ''channelToReceiver.'...
                                'json'' and ''resampleRateToSource.json'' '...
                                'have been created before proceeding further'])
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
            
        case 'detector'
            if ~isempty(fieldValue)
                if ischar(fieldValue) 
                    fieldValue = lower(fieldValue);
                    if ~ismember(fieldValue,{'slice','movingaverage',...
                            'constantrate','neymanpearson'})
                        fieldValue = [];
                        warning(['Non-supported character string for '...
                            'DETECTOR field'])
                    end
                else
                    fieldValue = [];
                    warning('DETECTOR must be a character vector')
                end
            end
            
        % UPDATE 'DetectParameters'
        case 'DetectParameters'
            detector = AudDetConfigOne.detector;
            switch detector
                case 'slice'
                    fieldNamesDetParams_valid = {'windowDuration'};
                    fieldNamesDetParams = fieldnames(fieldValue);
                    
                    if all(ismember(fieldNamesDetParams,...
                            fieldNamesDetParams_valid)) ...
                            && all(ismember(fieldNamesDetParams_valid,...
                            fieldNamesDetParams))
                        
                        % Parameter 'windowDuration'
                        windowDuration = fieldValue.windowDuration;
                        if ~isempty(windowDuration)
                            if ~isnumeric(windowDuration) ...
                                    || ~isscalar(windowDuration) ...
                                    || windowDuration <= 0
                                windowDuration = [];
                                warning(['DETECTPARAMETERS.WINDOWDURATION '...
                                    'must be a positive scalar number'])
                            end
                        end
                        
                        % Store Parameters in 'DetectParameters'
                        fieldValue.windowDuration = windowDuration;      
                    else
                        fieldValue = [];
                        warning(['One or more fields in DETECTPARAMETERS '...
                            'were not found or are not supported'])
                    end
                    
                case 'movingaverage'
                    fieldNamesDetParams_valid = {'windowDuration',...
                        'windowOffset','threshold','cutoffFreqs'};
                    fieldNamesDetParams = fieldnames(fieldValue);
                    
                    if all(ismember(fieldNamesDetParams,...
                            fieldNamesDetParams_valid)) ...
                            && all(ismember(fieldNamesDetParams_valid,...
                            fieldNamesDetParams))
                        
                        % Parameter 'windowDuration'
                        windowDuration = fieldValue.windowDuration;
                        if ~isempty(windowDuration)
                            if ~isnumeric(windowDuration) ...
                                    || ~isscalar(windowDuration) ...
                                    || windowDuration <= 0
                                windowDuration = [];
                                warning(['DETECTPARAMETERS.WINDOWDURATION '...
                                    'must be a positive scalar number'])
                            end
                        end
                        
                        % Parameter 'windowOffset'
                        windowOffset = fieldValue.windowOffset;
                        if ~isempty(windowOffset)
                            if ~isnumeric(windowOffset) ...
                                    || ~isscalar(windowOffset) ...
                                    || windowOffset < 0 ...
                                    || windowOffset >= fieldValue.windowDuration %#ok<*BDSCI>
                                windowOffset = [];
                                warning(['DETECTPARAMETERS.WINDOWOFFSET '...
                                    'must be a positive scalar lower than '...
                                    'WINDOWDURATION. No window offset will '...
                                    'be applied'])
                            end
                        end
                        
                        % Parameter 'threshold'
                        threshold = fieldValue.threshold;
                        if ~isempty(threshold)
                            if ~isnumeric(threshold) ...
                                    || ~isscalar(threshold) ...
                                    || threshold < 1
                                threshold = [];
                                warning(['DETECTPARAMETERS.THRESHOLD must '...
                                    'be a scalar number higher than or '...
                                    'equal to 1'])
                            end
                        end
                        
                        % Parameter 'cutoffFreqs'
                        cutoffFreqs = fieldValue.cutoffFreqs;
                        resampleRate = AudDetConfigOne.resampleRate;
                        if ~isempty(cutoffFreqs)
                            if isnumeric(cutoffFreqs) && numel(cutoffFreqs)==2
                                freqMin = min(cutoffFreqs);
                                freqMax = max(cutoffFreqs);
                                if freqMin < 0
                                    freqMin = 0;
                                    warning(['MIN(DETECTPARAMETERS.'...
                                        'CUTOFFFREQS) must be higher than '...
                                        '0. MIN(DETECTPARAMETERS.'...
                                        'CUTOFFFREQS) = 0 will be used'])
                                end
                                if ~isempty(resampleRate) ...
                                        && freqMax > resampleRate/2
                                    freqMax = resampleRate/2;
                                    warning(['MAX(DETECTPARAMETERS.'...
                                        'CUTOFFFREQS) must be lower than  '...
                                        'or equal to RESAMPLERATE/2. '...
                                        'MAX(DETECTPARAMETERS.'...
                                        'CUTOFFFREQS) = RESAMPLERATE/2 '...
                                        'will be used'])
                                end
                                cutoffFreqs = [freqMin freqMax];
                            else
                                cutoffFreqs = [0 resampleRate/2];
                                warning(['DETECTPARAMETERS.CUTOFFFREQS '...
                                    'must be a two-element numeric array. '...
                                    'DETECTPARAMETERS.CUTOFFFREQS = '...
                                    '[0 RESAMPLERATE/2] will be used'])
                            end
                        end
                                                
                        % Store Parameters in 'DetectParameters'
                        fieldValue.windowDuration = windowDuration;
                        fieldValue.windowOffset = windowOffset;
                        fieldValue.threshold = threshold;
                        fieldValue.cutoffFreqs = cutoffFreqs;

                    else
                        fieldValue = [];
                        warning(['One or more fields in DETECTPARAMETERS '...
                            'were not found or are not supported'])
                    end
                    
                case 'neymanpearson'
                    fieldNamesDetParams_valid = {'detectorType',...
                        'kernelDuration','windowDuration','windowOffset',...
                        'rtpFalseAlarm','detectorSensitivity','minSnrLevel',...
                        'cutoffFreqs','trainFolder','estimator','resampleRate'};
                    fieldNamesDetParams = fieldnames(fieldValue);
                    
                    if all(ismember(fieldNamesDetParams,...
                            fieldNamesDetParams_valid)) ...
                            && all(ismember(fieldNamesDetParams_valid,...
                            fieldNamesDetParams))
                        
                        % Parameter 'detectorType'
                        detectorType = fieldValue.detectorType;
                        if ~isempty(detectorType)
                            if ~ischar(detectorType) || ~ismember(...
                                    detectorType,{'ed','ecw','ecc'})
                                detectorType = 'ed';
                                warning(['DETECTPARAMETERS.DETECTORTYPE '...
                                    'is not a valid character vector. '...
                                    'DETECTPARAMETERS.DETECTORTYPE = ''%s'' '...
                                    'will be used'],detectorType)
                            end
                        end
                        
                        % Parameter 'kernelDuration'
                        kernelDuration = fieldValue.kernelDuration;
                        if ~isempty(kernelDuration)
                            if ~isnumeric(kernelDuration) ...
                                    || ~isscalar(kernelDuration) ...
                                    || kernelDuration <= 0
                                kernelDuration = [];
                                warning(['DETECTPARAMETERS.KERNELDURATION '...
                                    'must be a positive scalar number'])
                            end
                        end
                        
                        % Parameter 'windowDuration'
                        windowDuration = fieldValue.windowDuration;
                        if ~isempty(windowDuration)
                            if isnumeric(windowDuration) ...
                                    && isscalar(windowDuration) ...
                                    && windowDuration > 0
                                if rem(windowDuration,kernelDuration)
                                    windowDuration = ceil(windowDuration ...
                                        /kernelDuration) * kernelDuration;
                                    warning(['DETECTPARAMETERS.WINDOW'...
                                        'DURATION must be a multiple of '...
                                        'DETECTPARAMETERS.KERNELDURATION. '...
                                        'DETECTPARAMETERS.WINDOWDURATION '...
                                        '= %0.3e will be used'],windowDuration)
                                end
                            else
                                windowDuration = [];
                                warning(['DETECTPARAMETERS.WINDOWDURATION '...
                                    'must be a positive scalar number'])
                            end
                        end
                        
                        % Parameter 'windowOffset'
                        windowOffset = fieldValue.windowOffset;
                        if ~isempty(windowOffset)
                            if ~isnumeric(windowOffset) ...
                                    || ~isscalar(windowOffset) ...
                                    || windowOffset < 0 ...
                                    || windowOffset >= fieldValue.kernelDuration
                                windowOffset = [];
                                warning(['DETECTPARAMETERS.WINDOWOFFSET '...
                                    'must be a positive scalar lower than '...
                                    'KERNELDURATION. No window offset will '...
                                    'be applied'])
                            end
                        end
                        
                        % Parameter 'rtpFalseAlarm'
                        rtpFalseAlarm = fieldValue.rtpFalseAlarm;
                        if ~isempty(rtpFalseAlarm)
                            if ~isnumeric(rtpFalseAlarm) ...
                                    || ~isscalar(rtpFalseAlarm) ...
                                    || rtpFalseAlarm > 1 || rtpFalseAlarm < 0
                                rtpFalseAlarm = 1e-3;
                                warning(['DETECTPARAMETERS.RTPFALSEALARM '...
                                    'must be a scalar number between 0 and '...
                                    '1. DETECTPARAMETERS.RTPFALSEALARM = '...
                                    '%0.3e will be used'],rtpFalseAlarm)
                            end
                        else
                            rtpFalseAlarm = 1e-3;
                        end
                        
                        % Parameter 'detectorSensitivity'
                        detectorSensitivity = fieldValue.detectorSensitivity;
                        if ~isempty(detectorSensitivity)
                            if ~isnumeric(detectorSensitivity) ...
                                    || ~isscalar(detectorSensitivity) ...
                                    || detectorSensitivity > 1 ...
                                    || detectorSensitivity < 0
                                detectorSensitivity = 1;
                                warning(['DETECTPARAMETERS.DETECTOR'...
                                    'SENSITIVITY must be a scalar number '...
                                    'between 0 and 1. DETECTPARAMETERS.'...
                                    'DETECTORSENSITIVITY = %0.3e will be '...
                                    'used'],detectorSensitivity)
                            end
                        else
                            detectorSensitivity = 1;
                        end
                        
                        % Parameter 'minSnrLevel'
                        minSnrLevel = fieldValue.minSnrLevel;
                        if ~isempty(minSnrLevel)
                            if ~isnumeric(minSnrLevel) ...
                                    || ~isscalar(minSnrLevel)
                                minSnrLevel = -Inf;
                                warning(['DETECTPARAMETERS.MINSNRLEVEL'...
                                    'must be a scalar number. DETECT'...
                                    'PARAMETERS.MINSNRLEVEL = %0.3e will '...
                                    'be used'],minSnrLevel)
                            end
                        else
                            minSnrLevel = -Inf;
                        end
                        
                        % Parameter 'estimator'
                        estimator = fieldValue.estimator;
                        if ~isempty(estimator)
                            if ~ischar(estimator) || ~ismember(estimator,...
                                    {'oas','rblw','param1','param2',...
                                    'corr','diag','stock','looc','sample'})
                                estimator = 'sample';
                                warning(['DETECTPARAMETERS.ESTIMATOR '...
                                    'is not a valid character vector. '...
                                    'DETECTPARAMETERS.ESTIMATOR = ''%s'' '...
                                    'will be used'],estimator)
                            end
                        end
                        
                        % Parameter 'resampleRate'
                        resampleRate_det = fieldValue.resampleRate;
                        resampleRate_aud = AudDetConfigOne.resampleRate;
                        if ~isempty(resampleRate_det) ...
                                && ~isempty(resampleRate_aud)
                            if isnumeric(resampleRate_det) ...
                                    && isscalar(resampleRate_det)
                                if resampleRate_det > resampleRate_aud
                                    resampleRate_det = resampleRate_aud;
                                    warning(['DETECTPARAMETERS.RESAMPLERATE '...
                                        'must be lower than or equal to '...
                                        'RESAMPLERATE (audio file). DETECT'...
                                        'PARAMETERS.RESAMPLERATE = %0.0f '...
                                        'will be used'],resampleRate_det)
                                end
                            else
                                resampleRate_det = resampleRate_aud;
                                warning(['DETECTPARAMETERS.RESAMPLERATE'...
                                    'must be a scalar number. DETECT'...
                                    'PARAMETERS.RESAMPLERATE = %0.0f will '...
                                    'be used'],resampleRate_det)
                            end
                        else
                            if isempty(resampleRate_det)
                                if ~isempty(resampleRate_aud)
                                    resampleRate_det = resampleRate_aud;
                                else
                                    resampleRate_det = [];
                                end
                            end
                        end
                        
                        % Parameter 'cutoffFreqs'
                        cutoffFreqs = fieldValue.cutoffFreqs;
                        if ~isempty(cutoffFreqs)
                            if isnumeric(cutoffFreqs) || numel(cutoffFreqs)~=2
                                freqMin = min(cutoffFreqs);
                                freqMax = max(cutoffFreqs);
                                if freqMin < 0
                                    freqMin = 0;
                                    warning(['MIN(DETECTPARAMETERS.'...
                                        'CUTOFFFREQS) must be higher than '...
                                        '0. MIN(DETECTPARAMETERS.'...
                                        'CUTOFFFREQS) = 0 will be used'])
                                end
                                if ~isempty(resampleRate_det) ...
                                        && freqMax > resampleRate_det/2
                                    freqMax = resampleRate_det/2;
                                    warning(['MAX(DETECTPARAMETERS.'...
                                        'CUTOFFFREQS) must be lower than  '...
                                        'or equal to DETECTPARAMETERS.'...
                                        'RESAMPLERATE/2. MAX(DETECT'...
                                        'PARAMETERS.CUTOFFFREQS) = %0.0f '...
                                        'will be used'],freqMax)
                                end
                                cutoffFreqs = [freqMin freqMax];
                            else
                                cutoffFreqs = [0 resampleRate_det/2];
                                warning(['DETECTPARAMETERS.CUTOFFFREQS '...
                                    'must be a two-element numeric array. '...
                                    'DETECTPARAMETERS.CUTOFFFREQS = '...
                                    '[0 %0.0f] will be used'],cutoffFreqs(2))
                            end
                        else
                            if ~isempty(resampleRate_det)
                                cutoffFreqs = [0 resampleRate_det/2];
                            end
                        end
                        
                        % Parameter 'trainFolder'
                        trainFolder = fieldValue.trainFolder;
                        if ~isempty(trainFolder) ...
                                && ismember(detectorType,{'ecw','ecc'})
                            if ~ischar(trainFolder)
                                if exist(trainFolder,'dir') ~= 7
                                    trainFolder = [];
                                    warning(['<DETECTPARAMETERS.TRAINFOLDER>'...
                                        ' must be a valid existing directory'])
                                end
                            else
                                rawSignalDir = fullfile(trainFolder,'signal');
                                if exist(rawSignalDir,'dir') ~= 7
                                    warning(['Directory ''<DETECTPARAMETERS.'...
                                        'TRAINFOLDER>\signal'' does not exist'])
                                end

                                rawNoiseDir = fullfile(trainFolder,'noise');
                                if strcmp(detectorType,'ecc') ...
                                        && exist(rawNoiseDir,'dir') ~= 7
                                    warning(['Directory ''<DETECTPARAMETERS.'...
                                        'TRAINFOLDER>\noise'' does not exist'])
                                end
                            end
                        end
                        if isempty(trainFolder) ...
                                && ismember(detectorType,{'ecw','ecc'})
                            warning(['DETECTPARAMETERS.TRAINFOLDER '...
                                        'must be a valid existing directory'])
                        end
                                                
                        % Store Parameters in 'DetectParameters'
                        fieldValue.detectorType = detectorType;
                        fieldValue.kernelDuration = kernelDuration;
                        fieldValue.windowDuration = windowDuration;
                        fieldValue.windowOffset = windowOffset;
                        fieldValue.rtpFalseAlarm = rtpFalseAlarm;
                        fieldValue.detectorSensitivity = detectorSensitivity;
                        fieldValue.minSnrLevel = minSnrLevel;
                        fieldValue.cutoffFreqs = cutoffFreqs;
                        fieldValue.trainFolder = trainFolder;
                        fieldValue.estimator = estimator;
                        fieldValue.resampleRate = resampleRate_det;
                    else
                        fieldValue = [];
                        warning(['One or more fields in DETECTPARAMETERS '...
                            'were not found or are not supported'])
                    end
                        
                case 'constantrate'
                    
                    fieldNamesDetParams_valid = {'windowDuration',...
                        'windowOffset','fileName'};
                    fieldNamesDetParams = fieldnames(fieldValue);
                    
                    if all(ismember(fieldNamesDetParams,...
                            fieldNamesDetParams_valid)) ...
                            && all(ismember(fieldNamesDetParams_valid,...
                            fieldNamesDetParams))
                        
                        % Parameter 'windowDuration'
                        windowDuration = fieldValue.windowDuration;
                        if ~isempty(windowDuration)
                            if ~isnumeric(windowDuration) ...
                                    || ~isscalar(windowDuration) ...
                                    || windowDuration <= 0
                                windowDuration = [];
                                warning(['DETECTPARAMETERS.WINDOWDURATION '...
                                    'must be a positive scalar number'])
                            end
                        end
                        
                        % Parameter 'windowOffset'
                        windowOffset = fieldValue.windowOffset;
                        if ~isempty(windowOffset)
                            if ~isnumeric(windowOffset) ...
                                    || ~isscalar(windowOffset) ...
                                    || windowOffset < 0 ...
                                    || windowOffset >= fieldValue.windowDuration
                                windowOffset = [];
                                warning(['DETECTPARAMETERS.WINDOWOFFSET '...
                                    'must be a positive scalar lower than '...
                                    'WINDOWDURATION. No window offset will '...
                                    'be applied'])
                            end
                        end
                        
                        % Parameter 'fileName'
                        fileName = fieldValue.fileName;
                        filePath = fullfile(root.block,'configdb',fileName);
                        if ~isempty(fileName)
                            if ischar(fileName)
                                isTable = isPulseTable(filePath);                                     
                                if isTable == false % wrong file format
                                    fileName = [];
                                    warning(['Non-supported format for '...
                                        'pulse table ''<ROOT.BLOCK>\\configdb'...
                                        '\\%s''. The detection process '...
                                        'cannot be performed'],fileName)
                                end
                                if isTable == -1 % file does not exist
                                    fileName = [];
                                    warning(['Pulse table ''%s'' cannot '...
                                        'be found in directory'...
                                        '''<ROOT.BLOCK>\\configdb''. The '...
                                        'detection process cannot be '...
                                        'performed'],fileName)
                                end
                            else
                                fileName = [];
                                warning(['DETECTIONPARAMETERS.FILENAME must '...
                                    'be a character vector'])
                            end
                        end
                    else
                        fieldValue = [];
                        warning(['One or more fields in '...
                            'DETECTPARAMETERS were not found or are '...
                            'not supported'])
                    end
                        
                    % Store Parameters in 'DetectParameters'
                    fieldValue.windowDuration = windowDuration;
                    fieldValue.windowOffset = windowOffset;
                    fieldValue.fileName = fileName;
            end 
    end

    % Update Current Field ('fieldName') with Current Value ('fieldValue')
    AudDetConfigOne(1).(fieldName) = fieldValue;
end

% Verify CHANNEL and RESAMPLERATE
channel = AudDetConfigOne.channel;
resampleRate = AudDetConfigOne.resampleRate;
isChannel = ~isempty(channel) && isnumeric(channel) && isscalar(channel) ...
        && channel >= 1 && ~rem(channel,1); % true for valid channel
isResampleRate = ~isempty(resampleRate) && isnumeric(resampleRate) ...
    && isscalar(resampleRate); % true for valid resample rate

% Verify Audio Database Files
if isChannel && isResampleRate
    audiodbNames = getAudioDatabaseNames(root,channel,resampleRate);
    if isempty(audiodbNames)
        AudDetConfigOne(1).channel = [];
        AudDetConfigOne(1).resampleRate = [];
        warning(['No Audio Database file was found in <ROOT.BLOCK>/audiodb '...
            'for the specified CHANNEL and RESAMPLERATE'])
    end
end
