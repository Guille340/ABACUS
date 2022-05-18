%  SouImpData = INITIALISESOURCEIMPORTDATA()
%
%  DESCRIPTION
%  Initialises the source import data structure SOUIMPDATA. All the fields in 
%  this structure are set as empty ([]).
%
%  The fields in SOUIMPDATA are described below.
%
%  SOUIMPDATA
%  ==========
%  - positionPaths: absolute paths of the source position files.
%  - pcTick: vector of PC times of registered position sentences. Not available 
%    on P190 files (RECEIVERFORMAT = 'p190').
%  - utcTick: vector of UTC times of registered position sentences.
%  - latitude: source latitude, in degrees. May refer to the towing platform
%    or source itself (no horizontal offset correction applied).
%  - longitude: source longitude, in degrees. May refer to the towing 
%    platform or source itself (no horizontal offset correction applied).
%  - depth: depth of the source, in metres. DEPTH is a negative value.
%    Currently, this parameter can only be set as a constant value.
%
%  INPUT ARGUMENTS
%  - None
%
%  OUTPUT ARGUMENTS
%  - SouImpData: initialised source import data structure.
%
%  FUNCTION CALL
%  SouImpData = initialiseSourceImportData()
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

function SouImpData = initialiseSourceImportData()

SouImpData = struct('positionPaths',[],'pcTick',[],'utcTick',[],...
    'latitude',[],'longitude',[],'depth',[]);
