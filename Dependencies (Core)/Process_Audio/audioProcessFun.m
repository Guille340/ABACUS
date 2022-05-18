%  AUDIOPROCESSFUN(root,AudProConfig)
%
%  DESCRIPTION
%  Processes the acoustic metrics of the audio events detected in the Audio 
%  Databases in '<ROOT.BLOCK>\audiodb'. The selected Audio Databases are those
%  linked to the audio paths and parent directories listed in '<ROOT.BLOCK>\
%  configdb\audioPath.json'. The location of the audio events is determined 
%  from the ACODATA.AUDDETDATA substructure in the corresponding Acoustic 
%  Database, stored in '<ROOT.BLOCK>\acousticdb'. The processing is done as 
%  specified in the multi-element audio process configuration structure 
%  AUDPROCONFIG. 
%
%  AUDPROCONFIG is generated with READAUDIOPROCESSCONFIG. Each element in 
%  AUDPROCONFIG contains the information from an individual audio process 
%  config script 'audioProcessConfig*.json' stored in '<ROOT.BLOCK>\configdb'.
%
%  AUDIODETECTFUN must be run on the target audio files before AUDIOPROCESSFUN 
%  can be called, since AUDIOPROCESSFUN relies on the relative detection times 
%  calculated with the former to obtain the acoustic metrics.
%
%  Before running the processing algorithm, AUDIOPROCESSFUN removes from
%  AUDPROCONFIG any element that meets either of the next two conditions:
%  1. INPUTSTATUS = FALSE (see VERIFYAUDIOPROCESSCONFIG). A FALSE value
%     indicates that individual fields in the corresponding one-element 
%     structure AUDPROCONFIG(m) are incorrect or the selected Audio Databases 
%     do not exist to initiate the processing.
%  2. RECEIVERNAME/SOURCENAME combination already exists in other element of 
%     AUDPROCONFIG.
%
%  For each Audio Database that needs to be processed, AUDIOPROCESSFUN loads 
%  the corresponding Acoustic Database (.mat) and looks for the element with 
%  the RECEIVERNAME/SOURCENAME combination specified in AUDPROCONFIG. Then, it 
%  processes the acoustic metrics for each detection interval contained in 
%  ACODATA.AUDDETDATA. The process is repeated with each valid RECEIVERNAME/
%  SOURCENAME combination in AUDPROCONFIG. The function stores the processed 
%  acoustic metrics from all RECEIVERNAME/SOURCENAME combinations in 
%  ACODATA.AUDPRODATA.
%
%  When a RECEIVERNAME/SOURCENAME combination is not found, that indicates that
%  the function AUDIODETECTFUN has not been run for that specific case and the 
%  processing of the acoustic metrics cannot be carried out. 
%
%  If an audio process config file shares the same RECEIVERNAME/SOURCENAME 
%  combination as any element in the Acoustic Database, the acoustic metrics 
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
%  - AudProConfig: multi-element audio process configuration structure.
%
%  OUTPUT ARGUMENTS
%  - None
%
%  FUNCTION CALL
%  AUDIOPROCESSFUN(root,AudProConfig)
%
%  FUNCTION DEPENDENCIES
%  - discardRepeatedElements
%  - getAudioDatabaseNames
%  - digitalSingleFilterDesign
%  - fftBankFilterDesign
%  - findAcousticDatabaseElement
%  - getDcOffset
%  - digitalSingleFilter
%  - cumulativeEnergy
%  - fftBankFilter
%  - audioFileTick
%  - readTimeOffset
%  - getTimeOffset
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%  - Digital Filtering (Single)
%  - FFT Filtering (Bank)
%
%  See also READAUDIOPROCESSCONFIG

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  10 Aug 2021

function audioProcessFun(root,AudProConfig)

% Remove Scripts with 'inputStatus' = 0
AudProConfig = AudProConfig(logical([AudProConfig.inputStatus]));

% Discard Scripts with Identical RECEIVERNAME/SOURCENAME combination
AudProConfig = discardRepeatedElements(AudProConfig);

% Display Progress on Command Window
fprintf('\nPROCESSING AUDIO METRICS\n')

