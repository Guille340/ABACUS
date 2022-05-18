%  RecImpData = INITIALISERECEIVERIMPORTDATA()
%
%  DESCRIPTION
%  Initialises the receiver import data structure RECIMPDATA. All the fields in 
%  this structure are set as empty ([]).
%
%  The fields in RECIMPDATA are described below.
%
%  RECIMPDATA
%  ==========
%  - positionPaths: absolute paths of the receiver position files.
%  - pcTick: vector of PC times of registered position sentences. Not available 
%    on P190 files (RECEIVERFORMAT = 'p190').
%  - utcTick: vector of UTC times of registered position sentences.
%  - latitude: receiver latitude, in degrees. May refer to the towing platform
%    or receiver itself (no horizontal offset correction applied).
%  - longitude: receiver longitude, in degrees. May refer to the towing 
%    platform or receiver itself (no horizontal offset correction applied).
%  - depth: depth of the receiver, in metres. Currently, this parameter can
%    only be set as a constant value.
%
%  INPUT ARGUMENTS
%  - None
%
%  OUTPUT ARGUMENTS
%  - RecImpData: initialised receiver import data structure.
%
%  FUNCTION CALL
%  RecImpData = initialiseReceiverImportData()
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

function RecImpData = initialiseReceiverImportData()

RecImpData = struct('positionPaths',[],'pcTick',[],'utcTick',[],...
        'latitude',[],'longitude',[],'depth',[]);