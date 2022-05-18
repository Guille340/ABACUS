%  PerformanceData = initialisePerformanceData()
%
%  DESCRIPTION
%  Initialises the performance data structure PERFORMANCEDATA. All the fields 
%  in this structure are set as empty ([]). Function CHARACTERISEPERFORMANCE
%  generates a populated version of PERFORMANCEDATA (i.e., with non-empty 
%  values).
%
%  The fields in PERFORMANCEDATA are described below.
%
%  PERFORMANCEDATA
%  ===============
%  - detectorType: character vector specifying the type of Neyman-Pearson 
%    detector. There are three options:
%    ¬ 'ed': energy detector. The signal and background noise are assumed to 
%       be White Gaussian Noise (WGN) processes.
%    ¬ 'ecw': estimator-correlator in white Gaussian noise. The signal is 
%       characterised by its covariance matrix and the background noise is 
%       considered a White Gaussian Noise (WGN) process.
%    ¬ 'ecc': estimator-correlator in coloured Gaussian noise. The signal and 
%       the noise are characterised by their respective covariance matrices. 
%       The background noise is a Coloured Gaussian Noise (CGN) process.
%  - signalVariance: variance of the signal.
%  - noiseVariance: variance of the background noise.
%  - snrLevel: selected SNR given by 10*log10(signalVariance/noiseVariance)
%  - nVariables: number of variables (samples) in the data segment (= NDOF).
%  - cutoffFreqns: two-element vector with the normalised cutoff frequencies 
%    of the detection filter. The values must be between 0 and 1. cutoffFreqns
%    = 2*cutoffFreqs/ resampleRate, where cutoffFreqs and resampleRate are 
%    fields in the configuration file audioDetectConfig_NeymanPearson.json. 
%  - axisFalseAlarm: test-statistic axis for pdfFalseAlarm and rtpFalseAlarm.
%  - axisDetection: test-statistic axis for pdfDetection and rtpDetection.
%  - pdfFalseAlarm: null hypothesis probability density function (PDF).
%  - pdfDetection: alternative hypothesis probability density function (PDF).
%  - rtpFalseAlarm: false alarm right-tail probability (RTP) function.
%  - rtpDetection: detection right-tail probability (RTP) function.
%
%  INPUT ARGUMENTS
%  - None
%
%  OUTPUT ARGUMENTS
%  - PerformanceData: initialised performance data structure
%
%  FUNCTION CALL
%  PerformanceData = initialisePerformanceData()
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  02 Mar 2022

function PerformanceData = initialisePerformanceData()

PerformanceData = struct('detectorType',[],'signalVariance',[],...
    'noiseVariance',[],'snrLevel',[],'nVariables',[],'cutoffFreqns',[],...
    'axisFalseAlarm',[],'axisDetection',[],'pdfFalseAlarm',[],...
    'pdfDetection',[],'rtpFalseAlarm',[],'rtpDetection',[]);
