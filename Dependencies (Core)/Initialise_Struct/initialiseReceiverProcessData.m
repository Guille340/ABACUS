%  RecProData = INITIALISERECEIVERPROCESSDATA()
%
%  DESCRIPTION
%  Initialises the receiver process data structure RECPRODATA. All the fields 
%  in this structure are set as empty ([]).
%
%  The fields in RECPRODATA are described below.
%
%  AUDPRODATA
%  =========== 
%  - pcTick: vector of PC ticks, in seconds referred to '00 Jan 0000'.
%  - utcTick: vector of UTC ticks, in seconds referred to '00 Jan 0000'.
%  - latitude: vector of receiver latitudes, in degrees.
%  - longitude: vector of receiver longitudes, in degrees.
%  - depth: receiver depth, in metres.
%  - course: vector of receiver courses, in degrees (0 N, 90 E)
%  - speed: vector of receiver speeds, in m/s.
%
%  INPUT ARGUMENTS
%  - None
%
%  OUTPUT ARGUMENTS
%  - RecProData: initialised receiver process data structure.
%
%  FUNCTION CALL
%  RecProData = initialiseReceiverProcessData()
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

function RecProData = initialiseReceiverProcessData()

RecProData = struct('pcTick',[],'utcTick',[],'latitude',[],'longitude',[],...
    'depth',[],'course',[],'speed',[]);
