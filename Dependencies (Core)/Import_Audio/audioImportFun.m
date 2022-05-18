%  AUDIOIMPORTFUN(root,AudImpConfig)
%
%  DESCRIPTION
%  Reads and resamples (if applicable) the audio files in the folders and 
%  paths listed in '<ROOT.BLOCK>\configdb\audioPaths.json'. The reading and
%  resampling of the audio files is done as specified in the multi-element 
%  audio import configuration structure AUDIMPCONFIG. 
%
%  AUDIMPCONFIG is generated with READAUDIOIMPORTCONFIG. Each element in 
%  AUDIMPCONFIG contains the information from an individual audio import 
%  config scripts 'audioImportConfig*.json' stored in '<ROOT.BLOCK>\configdb'.
%
%  AUDIOIMPORTFUN creates an Audio Database (.mat) for each audio file
%  in 'audioPath.json' and stores it in '<ROOT.BLOCK>\audiodb'. Each
%  Audio Database contains two structures: AUDIMPCONFIG and AUDIMPDATA.
%  The first contains the audio configuration information and the second 
%  the imported audio data samples (with or without resampling). If an 
%  Audio Database has already been created for a selected audio file, 
%  that audio file will not be imported again.
%  
%  Audio Databases are named as '<AUDIO>_ch<CHANNEL>_fr<RESAMPLERATE>.mat' 
%  where <AUDIO> is the name of the audio file (excluding extension), 
%  <CHANNEL> is the number of the channel imported from the audio file and 
%  <RESAMPLERATE> is the sampling rate after resampling. 
%
%  For details about the fields in an Acoustic Database refer to the help
%  from function INITIALISEAUDIOIMPORTCONFIG.
%
%  INPUT ARGUMENTS
%  - root: structure containing the root directories where the audio data
%    (ROOT.AUDIO), position data (ROOT.POSITION) and block data (ROOT.BLOCK)
%    are stored. ROOT.BLOCK contains the directories where the Configuration 
%    Files ('configdb'), Resampled Audio ('audiodb'), Detection Database
%    ('detectiondb), Navigation Database ('navigationdb'), and Acoustic 
%    Databases ('acousticdb') are stored.
%  - AudImpConfig: multi-element audio import configuration structure.
%
%  OUTPUT ARGUMENTS
%  - None
%
%  FUNCTION CALL
%  AUDIOIMPORTFUN(root,AudImpConfig)
%
%  FUNCTION DEPENDENCIES
%  - readAudioPaths
%  - getFilePaths
%  - initialiseAudioImportData
%  - initialiseAudioDatabase
%  - readWavHeader
%  - readAudioFile
%  - resampleAudioFile  
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%  - Read Audio Files
%  - Resampling
%
%  See also READAUDIOIMPORTCONFIG

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  12 Jul 2021

function audioImportFun(root,AudImpConfig)

% Remove Scripts with 'inputStatus' = 0
AudImpConfig = AudImpConfig(logical([AudImpConfig.inputStatus]));

% Obtain Audio Absolute Paths from 'audioPaths.json'
filePath = fullfile(root.block,'configdb','audioPaths.json');
audioPaths = getFilePaths(readAudioPaths(root,filePath),...
    {'.wav','.raw2int16','.raw','.pcm'});

% Error Control: Ignore Duplicated Audio Files
nFiles = numel(audioPaths);
audioNames = cell(nFiles,1);
audioExtensions = cell(nFiles,1);
for n = 1:nFiles
    [~,audioNames{n},audioExtensions{n}] = fileparts(audioPaths{n});
end
[~,iUnique] = unique(audioNames,'stable');
if length(iUnique) ~= numel(audioPaths)
    audioPaths = audioPaths(iUnique);
    audioNames = audioNames(iUnique);
    audioExtensions = audioExtensions(iUnique);
    warning(['One or more audio files ''<ROOT.BLOCK>/configdb/'...
        'audioPaths.json'' are duplicated. Duplicated files will '...
        'be ignored'])
end

% Display Progress on Command Window
fprintf('\nIMPORTING AUDIO DATA\n')

% Import Audio Files
nScripts = numel(AudImpConfig);
for m = 1:nScripts
        
    % Load Common Variables
    configFileName = AudImpConfig(m).configFileName;
    audioFormat = AudImpConfig(m).audioFormat;
    channel = AudImpConfig(m).channel;
    resampleRate = AudImpConfig(m).resampleRate;  
    
    % Display Start of Processing of Current Script
    fprintf('Configuration File ''%s'' [%s]\n',configFileName,...
        datestr(datenum(clock),'dd-mmm-yyyy HH:MM:SS'))

    % Audio Paths for Current Script
    switch audioFormat
        case 'wav'
            iWav = ismember(audioExtensions,{'.wav'});
            audioPaths_m = audioPaths(iWav);
            audioNames_m = audioNames(iWav);
            audioExtensions_m = audioExtensions(iWav);
        case 'raw'
            iRaw = ismember(audioExtensions,{'.raw2int16','.raw','.pcm'});
            audioPaths_m = audioPaths(iRaw);
            audioNames_m = audioNames(iRaw);
            audioExtensions_m = audioExtensions(iRaw);
    end

    % Create Audio Database Folder in Root Directory (if doesn't exist)
    if exist(strcat(root.block,'\audiodb'),'dir') ~= 7
        mkdir(root.block,'audiodb');
    end
    
    % Warn if No Audio Files Could be Found
    if isempty(audioPaths_m)
        warning(['No audio files could be found for the specified audio '...
            'format (%s). Check ''<ROOT.BLOCK>\\configdb\\audioPaths.json'' '...
            'to ensure that the desired audio paths and folders were '...
            'included'],audioFormat)
    end
                
    % Discard Audio Paths that Already Exist in <ROOT.BLOCK>\audiodb
    audImpDataNames = strcat(audioNames_m,sprintf('_ch%d_fr%d',channel,...
        resampleRate),'.mat');
    audImpDataPaths = fullfile(root.block,'audiodb',audImpDataNames);
    existAudiodb = cellfun(@(x) exist(x,'file'),audImpDataPaths) == 2;
    audioNames_m(existAudiodb) = [];
    audioPaths_m(existAudiodb) = [];
    if any(existAudiodb)
        warning(['One or more Audio Databases already exist in '...
            '''<ROOT.BLOCK>\\audiodb'' for the specified audio files, '...
            'CHANNEL (%d) and RESAMPLERATE (%0.0f Hz)'],channel,resampleRate)
    end
    
    % Import Audio Data
    nFiles = numel(audioPaths_m);
    for n = 1:nFiles
        % Initialise Audio Database and Substructures
        AudImpConfigOne = AudImpConfig(m);
        AudImpDataOne = initialiseAudioImportData();
        AudioDatabase = initialiseAudioDatabase();
        
        % Read and Resample Audio Data
        switch audioFormat
            case 'raw'                        
                % Audio Parameters (RAW)
                sampleRate = AudImpConfig(m).sampleRate;
                bitDepth = AudImpConfig(m).bitDepth;
                numChannels = AudImpConfig(m).numChannels;
                endianness = AudImpConfig(m).endianness;

                % Calculate Resampling Factor & Resampling Rate
                p = 1;
                q = 1;
                if ~isempty(resampleRate) && resampleRate <= sampleRate
                    [~,sysmem] = memory;
                    freeRam = sysmem.PhysicalMemory.Available/200;
                    [p,q] = resamplingFactors(sampleRate,...
                        resampleRate,5,freeRam);
                end
                resampleRate = sampleRate * p/q;

                % Resample Audio File
                if sampleRate ~= resampleRate % resample file
                    fprintf('Resampling audio file ''%s'' (%d/%d) ',...
                        strcat(audioNames_m{n},audioExtensions_m{n}),...
                        n,nFiles)
                    AudImpDataOne(1).audioData = resampleAudioFile(...
                        audioPaths_m{n},channel,[],p,q,sampleRate,...
                        numChannels,bitDepth,endianness);
                    fprintf('[%s]\n',datestr(datenum(clock),...
                        'dd-mmm-yyyy HH:MM:SS'))
                else % read file
                    fprintf('Reading audio file ''%s'' (%d/%d) ',...
                        strcat(audioNames_m{n},audioExtensions_m{n}),...
                        n,nFiles)
                    AudImpDataOne(1).audioData = readAudioFile(...
                        audioPaths_m{n},channel,[],'float',sampleRate,...
                        numChannels,bitDepth,endianness);
                    fprintf('[%s]\n',datestr(datenum(clock),...
                        'dd-mmm-yyyy HH:MM:SS'))
                end

            case 'wav'
                % Audio Parameters (WAV)
                header = readwavHeader(audioPaths_m{n});
                sampleRate = header.sampleRate;
                bitDepth = header.bitsPerSample;
                numChannels = header.numChannels;
                endianness = header.byteOrder;

                % Calculate Resampling Factor & Resampling Rate
                p = 1;
                q = 1;
                if ~isempty(resampleRate) && resampleRate <= sampleRate
                    [~,sysmem] = memory;
                    freeRam = sysmem.PhysicalMemory.Available/200;
                    [p,q] = resamplingFactors(sampleRate,...
                        resampleRate,5,freeRam);
                end
                resampleRate = sampleRate * p/q;

                % Resample Audio File
                if channel <= numChannels % only needed for WAV files
                    if sampleRate ~= resampleRate % resample file
                        fprintf('Resampling audio file ''%s'' (%d/%d) ',...
                            strcat(audioNames_m{n},audioExtensions_m{n}),...
                            n,nFiles)
                        AudImpDataOne(1).audioData = resampleAudioFile(...
                            audioPaths_m{n},channel,[],p,q);
                        fprintf('[%s]\n',datestr(datenum(clock),...
                            'dd-mmm-yyyy HH:MM:SS'))
                    else % read file
                        fprintf('Reading audio file ''%s'' (%d/%d) ',...
                            strcat(audioNames_m{n},audioExtensions_m{n}),...
                            n,nFiles)
                        AudImpDataOne(1).audioData = readAudioFile(...
                            audioPaths_m{n},channel,[],'float');
                        fprintf('[%s]\n',datestr(datenum(clock),...
                            'dd-mmm-yyyy HH:MM:SS'))
                    end
                else
                    warning(['CHANNEL exceeds the number of channels in '...
                        'audio file ''%s''. The audio data will not be '...
                        'imported for this file'],audioNames_m{n})
                end
        end

        % Populate Audio Configuration Structure
        AudImpConfigOne(1).resampleRate = resampleRate;
        AudImpConfigOne(1).sampleRate = sampleRate;
        AudImpConfigOne(1).bitDepth = bitDepth;
        AudImpConfigOne(1).numChannels = numChannels;
        AudImpConfigOne(1).endianness = endianness;
        AudImpConfigOne(1).audioLength = length(AudImpDataOne(1).audioData);

        % Populate Audio Data Structure
        AudImpDataOne(1).audioPath = audioPaths_m{n};
        
        % Populate Audio Database
        AudioDatabase(1).AudImpData = AudImpDataOne;
        AudioDatabase(1).AudImpConfig = AudImpConfigOne;          

        % Save Audio Database Structure
        audImpDataName = [audioNames_m{n} sprintf('_ch%d_fr%d',channel,...
            resampleRate) '.mat'];
        audImpDataPath = fullfile(root.block,'audiodb',audImpDataName);
        fprintf('Saving audio into Audio Database ''%s'' ',audImpDataName)
        save(audImpDataPath,'-struct','AudioDatabase');
        fprintf('[%s]\n',datestr(datenum(clock),...
            'dd-mmm-yyyy HH:MM:SS'))
    end
end
