%  AUDIODETECTCONFIG (Script, detection algorithm 'MovingAverage')
%
%  DESCRIPTION
%  Input configuration script for the detection stage using a 'MovingAverage' 
%  detection algorithm. The 'MovingAverage' detector uses two consecutive
%  windows that move across the file processing the RMS values of the
%  their windowed segments. When the front ("signal") window has an RMS value
%  higher than the RMS on the back ("noise") window by a specific number of
%  times (DETECTRATIO), the segment enclosed by the front window is 
%  classified as a detection. The detector also includes an optional bandpass
%  filter to increase the noise rejection and improve the probability of
%  detection. This method is aimed at transient sources with good signal-to
%  -noise ratio (e.g. seismic airguns or piling).
%
%  This script is updated manually and read by READAUDIODETECTCONFIG to create 
%  a structure AUDDETCONFIGFILE that is used to populate a full audio detect 
%  configuration structure AUDDETCONFIG. The latter is used by AUDIODETECTFUN 
%  to detect "sound events" from the audio files listed in '<ROOTDIR>\configdb\
%  audioPaths.json' and save the results into individual Acoustic Databases 
%  (.mat), stored in '<ROOTDIR>/acousticdb'.
%
%  Audio detect configuration scripts must follow the naming convention
%  'audioDetectConfig<CHAR>_<NUM>.json', where <CHAR> is a character vector 
%  and <NUM> is a number indicating the reading and processing order for the 
%  configuration files (e.g. acousticDetectConfig_TK_CH1_01). 
%
%  Create as many AUDIODETECTCONFIG scripts as RECEIVERNAME/SOURCENAME 
%  combinations you wish to process. Configuration scripts must be saved in 
%  directory '<ROOTDIR>/configdb' for the software to be able to find and run 
%  them. 
%
%  INPUT FIELDS
%  - receiverName: name of the receiver to be processed.
%  - sourceName: name of the primary source to be processed.
%  - detector: character vector specifying the detection algorithm 
%    ('MovingAverage' for this template).
%  - DetectParameters: structure containing the detection parameters specific 
%    for the selected algorithm. For DETECTOR = 'MovingAverage' this structure 
%    contains the following fields:
%    ¬ windowDuration: duration of the detection window, in seconds.
%      Set it to fit the entire signal to be processed (long enough to
%      accomodate the longest signal duration, but as short as possible to
%      minimise background noise contribution). This same duration is applied 
%      to the front (signal) and the back (noise) windows.
%    ¬ windowOffset: backward displacement of the front window, in seconds, 
%      relative to the time where the maximum energy of the detection occurs. 
%      Must be a value between 0 and WINDOWDURATION. For best results, use a 
%      value between 0 and WINDOWDURATION/2. Set as [] for no window adjustement.
%    ¬ threshold: minimum RMS ratio between the front and back window for 
%      the front windowed segment to be classified as a detection. Note that 
%      low values have a higher risk of false detections and high values have
%      a higher risk of misses. Values between 1.2 (1.5 dB) and 2 (6 dB) 
%      generally work well. Always inspect the audio files to get an idea 
%      of what threshold may work. If usure, use THRESHOLD = [] for automatic 
%      thresholding.
%    ¬ cutoffFreqs: two-element numeric array specifying cutoff frequencies 
%      of the detection bandpass filter.
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
AudDetConfigFile.detector = 'MovingAverage';
AudDetConfigFile.DetectParameters.windowDuration = [];
AudDetConfigFile.DetectParameters.windowOffset = [];
AudDetConfigFile.DetectParameters.threshold = [];
AudDetConfigFile.DetectParameters.cutoffFreqs = [];
