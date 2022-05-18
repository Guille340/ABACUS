%  PREPROCESSNEYMANPEARSON(root,AudDetConfig)
% 
%  DESCRIPTION
%  Computes the performance of a Neyman-Pearson detector with the parameters 
%  specified in the substructure AUDDETCONFIG.DETECTPARAMETERS and stores it 
%  in '<ROOT.BLOCK>\detectiondb'. 
%
%  For a detector of type 'ed' (energy detector), the function only calculates 
%  the performance data. For a detector of type 'ecw' (estimator-correlator in
%  white Gaussian noise), the function calculates the matrix of raw scores for
%  the target signal, the normalised covariance matrices for the target signal,
%  the matrix of eigenvalues and the vector of eigenvectors. For a detector of 
%  type 'ecc' (estimator-correlator in coloured Gaussian noise), the function 
%  calculates the matrix of raw scores for the target signal and background 
%  noise, the normalised covariance matrices for the target signal and 
%  background noise, the matrix of eigenvalues and the vector of eigenvectors.
%
%  The raw score data, eigen data and performance data are stored as *.mat 
%  structures in '<ROOT.BLOCK>\detectiondb'. These files are named as follows:
%  
%  '<DATATYPE>_<SOURCE>_<DETECTORTYPE>_fa<CUTOFFFREQS(1)>_fb<CUTOFFFREQS(2)>_
%  fs<RESAMPLERATE>_t<KERNELDURATION>'
%
%  where <DATATYPE> is the type of file content ('RawSignal', 'RawNoise', 
%  'EigenData', 'PerformanceData'), <SOURCE> is the target source (e.g. airgun), 
%  <DETECTORTYPE> is the class of detector ('ed','ecw','ecc'), <RESAMPLERATE> 
%  is the sampling rate of the covariance and eigen matrices, and 
%  <KERNELDURATION> is the duration of the audio segment to be processed.
%  Note that the number of variables in the covariance matrix, eigenvectors, 
%  and eigenvalues is <KERNELDURATION> * <RESAMPLERATE>.
%
%  The stored eigen data and performance data are needed by the detection 
%  algorithm and must be available before the algorithm is called (see
%  function DETECTORNEYMANPEARSON).
%
%  INPUT ARGUMENTS
%  - root: structure containing the root directories where the audio data
%    (ROOT.AUDIO), position data (ROOT.POSITION) and block data (ROOT.BLOCK)
%    are stored. ROOT.BLOCK contains the directories where the Configuration 
%    Files ('configdb'), Resampled Audio ('audiodb'), Detection Database
%    ('detectiondb), Navigation Database ('navigationdb'), and Acoustic 
%    Databases ('acousticdb') are stored.
%  - AudDetConfig: multi-element audio detect configuration structure.
%  
%  OUTPUT ARGUMENTS
%  - None
%
%  FUNCTION CALL
%  AudDetConfig = preProcessNeymanPearson(root,AudDetConfig)
%
%  FUNCTION DEPENDENCIES
%  - discardRepeatedElements
%  - characterisePerformance
%  - plotPerformance
%  - digitalSingleFilterDesign
%  - digitalSingleFilter
%  - rawScores
%  - covariance
%  - eigenEquation
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%  - Digital Filtering (Single)
%
%  See also DETECTORNEYMANPEARSON

%  VERSION 2.1
%  Date: 04 Mar 2022
%  Author: Guillermo Jimenez Arranz
%  - Added progress display on command window
%
%  VERSION 2.0
%  Date: 25 Feb 2022
%  Author: Guillermo Jimenez Arranz
%  - Restructured code.
%  - Updated calls to modified functions
%  - The covariance matrices are now saved
%  
%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  24 Sep 2021

function preProcessNeymanPearson(root,AudDetConfig)

% Remove Scripts with 'inputStatus' = 0
AudDetConfig = AudDetConfig(logical([AudDetConfig.inputStatus]));

% Discard Scripts with Identical RECEIVERNAME/SOURCENAME combination
AudDetConfig = discardRepeatedElements(AudDetConfig);

% Discard Scripts from Detectors Different from 'NeymanPearson'
AudDetConfig = AudDetConfig(ismember({AudDetConfig.detector},'neymanpearson'));

% Display Progress on Command Window
nScripts = numel(AudDetConfig);
if nScripts > 0
    fprintf('\nPREPROCESSING NEYMAN-PEARSON DATA\n')
end

% Import Audio Files
for m = 1:nScripts   

    % Audio Detect Config for Current Structure (AUDDETCONFIGONE)
    AudDetConfigOne = AudDetConfig(m);

    % Load General Variables
    configFileName = AudDetConfigOne.configFileName;
    sourceName = AudDetConfigOne.sourceName;
    sampleRateAudio = AudDetConfigOne.resampleRate;
    minSnrLevel = 20; % fixed minimum SNR for raw score audio segments
    iSnrLevels = 31:5:71; % indices of SNR levels to plot (-20:5:20 dB)
    
    % Display Start of Processing of Current Script
    fprintf('Configuration File ''%s'' [%s]\n',configFileName,...
        datestr(datenum(clock),'dd-mmm-yyyy HH:MM:SS'))
    
    % Load Detection Parameters
    detectorType = lower(AudDetConfigOne.DetectParameters.detectorType);
    estimator = lower(AudDetConfigOne.DetectParameters.estimator);
    cutoffFreqs = AudDetConfigOne.DetectParameters.cutoffFreqs;
    trainFolder = AudDetConfigOne.DetectParameters.trainFolder;
    sampleRateForDetection = AudDetConfigOne.DetectParameters.resampleRate; % [Hz]
    kernelDuration = AudDetConfigOne.DetectParameters.kernelDuration; % [s]
    cutoffFreqns = 2*cutoffFreqs/sampleRateForDetection; % norm. cutoff freqs

    % Create Detection Database Folder
    if exist(fullfile(root.block,'detectiondb'),'dir') ~= 7
        mkdir(root.block,'detectiondb')
    end
    
    % File Paths
    rawSignalPath = fullfile(root.block,'detectiondb',sprintf(...
        'RawSignal_%s_%s_fs%0.0f_t%0.0f.mat',sourceName,...
        upper(detectorType),sampleRateAudio,kernelDuration*1000));
    rawNoisePath = fullfile(root.block,'detectiondb',sprintf(...
        'RawNoise_%s_%s_fs%0.0f_t%0.0f.mat',sourceName,...
        upper(detectorType),sampleRateAudio,kernelDuration*1000));
    covSignalPath = fullfile(root.block,'detectiondb',sprintf(...
        'CovarianceSignal_%s_%s_fa%0.0f_fb%0.0f_fs%0.0f_t%0.0f_%s.mat',...
        sourceName,upper(detectorType),cutoffFreqs(1),cutoffFreqs(2),...
        sampleRateForDetection,kernelDuration*1000,estimator));
    covNoisePath = fullfile(root.block,'detectiondb',sprintf(...
        'CovarianceNoise_%s_%s_fa%0.0f_fb%0.0f_fs%0.0f_t%0.0f_%s.mat',...
        sourceName,upper(detectorType),cutoffFreqs(1),cutoffFreqs(2),...
        sampleRateForDetection,kernelDuration*1000,estimator));
    eigenPath = fullfile(root.block,'detectiondb',sprintf(...
        'EigenData_%s_%s_fa%0.0f_fb%0.0f_fs%0.0f_t%0.0f_%s.mat',...
        sourceName,upper(detectorType),cutoffFreqs(1),cutoffFreqs(2),...
        sampleRateForDetection,kernelDuration*1000,estimator));
    performancePath = fullfile(root.block,'detectiondb',sprintf(...
        'PerformanceData_%s_%s_fa%0.0f_fb%0.0f_fs%0.0f_t%0.0f_%s.mat',...
        sourceName,upper(detectorType),cutoffFreqs(1),cutoffFreqs(2),...
        sampleRateForDetection,kernelDuration*1000,estimator));
    outputFolder = fullfile(root.block,'detectiondb',sprintf(...
        'ROC_%s_%s_fa%0.0f_fb%0.0f_fs%0.0f_t%0.0f_%s',sourceName,...
        upper(detectorType),cutoffFreqs(1),cutoffFreqs(2),...
        sampleRateForDetection,kernelDuration*1000,estimator));

    switch detectorType
        case 'ed' % "energy detector" (ED)            
            
            % Process Detection Performance Curves
            fprintf('# Processing detection performance ')
            if exist(performancePath,'file') == 2
                PerformanceData = load(performancePath);
                PerformanceData = PerformanceData.PerformanceData;
            else
                kernelLength = round(sampleRateForDetection*kernelDuration);
                PerformanceData = characterisePerformance(detectorType,...
                    cutoffFreqns,kernelLength,0,'DisplayProgress',true);
                save(performancePath,'PerformanceData')    
            end
            fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
            
            % Plot Receiver Operating Characteristic (ROC)
            if exist(outputFolder,'dir') ~= 7
                fprintf('# Plotting Receiver Operating Characteristic (ROC) ')
                plotPerformance(PerformanceData(iSnrLevels),outputFolder)
                fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
            end
             
        case {'ecw','ecc'} % "estimator-correlator" (EC)
                        
            % Process Matrix of Raw Scores (Target Signal)
            if exist(rawSignalPath,'file') == 2
                fprintf('# Loading matrix of signal raw scores ')
                RawSignal = load(rawSignalPath);
                fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
            else
                fprintf('# Processing matrix of signal raw scores ')
                RawSignal = rawScores(fullfile(trainFolder,'signal'),...
                    'MinimumSnr',minSnrLevel,'SampleRate',sampleRateAudio,...
                    'Duration',kernelDuration,'DisplayProgress',true);
                fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
                if ~isempty(RawSignal)
                    fprintf('# Saving matrix of signal raw scores ')
                    save(rawSignalPath,'-struct','RawSignal') 
                    fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
                end
            end
            
            % Process Matrix of Raw Scores (Background Noise)
            if strcmp(detectorType,'ecc')
                if exist(rawNoisePath,'file') == 2
                    fprintf('# Loading matrix of noise raw scores ')
                    RawNoise = load(rawNoisePath);
                    fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
                else
                    fprintf('# Processing matrix of noise raw scores ')
                    RawNoise = rawScores(fullfile(trainFolder,'noise'),...
                        'MinimumSnr',minSnrLevel,'SampleRate',sampleRateAudio,...
                        'Duration',kernelDuration,'DisplayProgress',true);
                    fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
                    if ~isempty(RawNoise)
                        fprintf('# Saving matrix of noise raw scores ')
                        save(rawNoisePath,'-struct','RawNoise') 
                        fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
                    end
                end   
            end
            
            % Design Filter
            if exist(covSignalPath,'file') ~= 2 ...
                    || (exist(covNoisePath,'file') ~= 2 ...
                    && strcmp(detectorType,'ecc'))
                fprintf('# Designing digital filter ')
                DigitalFilter = digitalSingleFilterDesign(...
                    sampleRateForDetection,cutoffFreqs);
                fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
            end
            
            % Process Covariance Matrix (Target Signal)
            if exist(covSignalPath,'file') == 2
                fprintf('# Loading signal covariance matrix ')
                CovarianceSignal = load(covSignalPath); 
                fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
            else
                fprintf('# Processing signal covariance matrix ')
                CovarianceSignal = covariance(RawSignal,'Duration',...
                    kernelDuration,'SampleRate',sampleRateForDetection,...
                    'Estimator',estimator,'DigitalFilter',DigitalFilter,...
                    'DisplayProgress',true); 
                fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
                if ~isempty(CovarianceSignal)
                    fprintf('# Saving signal covariance matrix ')
                    save(covSignalPath,'-struct','CovarianceSignal')
                    fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
                end
            end
            clear RawSignal
                
            % Process Covariance Matrix (Background Noise)
            CovarianceNoise = [];
            if strcmp(detectorType,'ecc')
                if exist(covNoisePath,'file') == 2
                    fprintf('# Loading noise covariance matrix ')
                    CovarianceNoise = load(covNoisePath); 
                    fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
                else
                    fprintf('# Processing noise covariance matrix ')
                    CovarianceNoise = covariance(RawNoise,'Duration',...
                        kernelDuration,'SampleRate',sampleRateForDetection,...
                        'Estimator',estimator,'DigitalFilter',DigitalFilter,...
                        'DisplayProgress',true); 
                    fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
                    if ~isempty(CovarianceNoise)
                        fprintf('# Saving noise covariance matrix ')
                        save(covNoisePath,'-struct','CovarianceNoise')
                        fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
                    end
                end
                clear RawNoise
            end
              
            % Process Eigenvalues and EigenVectors
            if exist(eigenPath,'file') == 2
                fprintf('# Loading eigen data ')
                Struct = load(eigenPath,'signalEigenValuesNorm');  
                signalEigenValuesNorm = Struct.signalEigenValuesNorm;
                fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
            else
                signalEigenValuesNorm = []; % initialise eigen values vector
                if ~isempty(CovarianceSignal)
                    fprintf('# Processing eigen data ')
                    EigenData = eigenEquation(CovarianceSignal,...
                        CovarianceNoise,'DisplayProgress',true);
                    signalEigenValuesNorm = EigenData.signalEigenValuesNorm;
                    fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
                    
                    if ~isempty(signalEigenValuesNorm)
                        fprintf('# Saving eigen data ')
                        save(eigenPath,'-struct','EigenData')
                        fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
                    end
                    clear EigenData
                end
            end

            % Process Detection Performance Curves
            if ~isempty(signalEigenValuesNorm)
                if exist(performancePath,'file') == 2   
                    fprintf('# Loading detection performance data ')
                    PerformanceData = load(performancePath);
                    PerformanceData = PerformanceData.PerformanceData;
                    fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
                else
                    fprintf('# Processing detection performance data ')
                    PerformanceData = characterisePerformance(...
                        detectorType,cutoffFreqns,signalEigenValuesNorm,...
                        'DisplayProgress',true);
                    fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
                    
                    fprintf('# Saving detection performance data ')
                    save(performancePath,'PerformanceData')
                    fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
                end
            end
            
            % Plot Detection Performance (ROC)
            if exist(outputFolder,'dir') ~= 7
                fprintf('# Plotting Receiver Operating Characteristic (ROC) ')
                plotPerformance(PerformanceData(iSnrLevels),outputFolder)
                fprintf('[%s]\n',datestr(clock,'dd-mmm-yyyy HH:MM:SS'))
            end
    end
end
