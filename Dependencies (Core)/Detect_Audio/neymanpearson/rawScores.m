%  RawScoreData = RAWSCORES(fileDir,varargin)
%
%  DESCRIPTION
%  Calculates the matrix of raw scores from the audio files in directory 
%  FILEDIR and its subfolders. The function generates a structure RAWSCORES 
%  that contains the matrix of raw scores and related relevant information.
%  Each audio file may contain one ('ReadMode' = 'single') or several 
%  ('ReadMode'= 'multi') observations of a particular type of signal (e.g., 
%  airgun pulses, background noise, etc).
%
%  The matrix of raw scores is later used by the function COVARIANCE to compute
%  the covariance matrix. In a statistical detector, the covariance matrix is 
%  used to detect signals statistically similar to those used to build the 
%  matrix. The covariance matrix characterises the statistical behaviour of the
%  observations. Note that the observations in the matrix of raw scores are 
%  normalised by their standard deviation, as for signal characterisation
%  purposes it is the relative variance between variables (samples) that we
%  are interested in. As a result of the normalisation, the mean variance or
%  mean of the diagonal entries in the covariance matrix is 1.
%
%  RAWSCOREMATRIX accepts several input properties. 'MinimumSnr' determines the 
%  minimum signal-to-noise ratio (SNR) that a file in FILEDIR must have to be
%  included as an observation in the matrix of raw scores. The SNR must be
%  appended to the name of the audio files as '<NAME>_SNR<SNRVALUE>.wav'. 
%  'Duration' sets a common duration for all observations and must be lower than
%  or equal to the original duration of the observations (i.e., observations
%  may be trimmed but never zero-padded). 'SampleRate' sets a common sampling
%  rate for all observations. 'ReadMode' indicates whether one or multiple
%  observations should be extracted from the audio signals. 'DisplayProgress' 
%  is TRUE if the progress of the calculations is to be displayed.
%
%  INPUT ARGUMENTS (Fixed)
%  - fileDir: absolute path of the parent directory where the audio files
%    containing the signal observations are stored. The function will
%    look for any .wav files stored in FILEDIR and its subfolders. Note that
%    only WAV files are supported by RAWSCORES.
%
%  INPUT ARGUMENTS (Variable, Property/Value Pairs)
%  In the function call, type the property string followed by its value (comma-
%  separated). Property/value pairs are variable input arguments specified after
%  the fixed arguments. Any number of property/value pairs can be included in 
%  the function call. The following propeties are available.
%  - 'MinimumSnr': minimum signal-to-noise ratio, in decibels. Only files in
%    FILEDIR with a minimum SNR higher than (or equal to) this value will be
%    used to generate the matrix of raw scores. Note that this option needs 
%    the files to be named as '<NAME>_SNR<SNRVALUE>.wav'. Omit 'MinimumSnr' 
%    or use 'MinimumSnr' = -Inf to accept all files. This option should only 
%    be used with audio files that contain only one observation ('ReadMode' 
%    = 'single'), since long audio files will contain multiple observations 
%    each with a different SNR. By default, MINIMUMSNR = -Inf.
%  - 'Duration': target duration for the observations, in seconds. Any
%    observation with a duration larger than this value will be ignored.
%    Any observation with a duration shorter than this value will be trimmed.
%    For an automatic selection of the duration, equal to the minimum of all 
%    observations, set DURATION = []. By default, DURATION = [].
%  - 'SampleRate': target sampling rate for the observations. Resampling will
%    be applied if the value is different from the actual sampling rate of
%    the observations. For an automatic selection of the sampling rate, equal
%    to the most frequent value from the observations, set SAMPLERATE = [].
%    By default, SAMPLERATE = [].
%  - 'ReadMode': read one or several observations from the .wav files in 
%     FILEDIR.
%     ¬ 'single': for reading one observation only. Each observation starts
%        at the first sample of each audio file. Choose this option for 
%        importing the observations of the target signal, as each audio file 
%        should contain only one event. It can also be used for background 
%        noise (for this case, 'ReadMode' = 'multi' is generally preferred).
%     ¬ 'multi': for reading multiple observations. The observations are
%        randomly selected from each file. Observations are extracted from all
%        files, insofar as the maximum size for the raw scores matrix is not 
%        exceeded. Choose this option for importing multiple observations of
%        background noise from one or more long audio files.
%  - 'DisplayProgress': TRUE for displaying the progress of TIMELIMIT. By 
%     default, DISPLAYPROGRESS = TRUE.
%
%  OUTPUT ARGUMENTS
%  - RawScoreData: structure containing the normalised matrix of raw scores and 
%    related information. It contains the following fields.
%    ¬ kernelDuration: duration of the observations [s]
%    ¬ sampleRate: new sampling rate for the observations [Hz]. No resampling 
%      is applied if equal to the sampling rate of the observations.
%    ¬ minSnrLevel: minimum signal to noise ratio for the observations [dB]
%    ¬ snrLevels: vector of signal to noise ratios of the observations [dB]
%    ¬ rawScoreMatrix: normalised matrix of raw scores. It has as many 
%      rows as observations (audio segments) and as many columns as variables 
%      (audio samples). The values are single-precision.
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  FUNCTION CALL
%  1. rawScores(fileDir)
%  2. rawScores(...,PROPERTY,VALUE)
%     PROPERTIES: 'MinimumSnr', 'Duration', 'SampleRate', 'ReadMode', 
%        'DisplayProgress'
%
%  CONSIDERATIONS & LIMITATIONS
%  - "For the target signal": use 'ReadMode' = 'single'. If the observations 
%    correspond to transient signals, it is advised that these start from the 
%    same reference sample so there exists certain alignement. This will allow 
%    an effective characterisation of common transient regions. The observations
%    should be extracted manually from one or more audio files to have control 
%    on the signal's starting sample. It is recommended that, whenever possible, 
%    all extracted observations have the same duration and sampling rate 
%    (otherwise, a unique duration and sampling rate will be automatically 
%    selected). The selected duration should be long enough to cover the 
%    longest expected signal, but not much longer than that to avoid including 
%    unnecessary background noise data.
%  - "For the background noise": Preferrably, use 'ReadMode' = 'multi'. This
%    option extracts multiple observations of specified duration from long 
%    audio files and uses them to build the raw score matrix. It is certainly 
%    more convenient to generate the raw scores matrix from one or more long 
%    audio files containing only background noise, recorded soon before or 
%    after the period where the target source is active.  Alternatively, use 
%    'ReadMode' = 'single' if you prefer to extract individual noise segments 
%    to have total control on the training noise data used to built the matrix
%    of raw scores. Use this option if there are no long background noise 
%    recordings available before or after the source's active period.
%  - It is advised that 'Duration' and 'SampleRate' are chosen to be equal to
%    the most frequent values from the extracted observations. The easiest way
%    to do that is to set 'Duration' and 'SampleRate' as empty [], in which 
%    case the function will select the most appropriate values.
%  - The maximum size for the matrix of raw scores is set to 1024 MB. If that
%    limit is reached, the number of observations is reduced to ensure the 
%    matrix of raw scores lies within that limit. Note that this will have a 
%    negative effect on the accuracy of the covariance matrix computed from 
%    RAWSCOREDATA. Therefore, it is advisable to reduce the duration of the 
%    observations if possible, so that the number of observations is comparable 
%    to or larger than the number of variables.

