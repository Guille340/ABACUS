%  covarianceMatrix = COVARIANCE(RawScoreData,varargin)
% 
%  DESCRIPTION
%  Calculates the normalised covariance matrix COVARIANCEMATRIX from the matrix 
%  of raw scores RAWSCOREDATA built with function RAWSCORES. The covariance 
%  matrix characterises the statistical behaviour of the observations. In a 
%  statistical detector, the covariance matrix  is employed to detect signals 
%  that are statistically similar to those used to build the matrix.
%
%  COVARIANCE accepts several input properties. 'Duration' sets a common 
%  duration for all observations and must be equal to or lower than the
%  duration of the observations (i.e., observations may be trimmed but not 
%  zero-padded). 'SampleRate' sets a common sampling rate for all observations 
%  by resampling. 'DigitalFilter' is a filtering object used to filter the 
%  observations before computing the covariance matrix. 'DisplayProgress' is 
%  TRUE if the progress of the calculations is to be displayed.
% 
%  INPUT ARGUMENTS (Fixed)
%  - RawScoreData: structure containing the normalised matrix of raw scores 
%    and related information (see RAWSCORES function).
% 
%  INPUT ARGUMENTS (Variable, Property/Value Pairs)
%  In the function call, type the property string followed by its value (comma-
%  separated). Property/value pairs are variable input arguments specified after
%  the fixed arguments. Any number of property/value pairs can be included in 
%  the function call. The following propeties are available.
%  - 'Duration': target duration for the observations, in seconds. DURATION 
%     must be equal or shorter than the duration of the observations. The 
%     observations are trimmed to DURATION. Set DURATION = [] to use the 
%     current duration of the observations. By default, DURATION = [].
%  - 'SampleRate': target sampling rate for the observations. Resampling will
%     be applied if the value is different from the actual sampling rate of
%     the observations. For an automatic selection of the sampling rate, equal
%     to the value from the observations, set SAMPLERATE = []. By default, 
%     SAMPLERATE = [].
%  - 'DigitalFilter': filtering object to be used to filter the observations. 
%     DIGITALFILTER must be a filter object of class 'digitalfilter' generated 
%     with DIGITALSINGLEFILTERDESIGN. For no filtering to be applied, set 
%     DIGITALFILTER = []. By default, DIGITALFILTER = [].
%  - 'FilterMode': filtering mode. There are two options: 'filter', for
%     standard filtering; and 'filtfilt', for zero-phase filtering (it uses
%     custom function MYFILTFILT). For details, see FILTER, FILTFILT and 
%     DIGITALSINGLEFILTER.  
%  - 'Estimator': estimator for computing the covariance matrix. Except for 
%     'sample', all estimators use linear shrinkage.
%     ¬ 'oas': Oracle Approximating Shrinkage (OAS) from Chen et al. (2010). 
%        See COVOAS function.
%     ¬ 'rblw': Rao-Blackwell Ledoit-Wolf (RBLW) from Chen et al. (2010).
%        See COVRBLW function.
%     ¬ 'param1': one-parameter shrinkage estimator from Ledoit & Wolf (2004).
%        See COVPARAM1 function.
%     ¬ 'param2': two-parameter shrinkage estimator from Ledoit. See COVPARAM2
%        function. Original code available at http://ledoit.net/cov2para.m
%     ¬ 'corr': shrinkage algorithm based on sample correlation matrix, from
%        Ledoit & Wolf (2003). See COVCORR function. Original code available
%        at https://www.econ.uzh.ch/en/people/faculty/wolf/publications.html
%     ¬ 'diag': shrinkage algorithm with diagonal target covariance matrix.
%        See COVDIAG. Original code available at http://ledoit.net/shrinkDiag.m
%     ¬ 'stock': shrinkage algorithm for stock market applications from 
%        Ledoit & Wolf (2001). Original code available at
%        https://www.econ.uzh.ch/en/people/faculty/wolf/publications.html
%     ¬ 'looc': shrinkage algorithm with Leave-One-Out Cross-Validation
%        approach for computing the intensity parameter. Based on concept
%        from Theiler (2012).
%     ¬ 'sample': sample covariance matrix.
%  - 'DisplayProgress': TRUE for displaying the progress of TIMELIMIT. By 
%     default, DISPLAYPROGRESS = TRUE.
%    
%  OUTPUT VARIABLES
%  - CovarianceData: structure containing the following covariance information.
%    ¬ 'kernelDuration': duration of raw score observations used to build the
%       covariance matrix [s].
%    ¬ 'sampleRate': sampling rate, after resampling, of the raw score
%       observations used to build the covariance matrix [Hz].
%    ¬ 'covarianceMatrix': normalised covariance matrix of the raw scores in 
%       RAWSCOREDATA. This is a square matrix with as many rows and columns as
%       variables (audio samples) are in the observations. The values are 
%       single-precision.
%
%  CONSIDERATIONS & LIMITATIONS
%  - With typical sampling rates and signal durations, the covariance matrix 
%    can reach sizes of several GigaBytes. For the covariance matrix to be
%    manageable, it shouldn't contain more than 10,000 variables (10,000 x 
%    10,000 dimension) for it to have a size of 381 MB or less. For larger 
%    dimensions the time required for computing the eigenstructure increases 
%    dramatically. That is why the estimator correlator, the statistical 
%    detection method that uses the covariance matrix, is limited to low-
%    frequency signals or short durations. In practice, this method works with
%    most underwater sounds due to an acceptable balance between bandwidth and
%    duration (e.g., 500 ms - 20 kHz for airgun pulses, 50 ms - 200 kHz for 
%    sparkers and sub-bottom profilers, 20 ms - 500 kHz for echosounders). 
%    COVARIANCE automatically limits the number of variables to 10,000.
%
%  FUNCTION DEPENDENCIES
%  - covOas
%  - covRblw
%  - covParam1
%  - covParam2
%  - covCorr
%  - covDiag
%  - covStock
%  - covLooc
%
%  FUNCTION CALL
%  1. covariance(RawScoreData)
%  2. covariance(...,PROPERTY,VALUE)
%     PROPERTIES: 'Duration', 'SampleRate', 'DigitalFilter', 'FilterMode',
%        'Estimator','DisplayProgress'
%
%  REFERENCES
%  - Chen, Y; Wiesel, A.; Eldar, Y.C.; Hero, A.O. (2010). "Shrinkage 
%    algorithms for MMSE covariance estimation", IEEE Transactions and
%    Signal Processing, 58(10).
%  - Ledoit, O., & Wolf, M. (2004). "A well-conditioned estimator for 
%    large-dimensional covariance matrices", Journal of Multivariate
%    analysis, 88, p. 365-411.
%  - Ledoit, O., & Wolf, M. (2003). "Honey, I shrunk the sample covariance
%    matrix", Journal of Portfolio Management, 30(4), 100-119.
%    https://doi.org/10.3905/jpm.2004.110
%  - Ledoit, O., & Wolf, M. (2001). "Improved estimation of the covariance
%    matrix of stock returns wit an application to portfolio selection",
%    Journal of Empirical Finance, 10(5), p. 603-621.
%    https://doi.org/10.1016/S0927-5398(03)00007-0
%  - Theiler, J (2012). "The incredible shrinking covariance estimator", 
%    Proceedings Volume 8391 of SPIE Defense, Security and Sensing - 
%    Automated Target Recognition XXII, 23-27 April 2012.

