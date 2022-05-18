%  RecImpConfigOne = UPDATERECEIVERIMPORTCONFIG(root,RecImpConfigFile)
%
%  DESCRIPTION
%  Returns a full one-element receiver configuration structure RECIMPCONFIGONE 
%  populated with the information given in the receiver import configuration 
%  structure RECIMPCONFIGFILE. The function also checks for any non-valid 
%  input values.
%
%  RECIMPCONFIGFILE is extracted directly from a receiver import config
%  file 'receiverImportConfig*.json' stored in '<ROOT.BLOCK>\configdb'. 
%  Function READRECEIVERIMPORTCONFIG generates the structure RECIMPCONFIGFILE 
%  and calls UPDATERECEIVERIMPORTCONFIG immediately after.
%
%  INPUT ARGUMENTS 
%  - root: structure containing the root directories where the audio data
%    (ROOT.AUDIO), position data (ROOT.POSITION) and block data (ROOT.BLOCK)
%    are stored. ROOT.BLOCK contains the directories where the Configuration 
%    Files ('configdb'), Resampled Audio ('audiodb'), Detection Database
%    ('detectiondb), Navigation Database ('navigationdb'), and Acoustic 
%    Databases ('acousticdb') are stored.
%  - RecImpConfigFile: partial receiver import configuration structure. 
%    Extracted from 'receiverImportConfig*.json' files.
%
%  OUTPUT ARGUMENTS
%  - RecImpConfigOne: populated receiver import configuration structure.
%    For details about its fields see INITIALISERECEIVERIMPORTCONFIG.
%
%  FUNCTION CALL
%  RecImpConfigOne = UPDATERECEIVERIMPORTCONFIG(RecImpConfigFile)
%
%  FUNCTION DEPENDENCIES
%  - initialiseReceiverImportConfig
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  See also READRECEIVERIMPORTCONFIG, VERIFYRECEIVERIMPORTCONFIG, 
%  RECEIVERIMPORTFUN

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  09 Jul 2021

function RecImpConfigOne = updateReceiverImportConfig(root,RecImpConfigFile)

narginchk(2,2) % check number of input arguments

% Retrieve Field Names
fieldNames = fieldnames(RecImpConfigFile); % field names of temporal structure

% Sort Properties by Priority Order
fieldNames_valid = {'receiverCategory','receiverName','receiverOffset',...
    'receiverOffsetMode','positionPaths','positionFormat',...
    'positionPlatform','vesselId','mmsi','latitude','longitude','depth'};
[iMember,iOrder] = ismember(fieldNames,fieldNames_valid);
fieldNames = fieldNames_valid(unique(iOrder(iMember)));

% Initialise Full Receiver Configuration Structure
RecImpConfigOne = initialiseReceiverImportConfig();

% Error Control (Structure Fields)
nFields = numel(fieldNames); % number of fields in temporal structure
for m = 1:nFields
    fieldName = fieldNames{m}; % current field name
    fieldValue = [RecImpConfigFile.(fieldName)]; % current field value

    switch fieldName
        case 'receiverCategory'
            fieldValue = lower(fieldValue); % make it case insensitive
            if ~ischar(fieldValue) || ~ismember(lower(fieldValue),...
                    {'fixed','towed'})
                fieldValue = '';
                warning('Non-supported value for RECEIVERCATEGORY')
            end
        case 'receiverName'
            if ~ischar(fieldValue)
                fieldValue = [];
                warning('RECEIVERNAME must be a character string');
            end
        case 'receiverOffset'
            if isempty(fieldValue) 
                fieldValue = [0 0];
            elseif ~isnumeric(fieldValue) || ~isvector(fieldValue) ...
                    || length(fieldValue) ~= 2
                fieldValue = [0 0];
                warning(['RECEIVEROFFSET must be a 2-element numeric '...
                    'vector. A null offset will be assumed '...
                    '(RECEIVEROFFSET = [0 0])']);
            end
        case 'receiverOffsetMode'
            fieldValue = lower(fieldValue); % make it case insensitive
            if ~ischar(fieldValue) || ~ismember(fieldValue,{'soft','hard'})
                fieldValue = 'hard';
                warning(['Non-supported value for RECEIVEROFFSETMODE. '...
                    'A ''hard'' offset will be assumed']);
            end
        case 'positionPaths'
            if ischar(fieldValue)
                fieldValue =  {fieldValue};
            end
            if ~iscell(fieldValue)
                fieldValue = '';
                warning(['POSITIONPATHS must be either a string or a '...
                    'cell array of strings'])
            end
            
            % Warn about Wrong Folders or Paths in POSITIONPATHS
            filePaths = fullfile(root.position,fieldValue); % absolute paths and folders
            isPath = cellfun(@(x) exist(x,'file') == 2,filePaths);
            isFolder = cellfun(@(x) exist(x,'dir') == 7,filePaths);
            if any(~isPath & ~isFolder)
                fieldValue = '';
                warning(['One or more of the absolute paths or directories '...
                    'in ''<ROOT.POSITION>\POSITIONPATHS'' do not exist'])
            end
        case 'positionFormat'
            fieldValue = lower(fieldValue); % make it case insensitive
            if ~ischar(fieldValue) || ~any(strcmp(fieldValue,...
                    {'gps','ais','p190'}))
                fieldValue = '';
                warning('POSITIONFORMAT string not recognised')
            end
        case 'positionPlatform'
            fieldValue = lower(fieldValue); % make it case insensitive
            if ~ischar(fieldValue) || ~any(strcmp(fieldValue,...
                    {'seichessv','pamguard','seismic'}))
                fieldValue = '';
                warning('Non-supported value for POSITIONPLATFORM');
            end
            if strcmp(fieldValue,'pamguard') && ...
                    strcmp(RecImpConfigOne.positionFormat,'p190')
                fieldValue = '';
                warning(['The P190 format is not a valid option for '...
                    'POSITIONPLATFORM = ''PamGuard'''])
            end
            if strcmp(fieldValue,'seichessv') && ...
                    ~strcmp(RecImpConfigOne.positionFormat,'gps')
                fieldValue = '';
                warning(['The %s format is not a valid option for '...
                    'POSITIONPLATFORM = ''SeicheSsv'''],...
                    RecImpConfigOne.positionFormat)
            end
            if strcmp(fieldValue,'seismic') && ...
                    ~strcmp(RecImpConfigOne.positionFormat,'p190')
                fieldValue = '';
                warning(['The %s format is not a valid option for '...
                    'POSITIONPLATFORM = ''Seismic'''],...
                    RecImpConfigOne.positionFormat)
            end
        case 'vesselId'
            if ~isempty(fieldValue) && (~isnumeric(fieldValue) ...
                    || ~isscalar(fieldValue))
                fieldValue = [];
                warning('VESSELID must be a numeric value');
            end
        case 'mmsi'
            if ~isempty(fieldValue) && isnumeric(fieldValue) ...
                    && isscalar(fieldValue)
                nDigits = floor(log10(fieldValue)) + 1; % number of digits in mmsi
                if nDigits ~= 9
                    fieldValue = [];
                    warning('The MMSI must be a 9 digits number');
                end
            end
        case 'latitude'
            if ~isempty(fieldValue) &&  (~isnumeric(fieldValue) ...
                    || ~isscalar(fieldValue) || fieldValue > 90 ...
                    || fieldValue < -90) %#ok<BDSCI>
                        fieldValue = [];
                        warning(['LATITUDE must be a scalar numeric value'...
                            'between -90 and 90']);
            end
        case 'longitude'
            if ~isempty(fieldValue) &&  (~isnumeric(fieldValue) ...
                    || ~isscalar(fieldValue) || fieldValue > 180 ...
                    || fieldValue < -180) %#ok<BDSCI>
                        fieldValue = [];
                        warning(['LONGITUDE must be a scalar numeric value'...
                            'between -180 and 180']);
            end
        case 'depth'
            if ~isempty(fieldValue)
                if isnumeric(fieldValue) && isscalar(fieldValue)
                    fieldValue = -abs(fieldValue); % depth is negative down
                else
                    fieldValue = [];
                    warning('DEPTH must be a scalar numeric value');
                end
            end
    end

    % Update Current Field ('fieldName') with Current Value ('fieldValue')
    RecImpConfigOne(1).(fieldName) = fieldValue;
end
