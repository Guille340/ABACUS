%  VesProData = INITIALISEVESSELPROCESSDATA()
%
%  DESCRIPTION
%  Initialises the vessel process data structure VESPRODATA. All the fields 
%  in this structure are set as empty ([]).
%
%  The fields in VESPRODATA are described below. The structure is identical
%  to SOUPRODATA.
%
%  AUDPRODATA
%  =========== 
%  - pcTick: vector of PC ticks, in seconds referred to '00 Jan 0000'.
%  - utcTick: vector of UTC ticks, in seconds referred to '00 Jan 0000'.
%  - latitude: vector of vessel latitudes, in degrees.
%  - longitude: vector of vessel longitudes, in degrees.
%  - depth: vessel depth, in metres. For vessels, DEPTH = [].
%  - course: vector of vessel courses, in degrees (0 N, 90 E)
%  - speed: vector of vessel speeds, in m/s.
%  - sou2recDistance: vessel to receiver distance, in metres.
%  - sou2recBearing: vessel to receiver bearing, in degrees (0 N, 90 E)
%  - sourceHeading: vessel heading, in degress (0 N, 90 E)
%  - sourceEmitAngle: vessel directivity angle, in degrees (0 N, 90 E)
%
%  INPUT ARGUMENTS
%  - None
%
%  OUTPUT ARGUMENTS
%  - VesProData: initialised source process data structure.
%
%  FUNCTION CALL
%  VesProData = initialiseVesselProcessData()
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

function SouProData = initialiseVesselProcessData()

SouProData = struct('pcTick',[],'utcTick',[],'latitude',[],'longitude',[],...
    'depth',[],'course',[],'speed',[],'sou2recDistance',[],...
    'sou2recBearing',[],'sourceHeading',[],'sourceEmitAngle',[]);