%  VERSION 3.0
%  Date: 04 Mar 2022
%  Author: Guillermo Jimenez Arranz
%  - Added property 'FilterMode'.
%  - Added property 'Estimator'.
%
%  VERSION 2.0
%  Date: 07 Sep 2021
%  Author: Guillermo Jimenez Arranz
%  - The original function COVARIANCE is now split into functions COVARIANCE
%    and RAWSCORES. COVARIANCE can do the relatively fast job of computing the 
%    covariance matrix from the matrix of raw scores, and then used to apply 
%    any additional resampling, filtering or trimming if needed.
%
%  VERSION 1.0
%  Date: 04 May 2021
%  Author: Guillermo Jimenez Arranz
%  Email: gjarranz@gmail.com

function CovarianceData = covariance(RawScoreData,varargin)

% INPUT ARGUMENTS
% Verify number of Input Arguments
nFixArg = 1;
nProArg = 12;
narginchk(nFixArg,nFixArg + nProArg)
if rem(nargin - nFixArg,2)
    error('Variable input arguments must come in pairs (PROPERTY,VALUE)')
end

% Extract and Verify Input Properties
validProperties = {'duration','samplerate','digitalfilter','filtermode',...
    'estimator','displayprogress'};
properties = lower(varargin(1:2:end));
if any(~ismember(properties,validProperties))
    error('One or more input properties are not recognised')
