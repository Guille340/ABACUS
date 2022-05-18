%  SOURCEIMPORTCONFIG (Template for 'vessel' Category)
%
%  DESCRIPTION
%  Input settings for a source of category 'vessel'. A 'vessel' source is any
%  vessel with available position data in GPS, AIS or P190 formats. Use this 
%  category when the source is the vessel itself (fields sourceOffset and 
%  sourceOffsetMode are not included).
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
%  Create as many SOURCEIMPORTCONFIG scripts as sources are to be processed. 
%  Configuration scripts must be saved in '<ROOTDIR>/configdb' directory for 
%  the software to be able to find and run them.
%  
%  SOUIMPCONFIGFILE contains the following fields:
%  - sourceCategory: category of the source ('towed' for this template).
%  - sourceName: name of the source. Used as a unique identifier. You
%    can set it as the name of the vessel (see VESSELNAME field) or as
%    a descriptive name (e.g., 'Seismic Vessel' or 'Guard Vessel').
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
%    ¬ 'P190': P190 format. Only the .p190 extension (seismic) is supported.
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
%  - mmsi: MMSI number of the vessel. Only for POSITIONFORMAT = 'AIS'.
%  - vesselName: name of the vessel. This is a unique identifier.
%  - vesselLength: length of the vessel, in metres.
%  - vesselBeam: width of the vessel, in metres.
%  - vesselDraft: draft of the vessel, in metres.
%  - vesselGrossTonnage: gross tonnage of the vessel, in tonnes.
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

SouImpConfigFile.sourceCategory = 'vessel';
SouImpConfigFile.sourceName = '';
SouImpConfigFile.positionPaths = {''};
SouImpConfigFile.positionFormat = '';
SouImpConfigFile.positionPlatform = '';
SouImpConfigFile.vesselId = [];
SouImpConfigFile.mmsi = [];
SouImpConfigFile.vesselName = [];
SouImpConfigFile.vesselLength = [];
SouImpConfigFile.vesselBeam = [];
SouImpConfigFile.vesselDraft = [];
SouImpConfigFile.vesselGrossTonnage = [];
