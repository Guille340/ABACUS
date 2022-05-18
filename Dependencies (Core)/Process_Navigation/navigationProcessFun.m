%  NAVIGATIONPROCESSFUN(root,NavProConfig)
%
%  DESCRIPTION
%  Processes the navigation parameters of receivers, sources and vessels at the
%  time of the audio events detected in the Audio Databases in '<ROOT.BLOCK>\
%  audiodb'. The selected Audio Databases are those linked to the audio paths 
%  and parent directories listed in '<ROOT.BLOCK>\configdb\audioPath.json'. The 
%  location of the audio events is determined from the ACODATA.AUDDETDATA 
%  substructure in the corresponding Acoustic Database, stored in '<ROOT.BLOCK>\
%  acousticdb'. The processing is done as specified in the multi-element 
%  navigation process configuration structure NAVPROCONFIG. 
%
%  NAVPROCONFIG is generated with READNAVIGATIONPROCESSCONFIG. Each element in 
%  NAVPROCONFIG contains the information from an individual navigation process 
%  config script 'navigationProcessConfig*.json' stored in '<ROOT.BLOCK>\
%  configdb'.
%
%  Both AUDIODETECTFUN and AUDIOPROCESSFUN must be run on the target audio 
%  files before NAVIGATIONPROCESSFUN can be called, since the latter relies
%  on the absolute UTC tick vector calculated with AUDIOPROCESSFUN, which in
%  turn relies on the relative detection times calculated with AUDIODETECTFUN.
%
%  Before running the navigation processing algorithm, NAVIGATIONPROCESSFUN 
%  removes from NAVPROCONFIG any element that meets either of the next two 
%  conditions:
%  1. INPUTSTATUS = FALSE (see VERIFYNAVIGATIONPROCESSCONFIG). A FALSE value
%     indicates that individual fields in the corresponding one-element 
%     structure NAVPROCONFIG(m) are incorrect, the selected Acoustic Databases 
%     do not exist to initiate the processing, or the RECEIVERNAME/SOURCENAME
%     combination is not found in the Navigation Database.
%  2. RECEIVERNAME/SOURCENAME combination already exists in other element of 
%     NAVPROCONFIG.
%
%  NAVIGATIONPROCESSFUN first loads the Navigation Database (.mat). Then, for 
%  each Audio Database that needs to be processed, NAVIGATIONPROCESSFUN loads 
%  the corresponding Acoustic Database (.mat) and looks for the element with 
%  the RECEIVERNAME/SOURCENAME combination specified in NAVPROCONFIG. It then
%  extracts from ACODATA.AUDPRODATA the UTC ticks of the detections and 
%  processes the navigation parameters for the receiver, sources and vessels
%  using the raw position data in the Navigation Database. The process is 
%  repeated with each valid RECEIVERNAME/SOURCENAME combination in NAVPROCONFIG. 
%  The function stores the processed navigation parameters from all 
%  RECEIVERNAME/SOURCENAME combinations in ACODATA.NAVPRODATA.
%
%  When a RECEIVERNAME/SOURCENAME combination is not found, that indicates that
%  the function NAVIGATIONPROCESSFUN has not been run for that specific case 
%  and the processing of the navigation parameters cannot be carried out. 
%
%  If a navigation process config file shares the same RECEIVERNAME/SOURCENAME 
%  combination as any element in the Acoustic Database, the navigation data 
%  will be reprocessed and the old content for that element overwritten.
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
%  - NavProConfig: multi-element navigation process configuration structure.
%
%  OUTPUT ARGUMENTS
%  - None
%
%  FUNCTION CALL
%  NAVIGATIONPROCESSFUN(root,NavProConfig)
%
%  FUNCTION DEPENDENCIES
%  - discardRepeatedElements
%  - getAudioDatabaseNames
%  - findAcousticDatabaseElement
%  - getNavigationParameters
%  - sourceToReceiverParameters
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%  - Geo Formulas (Distance & Bearing)
%
%  See also READNAVIGATIONPROCESSCONFIG

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  12 Aug 2021

function navigationProcessFun(root,NavProConfig)

% Remove Scripts with 'inputStatus' = 0
NavProConfig = NavProConfig(logical([NavProConfig.inputStatus]));

% Discard Scripts with Identical RECEIVERNAME/SOURCENAME combination
NavProConfig = discardRepeatedElements(NavProConfig);

% Load Navigation Database
nScripts = numel(NavProConfig);
if nScripts > 0
    navigationdbPath = fullfile(root.block,'navigationdb','navigationdb.mat');
    NavigationDatabase = load(navigationdbPath);
    receiverList = NavigationDatabase.receiverList;
    sourceList = NavigationDatabase.sourceList;
end

% Display Progress on Command Window
fprintf('\nPROCESSING NAVIGATION PARAMETERS\n')