%  VERSION 2.2
%  Date: 04 Mar 2022
%  Author: Guillermo Jimenez Arranz
%  - Updated help
%
%  VERSION 2.1
%  Date: 23 Feb 2022
%  Author: Guillermo Jimenez Arranz
%  - Added the option 'ReadMode' to import one or multiple observations from 
%    each file. 
%
%  VERSION 2.0
%  Date: 07 Sep 2021
%  Author: Guillermo Jimenez Arranz
%  - The original function COVARIANCE is now split into functions RAWSCOREMATRIX
%    and COVARIANCEMATRIX. The idea is to use RAWSCOREMATRIX to compute the
%    matrix of raw scores with the observations minimally altered (if at all)
%    and at the same time save some space, since the matrix of raw scores is
%    generally lighter than the covariance matrix.
%
%  VERSION 1.0
%  Date: 04 May 2021
%  Author: Guillermo Jimenez Arranz
%  Email: gjarranz@gmail.com

function RawScoreData = rawScores(fileDir,varargin)

% INPUT ARGUMENTS
% Verify number of Input Arguments
nFixArg = 1;
nProArg = 10;
narginchk(nFixArg,nFixArg + nProArg)
if rem(nargin - nFixArg,2)
    error('Variable input arguments must come in pairs (PROPERTY,VALUE)')
end

% Extract and Verify Input Properties
properties_valid = {'minimumsnr','duration','samplerate','readmode',...
    'displayprogress'};
properties = lower(varargin(1:2:end));
if any(~ismember(properties,properties_valid))
    error('One or more PROPERTY is not recognised')
end

% Default Input Values
minSnrLevel = -inf;
kernelDuration = [];
fr = [];
readMode = 'multi';
displayProgress = false;

