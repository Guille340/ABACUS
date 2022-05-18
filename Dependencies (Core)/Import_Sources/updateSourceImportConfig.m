%  SouImpConfigOne = UPDATESOURCEIMPORTCONFIG(root,SouImpConfigFile)
%
%  DESCRIPTION
%  Returns a full one-element source configuration structure SOUIMPCONFIGONE 
%  populated with the information given in the source import configuration 
%  structure SOUIMPCONFIGFILE. The function also checks for any non-valid 
%  input values.
%
%  SOUIMPCONFIGFILE is extracted directly from a source import config file 
%  'sourceImportConfig*.json' stored in '<ROOT.BLOCK>\configdb'. Function
%  READSOURCEIMPORTCONFIG generates the structure SOUIMPCONFIGFILE and calls 
%  UPDATESOURCEIMPORTCONFIG immediately after.
%
%  INPUT ARGUMENTS 
%  - root: structure containing the root directories where the audio data
%    (ROOT.AUDIO), position data (ROOT.POSITION) and block data (ROOT.BLOCK)
%    are stored. ROOT.BLOCK contains the directories where the Configuration 
%    Files ('configdb'), Resampled Audio ('audiodb'), Detection Database
%    ('detectiondb), Navigation Database ('navigationdb'), and Acoustic 
%    Databases ('acousticdb') are stored.
%  - SouImpConfigFile: partial source import configuration structure. 
%    Extracted from 'sourceImportConfig*.json' files.
%
%  OUTPUT ARGUMENTS
%  - SouImpConfigOne: populated source import configuration structure.
%    For details about its fields see INITIALISESOURCEIMPORTCONFIG.
%
%  FUNCTION CALL
%  SouImpConfigOne = UPDATESOURCEIMPORTCONFIG(SouImpConfigFile)
%
%  FUNCTION DEPENDENCIES
%  - initialiseSourceImportConfig
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  See also READSOURCEIMPORTCONFIG, VERIFYSOURCEIMPORTCONFIG, SOURCEIMPORTFUN

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  09 Jul 2021

function SouImpConfigOne = updateSourceImportConfig(root,SouImpConfigFile)

narginchk(2,2) % check number of input arguments

% Retrieve Field Names
fieldNames = fieldnames(SouImpConfigFile); % field names of temporal structure

% Sort Properties by Priority Order
validFieldNames = {'sourceCategory','sourceName',...
    'sourceOffset','sourceOffsetMode','positionPaths',...
    'positionFormat','positionPlatform','vesselId','sourceId',...
    'mmsi','vesselName','vesselLength','vesselBeam','vesselDraft',...
    'vesselGrossTonnage','latitude','longitude','depth'};
[~,i2] = ismember(fieldNames,validFieldNames);
[~,iOrder] = sort(i2);
fieldNames = fieldNames(iOrder);

% Initialise Full Source Configuration Structure
SouImpConfigOne = initialiseSourceImportConfig();

% Error Control (Structure Fields)
nFields = numel(fieldNames); % number of fields in temporal structure
for m = 1:nFields
    fieldName = fieldNames{m}; % current field name
    fieldValue = [SouImpConfigFile.(fieldName)]; % current field value

    switch fieldName
        case 'sourceCategory'
            fieldValue = lower(fieldValue); % make it case insensitive
            if ~ischar(fieldValue) || ~ismember(fieldValue,...
                    {'fixed','towed','vessel','fleet'})
                fieldValue = '';
                warning('Non-supported value for SOURCECATEGORY')
            end
        case 'sourceName'
            if ~ischar(fieldValue)
                if strcmp(SouImpConfigOne.sourceCategory,'fleet')
                    fieldValue = 'fleet';
                else
                    fieldValue = [];
                    warning('SOURCENAME must be a character string');
                end
            end
        case 'sourceOffset'
            if isempty(fieldValue) 
                fieldValue = [0 0];
            elseif ~isnumeric(fieldValue) || ~isvector(fieldValue) ...
                    || length(fieldValue) ~= 2
                fieldValue = [0 0];
                warning(['SOURCEOFFSET must be a 2-element numeric '...
                    'vector. A null offset will be assumed '...
                    '(SOURCEOFFSET = [0 0 ])']);
            end
        case 'sourceOffsetMode'
            fieldValue = lower(fieldValue); % make it case insensitive
            if ~ischar(fieldValue) || ~ismember(fieldValue,{'soft','hard'})
                fieldValue = 'hard';
                warning(['Non-supported value for SOURCEOFFSETMODE. '...
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
                    strcmp(SouImpConfigOne.positionFormat,'p190')
                fieldValue = '';
                warning(['The P190 format is not a valid option for '...
                    'POSITIONPLATFORM = ''PamGuard'''])
            end
            if strcmp(fieldValue,'seichessv') && ...
                    ~strcmp(SouImpConfigOne.positionFormat,'gps')
                fieldValue = '';
                warning(['The %s format is not a valid option for '...
                    'POSITIONPLATFORM = ''SeicheSsv'''],...
                    SouImpConfigOne.positionFormat)
            end
            if strcmp(fieldValue,'seismic') && ...
                    ~strcmp(SouImpConfigOne.positionFormat,'p190')
                fieldValue = '';
                warning(['The %s format is not a valid option for '...
                    'POSITIONPLATFORM = ''Seismic'''],...
                    SouImpConfigOne.positionFormat)
            end
        case 'vesselId'
            if ~isempty(fieldValue) && (~isnumeric(fieldValue) ...
                    || ~isscalar(fieldValue))
                fieldValue = [];
                warning('VESSELID must be a numeric value');
            end
        case 'sourceId'
            if ~isempty(fieldValue) && (~isnumeric(fieldValue) ...
                    || ~isscalar(fieldValue))
                fieldValue = [];
                warning('SOURCEID must be a numeric value');
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
        case 'vesselName'
            if ~char(fieldValue)
                fieldValue = [];
                warning('VESSELNAME must be a character string');
            end
        case 'vesselLength'
            if ~isempty(fieldValue) && ~isnumeric(fieldValue)
                fieldValue = [];
                warning('VESSELLENGTH must be a numeric value');
            end
        case 'vesselBeam'
            if ~isempty(fieldValue) && (~isnumeric(fieldValue) ...
                    || ~isscalar(fieldValue))
                fieldValue = [];
                warning('VESSELBEAM must be a numeric value');
            end
        case 'vesselDraft'
            if ~isempty(fieldValue) && (~isnumeric(fieldValue) ...
                    || ~isscalar(fieldValue))
                fieldValue = [];
                warning('VESSELDRAFT must be a numeric value');
            end
        case 'vesselGrossTonnage'
            if ~isempty(fieldValue) && (~isnumeric(fieldValue) ...
                    || ~isscalar(fieldValue))
                fieldValue = [];
                warning('VESSELGROSSTONNAGE must be a numeric value');
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
    SouImpConfigOne(1).(fieldName) = fieldValue;
end
