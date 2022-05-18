%  RECEIVERIMPORTCONFIG (Template for 'fixed' Category)
%
%  DESCRIPTION
%  Input settings for a receiver of category 'fixed'. A 'fixed' receiver is 
%  any receiver with a known fixed position (LAT,LON). Examples of fixed 
%  receivers are moored ARUs, moored buoys and seabed stations.
%
%  This script is updated manually and read by READRECEIVERIMPORTCONFIG to 
%  create a structure RECIMPCONFIGFILE that is used to populate a full 
%  receiver import configuration structure RECIMPCONFIG. The latter is used 
%  by RECEIVERIMPORTFUN to locate and extract the position information for 
%  each receiver and save the results in the Navigation Database (.mat), 
%  stored in directory '<ROOTDIR>/navigationdb'.
%
%  Receiver import configuration scripts must follow the naming convention
%  'receiverImportConfig<CHAR>_<NUM>.json', where <CHAR> is a character 
%  vector and <NUM> is a number indicating the reading and processing order 
%  for the configuration files (e.g. receiverImportConfig_TK_CH1_01). 
%
%  Create as many RECEIVERIMPORTCONFIG scripts as receivers are to be
%  processed. Configuration scripts must be saved in '<ROOTDIR>/configdb' 
%  directory for the SPLToolbox to be able to find and run them. 
%  
%  RECIMPCONFIGFILE contains the following fields:
%  - receiverCategory: category of the receiver ('fixed' for this template).
%  - receiverName: name of the receiver. Used as a unique identifier.
%  - latitude: latitude, in degrees, for the 'fixed' receiver.
%  - longitude: longitude, in degrees, for the 'fixed' receiver.
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
%  See also READRECEIVERIMPORTCONFIG

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  18 Jun 2021

RecImpConfigFile.receiverCategory = 'fixed';
RecImpConfigFile.receiverName = '';
RecImpConfigFile.latitude = [];
RecImpConfigFile.longitude = [];
RecImpConfigFile.depth = [];