end

% Default Input Values
warnFlag = false;
kernelDuration = [];
sampleRate = [];
DigitalFilter = [];
filtMode = 'filter';
estimator = 'sample';
displayProgress = false;

% Extract and Verify Input Values
values = varargin(2:2:end);
nPairs = (nargin - nFixArg)/2; % number of (PROPERTY,VALUE) pairs
for m = 1:nPairs
    property = properties{m};
    switch property % populate with more properties if needed
        case 'duration'
            kernelDuration = values{m};
            if ~isempty(kernelDuration) && (~isnumeric(kernelDuration) ...
                    || kernelDuration < 0)
                kernelDuration = [];
                warning(['Non-supported value for PROPERTY = '...
                    '''Duration''. A value of [] will be used'])
            end
        case 'samplerate'
            sampleRate = values{m};
            if ~isempty(sampleRate) && (~isnumeric(sampleRate) ...
                    || sampleRate < 0)
                sampleRate = [];
                warning(['Non-supported value for PROPERTY = '...
                    '''SampleRate''. No resampling will be applied'])
            end
        case 'digitalfilter'
            DigitalFilter = values{m};
            if ~isempty(DigitalFilter) && ~isDigitalSingleFilter(DigitalFilter)
                DigitalFilter = [];
                warning(['Input value for PROPERTY = ''DigitalFilter'' '...
                    'is not a valid Digital Filter generated with '...
                    'digitalSingleFilterDesign.m. No filtering will be '...
                    'applied'])
            end
        case 'filtermode'
            filtMode = values{m};
            if ~ischar(filtMode) || ~ismember(filtMode,{'filter','filtfilt'})
                filtMode = 'filter';
                warning(['Non-supported value for PROPERTY = '...
                    '''FilterMode''. ''FilterMode'' = %s will be used'],...
                    filtMode)
            end
        case 'estimator'
            estimator = values{m};
            if ischar(estimator)
                estimator = lower(estimator);
                if ~ismember(estimator,{'oas','rblw','param1','param2',...
                        'corr','diag','stock','looc','sample'})
                    estimator = 'sample';
                    warning(['Non-supported character vector for ESTIMATOR. '...
                        'ESTIMATOR = ''%s'' will be used'],estimator)
                end
            else
                estimator = 'sample';
                warning(['ESTIMATOR must be a character vector. ESTIMATOR '...
                    '= ''%s'' will be used'],estimator)
            end
        case 'displayprogress'
            displayProgress = values{m};
            if ~islogical(displayProgress) && ~any(displayProgress == [0 1])
                displayProgress = 0;
                warning(['Non-supported value for PROPERTY = '...
                    '''DisplayProgress''. A value of 0 will be used'])
            end
    end
end

% Error Control: RawScoreData
if ~isRawScoreData(RawScoreData)
    warning('RAWSCOREDATA is not a valid raw scores data structure')
end

% Set Resampling Rate if FR = []
if isempty(sampleRate)
    sampleRate = RawScoreData.sampleRate;
end
if sampleRate > RawScoreData.sampleRate
    warning(['SAMPLERATE is larger than the sampling rate of the matrix '...
        'of raw scores. This may lead to an inaccurate performance of '...
        'the detector. Using SAMPLERATE <= %0.0f is recommended.'],...
        RawScoreData.sampleRate)
end

% Set Duration if DURATION = []
if isempty(kernelDuration)
    kernelDuration = RawScoreData.kernelDuration;
end

% Error Control: Duration of Observation
if kernelDuration > RawScoreData.kernelDuration
    kernelDuration = RawScoreData.kernelDuration;
    warning(['DURATION cannot be larger than the duration of the '...
        'observations in the matrix of raw scores. DURATION = %0.1e '...
        's will be used'],RawScoreData.kernelDuration);
end
    
% Error Control: Size of Covariance Matrix
kernelLength = round(kernelDuration*sampleRate); % number of samples for resampled signal
if kernelLength > 1e4
    warnFlag = true;
    warning(['The number of variables in the covariance matrix is too '...
        'large (limited to DURATION * SAMPLERATE = 10,000). Try reducing '...
        'DURATION and/or SAMPLERATE']) 
end

% Error Control: Empty Raw Score Matrix
if isempty(RawScoreData.rawScoreMatrix)
    warnFlag = true;
    warning(['The matrix of raw scores in RAWSCOREDATA is empty. The '...
        'covariance matrix cannot be computed'])
end  

% Recalculate Matrix of Raw Scores (resample and filter)
CovarianceData = []; % initialise covariance data structure
if ~warnFlag
    % Display Progress (open)
    if displayProgress
        h = waitbar(0,'','Name','covariance.m'); 
    end
       
    % Resample Matrix of Raw Scores
    nTests = size(RawScoreData.rawScoreMatrix,1); % number of observations
    k = gcd(RawScoreData.sampleRate,sampleRate);
    P = sampleRate/k; % upsampling factor
    Q = RawScoreData.sampleRate/k; % downsampling factor
    X = nan(nTests,kernelLength); % matrix of raw scores (filtered)
    for m = 1:nTests
        [x,b] = resample(double(RawScoreData.rawScoreMatrix(m,:)),P,Q); % resample observation
        x = x(1:kernelLength); % trim observation to fixed duration
        X(m,:) = x/std(x); % matrix of raw scores

        % Display Progress (if applicable)
        if displayProgress
            messageString = sprintf('Resampling raw scores (%d/%d)',m,nTests);
            waitbar(m/nTests,h,messageString);
        end
    end
    
    % Display Progress (close)
    if displayProgress, close(h); end
   
    % Filter Matrix of Raw Scores
    nFilters = numel(DigitalFilter);
    for m = 1:nTests
        for n = 1:nFilters
            x = digitalSingleFilter(DigitalFilter(n),X(m,:),...
                'MetricsOutput',false,'FilterMode',filtMode,'DataWrap',true);
            X(m,:) = x/std(x); % matrix of raw scores
        end
    end
    
    % Initialise Covariance Matrix
    CovarianceData = initialiseCovarianceData();
    
    % Estimate Covariance Matrix
    switch estimator
        case 'oas'
            CovarianceData.covarianceMatrix = covOas(X);
   
        case 'rblw'
            CovarianceData.covarianceMatrix = covRblw(X);
            
        case 'param1'
            CovarianceData.covarianceMatrix = covParam1(X);
            
        case 'param2'
            CovarianceData.covarianceMatrix = covParam2(X);
            
        case 'corr'
            CovarianceData.covarianceMatrix = covCorr(X);
            
        case 'diag'
            CovarianceData.covarianceMatrix = covDiag(X);
           
        case 'stock'
            CovarianceData.covarianceMatrix = covStock(X);
            
        case 'looc'
            % Design Lowpass Filter (from RESAMPLERATE)
            nPoints = round(50 * P*RawScoreData.sampleRate/sampleRate); % 50 points within SAMPLERATE/2
            [lpfResp0,f0] = freqz(b,1,nPoints,P*RawScoreData.sampleRate);
            f = (0:nPoints)/nPoints * sampleRate/2;
            lpfResp = interp1(f0,abs(lpfResp0)/P,f,'linear','extrap');   
            LowPassFilter = designfilt('arbmagfir','FilterOrder',30,...
                'Frequencies',f,'Amplitudes',lpfResp,'SampleRate',sampleRate);
    
            % Compute Target and Estimated Covariance Matrices
            F = targetCovariance(kernelLength,DigitalFilter,...
                'LowPassFilter',LowPassFilter,'FilterMode',filtMode,...
                'DisplayProgress',displayProgress); % based on filtered WGN (var = 1) 
            CovarianceData.covarianceMatrix = covLooc(X,'ShrinkTarget',F,...
                'ShrinkMethod','interp','DisplayProgress',displayProgress); % covariance estimate
                        
        case 'sample'
            X_mean = mean(X); % vector of means
            X = X - X_mean; % deviation scores matrix
            CovarianceData.covarianceMatrix = (X'*X)/nTests; % sample covariance matrix
    end
    
    % Mean Variance
    meanVar = mean(diag(CovarianceData.covarianceMatrix));
            
    % Build COVARIANCEDATA Structure
    CovarianceData.kernelDuration = kernelDuration;
    CovarianceData.sampleRate = sampleRate;
    CovarianceData.covarianceMatrix = CovarianceData.covarianceMatrix/meanVar;
end
