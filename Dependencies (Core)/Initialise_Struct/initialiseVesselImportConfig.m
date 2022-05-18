%  VesImpConfig = INITIALISEVESSELIMPORTCONFIG()
%
%  DESCRIPTION
%  Initialises the vessel import configuration structure VESIMPCONFIG. All 
%  the fields in this structure are set as empty ([]).
%
%  The fields in VESIMPCONFIG are described below. The structure is identical
%  to SOUIMPCONFIG
%
%  VESIMPCONFIG
%  ============
%  - inputStatus: TRUE if the source import configuration is valid. This 
%    field is updated by function VERIFYSOURCEIMPORTCONFIG.
%  - configFileName: name of the source import configuration file from 
%    which VESIMPCONFIG comes from.
%  - sourceCategory: category of the source. The category indicates
%    the software what type of information is necessary to process the
%    source. For the vessel configuration files this is always 'fleet'.
%  - sourceName: name of the source. This is used as a unique identifier.
%  - sourceOffset: two-element numeric array (x,y) representing the position 
%    of the source, in metres, relative to the position of the towinig platform 
%    for which position data is available. For vessels, SOURCEOFFSET = [0 0].
%  - sourceOffsetMode: character vector indicating the nature of the physical
%    connection between the source and the towing platform. For vessels, this
%    is always 'hard'.
%  - positionPaths: character vector or cell array of character vectors
%    containing the relative directories and paths where the vessel position 
%    files are stored. The directories and paths are relative to ROOT.POSITION 
%    (see 'root.json').
%  - positionFormat: format of the source position files. For vessels from
%    'fleet' category, this is always 'AIS'.
%  - positionPlatform: software platform used to produce the receiver position 
%    files. Combined with POSITIONFORMAT, it helps determine the expected file
%    extensions. For vessels from 'fleet' category, this is always 'PamGuard'.
%  - vesselId: identification number for the vessel in a P190 file. Only
%    for POSITIONFORMAT = 'P190'. For vessels of 'fleet' category, this is 
%    always [].
%  - sourceId: identification number for the vessel in a P190 file. Only
%    for POSITIONFORMAT = 'P190'. For vessels of 'fleet' category, this is 
%    always [].
%  - mmsi: MMSI number of the vessel.
%  - vesselName: name of the vessel.
%  - vesselLength: length of the vessel, in metres.
%  - vesselBeam: width of the vessel, in metres.
%  - vesselDraft: draft of the vessel, in metres.
%  - vesselGrossTonnage: gross tonnage of the vessel, in tonnes.
%  - latitude: latitude, in degrees, of the vessel.
%  - longitude: longitude, in degrees, of the vessel.
%  - depth: depth of the source, in metres. For vessels, this is always 0.
%
%  INPUT ARGUMENTS
%  - None
%
%  OUTPUT ARGUMENTS
%  - VesImpConfig: initialised vessel import configuration structure.
%
%  FUNCTION CALL
%  VesImpConfig = initialiseVesselImportConfig()
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

function VesImpConfig = initialiseVesselImportConfig()

VesImpConfig = struct('inputStatus',[],'configFileName',[],...
    'sourceCategory',[],'sourceName',[],'sourceOffset',[],...
    'sourceOffsetMode',[],'positionPaths',[],'positionFormat',[],...
    'positionPlatform',[],'vesselId',[],'sourceId',[],'mmsi',[],...
    'vesselName',[],'vesselLength',[],'vesselBeam',[],'vesselDraft',[],...
    'vesselGrossTonnage',[],'latitude',[],'longitude',[],'depth',[]);
