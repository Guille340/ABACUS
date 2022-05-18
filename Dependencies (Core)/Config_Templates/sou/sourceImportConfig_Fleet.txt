%  SOURCEIMPORTCONFIG (Template for 'fleet' Category)
%
%  DESCRIPTION
%  Input settings for a source of category 'fleet'. A 'fleet' source refers 
%  to a vessel fleet with the position and other information for individual 
%  vessels is retrieved from AIS data files. Use this category when you want 
%  to incorporate multiple vessels for later plotting in an Operations Map 
%  or even when you are planning to acoustically evaluate the noise produced 
%  by those vessels.
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
%  Note that 'mmsi','vesselName','vesselLength', 'vesselBeam', 'vesselDraft', 
%  and 'vesselGrossTonnage' are not included as a fields. That is because 
%  this information is provided separately through a Vessel Database (.csv), 
%  stored in '<ROOTDIR>/navigationdb' along with the Navigation Database 
%  (.mat). The Vessel Database is not strictly necessary, but it is adviced 
%  to include it. If the Vessel Database is not available, the software will 
%  retrieve what it can from the AIS files; however, creating a Vessel Database 
%  allows the user to select exactly what vessels to process (through the MMSI 
%  number), and introduce their names and properties. Having all this 
%  information available is particularly useful for the generation an 
%  Operations Map where vessels can be easily identified and their noise 
%  contribution assessed. For more information about vessel databases check 
%  help in READVESSELDATABASE.
%  
%  SOUIMPCONFIGFILE contains the following fields:
%  - sourceCategory: category of the source ('towed' for this template).
%  - sourceName: name of the source. Used as a unique identifier. Currently
%    set to 'fleet' but it can be changed into a more descriptive name.
%  - positionPaths: character vector or cell array of character vectors
%    containing the relative directories and paths where the source position 
%    files are stored. The directories and paths are relative to ROOT.POSITION 
%    (see 'root.json').
%  - positionFormat: format of the source position files. For this template, 
%    only 'AIS' is available. Below are listed all common options for reference:
%    ¬ 'GPS': GPS format. Only the extensions .gpstext (SeicheSSV GPS 
%      database) and .csv (PAMGuard exported table) are currently supported.
%    ¬ 'AIS': AIS format. Only the .csv extension (PAMGuard exported table)
%      is supported. Support for .aistext extension (SeicheSSV AIS database)
%      will be added in a future release.
%    ¬ 'P190': P190 format. Only the .p190 extension (seismic) is supported.
%  - positionPlatform: software platform used to produce the source position 
%    files. Combined with POSITIONFORMAT, it helps determine the expected file 
%    extensions. For this template, only 'PamGuard' is currently available. 
%    Below are listed all common options for reference:
%    ¬ 'SeicheSsv': position file recorded with SeicheSSV software. It supports
%      GPS (.gpstext). Support for AIS (.aistext) will be added in a future 
%      release.
%    ¬ 'PamGuard': position file recorded with PAMGuard software. It supports 
%      GPS (.csv) and AIS (.csv).
%    ¬ 'Seismic': position file recorded with a seismic vessel's system. It 
%      only supports P190 (.p190).
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

SouImpConfigFile.sourceCategory = 'fleet';
SouImpConfigFile.sourceName = 'fleet';
SouImpConfigFile.positionPaths = {''};
SouImpConfigFile.positionFormat = 'AIS';
SouImpConfigFile.positionPlatform = 'PamGuard';