% Import Audio Files
nScripts = numel(AudProConfig);
for m = 1:nScripts
    
    % Audio Process Config for Current Structure (AUDPROCONFIGONE)
    AudProConfigOne = AudProConfig(m);
    
    % Load Common Variables
    channel = AudProConfigOne.channel;
    resampleRate = AudProConfigOne.resampleRate;
    receiverName = AudProConfigOne.receiverName;
    sourceName = AudProConfigOne.sourceName;
    freqLimits = AudProConfigOne.freqLimits;
    bandsPerOctave = AudProConfigOne.bandsPerOctave;
    cumEnergyRatio = AudProConfigOne.cumEnergyRatio;
    audioTimeFormat = AudProConfigOne.audioTimeFormat;
    timeOffset = AudProConfigOne.timeOffset;
    
    % Retrieve Names of Target Audio Databases
    audiodbNames = getAudioDatabaseNames(root,channel,resampleRate);  

    % Design Processing Filters
    DigitalFilter = digitalSingleFilterDesign(resampleRate,freqLimits,...
        'FilterOrder',10,'FilterType','bandpass');
    FftFilterBank = fftBankFilterDesign(resampleRate,bandsPerOctave,freqLimits);
    fc_nom = FftFilterBank.nominalFreq';
    fc = FftFilterBank.centralFreq';
    f1 = FftFilterBank.halfPowerFreq1';
    f2 = FftFilterBank.halfPowerFreq2';
    
    % Read Time Offsets (if TIMEOFFSET = [])
    tick = [];
    if isempty(timeOffset) % do not use TIMEOFFSET directly
        filePath = fullfile(root.block,'configdb','timeOffset.csv');
        [tick,timeOffset] = readTimeOffset(filePath);
    end
    
    % Run Processing on Files
    nFiles = numel(audiodbNames);
    for n = 1:nFiles            
        % Audio Database Path
        audiodbName = audiodbNames{n};
        audiodbPath = fullfile(root.block,'audiodb',audiodbName);
        
        % Display Audio Database File
        fprintf('Audio Database File ''%s''\n',audiodbName)
            
        % Load Acoustic Database and Find RECEIVERNAME/SOURCENAME Element
        acousticdbName = strrep(audiodbName,sprintf('_ch%d_fr%d',channel,...
            resampleRate),'');
        acousticdbPath = fullfile(root.block,'acousticdb',acousticdbName);
        index = [];
        if exist(acousticdbPath,'file') == 2
            % Load Acoustic Database
            AcousticDatabase = load(acousticdbPath);
            
            % Find RECEIVERNAME/SOURCENAME Index
            index = findAcousticDatabaseElement(acousticdbPath,...
                receiverName,sourceName);
        end
        
        % Process Detections if RECEIVERNAME/SOURCENAME is found
        nDetections = 0; % initialise number of detections
        if ~isempty(index)     
            % Load Relative Times
            signalTime = AcousticDatabase.AcoData(index).AudDetData.signalTime;
            signalTime1 = AcousticDatabase.AcoData(index).AudDetData.signalTime1;
            signalTime2 = AcousticDatabase.AcoData(index).AudDetData.signalTime2;
            noiseTime1 = AcousticDatabase.AcoData(index).AudDetData.noiseTime1;
            noiseTime2 = AcousticDatabase.AcoData(index).AudDetData.noiseTime2;
            nDetections = length(signalTime);
        end
        
        % Process Detections if any and if RECEIVERNAME/SOURCENAME is found
        if ~isempty(index) && nDetections > 0
            % Load Audio Data
            fprintf('# Loading audio file ')
            AudioDatabase = load(audiodbPath);
            audioData = AudioDatabase.AudImpData.audioData;
            fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
            
            % Calculate DC-Offset In Ten-Second Intervals
            audioLength = length(audioData);
            dcWindowLength = min(round(10*resampleRate),audioLength);
            [dcOffsets,iDcOffsets] = getDcOffset(audioData,dcWindowLength);

            % Initialise Variables
            nSamplesFile = length(audioData);
            nBands = length(fc);
            signalEnergyTime1 = nan(1,nDetections);
            signalEnergyTime2 = nan(1,nDetections);
            noiseEnergyTime1 = nan(1,nDetections);
            noiseEnergyTime2 = nan(1,nDetections);
            srms = nan(1,nDetections);
            sexp = nan(1,nDetections);
            sz2p = nan(1,nDetections);
            sp2p = nan(1,nDetections);
            nrms = nan(1,nDetections);
            nexp = nan(1,nDetections);
            nz2p = nan(1,nDetections);
            np2p = nan(1,nDetections);
            srmsb = nan(nBands,nDetections);
            sexpb = nan(nBands,nDetections);
            nrmsb = nan(nBands,nDetections);
            nexpb = nan(nBands,nDetections);
            
            % Initialise Progress Dialogue
            fprintf('# Processing detections ')
            hfig = waitbar(0,sprintf('Processing detections (%d/%d)',...
                1,nDetections),'Name',sprintf('%s',audiodbName));
            
            % Process Detections
            for p = 1:nDetections
                % Update Progress Dialogue
                waitbar(p/nDetections,hfig,...
                    sprintf('Processing detections (%d/%d)',p,nDetections))
                
                % Retrieve Detection Intervals (signal)
                signalSample1 = round(signalTime1(p)*resampleRate) + 1;
                signalSample1 = max(min(signalSample1,nSamplesFile),1);
                signalSample2 = round(signalTime2(p)*resampleRate) + 1;
                signalSample2 = max(min(signalSample2,nSamplesFile),1);
                
                % Retrieve Detection Intervals (noise)
                noiseSample1 = round(noiseTime1(p)*resampleRate) + 1;
                noiseSample1 = max(min(noiseSample1,nSamplesFile),1);
                noiseSample2 = round(noiseTime2(p)*resampleRate) + 1;
                noiseSample2 = max(min(noiseSample2,nSamplesFile),1);
                
                % Load Detection Waveform and Correct DC Offset (signal & noise)
                dcOffset_signal = dcOffsets;
                dcOffset_noise = dcOffsets;
                if length(dcOffsets) > 1
                    dcOffset_signal = interp1(iDcOffsets,dcOffsets,...
                        mean([signalSample1,signalSample2]),'nearest','extrap');
                    dcOffset_noise = interp1(iDcOffsets,dcOffsets,...
                        mean([noiseSample1,noiseSample2]),'nearest','extrap');
                end       

                % Gate Detection Waveform and Correct DC Offset (signal & noise)
                xs = audioData(signalSample1:signalSample2) - dcOffset_signal;  
                xn = audioData(noiseSample1:noiseSample2) - dcOffset_noise;
                
                % Filter Detection Waveform (signal & noise)
                xsf = digitalSingleFilter(DigitalFilter,xs,'MetricsOutput',...
                    false,'FilterMode','filtfilt','DataWrap',true);
                xnf = digitalSingleFilter(DigitalFilter,xn,'MetricsOutput',...
                    false,'FilterMode','filtfilt','DataWrap',true);

                % Delimit Detection (Cumulative Energy Window)
                windowLimits = cumulativeEnergy(xsf,cumEnergyRatio);
                signalEnergyTime1(p) = signalTime1(p) ...
                    + (windowLimits(1) - 1)/resampleRate;
                signalEnergyTime2(p) = signalTime2(p) ...
                    + (windowLimits(2) - 1)/resampleRate;
                noiseEnergyTime1(p) = noiseTime1(p) ...
                    + (windowLimits(1) - 1)/resampleRate;
                noiseEnergyTime2(p) = noiseTime2(p) ...
                    + (windowLimits(2) - 1)/resampleRate;

                % Calculate Broadband Metrics (Signal)
                nSamples_signal = signalSample2 - signalSample1 + 1;
                srms(1,p) = rms(xsf); % root-mean-square
                sexp(1,p) = rms(xsf)^2*nSamples_signal/resampleRate; % exposure
                sz2p(1,p) = max(abs(xsf)); % peak
                sp2p(1,p) = max(xsf) - min(xsf); % peak-to-peak  

                % Calculate Broadband Metrics (Noise)
                nSamples_noise = noiseSample2 - noiseSample1 + 1;
                nrms(1,p) = rms(xnf); % root-mean-square
                nexp(1,p) = rms(xnf)^2*nSamples_noise/resampleRate; % exposure
                nz2p(1,p) = max(abs(xnf)); % peak
                np2p(1,p) = max(xnf) - min(xnf); % peak-to-peak 

                % Calculate Band Metrics (Signal)
                signalBandMetrics = fftBankFilter(FftFilterBank,xsf,true);               
                srmsb(:,p) = signalBandMetrics(1,:)'; % rms
                sexpb(:,p) = signalBandMetrics(2,:)'; % exposure

                % Calculate Band Metrics (Noise)
                noiseBandMetrics = fftBankFilter(FftFilterBank,xnf,true);    
                nrmsb(:,p) = noiseBandMetrics(1,:)'; % rms
                nexpb(:,p) = noiseBandMetrics(2,:)'; % exposure
            end
            close(hfig)
            fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))

            % Calculate File Absolute Time (Tick)
            fileTick = audioFileTick(audiodbName,audioTimeFormat);
            fileTimestamp = datestr(fileTick/86400,'yyyy-mmm-dd HH:MM:SS.FFF');

            % Calculate Time Offsets and Signal Absolute Times (PC and UTC)
            signalPcTick = fileTick + signalTime; % original
            timeOffsetPerDetection = getTimeOffset(tick,timeOffset,signalPcTick);
            signalUtcTick = signalPcTick - timeOffsetPerDetection; % offset corrected

            % Populate AUDPRODATAONE
            AudProDataOne.signalPcTick = signalPcTick;
            AudProDataOne.signalUtcTick = signalUtcTick;
            AudProDataOne.timeOffset = timeOffsetPerDetection;
            AudProDataOne.fileTimestamp = fileTimestamp;
            AudProDataOne.fileTick = fileTick;
            AudProDataOne.signalTime1 = signalTime1;
            AudProDataOne.signalTime2 = signalTime2;
            AudProDataOne.signalEnergyTime1 = signalEnergyTime1;
            AudProDataOne.signalEnergyTime2 = signalEnergyTime2;
            AudProDataOne.noiseTime1 = noiseTime1;
            AudProDataOne.noiseTime2 = noiseTime2;
            AudProDataOne.noiseEnergyTime1 = noiseEnergyTime1;
            AudProDataOne.noiseEnergyTime2 = noiseEnergyTime2;
            AudProDataOne.signalZ2p = sz2p;
            AudProDataOne.signalP2p = sp2p;
            AudProDataOne.signalRms = srms;
            AudProDataOne.signalExp = sexp;
            AudProDataOne.noiseZ2p = nz2p;
            AudProDataOne.noiseP2p = np2p;
            AudProDataOne.noiseRms = nrms;
            AudProDataOne.noiseExp = nexp;
            AudProDataOne.signalRmsBand = srmsb;
            AudProDataOne.signalExpBand = sexpb;
            AudProDataOne.noiseRmsBand = nrmsb;
            AudProDataOne.noiseExpBand = nexpb;
            AudProDataOne.nominalFreq = fc_nom;
            AudProDataOne.centralFreq = fc;
            AudProDataOne.cutoffFreq1 = f1;
            AudProDataOne.cutoffFreq2 = f2;

            % Populate Acoustic Database with AUDDETCONFIG and AUDDETDATA
            AcousticDatabase.AcoConfig(index).AudProConfig = AudProConfigOne; 
            AcousticDatabase.AcoData(index).AudProData = AudProDataOne;

            % Save Acoustic Database
            save(acousticdbPath,'-struct','AcousticDatabase')
        else
            if isempty(index)
                warning(['Acoustic Database ''%s'' has not been processed '...
                    'for detections for the RECEIVERNAME\\SOURCENAME '...
                    'combination ''%s''\\''%s''. Run AUDIODETECTFUN on '...
                    'this file before attempting to process it with '...
                    'AUDIOPROCESSFUN. Processing will not be carried out'],...
                    acousticdbName,receiverName,sourceName)
            end
            if ~nDetections
                fprintf('[!] No detections [%s]\n',...
                    datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
            end
        end
    end
end
