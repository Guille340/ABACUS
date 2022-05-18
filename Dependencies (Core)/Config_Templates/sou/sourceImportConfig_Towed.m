%  SOURCEIMPORTCONFIG (Template for 'towed' Category)
%
%  DESCRIPTION
%  Input settings for a source of category 'towed'. A 'towed' source is any 
%  towed or platform-attached source with available position data in GPS, 
%  AIS or P190 formats. Examples of towed sources are hull-mounted SBP and 
%  vessel-towed airgun arrays.
%
%  This script is updated manually and read by READSOURCEIMPORTCONFIG to 
%  create a structure SOUIMPCONFIGFILE that is used to populate a full 
%  source import configuration structure SOUIMPCONFIG. The latter is used 
%  by SOURCEIMPORTFUN to locate and extract the position information for 
%  each source and save the results in the Navigation Database (.mat), 
%  stored in directory '<ROOTDIR>/navigationdb'.
%
%  Source import configuration scripts must follow the naming convention
%  'sourceImportConfig<CHAR>_<NUM>.json', where <CHAR> is a character 
%  vector and <NUM> is a number indicating the reading and processing order 
%  for the configuration files (e.g. sourceImportConfig_TK_CH1_01). 
%
%  Create as many SOURCEIMPORTCONFIG scripts as sources are to be  processed. 
%  Configuration scripts must be saved in '<ROOTDIR>/configdb' directory for 
%  the software to be able to find and run them.
%  
%  SOUIMPCONFIGFILE contains the following fields:
%  - sourceCategory: category of the source ('towed' for this template).
%  - sourceName: name of the source. Used as a unique identifier.
%  - sourceOffset: two-element numeric array (x,y) representing the 
%    position of the source, in metres, relative to the position of the 
%    towing platform for which position data is available. The values are 
%    positive 'up' (x) and 'right' (y).
%  - sourceOffsetMode: string indicating the nature of the physical connection 
%    between the source and the towing platform.
%    ¬ 'hard': the source remains at the same relative position from
%      the towing platform at all times (e.g. sub-bottom profiler).
%    ¬ 'soft': the source is loosely connected to the towing platform,
%      changing its relative position as the first moves in different
%      directions (e.g. vessel-towed airgun).
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
%    ¬ 'SeicheSsv': position file recorded with SeicheSSV software. It supports 
%      GPS (.gpstext). Support for AIS (.aistext) will be added in a future 
%      release.
%    ¬ 'PamGuard': position file recorded with PAMGuard software. It supports 
%      GPS (.csv) and AIS (.csv).
%    ¬ 'Seismic': position file recorded with a seismic vessel's system. It 
%      only supports P190 (.p190).
%  - vesselId: identification number for the vessel in a P190 file. Only for 
%    POSITIONFORMAT = 'P190'.
%  - sourceId: identification number for the source in a P190 file. Only for 
%    POSITIONFORMAT = 'P190'. If the source position from the P190 file is to 
%    be used, both VESSELID and SOURCEID must be provided.
%  - mmsi: MMSI number of the vessel. Only for POSITIONFORMAT = 'AIS'.
%  - depth: depth of the receiver, in metres. DEPTH is a negative value. 
%    Currently, this parameter can only be set as constant.
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
%  See also READSOURCEIMPORTCONFIG

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  18 Jun 2021

SouImpConfigFile.sourceCategory = 'towed';
SouImpConfigFile.sourceName = '';
SouImpConfigFile.sourceOffset = [];
SouImpConfigFile.sourceOffsetMode = '';
SouImpConfigFile.positionPaths = '';
SouImpConfigFile.positionFormat = '';
SouImpConfigFile.positionPlatform = '';
SouImpConfigFile.vesselId = [];
SouImpConfigFile.sourceId = [];
SouImpConfigFile.mmsi = [];
SouImpConfigFile.depth = [];
