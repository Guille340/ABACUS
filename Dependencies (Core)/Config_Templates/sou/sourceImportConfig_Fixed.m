%  SOURCEIMPORTCONFIG (Template for 'fixed' Category)
%
%  DESCRIPTION
%  Input settings for a source of category 'fixed'. A 'fixed' source is any 
%  source with a known fixed position (LATITUDE,LONGITUDE). Examples of fixed 
%  sources are piles and vessel on stationary DP mode.
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
%  Create as many SOURCEIMPORTCONFIG scripts as sources are to be
%  processed. Configuration scripts must be saved in '<ROOTDIR>/configdb' 
%  directory for the SPLToolbox to be able to find and run them. 
%  
%  SOUIMPCONFIGFILE contains the following fields:
%  - sourceCategory: category of the source ('fixed' for this template).
%  - sourceName: name of the source. Used as a unique identifier.
%  - latitude: latitude, in degrees, for the 'fixed' source.
%  - longitude: longitude, in degrees, for the 'fixed' source.
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

SouImpConfigFile.sourceCategory = 'fixed';
SouImpConfigFile.sourceName = '';
SouImpConfigFile.latitude = [];
SouImpConfigFile.longitude = [];
SouImpConfigFile.depth = [];
