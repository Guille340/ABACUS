%  NavigationDatabase = INITIALISENAVIGATIONDATABASE()
%
%  DESCRIPTION
%  Initialises the NAVIGATIONDATABASE structure. The initialised structure
%  contains all the fields and subfields down to the lowest level. All 
%  fields that are not structures are set as empty ([]).
%
%  NAVIGATIONDATABASE contains three global parameters (RECEIVERLIST,
%  SOURCELIST, and VESSELLIST) and six multi-element structures (RECIMPCONFIG,
%  RECIMPDATA, SOUIMPCONFIG, SOUIMPDATA, VESIMPCONFIG, VESIMPDATA).
%
%  RECIMPCONFIG and RECIMPDATA contain as many elements as receivers, 
%  SOUIMPCONFIG and SOUIMPDATA contain as many elements as sources, and
%  VESIMPCONFIG and VESIMPDATA contain as many elements as vessels.
%
%  Note that the substructures in output NAVIGATIONDATABASE contain only one 
%  element and no information, other than the structure fields.
%
%  The general parameters and fields in each of these structures are described 
%  below.
%
%  General Parameters
%  ==================
%  - receiverList: cell array of all receiver names stored in the database
%  - sourceList: cell array of all source names stored in the database
%  - vesselList: cell array of all vessel names stored in the database
%
%  RECIMPCONFIG
%  ============
%  See INITIALISERECEIVERIMPORTCONFIG
%
%  RECIMPDATA
%  ===========
%  See INITIALISERECEIVERIMPORTDATA
%
%  SOUIMPCONFIG
%  ============
%  See INITIALISESOURCEIMPORTCONFIG
%
%  SOUIMPDATA
%  ===========
%  See INITIALISESOURCEIMPORTDATA
%
%  VESIMPCONFIG
%  ============
%  See INITIALISEVESSELIMPORTCONFIG
%
%  VESIMPDATA
%  ===========
%  See INITIALISEVESSELIMPORTDATA
%
%  INPUT ARGUMENTS
%  - None
%
%  OUTPUT ARGUMENTS
%  - NavigationDatabase: initialised Navigation Database structure.
%
%  FUNCTION CALL
%  NavigationDatabase = initialiseNavigationDatabase()
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

function NavigationDatabase = initialiseNavigationDatabase()

RecImpConfig = initialiseReceiverImportConfig();
RecImpData = initialiseReceiverImportData();
SouImpConfig = initialiseSourceImportConfig();
SouImpData = initialiseSourceImportData();
VesImpConfig = initialiseVesselImportConfig();
VesImpData = initialiseVesselImportData();

NavigationDatabase = struct(...
    'receiverList',[],'sourceList',[],'vesselList',[],...
    'RecImpConfig',RecImpConfig,'RecImpData',RecImpData,...
    'SouImpConfig',SouImpConfig,'SouImpData',SouImpData,...
    'VesImpConfig',VesImpConfig,'VesImpData',VesImpData);

