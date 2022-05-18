%  NavProConfig = INITIALISENAVIGATIONPROCESSCONFIG()
%
%  DESCRIPTION
%  Initialises the navigation process configuration structure NAVPROCONFIG. All 
%  the fields in this structure are set as empty ([]).
%
%  The fields in NAVPROCONFIG are described below.
%
%  NAVPROCONFIG
%  ============
%  - inputStatus: TRUE if the navigation process configuration is valid. This 
%    field is updated by function VERIFYNAVIGATIONPROCESSCONFIG.
%  - configFileName: name of the navigation process configuration file from 
%    which NAVPROCONFIG comes from.
%  - channel: channel to import and resample.
%  - resampleRate: sampling rate after resampling [Hz]
%  - receiverName: name of the receiver to be processed.
%  - sourceName: name of the primary source to be processed.
%  - smoothWindow: time window used for averaging position information,
%    in seconds. Using a SMOOTHWINDOW of several seconds will help improve the 
%    accuracy of the navigation parameters. The slower the platform, the longer 
%    the averaging period (recommended 10-30 s).
%  - maxTimeGap: maximum time interval, in seconds, between two consecutive 
%    sentences for applying spatial interpolation to a sound event detected 
%    within that period. If the period exceeds MAXTIMEGAP and a sound event is 
%    detected within it, the navigation parameters for that sound event are 
%    set to NaN.
%  - interpMethod: interpolation method used for calculating the position
%    of a detected sound event. See INTERP1 for available methods.
%
%  INPUT ARGUMENTS
%  - None
%
%  OUTPUT ARGUMENTS
%  - NavProConfig: initialised navigation process configuration structure.
%
%  FUNCTION CALL
%  NavProConfig = initialiseNavigationProcessConfig()
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  18 Jun 2021


function NavProConfig = initialiseNavigationProcessConfig()

NavProConfig = struct('inputStatus',[],'configFileName',[],...
'channel',[],'resampleRate',[],'receiverName',[],'sourceName',[],...
'smoothWindow',[],'maxTimeGap',[],'interpMethod',[]);
