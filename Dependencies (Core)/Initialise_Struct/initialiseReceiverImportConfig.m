%  RecImpConfig = INITIALISERECEIVERIMPORTCONFIG()
%
%  DESCRIPTION
%  Initialises the receiver import configuration structure RECIMPCONFIG. All 
%  the fields in this structure are set as empty ([]).
%
%  The fields in RECIMPCONFIG are described below.
%
%  RECIMPCONFIG
%  ============
%  - inputStatus: TRUE if the receiver import configuration is valid. This 
%    field is updated by function VERIFYRECEIVERIMPORTCONFIG.
%  - configFileName: name of the receiver import configuration file from 
%    which RECIMPCONFIG comes from.
%  - receiverCategory: category of the receiver. The category indicates
%    the software what type of information is necessary to process the 
%    receiver. There are two categories available for receivers.
%    ¬ 'fixed': any fixed receiver with known position (e.g. moored buoy)
%    ¬ 'towed': any towed or automonous receiver (e.g. AutoNaut, drift
%      buoy, vessel-towed hydrophone)
%  - receiverName: name of the receiver. This is used as a unique identifier.
%  - receiverOffset: two-element numeric array (x,y) representing the position 
%    of the receiver, in metres, relative to the position of the towinig 
%    platform for which position data is available.
%  - receiverOffsetMode: character vector indicating the nature of the physical
%    connection between the receiver and the towing platform.
%    ¬ 'hard': the receiver remains at the same relative position from
%      the towing platform at all times (e.g. hydrophone vertically-
%      deployed from vessel).
%    ¬ 'soft': the receiver is loosely connected to the towing platform,
%      changing its relative position as the former moves while changing 
%      course (e.g. vessel-towed hydrophone array).
%  - positionPaths: character vector or cell array of character vectors
%    containing the relative directories and paths where the receiver position 
%    files are stored. The directories and paths are relative to ROOT.POSITION 
%    (see 'root.json').
%  - positionFormat: format of the receiver position files.
%    ¬ 'GPS': GPS format. Only the extensions .gpstext (SeicheSSV GPS 
%      database) and .csv (PAMGuard exported table) are currently supported.
%    ¬ 'AIS': AIS format. Only the .csv extension (PAMGuard exported table)
%      is supported. Support for .aistext extension (SeicheSSV AIS database)
%      will be added in a future release.
%    ¬ 'P190': P190 format. Only .p190 extension (seismic) is supported.
%  - positionPlatform: software platform used to produce the receiver position 
%    files. Combined with POSITIONFORMAT, it helps determine the expected file
%    extensions.
%    ¬ 'SeicheSsv': position file recorded with SeicheSSV software. It supports 
%      GPS (.gpstext). Support for AIS (.aistext) will be added in a future
%      release.
%    ¬ 'PamGuard': position file recorded with PAMGuard software. It supports 
%      GPS (.csv) and AIS (.csv).
%    ¬ 'Seismic': position file recorded with a seismic vessel's system. It 
%      only supports P190 (.p190).
%  - vesselId: identification number for the vessel in a P190 file. Only for 
%    POSITIONFORMAT = 'P190'.
%  - mmsi: MMSI number of the vessel. Only for POSITIONFORMAT = 'AIS'.
%  - latitude: latitude, in degrees, of the towing platform ('towed') or 
%    receiver itself ('towed' with RECEIVEROFFSET = [0 0] or 'fixed').
%  - longitude: longitude, in degrees, of the towing platform ('towed') or 
%    receiver itself ('towed' with RECEIVEROFFSET = [0 0] or 'fixed').
%  - depth: depth of the receiver, in metres. DEPTH is a negative value. 
%    Currently, this parameter can only be set as constant.
%
%  INPUT ARGUMENTS
%  - None
%
%  OUTPUT ARGUMENTS
%  - RecImpConfig: initialised receiver import configuration structure.
%
%  FUNCTION CALL
%  RecImpConfig = initialiseReceiverImportConfig()
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

function RecImpConfig = initialiseReceiverImportConfig()

RecImpConfig = struct('inputStatus',[],'configFileName',[],...
    'receiverCategory',[],'receiverName',[],'receiverOffset',[],...
    'receiverOffsetMode',[],'positionPaths',[],'positionFormat',[],...
    'positionPlatform',[],'vesselId',[],'mmsi',[],'latitude',[],...
    'longitude',[],'depth',[]);
