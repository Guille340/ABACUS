%  SouImpConfig = INITIALISESOURCEIMPORTCONFIG()
%
%  DESCRIPTION
%  Initialises the source import configuration structure SOUIMPCONFIG. All 
%  the fields in this structure are set as empty ([]).
%
%  The fields in SOUIMPCONFIG are described below.
%
%  SOUIMPCONFIG
%  ============
%  - inputStatus: TRUE if the source import configuration is valid. This 
%    field is updated by function VERIFYSOURCEIMPORTCONFIG.
%  - configFileName: name of the source import configuration file from 
%    which SOUIMPCONFIG comes from.
%  - sourceCategory: category of the source. The category indicates
%    the software what type of information is necessary to process the
%    source. There are four categories available for sources.
%    ¬ 'fixed': any fixed source with known position (e.g. pile)
%    ¬ 'towed': any towed or automonous source (e.g. vessel-towed airgun) 
%       with available position data (GPS,AIS,P190).
%    ¬ 'vessel': any vessel with available position data (GPS,AIS,P190).
%    ¬ 'fleet': multiple vessel with available position data (AIS).
%  - sourceName: name of the source. This is used as a unique identifier.
%  - sourceOffset: two-element numeric array (x,y) representing the position 
%    of the source, in metres, relative to the position of the towinig platform 
%    for which position data is available.
%  - sourceOffsetMode: character vector indicating the nature of the physical
%    connection between the source and the towing platform.
%    ¬ 'hard': the source remains at the same relative position from
%      the towing platform at all times (e.g. hydrophone vertically-
%      deployed from vessel, side-mounted SBP).
%    ¬ 'soft': the source is loosely connected to the towing platform,
%      changing its relative position as the former moves in different
%      directions (e.g. vessel-towed airgun array).
%  - positionPaths: character vector or cell array of character vectors
%    containing the relative directories and paths where the source position 
%    files are stored. The directories and paths are relative to ROOT.POSITION 
%    (see 'root.json').
%  - positionFormat: format of the source position files.
%    ¬ 'GPS': GPS format. Only the extensions .gpstext (SeicheSSV GPS 
%      database) and .csv (PAMGuard exported table) are currently supported.
%    ¬ 'AIS': AIS format. Only the .csv extension (PAMGuard exported table)
%      is supported. Support for .aistext extension (SeicheSSV AIS database)
%      will be added in a future release.
%    ¬ 'P190': P190 format. Only .p190 extension (seismic) is supported.
%  - positionPlatform: software platform used to produce the source position 
%    files. Combined with POSITIONFORMAT, it helps determine the expected file
%    extensions.
%    ¬ 'SeicheSSV': position file recorded with SeicheSSV software. It supports 
%      GPS (.gpstext). Support for AIS (.aistext) will be added in a future
%      release.
%    ¬ 'PamGuard': position file recorded with PAMGuard software. It supports 
%      GPS (.csv) and AIS (.csv).
%    ¬ 'Seismic': position file recorded with a seismic vessel's system. It 
%      only supports P190 (.p190).
%  - vesselId: identification number for the vessel in a P190 file. Only
%    for POSITIONFORMAT = 'P190'.
%  - sourceId: identification number for the vessel in a P190 file. Only
%    for POSITIONFORMAT = 'P190'. SOURCEID does not need to be given for 
%    SOURCECATEGORY = 'vessel'.
%  - mmsi: MMSI number of the vessel. Only for POSITIONFORMAT = 'AIS'.
%  - vesselName: name of the vessel.
%  - vesselLength: length of the vessel, in metres.
%  - vesselBeam: width of the vessel, in metres.
%  - vesselDraft: draft of the vessel, in metres.
%  - vesselGrossTonnage: gross tonnage of the vessel, in tonnes.
%  - latitude: latitude, in degrees, of the towing platform ('towed') or 
%    source itself ('towed' with SOURCEOFFSET = [0 0] or {'fixed','vessel',
%    'fleet'}).
%  - longitude: longitude, in degrees, of the towing platform ('towed') or 
%    source itself ('towed' with SOURCEOFFSET = [0 0] or {'fixed','vessel',
%    'fleet'}).
%  - depth: depth of the source, in metres. DEPTH is a negative values.
%    Currently, this parameter can only be set as a constant value.
%
%  NOTE: Fields SOURCEOFFSET, SOURCEOFFSETMODE are only relevant for 
%  SOURCECATEGORY = 'towed'. VESSELNAME, VESSELLENGTH, VESSELBEAM, VESSELDRAFT 
%  and VESSELGROSSTONNAGE are only relevant for SOURCECATEGORY = 'vessel'.
%  For further details about supported fields, see 'sourceImportConfig*.json' 
%  templates.
%
%  INPUT ARGUMENTS
%  - None
%
%  OUTPUT ARGUMENTS
%  - SouImpConfig: initialised source import configuration structure.
%
%  FUNCTION CALL
%  SouImpConfig = initialiseSourceImportConfig()
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

function SouImpConfig = initialiseSourceImportConfig()

SouImpConfig = struct('inputStatus',[],'configFileName',[],...
    'sourceCategory',[],'sourceName',[],'sourceOffset',[],...
    'sourceOffsetMode',[],'positionPaths',[],'positionFormat',[],...
    'positionPlatform',[],'vesselId',[],'sourceId',[],'mmsi',[],...
    'vesselName',[],'vesselLength',[],'vesselBeam',[],'vesselDraft',[],...
    'vesselGrossTonnage',[],'latitude',[],'longitude',[],'depth',[]);
