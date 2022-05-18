%  NAVIGATIONPROCESSCONFIG (Script)
%
%  DESCRIPTION
%  Input configuration script for the navigation processing stage.
%
%  This script is updated manually and read by READNAVIGATIONPROCESSCONFIG 
%  to create a structure NAVPROCONFIGFILE that is used to populate a full 
%  navigation process configuration structure NAVPROCONFIG. The latter is 
%  used by NAVIGATIONPROCESSFUN to process the navigation parameters for
%  the receiver and sources at each detected sound event using the position
%  and descriptive information stored in the Navigation Database (.mat) 
%  in '<ROOTDIR>\navigationdb\navigationdb*.json'.
%
%  Navigation process configuration scripts must follow the naming convention
%  'navigationProcessConfig<CHAR>_<NUM>.json', where <CHAR> is a character 
%  vector and <NUM> is a number indicating the reading and processing order 
%  for the configuration files (e.g. navigationProcessConfig_TK_CH1_01). 
%
%  Create as many NAVIGATIONPROCESSCONFIG scripts as RECEIVERNAME/SOURCENAME 
%  combinations you wish to process. Configuration scripts must be saved 
%  in directory '<ROOTDIR>/configdb' for the software to be able to find 
%  and run them. 
%
%  INPUT FIELDS
%  - receiverName: name of the receiver to be processed.
%  - sourceName: name of the primary source to be processed.
%  - 'smoothWindow': time window used for averaging position information,
%    in seconds. Position sentences are recorded at a typical rate of one 
%    sentence per second. Using a SMOOTHWINDOW of several seconds will 
%    help improve the accuracy of the navigation parameters. The slower the 
%    platform, the longer the averaging period. Typical values lie within 
%    10 and 30 seconds.
%  - 'maxTimeGap': maximum time interval, in seconds, between two consecutive 
%    sentences for applying spatial interpolation to a sound event detected 
%    within that period. If the period exceeds MAXTIMEGAP and a sound event is 
%    detected within it, the navigation parameters for that sound event are 
%    set to NaN.
%  - 'interpMethod': interpolation method used for calculating the position
%    of a detected sound event. See INTERP1 for available methods.
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
%  See also READNAVIGATIONPROCESSCONFIG

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  19 Jul 2021

NavProConfigFile.receiverName = '';
NavProConfigFile.sourceName = '';
NavProConfigFile.smoothWindow = [];
NavProConfigFile.maxTimeGap = [];
NavProConfigFile.interpMethod = '';
