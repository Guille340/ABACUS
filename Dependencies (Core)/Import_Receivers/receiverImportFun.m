%  RECEIVERIMPORTFUN(root,RecImpConfig)
%
%  DESCRIPTION
%  Reads the position data for each receiver, as specified in the multi-
%  element receiver configuration structure RECIMPCONFIG, and saves it in 
%  the Navigation Database (.mat) 'navigationdb*.json' stored in directory
%  '<ROOT.BLOCK>\navigationdb'. If the Navigation Database does not exist, it 
%  creates one. 
%
%  RECIMPCONFIG is generated with READRECEIVERIMPORTCONFIG. Each element in 
%  RECIMPCONFIG contains the information from an individual receiver import 
%  configuration script 'receiverImportConfig*.json' stored in '<ROOT.BLOCK>\
%  configdb'. The information comprises the folder(s) where the position 
%  files are stored and receiver information including category, dimensions 
%  and relative position.
%
%  Before acquiring the position data, RECEIVERIMPORTFUN removes from
%  RECIMPCONFIG any element that meets either of the next two conditions:
%  1. INPUTSTATUS = FALSE (see VERIFYAUDIOINPUTCONFIG). A FALSE value
%     indicates that individual field values in the corresponding one-
%     element structure of RECEIVERIMPORTFUN are incorrect.
%  2. RECEIVERNAME already exists in other element of input RECIMPCONFIG
%     or in the Navigation Database. If new data needs to be added for
%     that exact receiver, delete the receiver with DELETERECEIVERS and
%     run RECEIVERIMPORTFUN with the updated 'receiverImportConfig*.json'
%     pointing at the new position files (if any).
%
%  The position data and general information of each valid receiver in 
%  RECIMPCONFIG is stored in the Navigation Database (.mat) under
%  substructures RECIMPDATA and RECIMPCONFIG. 
%
%  The Navigation Database is later used for calculating navigation 
%  parameters (speed, course, relative angles and distances) for the 
%  receiver, source, and vessels associated with each detected sound event.
%
%  For details about the fields in an Navigation Database refer to the help
%  from function INITIALISENAVIGATIONDATABASE.
%
%  INPUT ARGUMENTS
%  - root: structure containing the root directories where the audio data
%    (ROOT.AUDIO), position data (ROOT.POSITION) and block data (ROOT.BLOCK)
%    are stored. ROOT.BLOCK contains the directories where the Configuration 
%    Files ('configdb'), Resampled Audio ('audiodb'), Detection Database
%    ('detectiondb), Navigation Database ('navigationdb'), and Acoustic 
%    Databases ('acousticdb') are stored.
%  - RecImpConfig: multi-element receiver import configuration structure.
%
%  OUTPUT ARGUMENTS
%  - None
%
%  FUNCTION CALL
%  RECEIVERIMPORTFUN(root,RecImpConfig)
%
%  FUNCTION DEPENDENCIES
%  - initialiseNavigationDatabase
%  - isNavigationDatabase
%  - discardRepeatedReceivers
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
%  See also READRECEIVERIMPORTCONFIG, ISNAVIGATIONDATABASE,
%  DISCARDREPEATEDRECEIVERS

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  09 Jul 2021

function receiverImportFun(root,RecImpConfig)

% Display Progress on Command Window
fprintf('\nIMPORTING RECEIVER POSITION\n')

% Read Navigation Database
navigationdbPath = fullfile(root.block,'navigationdb','navigationdb.mat');
isNavigationdb = isNavigationDatabase(navigationdbPath);
if isNavigationdb == true % if 'navigationdb.mat' exists and is a Navig DB
    NavigationDatabase = load(navigationdbPath);
    iReceiver = numel([NavigationDatabase.RecImpConfig.inputStatus]) + 1;  
else
    NavigationDatabase = initialiseNavigationDatabase();
    iReceiver = 1; % receiver index 
end

% Remove Repeated and Non-Valid Receivers from Configuration Structure
RecImpConfig = discardRepeatedReceivers(RecImpConfig,navigationdbPath);
RecImpConfig = RecImpConfig(logical([RecImpConfig.inputStatus]));

% Read Position of Receivers and Assign to Navigation Structure
RecImpConfig_temp = NavigationDatabase.RecImpConfig;
RecImpData_temp = NavigationDatabase.RecImpData;
nReceivers = numel(RecImpConfig); % number of valid non-repeated receivers
for m = 1:nReceivers
    % Display Name of Current Script
    configFileName = RecImpConfig(m).configFileName;
    fprintf('Configuration File ''%s'' [%s]\n',configFileName,...
        datestr(datenum(clock),'dd-mmm-yyyy HH:MM:SS'))
    
    % Assign Receiver Configuration to Navigation Database
    RecImpConfig_temp(iReceiver,1) = RecImpConfig(m);

    % Read Position Data
    fprintf('# Reading position data of receiver ''%s'' (%d/%d) ',...
        RecImpConfig(m).receiverName,m,nReceivers)
    if strcmp(RecImpConfig(m).receiverCategory,'fixed') % manual position
        % Assign Data to Navigation Structure
        RecImpData_temp(iReceiver,1).positionPaths = {};
        RecImpData_temp(iReceiver,1).pcTick = [];
        RecImpData_temp(iReceiver,1).utcTick = [];
        RecImpData_temp(iReceiver,1).latitude = RecImpConfig(m).latitude;
        RecImpData_temp(iReceiver,1).longitude = RecImpConfig(m).longitude;
        RecImpData_temp(iReceiver,1).depth = RecImpConfig(m).depth;
        
        % Update Receiver Index
        iReceiver = iReceiver + 1;
        
    else % position from files 
        switch RecImpConfig(m).positionFormat
            case 'gps'
                % Identify Extension of Position Files
                switch RecImpConfig(m).positionPlatform
                    case 'seichessv'
                        positionExtension = '.gpstext';
                    case 'pamguard'
                        positionExtension = '.csv';
                end
                
                % Extract Paths of GPS Files
                positionPaths = fullfile(root.position,...
                    RecImpConfig(m).positionPaths); % abs paths and folders
                positionPaths = getFilePaths(positionPaths,positionExtension); % abs paths
                
                % Read GPS Data
                GpsData = readgps(positionPaths);
          
                % Assign GPS Data to Navigation Structure
                RecImpData_temp(iReceiver,1).positionPaths = positionPaths;
                RecImpData_temp(iReceiver,1).pcTick = GpsData.pctick;
                RecImpData_temp(iReceiver,1).utcTick = GpsData.utctick;
                RecImpData_temp(iReceiver,1).latitude = GpsData.lat;
                RecImpData_temp(iReceiver,1).longitude = GpsData.lon;
                RecImpData_temp(iReceiver,1).depth = RecImpConfig(m).depth;
                
                % Update Receiver Index
                iReceiver = iReceiver + 1;
                
             case 'ais'
                % Identify Extension of Position Files
                positionExtension = '.csv'; % only PAMGuard (.csv) supported
                
                % Extract Paths of AIS Files
                positionPaths = fullfile(root.position,...
                    RecImpConfig(m).positionPaths); % abs paths and folders
                positionPaths = getFilePaths(positionPaths,positionExtension); % abs paths
                
                % Read AIS Data
                aisdata = readais(positionPaths,RecImpConfig(m).mmsi);
                
                % Assign AIS Data to Navigation Structure
                RecImpData_temp(iReceiver,1).positionPaths = positionPaths;
                RecImpData_temp(iReceiver,1).pcTick = aisdata.pctick;
                RecImpData_temp(iReceiver,1).utcTick = aisdata.utctick;
                RecImpData_temp(iReceiver,1).latitude = aisdata.lat;
                RecImpData_temp(iReceiver,1).longitude = aisdata.lon;
                RecImpData_temp(iReceiver,1).depth = RecImpConfig(m).depth;
                
                % Update Receiver Index
                iReceiver = iReceiver + 1;
                
            case 'p190' 
                % Identify Extension of Position Files
                positionExtension = '.p190'; % only PAMGuard (.csv) supported
                
                % Extract Paths of P190 Files
                positionPaths = fullfile(root.position,...
                    RecImpConfig(m).positionPaths); % abs paths and folders
                positionPaths = getFilePaths(positionPaths,positionExtension); % abs paths
                
                % Read P190 Data
                p190data = readp190(positionPaths);
                
                % Indices of P190 Data from Specified Vessel ID
                ind = p190data.vesid == RecImpConfig(m).vesselId;
                
                % Assign P190 Data to Navigation Structure
                RecImpData_temp(iReceiver,1).positionPaths = positionPaths;
                RecImpData_temp(iReceiver,1).pcTick = [];
                RecImpData_temp(iReceiver,1).utcTick = p190data.utctick(ind);
                RecImpData_temp(iReceiver,1).latitude = p190data.lat(ind);
                RecImpData_temp(iReceiver,1).longitude = p190data.lon(ind);
                RecImpData_temp(iReceiver,1).depth = RecImpConfig(m).depth;
                
                % Update Receiver Index
                iReceiver = iReceiver + 1;
        end        
    end
    fprintf('[%s]\n',datestr(datenum(clock),'dd-mmm-yyyy HH:MM:SS'))
end

% Add 'receiverList' Field to Navigation Database
NavigationDatabase.receiverList = {RecImpConfig_temp.receiverName}'; 
if isempty(NavigationDatabase.receiverList{1})
    NavigationDatabase.receiverList = []; % for consistency ([] rather than {[]})
end

% Populate Navigation Database with RECIMPCONFIG and RECIMPDATA
NavigationDatabase.RecImpConfig = RecImpConfig_temp;
NavigationDatabase.RecImpData = RecImpData_temp;
clear RecImpData_temp

% Save to Navigation Data Structure (if any receiver is valid, new or unique)
if nReceivers > 0
    % Create Navigation Database Folder in Root Directory (if doesn't exist)
    if exist(strcat(root.block,'\navigationdb'),'dir') ~= 7
        mkdir(root.block,'navigationdb');
    end
    
    % Save Navigation Database
    fprintf('# Saving position data of receivers ')
    save(navigationdbPath,'-struct','NavigationDatabase')
    fprintf('[%s]\n',datestr(datenum(clock),'dd-mmm-yyyy HH:MM:SS'))
else
    warning(['No valid, new or unique receivers were found in the '...
        '''<ROOT.BLOCK>/configdb'' folder. No changes will be made to the '...
        'Navigation Database'])
end