% Extract and Verify Input Values
values = varargin(2:2:end);
nPairs = (nargin - nFixArg)/2; % number of (PROPERTY,VALUE) pairs
for m = 1:nPairs
    property = properties{m};
    switch property % populate with more properties if needed
        case 'minimumsnr'
            minSnrLevel = values{m};
            if ~isnumeric(minSnrLevel)
                minSnrLevel = 12;
                warning(['Non-supported value for PROPERTY = '...
                    '''MinimumSnr''. ''MinimumSnr'' = 12 will be used'])
            end
        case 'duration'
            kernelDuration = values{m};
            if ~isempty(kernelDuration) && (~isnumeric(kernelDuration) ...
                    || kernelDuration < 0)
                kernelDuration = [];
                warning(['Non-supported value for PROPERTY = '...
                    '''Duration''. ''Duration'' = [] will be used'])
            end     
        case 'samplerate'
            fr = values{m};
            if ~isempty(fr) && (~isnumeric(fr) || fr < 0)
                fr = [];
                warning(['Non-supported value for PROPERTY = '...
                    '''SampleRate''. No resampling will be applied'])
            end
        case 'readmode'
            readMode = values{m};
            if ischar(readMode)
                readMode = lower(readMode);
            end
            if ~ischar(readMode) || ~ismember(readMode,{'single','multi'})
                readMode = 'multi';
                warning(['Non-supported value for PROPERTY = '...
                    '''ReadMode''. ''ReadMode'' = ''%s'' will be used'],...
                    readMode)
            end
        case 'displayprogress'
            displayProgress = values{m};
            if ~any(displayProgress == [0 1])
                displayProgress = 0;
                warning(['Non-supported value for PROPERTY = '...
                    '''DisplayProgress''. A value of 0 will be used'])
            end
    end
end

% Extract Absolute Paths of WAV Files
fileList = dir(fullfile(fileDir,'**','*.wav'));

% Display Progress (open)
if displayProgress
    h = waitbar(0,'','Name','rawScores.m'); 
end

% Extract Audio Specs
nFiles = numel(fileList); % number of audio files
sampleRate = zeros(nFiles,1); % sample rate of target signal
numSamples = zeros(nFiles,1); % length of target signal [samples]
numSeconds = zeros(nFiles,1); % duration of target signal [s]
numChannels = zeros(nFiles,1); % number of channels of target signal
for m = 1:nFiles
    fileName = fileList(m).name;
    folderName = fileList(m).folder;
    fpath = fullfile(folderName,fileName);
    
    audinfo = audioinfo(fpath); 
    sampleRate(m) = audinfo.SampleRate;
    numSamples(m) = audinfo.TotalSamples;
    numSeconds(m) = audinfo.Duration;
    numChannels(m) = audinfo.NumChannels;
    
    % Display Progress (if applicable)
    if displayProgress
        messageString = sprintf('Verifying audio files (%d/%d)',m,nFiles);
        waitbar(m/nFiles,h,messageString);
    end
end

% Extract SNR
snrLevels = inf(nFiles,1); % SNR audio segments (initialise to Inf)
if strcmp(readMode,'single') && minSnrLevel ~= -inf
    for m = 1:nFiles
        fileName = fileList(m).name;
        ind1 = strfind(fileName,'SNR') + 3;
        ind2 = strfind(fileName,'.wav') - 1;
        snrLevels(m) = str2double(fileName(ind1:ind2));
    end
end

% Error Control: Audio Segments of Different Durations
if length(unique(numSeconds)) > 1 
    warning('The observations (audio segments) have different durations')
end

% Error Control: Duration of Audio Segments
if kernelDuration > min(numSeconds)
    if kernelDuration <= max(numSeconds)
        warning(['One or more audio files are shorter than the target '...
            'DURATION. These files will be ignored'])
    else
        warning(['All audio files are shorter than the target DURATION. '...
            'All files will be ignored'])
    end
end 

% Set Resampling Rate to Most Frequent (if FR = [])
if isempty(fr)
    fsUnique = unique(sampleRate);
    nFsOccur = histc(sampleRate,fsUnique); %#ok<HISTC>
    [~,iFs] = max(nFsOccur);
    fr = fsUnique(iFs);
end

% Set Duration of Observations to MIN(NUMSECONDS) (if DURATION = [])
if isempty(kernelDuration)
    kernelDuration = min(numSeconds);
end

% Remove Non-Valid Observations (SNR < MINSNR and NUMSECONDS < DURATION)
iValid = snrLevels >= minSnrLevel & numSeconds >= kernelDuration;
fileList = fileList(iValid);
snrLevels = snrLevels(iValid);
numChannels = numChannels(iValid);
nFiles = numel(fileList);
        
% Error Control: Number of Channels
if any(numChannels > 1)
    warning(['One or more audio files have more than one channel. The first'...
    'channel will be used']);
end

% Calculate Number of Observations
nTests = nFiles;
if strcmp(readMode,'multi')
    nKernelsPerFile = floor(numSeconds/kernelDuration);
    nTests = sum(nKernelsPerFile);
end

% Error Control: Size of Matrix of Raw Scores
bytesPerMegabyte = 1024^2;
bytesPerSample = 4; % audio samples stored as single-precision
kernelLength = round(kernelDuration*fr); % number of samples for resampled signal
matrixSize = bytesPerSample*kernelLength*nTests/bytesPerMegabyte; % size of matrix of raw scores [MB]
maxSize = 1024; % maximum size for matrix of raw scores [MB]
if matrixSize > maxSize
    nTests = floor(maxSize*bytesPerSample*bytesPerMegabyte/kernelLength);
    warning(['The matrix of raw scores is larger than 1024 MB. The number '...
        'of observations will be reduced to %d'],nTests)    
end

% COMPUTE AND SAVE MATRIX OF RAW SCORES
% Initialise RawScoreData Structure
RawScoreData.kernelDuration = kernelDuration;
RawScoreData.sampleRate = fr;
RawScoreData.minSnrLevel = minSnrLevel;
RawScoreData.snrLevels = snrLevels';
RawScoreData.rawScoreMatrix = single(nan(nTests,kernelLength));

% Matrix of Raw Scores (readMode = 'single')
if strcmp(readMode,'single')
    for m = 1:nFiles
        fileName = fileList(m).name;
        folderName = fileList(m).folder;
        fpath = fullfile(folderName,fileName); 
        x = double(audioread(fpath,'native')); % double-precision for processing
        k = gcd(sampleRate(m),fr);
        P = fr/k; % interpolation factor
        Q = sampleRate(m)/k; % decimation factor
        xr = resample(x,P,Q); % resample audio file to target sample rate
        xr = xr(1:kernelLength); % trim audio file to fixed duration
        RawScoreData.rawScoreMatrix(m,:) = xr/std(xr); % matrix of raw scores (resampled)

        % Display Progress (if applicable)
        if displayProgress
            messageString = sprintf('Generating matrix of raw scores (%d/%d)',...
                m,nTests);
            waitbar(m/nTests,h,messageString);
        end
    end
end

% Matrix of Raw Scores (readMode = 'multi')
if strcmp(readMode,'multi')
    % Number of Observations to Extract from Each File
    cnt = 0;
    ind = 1;
    nKernelsPerFile = floor(numSeconds/kernelDuration);
    nTestsPerFile = zeros(nFiles,1);
    while cnt < nTests
        addOne = double(nTestsPerFile(ind) < nKernelsPerFile(ind)); % 0 or 1
        nTestsPerFile(ind) = addOne + nTestsPerFile(ind);
        ind = rem(ind,nFiles) + 1;
        cnt = cnt + addOne;   
    end
    
    % Compute Matrix of Raw Scores
    testNum = 0;
    for m = 1:nFiles
        fileName = fileList(m).name;
        folderName = fileList(m).folder;
        fpath = fullfile(folderName,fileName);
        segmentLength = floor(sampleRate(m)*kernelDuration); % length of segments (before resampling)
        iSegments = randperm(nKernelsPerFile(m),nTestsPerFile(m)); % indices of randomly selected segments
        k = gcd(sampleRate(m),fr);
        P = fr/k; % interpolation factor
        Q = sampleRate(m)/k; % decimation factor
        
        for n = 1:nTestsPerFile(m)
            testNum = testNum + 1;
            iSegment = iSegments(n); % index of selected segment within file
            i1 = (iSegment - 1)*segmentLength + 1;
            i2 = iSegment*segmentLength;
            x = double(audioread(fpath,[i1 i2],'native')); % double-precision for processing
            xr = resample(x,P,Q); % resample audio file to target sample rate
            xr = xr(1:kernelLength); % trim audio file to fixed duration
            RawScoreData.rawScoreMatrix(testNum,:) = xr/std(xr); % matrix of raw scores (resampled)

            % Display Progress (if applicable)
            if displayProgress
                messageString = sprintf('Generating matrix of raw scores (%d/%d)',...
                    testNum,nTests);
                waitbar(testNum/nTests,h,messageString);
            end
        end
    end
end

% Display Progress (close)
if displayProgress, close(h); end

% Error Control: Number of Observations
if ~nTests
    RawScoreData = [];
    warning(['No valid observations found. Try reducing DURATION or '...
        'MINIMUMSNR. The matrix of raw scores cannot be processed'])  
end
