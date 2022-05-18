%  NavProConfigOne = UPDATENAVIGATIONPROCESSCONFIG(root,NavProConfigFile)
%
%  DESCRIPTION
%  Returns a full one-element navigation processing configuration structure 
%  NAVPROCONFIGONE populated with the information given in the partial 
%  navigation process configuration structure NAVPROCONFIGFILE.
%
%  UPDATENAVIGATIONPROCESSCONFIG checks for any non-valid input values. It also 
%  checks whether the Navigation Database and Acoustic Database (.mat) files 
%  contain the specified RECEIVERNAME/SOURCENAME combination; processing 
%  of the navigation parameters cannot be performed if either type of database 
%  is not found. Warnings are not displayed; instead, any error is flagged on 
%  the relevant structure field by setting it as empty ([]).
%  
%  NAVPROCONFIGFILE is extracted directly from a navigation process config file 
%  'navigaitonProcessConfig*.json' stored in '<ROOT.BLOCK>\configdb'. Function
%  READNAVIGATIONPROCESSCONFIG generates the structure NAVPROCONFIGFILE and 
%  calls UPDATENAVIGATIONPROCESSCONFIG immediately after.
%    
%  INPUT ARGUMENTS
%  - root: structure containing the root directories where the audio data
%    (ROOT.AUDIO), position data (ROOT.POSITION) and block data (ROOT.BLOCK)
%    are stored. ROOT.BLOCK contains the directories where the Configuration 
%    Files ('configdb'), Resampled Audio ('audiodb'), Detection Database
%    ('detectiondb), Navigation Database ('navigationdb'), and Acoustic 
%    Databases ('acousticdb') are stored.
%  - NavProConfigFile: partial navigation process configuration structure 
%    extracted from an 'navigaitonProcessConfig*.json' configuration file 
%    stored in folder '<ROOT.BLOCK>\configdb'. It contains only a fraction of 
%    the fields of NAVDETCONFIGONE.
%
%  OUTPUT ARGUMENTS
%  - NavProConfigOne: populated navigation process configuration structure.
%
%  FUNCTION CALL
%  NavProConfigOne = UPDATENAVIGATIONPROCESSCONFIG(root,NavProConfigFile)
%
%  FUNCTION DEPENDENCIES
%  - initialiseNavigationDatabase
%  - readChannelToReceiver
%  - readResampleRateToSource
%  - isNavigationDatabase
%  - getAcousticDatabaseNames
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  See also READNAVIGATIONPROCESSCONFIG

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  20 Jul 2021

function NavProConfigOne = updateNavigationProcessConfig(root,NavProConfigFile)

narginchk(2,2) % check number of input arguments

% Retrieve Field Names
fieldNames = fieldnames(NavProConfigFile); % field names of temporal structure

% Sort Properties by Priority Order
fieldNames_valid = {'receiverName','sourceName','smoothWindow',...
    'maxTimeGap','interpMethod'};
[iMember,iOrder] = ismember(fieldNames,fieldNames_valid);
fieldNames = fieldNames_valid(unique(iOrder(iMember)));

% Initialise Full Audio Process Configuration Structure
NavProConfigOne = initialiseNavigationProcessConfig();

% Read 'channelToReceiver.json'
ch2recPath = fullfile(root.block,'configdb','channelToReceiver.json');
ch2rec = readChannelToReceiver(ch2recPath);
if isempty(ch2rec)
    NavProConfigOne(1).channel = [];
end

% Read 'resampleRateToSource.json'
fr2souPath = fullfile(root.block,'configdb','resampleRateToSource.json');
fr2sou = readResampleRateToSource(fr2souPath);
if isempty(fr2sou)
    NavProConfigOne(1).resampleRate = [];
end

navigationdbPath = fullfile(root.block,'navigationdb','navigationdb.mat'); % abs path of Navigation DB
isNavigationdb = isNavigationDatabase(navigationdbPath);
if isNavigationdb == true % if 'navigationdb.mat' exists and is a Navigation Database
    NavigationDatabase = load(navigationdbPath);
    receiverList = NavigationDatabase.receiverList;
    sourceList = NavigationDatabase.sourceList;
    clear NavigationDatabase
else
    receiverList = [];
    sourceList = [];
    warning(['A Navigation Database (.mat) could not be found in '...
        '''ROOT.BLOCK>\navigationdb''. The navigation information for the '...
        'receiver and sources will not be processed'])
end

% Error Control(Structure Fields)
nFields = numel(fieldNames); % number of fields in temporal structure
for m = 1:nFields
    fieldName = fieldNames{m}; % current field name
    fieldValue = [NavProConfigFile.(fieldName)]; % current field value

    switch fieldName 
        case 'receiverName'
            if ~isempty(fieldValue)
                % If RECEIVERNAME is a character vector
                if ischar(fieldValue)
                    % Verify Channel and Receiver Name
                    if ~isempty(ch2rec)
                        isReceiver = ismember(ch2rec.receiverName,fieldValue);
                        if any(isReceiver)
                            NavProConfigOne(1).channel = ...
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
                            NavProConfigOne(1).resampleRate = ...
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
            
        case 'smoothWindow'
            if ~isempty(fieldValue)
                if ~isnumeric(fieldValue) || ~isscalar(fieldValue) ...
                        || fieldValue < 0 %#ok<*BDSCI>
                    fieldValue = 0;
                    warning(['SMOOTHWINDOW must be a positive scalar. No '...
                        'smoothing will be applied to the navigation data '...
                        '(SMOOTHWINDOW = %0.0f)'],fieldValue)
                end
            end
            
        case 'maxTimeGap'
            if ~isempty(fieldValue)
                smoothWindow = NavProConfigOne.smoothWindow;
                if ~isnumeric(fieldValue) || ~isscalar(fieldValue) ...
                        || fieldValue <= smoothWindow
                    fieldValue = max(300,2*smoothWindow);
                    warning(['MAXTIMEGAP must be a scalar number '...
                        'higher than SMOOTHWINDOW. MAXTIMEGAP '...
                        '= %0.1f will be used'],fieldValue)
                end
            end 
            
        case 'interpMethod'
            if ~isempty(fieldValue)
                if ~ischar(fieldValue) || ~ismember(fieldValue,...
                        {'linear','nearest','next','previous',...
                        'spline','pchip','cubic','v5cubic'})
                    fieldValue = 'linear';
                    warning(['INTERPMETHOD is not a valid string (see '...
                        'help from INTERP1). INTERPMETHOD = ''linear'''...
                        'will be used'])
                end
            end
    end
            
    % Update Current Field ('fieldName') with Current Value ('fieldValue')
    NavProConfigOne(1).(fieldName) = fieldValue;
end

% Verify Acoustic Database Files
receiverName = NavProConfigOne.receiverName;
sourceName = NavProConfigOne.sourceName;
if ~isempty(receiverName) && ~isempty(sourceName)
    acousticdbNames = getAcousticDatabaseNames(root);
    acousticdbPaths = fullfile(root.block,'acousticdb',acousticdbNames);
    % If no Acoustic Databases found
    if isempty(acousticdbNames)
        NavProConfigOne(1).receiverName = [];
        NavProConfigOne(1).sourceName = [];
        warning('No Acoustic Database file was found in <ROOT.BLOCK>/acousticdb')
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
                '<ROOT.BLOCK>\acousticdb do not match the RECEIVERNAME/'...
                'SOURCENAME combination specified in the '...
                '''audioProcessConfig.json'' file. No processing will be '...
                'performed on those Acoustic Databases. '...
                'NOTE: Run the detection function AUDIODETECTFUN for the '...
                'RECEIVERNAME/SOURCENAME combination given in '...
                '''audioProcessConfig.json'' before attempting to process '...
                'the navigation data'])
        end
    end
end

% Verify Navigation Database File
if ~isempty(receiverList) && ~isempty(sourceList)
    [~,navigationdbName] = fileparts(navigationdbPath); 
    if ~ismember(receiverName,receiverList) 
        NavProConfigOne(1).receiverName = [];
        warning(['The specified RECEIVERNAME could not be found in the '...
            'Navigation Database ''<ROOT.BLOCK>\\navigationdb\\%s.mat''. '...
            'The navigation information will not be processed for '...
            'the specified RECEIVERNAME/SOURCENAME combination'],...
            navigationdbName)
    end
    if ~ismember(sourceName,sourceList)
        NavProConfigOne(1).sourceName = [];
        warning(['The specified SOURCENAME could not be found in the '...
            'Navigation Database ''<ROOT.BLOCK>\\navigationdb\\%s''. '...
            'The navigation information will not be processed for '...
            'the specified RECEIVERNAME/SOURCENAME combination'],...
            strcat(navigationdbName,navigationdbExt))
    end
else
    NavProConfigOne(1).receiverName = [];
    NavProConfigOne(1).sourceName = [];
end
