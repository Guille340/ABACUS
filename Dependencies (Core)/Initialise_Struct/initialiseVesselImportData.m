%  VesImpData = INITIALISEVESSELIMPORTDATA()
%
%  DESCRIPTION
%  Initialises the vessel import data structure VESIMPDATA. All the fields in 
%  this structure are set as empty ([]).
%
%  The fields in VESIMPDATA are described below.
%
%  VESIMPDATA
%  ==========
%  - positionPaths: absolute paths of the vessel position files.
%  - pcTick: vector of PC times of registered position sentences. Not available 
%    on P190 files (RECEIVERFORMAT = 'p190').
%  - utcTick: vector of UTC times of registered position sentences.
%  - latitude: vessel latitude, in degrees. May refer to the towing platform
%    or vessel itself (no horizontal offset correction applied).
%  - longitude: vessel longitude, in degrees. May refer to the towing 
%    platform or vessel itself (no horizontal offset correction applied).
%  - depth: depth of the vessel, in metres. For vessels, DEPTH = [].
%
%  INPUT ARGUMENTS
%  - None
%
%  OUTPUT ARGUMENTS
%  - VesImpData: initialised vessel import data structure.
%
%  FUNCTION CALL
%  VesImpData = initialiseVesselImportData()
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

function VesImpData = initialiseVesselImportData()

VesImpData = struct('positionPaths',[],'pcTick',[],'utcTick',[],...
    'latitude',[],'longitude',[],'depth',[]);
