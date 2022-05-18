%  SOURCEIMPORTFUN(root,SouImpConfig)
%
%  DESCRIPTION
%  Reads the position data for each source, as specified in the multi-
%  element source configuration structure SOUIMPCONFIG, and saves it in the
%  Navigation Database (.mat) 'navigationdb*.json' stored in directory
%  '<ROOT.BLOCK>\navigationdb\'. If the Navigation Database does not exist, it 
%  creates one. 
%
%  SOUIMPCONFIG is generated with READSOURCEIMPORTCONFIG. Each element in 
%  SOUIMPCONFIG contains the information from an individual source import 
%  configuration script 'sourceImportConfig*.json' stored in '<ROOT.BLOCK>\
%  configdb'. The information comprises the folder(s) where the position 
%  files are stored and source information including category, dimensions 
%  and relative position.
%
%  Before acquiring the position data, SOURCEIMPORTFUN removes from
%  SOUIMPCONFIG any element that meets either of the next two conditions:
%  1. INPUTSTATUS = FALSE (see VERIFYAUDIOINPUTCONFIG). A FALSE value
%     indicates that individual field values in the corresponding one-
%     element structure of SOURCEIMPORTFUN are incorrect.
%  2. RECEIVERNAME already exists in other element of input SOUIMPCONFIG
%     or in the Navigation Database. If new data needs to be added for
%     that exact source, delete the source with DELETESOURCES and
%     run SOURCEIMPORTFUN with the updated 'sourceImportConfig*.json'
%     pointing at the new position files (if any).
%  
%  The position data and general information of each valid source in 
%  SOUIMPCONFIG is stored in the Navigation Database (.mat) under the
%  substructures SOUIMPDATA and SOUIMPCONFIG. If the source belongs to
%  SOURCECATEGORY = 'fleet', the position data and general information
%  is stored in VESIMPDATA and VESIMPCONFIG. 
%
%  The Navigation Database is later used for calculating navigation 
%  parameters (speed, course, relative angles and distances) for the 
%  receiver, source, and vessels associated with each detected sound event.
%
%  INPUT ARGUMENTS
%  - root: structure containing the root directories where the audio data
%    (ROOT.AUDIO), position data (ROOT.POSITION) and block data (ROOT.BLOCK)
%    are stored. ROOT.BLOCK contains the directories where the Configuration 
%    Files ('configdb'), Resampled Audio ('audiodb'), Detection Database
%    ('detectiondb), Navigation Database ('navigationdb'), and Acoustic 
%    Databases ('acousticdb') are stored.
%  - SouImpConfig: multi-element source import configuration structure.
%
%  OUTPUT ARGUMENTS
%  - None
%
%  FUNCTION CALL
%  SOURCEIMPORTFUN(root,SouImpConfig)
%
%  FUNCTION DEPENDENCIES
%  - initialiseNavigationDatabase
%  - isNavigationDatabase
%  - discardRepeatedSources
%  - getFilePaths
%  - readgps
%  - readais
%  - readp190
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%  - Read GPS
%  - Read AIS
%  - Read P190
%    
%  See also READSOURCEIMPORTCONFIG, ISNAVIGATIONDATABASE, 
%  DISCARDREPEATEDSOURCES

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  09 Jul 2021

function sourceImportFun(root,SouImpConfig)

% Display Progress on Command Window
fprintf('\nIMPORTING SOURCE POSITION\n')

% Read Navigation Database
navigationdbPath = fullfile(root.block,'navigationdb','navigationdb.mat'); 
isNavigationdb = isNavigationDatabase(navigationdbPath);
if isNavigationdb == true % if 'navigationdb.mat' exists and is a Navig DB
    NavigationDatabase = load(navigationdbPath);
    iSource = numel([NavigationDatabase.SouImpConfig.inputStatus]) + 1;  
else
    NavigationDatabase = initialiseNavigationDatabase();
    iSource = 1; % source index 
end

% Remove Repeated and Non-Valid Source from Configuration Structure
SouImpConfig = discardRepeatedSources(SouImpConfig,navigationdbPath);
SouImpConfig = SouImpConfig(logical([SouImpConfig.inputStatus]));

% Read Position of Sources and Assign to Navigation Structure
SouImpConfig_temp = NavigationDatabase.SouImpConfig;
SouImpData_temp = NavigationDatabase.SouImpData;
VesImpConfig_temp = NavigationDatabase.VesImpConfig;
VesImpData_temp = NavigationDatabase.VesImpData;
nSources = numel(SouImpConfig); % number of valid non-repeated sources
for m = 1:nSources
    
    % Display Name of Current Script
    configFileName = SouImpConfig(m).configFileName;
    fprintf('Configuration File ''%s'' [%s]\n',configFileName,...
        datestr(datenum(clock),'dd-mmm-yyyy HH:MM:SS'))

    % Read Position Data
    fprintf('# Reading position data of source ''%s'' (%d/%d) ',...
        SouImpConfig(m).sourceName,m,nSources)
    if strcmp(SouImpConfig(m).sourceCategory,'fixed') % manual position
        % Assign Source Configuration to Navigation Database
        SouImpConfig_temp(iSource,1) = SouImpConfig(m);
    
        % Assign Data to Navigation Structure
        SouImpData_temp(iSource,1).positionPaths = {};
        SouImpData_temp(iSource,1).pcTick = [];
        SouImpData_temp(iSource,1).utcTick = [];
        SouImpData_temp(iSource,1).latitude = SouImpConfig(m).lat;
        SouImpData_temp(iSource,1).longitude = SouImpConfig(m).longitude;
        SouImpData_temp(iSource,1).depth = SouImpConfig(m).depth;
        
        % Update Source Index
        iSource = iSource + 1;  
        
    else % position from files 
        switch SouImpConfig(m).positionFormat
            case 'gps'
                % Identify Extension of Position Files
                switch SouImpConfig(m).positionPlatform
                    case 'seichessv'
                        positionExtension = '.gpstext';
                    case 'pamguard'
                        positionExtension = '.csv';
                end
                
                % Extract Paths of GPS Files
                positionPaths = fullfile(root.position,...
                    SouImpConfig(m).positionPaths); % abs paths and folders
                positionPaths = getFilePaths(positionPaths,positionExtension); % abs paths
                
                % Read GPS Data
                GpsData = readgps(positionPaths);
                
                % Assign Source Configuration to Navigation Database
                SouImpConfig_temp(iSource,1) = SouImpConfig(m);
          
                % Assign GPS Data to Navigation Structure
                SouImpData_temp(iSource,1).positionPaths = positionPaths;
                SouImpData_temp(iSource,1).pcTick = GpsData.pctick;
                SouImpData_temp(iSource,1).utcTick = GpsData.utctick;
                SouImpData_temp(iSource,1).latitude = GpsData.lat;
                SouImpData_temp(iSource,1).longitude = GpsData.lon;
                SouImpData_temp(iSource,1).depth = SouImpConfig(m).depth;
                
                % Update Source Index
                iSource = iSource + 1; 
                
             case 'ais'
                % Identify Extension of Position Files
                positionExtension = '.csv'; % only PAMGuard (.csv) supported
                
                % Extract Paths of AIS Files
                positionPaths = fullfile(root.position,...
                    SouImpConfig(m).positionPaths); % abs paths and folders
                positionPaths = getFilePaths(positionPaths,positionExtension); % abs paths
                
                switch SouImpConfig(m).sourceCategory
                    case {'towed','vessel'}
                        % Read AIS Data
                        AisData = readais(positionPaths,SouImpConfig(m).mmsi);
                        
                        % Assign Source Configuration to Navigation Database
                        SouImpConfig_temp(iSource,1) = SouImpConfig(m);

                        % Assign AIS Data to Navigation Structure
                        SouImpData_temp(iSource,1).positionPaths = positionPaths;
                        SouImpData_temp(iSource,1).pcTick = AisData.pctick;
                        SouImpData_temp(iSource,1).utcTick = AisData.utctick;
                        SouImpData_temp(iSource,1).latitude = AisData.lat;
                        SouImpData_temp(iSource,1).longitude = AisData.lon;
                        SouImpData_temp(iSource,1).depth = SouImpConfig(m).depth;

                        % Update Source Index
                        iSource = iSource + 1;
                       
                    % 'fleet' is only accessed if VesImpConfig is empty 
                    % (see DISCARDSOURCEIMPORTCONFIG)
                    case 'fleet' 
                        % Read AIS and Vessel Data
                        AisData = readais(positionPaths,[]);
                        vesseldbPath = fullfile(root.block,'configdb',...
                            'vesseldb.csv');
                        VesselDatabase = readVesselDatabase(vesseldbPath);
                        
                        % Combine AIS and Vessel Data
                        if ~isempty(VesselDatabase) % if Vessel Database exists
                            % Remove Values with Non-Unique MMSI
                            [mmsiList,iUnique] = ...
                                unique(VesselDatabase.mmsi,'stable');
                            VesselDatabase.vesselName = ...
                                VesselDatabase.vesselName(iUnique);
                            VesselDatabase.vesselLength = ...
                                VesselDatabase.vesselLength(iUnique);
                            VesselDatabase.vesselBeam = ...
                                VesselDatabase.vesselBeam(iUnique);
                            VesselDatabase.vesselDraft = ...
                                VesselDatabase.vesselDraft(iUnique);
                            VesselDatabase.vesselGrossTonnage = ...
                                VesselDatabase.vesselGrossTonnage(iUnique);
                              
                            % Assign AIS and Vessel Info for Each Vessel
                            nVessels = length(mmsiList);
                            for iVessel = 1:nVessels
                                % Assign Vessel Info
                                VesImpConfig_temp(iVessel,1) = SouImpConfig(m);
                                VesImpConfig_temp(iVessel,1).mmsi = ...
                                    mmsiList(iVessel);
                                VesImpConfig_temp(iVessel,1).vesselName = ...
                                    VesselDatabase.vesselName{iVessel};
                                VesImpConfig_temp(iVessel,1).vesselLength = ...
                                    VesselDatabase.vesselLength(iVessel);
                                VesImpConfig_temp(iVessel,1).vesselBeam = ...
                                    VesselDatabase.vesselBeam(iVessel);
                                VesImpConfig_temp(iVessel,1).vesselDraft = ...
                                    VesselDatabase.vesselDraft(iVessel);
                                VesImpConfig_temp(iVessel,1).vesselGrossTonnage = ...
                                    VesselDatabase.vesselGrossTonnage(iVessel);
                                
                                % Assign AIS
                                iValues = mmsiList(iVessel) == AisData.mmsi;
                                VesImpData_temp(iVessel,1).positionPaths = ...
                                    positionPaths;
                                VesImpData_temp(iVessel,1).pcTick = ...
                                    AisData.pctick(iValues);
                                VesImpData_temp(iVessel,1).utcTick = ...
                                    AisData.utctick(iValues);
                                VesImpData_temp(iVessel,1).latitude = ...
                                    AisData.lat(iValues);
                                VesImpData_temp(iVessel,1).longitude = ...
                                    AisData.lon(iValues);
                                VesImpData_temp(iVessel,1).depth = ...
                                    SouImpConfig(m).depth;
                            end
                            
                        else % if Vessel Database does not exist
                            mmsiList = AisData.mmsi;
                            nVessels = length(mmsiList);
                            for iVessel = 1:nVessels
                                % Assign Vessel Info
                                VesImpConfig_temp(iVessel,1) = SouImpConfig(m);
                                VesImpConfig_temp(iVessel,1).mmsi = ...
                                    mmsiList(iVessel);
                                VesImpConfig_temp(iVessel,1).vesselName = ...
                                    AisData(iVessel).shipName;
                                
                                % Assign AIS
                                iValues = mmsiList(iVessel) == AisData.mmsi;
                                VesImpData_temp(iVessel,1).positionPaths = ...
                                    positionPaths;
                                VesImpData_temp(iVessel,1).pcTick = ...
                                    AisData.pctick(iValues);
                                VesImpData_temp(iVessel,1).utcTick = ...
                                    AisData.utctick(iValues);
                                VesImpData_temp(iVessel,1).latitude = ...
                                    AisData.lat(iValues);
                                VesImpData_temp(iVessel,1).longitude = ...
                                    AisData.lon(iValues);
                                VesImpData_temp(iVessel,1).depth = ...
                                    SouImpConfig(m).depth;
                            end
                        end
                        
                        % Update Source Index
                        iSource = iSource + 1;
                end
                
            case 'p190' 
                % Identify Extension of Position Files
                positionExtension = '.p190'; % only PAMGuard (.csv) supported
                
                % Extract Paths of P190 Files
                positionPaths = fullfile(root.position,...
                    SouImpConfig(m).positionPaths); % abs paths and folders
                positionPaths = getFilePaths(positionPaths,positionExtension); % abs paths
                
                % Read P190 Data
                P190Data = readp190(positionPaths);
                
                % Indices of P190 Data from Specified Vessel ID
                ind = P190Data.vesid == SouImpConfig(m).vesselId ...
                    & P190Data.souid == SouImpConfig(m).sourceId;
                
                % Assign Source Configuration to Navigation Database
                SouImpConfig_temp(iSource,1) = SouImpConfig(m);
                
                % Assign P190 Data to Navigation Structure
                SouImpData_temp(iSource,1).positionPaths = positionPaths;
                SouImpData_temp(iSource,1).pcTick = [];
                SouImpData_temp(iSource,1).utcTick = P190Data.utctick(ind);
                SouImpData_temp(iSource,1).latitude = P190Data.lat(ind);
                SouImpData_temp(iSource,1).longitude = P190Data.lon(ind);
                SouImpData_temp(iSource,1).depth = SouImpConfig(m).depth;
                
                % Update Source Index
                iSource = iSource + 1;
        end    
    end
    fprintf('[%s]\n',datestr(datenum(clock),'dd-mmm-yyyy HH:MM:SS'))
end

% Add 'sourceList' Field to Navigation Database
NavigationDatabase.sourceList = {SouImpConfig_temp.sourceName}';
if isempty(NavigationDatabase.sourceList{1})
    NavigationDatabase.sourceList = []; % for consistency ([] rather than {[]})
end
NavigationDatabase.vesselList = {VesImpConfig_temp.vesselName}'; 
if isempty(NavigationDatabase.vesselList{1})
    NavigationDatabase.vesselList = []; % for consistency ([] rather than {[]})
end

% Populate Navigation Database SOUIMPCONFIG,SOUIMPDATA,VESIMPCONFIG,VESIMPDATA
NavigationDatabase.SouImpConfig = SouImpConfig_temp;
NavigationDatabase.SouImpData = SouImpData_temp;
NavigationDatabase.VesImpConfig = VesImpConfig_temp;
NavigationDatabase.VesImpData = VesImpData_temp;
clear SouImpData_temp VesImpData_temp

% Save to Navigation Data Structure (if any source is valid, new or unique)
if nSources > 0
    % Create Navigation Database Folder in Root Directory (if doesn't exist)
    if exist(strcat(root.block,'\navigationdb'),'dir') ~= 7
        mkdir(root.block,'navigationdb');
    end
    
    % Save Navigation Database
    fprintf('# Saving position data of sources ')
    save(navigationdbPath,'-struct','NavigationDatabase')
    fprintf('[%s]\n',datestr(datenum(clock),'dd-mmm-yyyy HH:MM:SS'))
else
    warning(['No valid, new or unique sources were found in the '...
        '''<ROOT.BLOCK>/configdb'' folder. No changes will be made to the '...
        'Navigation Database'])
end
