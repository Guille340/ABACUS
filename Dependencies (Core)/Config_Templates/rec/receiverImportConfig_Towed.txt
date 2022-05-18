%  RECEIVERIMPORTCONFIG (Template for 'towed' Category)
%
%  DESCRIPTION
%  Input settings for a receiver of category 'towed'. A 'towed' receiver is 
%  any towed or platform-attached receiver with available position data in 
%  GPS, AIS or P190 formats. Examples of towed receivers are drift buoys and 
%  vessel-towed hydrophone arrays.
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
%  - receiverCategory: category of the receiver ('towed' for this template).
%  - receiverName: name of the receiver. Used as a unique identifier.
%  - receiverOffset: two-element numeric array (x,y) representing the 
%    position of the receiver, in metres, relative to the position of the 
%    towing platform for which position data is available. The values are 
%    positive 'up' (x) and 'right' (y).
%  - receiverOffsetMode: character vector indicating the nature of the physical
%    connection between the receiver and the towing platform.
%    ¬ 'hard': the receiver remains at the same relative position from the 
%      towing platform at all times (e.g. hydrophone vertically-deployed from 
%      vessel).
%    ¬ 'soft': the receiver is loosely connected to the towing platform,
%      changing its relative position as the first moves and changes
%      course (e.g. vessel-towed hydrophone array).
%  - positionPaths: character vector or cell array of character vectors
%    containing the relative directories and paths where the receiver position 
%    files are stored. These directories and paths are relative to ROOT.POSITION
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

RecImpConfigFile.receiverCategory = 'towed';
RecImpConfigFile.receiverName = '';
RecImpConfigFile.receiverOffset = [];
RecImpConfigFile.receiverOffsetMode = '';
RecImpConfigFile.positionPaths = '';
RecImpConfigFile.positionFormat = '';
RecImpConfigFile.positionPlatform = '';
RecImpConfigFile.vesselId = [];
RecImpConfigFile.mmsi = [];
RecImpConfigFile.depth = [];
