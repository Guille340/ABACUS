%  AUDIODETECTCONFIG (Script, detection algorithm 'NeymanPearson')
%
%  DESCRIPTION
%  Input configuration script for the detection stage using a 'NeymanPearson' 
%  detection algorithm. The 'NeymanPearson' detector comprises three types of
%  detector: and Energy Detector ('ed'), the Estimator-Correlator in White
%  Gaussian Noise ('ecw'), and the Estimator-Correlator in Coloured Gaussian
%  Noise 'ecc'). A processed segment is classified as "detection" if the 
%  computed test statistic exceeds the computed threshold. The 'ed', 'ecw' and 
%  'ecc' options calculate the threshold and test statistic in different ways. 
%  The Energy Detector is the simplest of the three as it assumes that both 
%  background noise and target signal are White Gaussian (WGN,WGS) processes.
%  The Estimator-Correlator is a more complex detector that characterises the 
%  target signal by its covariance matrix and assumes that the background noise 
%  is either a white ('ecw') or coloured ('ecc') Gaussian process. The 
%  Estimator Correlator "estimates" the signal from previously known 
%  information (covariance matrix, signal variance, noise variance) and
%  "correlates" the result with the segment to be classified, hence its name.
%  The signal is pre-whitened for the case of the Estimator-Correlator in CGN.
%
%  For the calculation of the threshold, both detectors analyse in advance the 
%  performance of the detector. The performance can be characterised by the
%  the probability functions of detection and false alarm. A target probability
%  of false alarm is then used to infer the threshold from the probability of
%  false alarm curve. A sensitivity parameter has been added to control the 
%  sensitivity of the detectors. A lower sensitivity value scales ("expands")
%  the probability of false alarm curve to artificially increase the detection
%  threshold (note that this is a test feature and will modify the natural
%  behaviour of the detectors). The Energy Detector computes the performance 
%  curves (PDF of null and alternative hypotheses, and probability functions of
%  false alarm and detection) directly from a non-central Chi-squared function 
%  given the length of the segment to be processed, its mean value and the 
%  signal-to-noise ratio. The Estimator-Correlator is a more complex detector 
%  and requires the eigendata from the covariance matrices of the signal 
% ('ecw') or signal and noise ('ecc'), and the variance of the signal and noise
%  to estimate the PDF and PF.
%
%  For the calculation of the test statistic, the three detectors use a fairly
%  different approach. In the Energy Detector, the test statistic is simply the 
%  sum of the squared amplitudes of the samples in the segment to be processed.
%  In the Estimator-Correlators, the samples in a decorrelated version of the 
%  segment are squared, weighted and summed to obtain the test statistic.
%
%  The detector also includes an optional bandpass filter to increase the noise 
%  rejection and improve the probability of detection. A minimum SNR can also
%  be set to discard any potential detections of signals with low SNR. Defining
%  a lower SNR limit is reasonable considering that the metrics (RMS, SEL) of 
%  target signals with a SNR below -10 dB cannot be accurately quantified due 
%  to large uncertainties.
%
%  The NP detectors are aimed at any sources with any signal-to-noise ratio 
%  (e.g. anything from low-energy continuous noise such as vessels to high-
%  energy transient noise such as pulses from seismic airguns and piling).
%
%  This script is updated manually and read by READAUDIODETECTCONFIG to create 
%  a structure AUDDETCONFIGFILE that is used to populate a full audio detect 
%  configuration structure AUDDETCONFIG. The latter is used by AUDIODETECTFUN 
%  to detect "sound events" from the audio files listed in '<ROOT.BLOCK>\
%  configdb\audioPaths.json' and save the results into individual Acoustic 
%  Databases (.mat), stored in '<ROOT.BLOCK>/acousticdb'.
%
%  Audio detect configuration scripts must follow the naming convention
%  'audioDetectConfig<CHAR>_<NUM>.json', where <CHAR> is a character vector 
%  and <NUM> is a number indicating the reading and processing order for the 
%  configuration files (e.g. acousticDetectConfig_TK_CH1_01). 
%
%  Create as many AUDIODETECTCONFIG scripts as RECEIVERNAME/SOURCENAME 
%  combinations you wish to process. Configuration scripts must be saved in 
%  directory '<ROOT.BLOCK>/configdb' for the software to be able to find and run 
%  them. 
%
%  INPUT FIELDS
%  - receiverName: name of the receiver to be processed.
%  - sourceName: name of the primary source to be processed.
%  - detector: character vector specifying the detection algorithm 
%    ('NeymanPearson' for this template).
%  - DetectParameters: structure containing the detection parameters specific 
%    for the selected algorithm. For DETECTOR = 'MovingAverage' this structure 
%    contains the following fields:
%    ¬ detectorType: type of detector ('ed' for Energy Detector, 'ecw' for
%      Estimator-Correlator in White Gaussian Noise, and 'ecc' for Estimator-
%      Correlator in Coloured Gaussian Noise).
%    ¬ kernelDuration: duration of the detection sub-window, in seconds. 
%      Note that the audio file is split into segments of KERNELDURATION to be 
%      processed for detections. Segments of WINDOWDURATION simply group the
%      results from the sub-windows of KERNELDURATION. 
%    ¬ windowDuration: duration of the detection window, in seconds.
%      Set it to fit the entire signal to be processed (long enough to
%      accomodate the longest signal duration, but as short as possible to
%      minimise background noise contribution).
%    ¬ windowOffset: backward displacement of the front window, in seconds, 
%      relative to the time where the maximum energy of the detection occurs. 
%      Must be a value between 0 and WINDOWDURATION. For best results, use a 
%      value between 0 and WINDOWDURATION/2. Set as [] for no window adjustement.
%    ¬ rtpFalseAlarm: target probability of false alarm.
%    ¬ detectorSensitivity: sensitivity of the detector. This is a value
%      between 0 (target rtp = detection probability of 0.99999) and 1 (target 
%      rtp = RTPFALSEALARM). 
%    ¬ minSnrLevel: minimum signal-to-noise ratio to consider for detections.
%    ¬ cutoffFreqs: two-element numeric array specifying cutoff frequencies 
%      of the detection bandpass filter.
%    ¬ trainFolder: directory containing the audio segments to be used to build
%      the matrices of raw scores. The training data for the signal and noise 
%      is stored in "*\trainFolder\signal" and "*\trainFolder\noise".
%    ¬ estimator: covariance matrix estimator. There are 9 options available.
%      # 'oas': Oracle Approximating Shrinkage (OAS) method from Chen et al. 
%        (2010). See covOas.m for details.
%      # 'rblw': Rao-BlackWell Ledoit-Wolf (RBLW) method from Chen et al. 
%        (2010). See covRblw.m for details.
%      # 'param1': One-parameter method from Ledoit & Wolf (2004). See 
%         covParam1.m for details.
%      # 'param2': Two-parameter method from Ledoit. See covParam2.m for 
%         details.
%      # 'corr': correlation method from Ledoit & Wolf (2003). See covCorr.m
%         for details.
%      # 'diag': diagonal shrinkage target method from Ledoit. See covDiag.m
%         for details.
%      # 'stock': method for portfolio optimisation from Ledoit & Wolf (2001). 
%         See covStock.m for details.
%      # 'looc': Leave-One-Out Covariance (LOOC) method from Theiler (2012).
%         See covLooc.m for details.
%      # 'sample': sample covariance matrix.
%    ¬ resampleRate: sampling rate of the covariance and eigen matrices, in
%      Hz. The segment to be processed will be resampled to this sampling rate.
%
%  SCRIPT DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - None
%
%  CONSIDERATIONS & LIMITATIONS
%  - This configuration script is now implemented as .json files. The .m
%    format is now obsolete (this help is still applicable and a useful
%    reference).
%
%  See also READAUDIOPROCESSCONFIG, AUDIOPROCESSFUN

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  16 Jul 2021

AudDetConfigFile.receiverName = '';
AudDetConfigFile.sourceName = '';
AudDetConfigFile.detector = 'NeymanPearson';
AudDetConfigFile.DetectParameters.detectorType = [];
AudDetConfigFile.DetectParameters.kernelDuration = [];
AudDetConfigFile.DetectParameters.windowDuration = [];
AudDetConfigFile.DetectParameters.windowOffset = [];
AudDetConfigFile.DetectParameters.rtpFalseAlarm = [];
AudDetConfigFile.DetectParameters.detectorSensitivity = [];
AudDetConfigFile.DetectParameters.minSnrLevel = [];
AudDetConfigFile.DetectParameters.cutoffFreqs = [];
AudDetConfigFile.DetectParameters.trainFolder = [];
AudDetConfigFile.DetectParameters.estimator = [];
AudDetConfigFile.DetectParameters.resampleRate = [];