for m = 1:nScripts 
    
    % Display Name of Current Script
    configFileName = NavProConfig(m).configFileName;
    fprintf('Configuration File ''%s'' [%s]\n',configFileName,...
        datestr(datenum(clock),'dd-mmm-yyyy HH:MM:SS'))
    
    % Navigation Process Config for Current Structure (NAVPROCONFIGONE)
    NavProConfigOne = NavProConfig(m);
    
    % Load Common Variables
    channel = NavProConfigOne.channel;
    resampleRate = NavProConfigOne.resampleRate;
    receiverName = NavProConfigOne.receiverName;
    sourceName = NavProConfigOne.sourceName;
    smoothWindow = NavProConfigOne.smoothWindow;
    maxTimeGap = NavProConfigOne.maxTimeGap;
    interpMethod = NavProConfigOne.interpMethod;
     
    % Retrieve RECIMPCONFIG & RECIMPDATA for RECEIVERNAME from Navigation DB
    isRecInNavigationdb = ismember(receiverList,receiverName); % target receiver = TRUE
    RecImpConfigOne = NavigationDatabase.RecImpConfig(isRecInNavigationdb);
    RecImpDataOne = NavigationDatabase.RecImpData(isRecInNavigationdb);
    
    % Retrieve SOUIMPCONFIG & SOUIMPDATA for SOURCENAME from Navigation DB
    isSouInNavigationdb = ismember(sourceList,sourceName); % target source (primary) = TRUE
    nSecondary = sum(~isSouInNavigationdb); % no. secondary sources
    SouImpConfigOne = NavigationDatabase.SouImpConfig;
    SouImpConfigOne(1) = SouImpConfigOne(isSouInNavigationdb);
    SouImpConfigOne(2:nSecondary+1) = SouImpConfigOne(~isSouInNavigationdb);
    SouImpDataOne = NavigationDatabase.SouImpData;
    SouImpDataOne(1) = SouImpDataOne(isSouInNavigationdb);
    SouImpDataOne(2:nSecondary+1) = SouImpDataOne(~isSouInNavigationdb);
    
    % Retrieve VESIMPCONFIG & VESIMPDATA from Navigation DB
    VesImpConfigOne = NavigationDatabase.VesImpConfig;
    VesImpDataOne = NavigationDatabase.VesImpData;
    
    % Retrieve Names of Target Audio Databases
    audiodbNames = getAudioDatabaseNames(root,channel,resampleRate);
    
    % Run Navigation Processing on Files
    nFiles = numel(audiodbNames);
    for n = 1:nFiles  
        
        % Display File Name
        acousticdbName = strrep(audiodbNames{n},sprintf('_ch%d_fr%d',...
            channel,resampleRate),'');
        fprintf('Acoustic Database File ''%s''\n',acousticdbName)
        
        % Load Acoustic Database and Find RECEIVERNAME/SOURCENAME Element
        acousticdbPath = fullfile(root.block,'acousticdb',acousticdbName);
        index = [];
        if exist(acousticdbPath,'file') == 2
            % Load Acoustic Database
            AcousticDatabase = load(acousticdbPath);
            
            % Find RECEIVERNAME/SOURCENAME Index
            index = findAcousticDatabaseElement(acousticdbPath,...
                receiverName,sourceName);
        end
        
        % Retrieve Number of Detections
        nDetections = 0; % initialise number of detections
        if ~isempty(index)     
            signalTime = AcousticDatabase.AcoData(index).AudDetData.signalTime;
            nDetections = length(signalTime);
        end
            
        % Process Navigation Data if RECEIVERNAME/SOURCENAME is found
        if ~isempty(index) && nDetections > 0
            % Initialise Receiver Process Data Structure
            RecProDataOne = initialiseReceiverProcessData();

            % Load Navigation Parameters (Receiver)
            fprintf('# Processing receiver ')
            offset_rec = RecImpConfigOne.receiverOffset;
            offsetMode_rec = RecImpConfigOne.receiverOffsetMode;
            signalUtcTick = AcousticDatabase.AcoData(index).AudProData.signalUtcTick;
            
            % Process Navigation Parameters (Receiver)           
            NavPar_rec = getNavigationParameters(...
                signalUtcTick,RecImpDataOne,'Offset',offset_rec,...
                'OffsetMode',offsetMode_rec,'SmoothWindow',smoothWindow,...
                'MaxTimeGap',maxTimeGap,'InterpMethod',interpMethod);
            
            % Populate Acoustic Database (Receiver)
            RecProDataOne(1).pcTick = NavPar_rec.pcTick;
            RecProDataOne(1).utcTick = NavPar_rec.utcTick;
            RecProDataOne(1).latitude = NavPar_rec.latitude;
            RecProDataOne(1).longitude = NavPar_rec.longitude;
            RecProDataOne(1).depth = RecImpDataOne.depth;
            RecProDataOne(1).course = NavPar_rec.course;
            RecProDataOne(1).speed = NavPar_rec.speed;
            fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
            
            % Loop through Sources
            fprintf('# Processing sources ')
            nSources = numel(SouImpDataOne);
            if isequal(SouImpDataOne,initialiseSourceImportData)
                nSources = 0;
            end
            SouProDataOne = initialiseSourceProcessData();
            for p = 1:nSources                
                % Load Navigation Database Parameters (Source)
                offset_sou = SouImpConfigOne(p).sourceOffset;
                offsetMode_sou = SouImpConfigOne(p).sourceOffsetMode;
                
                % Process Navigation Parameters (Source)
                NavPar_sou = getNavigationParameters(...
                    signalUtcTick,SouImpDataOne(p),'Offset',offset_sou,...
                    'OffsetMode',offsetMode_sou,'SmoothWindow',smoothWindow,...
                    'MaxTimeGap',maxTimeGap,'InterpMethod',interpMethod);
            
                % Process Navigation Parameters (Source To Receiver)
                SouRecPar = sourceToReceiverParameters(NavPar_sou,NavPar_rec);
                
                % Populate Acoustic Database
                SouProDataOne(p).pcTick = NavPar_sou.pcTick;
                SouProDataOne(p).utcTick = NavPar_sou.utcTick;
                SouProDataOne(p).latitude = NavPar_sou.latitude;
                SouProDataOne(p).longitude = NavPar_sou.longitude;
                SouProDataOne(p).depth = SouImpDataOne(p).depth;
                SouProDataOne(p).course = NavPar_sou.course;
                SouProDataOne(p).speed = NavPar_sou.speed;
                SouProDataOne(p).sou2recDistance = SouRecPar.sou2recDistance;
                SouProDataOne(p).sou2recBearing = SouRecPar.sou2recBearing;
                SouProDataOne(p).sourceHeading = SouRecPar.sourceHeading;
                SouProDataOne(p).sourceEmitAngle = SouRecPar.sourceEmitAngle;
            end      
            fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
            
            % Loop through Vessels
            fprintf('# Processing vessels ')
            nVessels = numel(VesImpDataOne);
            if isequal(VesImpDataOne,initialiseVesselImportData)
                nVessels = 0;
            end
            VesProDataOne = initialiseVesselProcessData();
            for p = 1:nVessels                
                % Load Navigation Database Parameters (Vessel)
                offset_ves = [0 0];
                offsetMode_ves = 'hard';
                
                % Process Navigation Parameters (Source)
                NavPar_ves = getNavigationParameters(...
                    signalUtcTick,VesImpDataOne(p),'Offset',offset_ves,...
                    'OffsetMode',offsetMode_ves,'SmoothWindow',smoothWindow,...
                    'MaxTimeGap',maxTimeGap,'InterpMethod','linear');
            
                % Process Navigation Parameters (Source To Receiver)
                VesRecPar = sourceToReceiverParameters(NavPar_ves,NavPar_rec);
                
                % Populate Acoustic Database
                VesProDataOne(p).pcTick = NavPar_ves.pcTick;
                VesProDataOne(p).utcTick = NavPar_ves.utcTick;
                VesProDataOne(p).latitude = NavPar_ves.latitude;
                VesProDataOne(p).longitude = NavPar_ves.longitude;
                VesProDataOne(p).depth = VesImpDataOne(p).depth;
                VesProDataOne(p).course = NavPar_ves.course;
                VesProDataOne(p).speed = NavPar_ves.speed;
                VesProDataOne(p).sou2recDistance = VesRecPar.sou2recDistance;
                VesProDataOne(p).sou2recBearing = VesRecPar.sou2recBearing;
                VesProDataOne(p).sourceHeading = VesRecPar.sourceHeading;
                VesProDataOne(p).sourceEmitAngle = VesRecPar.sourceEmitAngle;
            end 
            fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
            
            % Populate Acoustic Database with AUDDETCONFIG and AUDDETDATA
            AcousticDatabase.AcoConfig(index).RecImpConfig = RecImpConfigOne; 
            AcousticDatabase.AcoConfig(index).SouImpConfig = SouImpConfigOne; 
            AcousticDatabase.AcoConfig(index).VesImpConfig = VesImpConfigOne; 
            AcousticDatabase.AcoConfig(index).NavProConfig = NavProConfigOne; 
            AcousticDatabase.AcoData(index).RecProData = RecProDataOne;
            AcousticDatabase.AcoData(index).SouProData = SouProDataOne;
            AcousticDatabase.AcoData(index).VesProData = VesProDataOne;

            % Save Acoustic Database
            save(acousticdbPath,'-struct','AcousticDatabase')
        else
            if isempty(index)
                warning(['The navigation data in Acoustic Database ''%s'' '...
                    'has not been processed for the RECEIVERNAME\SOURCENAME '...
                    'combination ''%s''\''%s''. Run AUDIODETECTFUN and '...
                    'AUDIOPROCESSFUN on this file before attempting to '...
                    'process the navigation data with NAVIGATIONPROCESSFUN. '...
                    'The navigation data processing will not be carried '...
                    out'],acousticdbName,receiverName,sourceName)
            end
            if ~nDetections
                fprintf('# [!] No detections [%s]\n',...
                    datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
            end
        end
    end
end
