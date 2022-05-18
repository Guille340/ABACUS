%  SouProData = INITIALISESOURCEPROCESSDATA()
%
%  DESCRIPTION
%  Initialises the source process data structure SOUPRODATA. All the fields 
%  in this structure are set as empty ([]).
%
%  The fields in SOUPRODATA are described below.
%
%  SOUPRODATA
%  =========== 
%  - pcTick: vector of PC ticks, in seconds referred to '00 Jan 0000'.
%  - utcTick: vector of UTC ticks, in seconds referred to '00 Jan 0000'.
%  - latitude: vector of source latitudes, in degrees.
%  - longitude: vector of source longitudes, in degrees.
%  - depth: source depth, in metres.
%  - course: vector of source courses, in degrees (0 N, 90 E)
%  - speed: vector of source speeds, in m/s.
%  - sou2recDistance: source to receiver distance, in metres.
%  - sou2recBearing: source to receiver bearing, in degrees (0 N, 90 E)
%  - sourceHeading: source heading, in degress (0 N, 90 E)
%  - sourceEmitAngle: source directivity angle, in degrees (0 N, 90 E)
%
%  INPUT ARGUMENTS
%  - None
%
%  OUTPUT ARGUMENTS
%  - SouProData: initialised source process data structure.
%
%  FUNCTION CALL
%  SouProData = initialiseSourceProcessData()
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

function SouProData = initialiseSourceProcessData()

SouProData = struct('pcTick',[],'utcTick',[],'latitude',[],'longitude',[],...
    'depth',[],'course',[],'speed',[],'sou2recDistance',[],...
    'sou2recBearing',[],'sourceHeading',[],'sourceEmitAngle',[]);
