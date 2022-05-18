%  index = FINDACOUSTICDATABASEELEMENT(acousticdbPath,receiverName,sourceName)
%
%  DESCRIPTION
%  Finds the index of the element in the AcousticDatabase in absolute
%  path ACOUSTICDBPATH that matches the RECEIVERNAME/SOURCENAME combination.
%
%  INPUT ARGUMENTS
%  - acousticdbPath: absolute path of the acoustic database.
%  - receiverName: character vector specifying the name of the receiver to look
%    for in the Acoustic Database.
%  - sourceName: character vector specifying the name of the source to look for 
%    in the Acoustic Database.
%
%  OUTPUT ARGUMENTS
%  - index: index of the element in the Acoustic Database matching the pair
%    RECEIVERNAME/SOURCENAME. INDEX = [] if ACOUSTICDBPATH does not exist or 
%    the RECEIVERNAME/SOURCENAME combination is not found.
%
%  FUNCTION CALL
%  index = findAcousticDatabaseElement(acousticdbPath,receiverName,sourceName)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  See also AUDIODETECTFUN, AUDIOPROCESSFUN, NAVIGATIONPROCESSFUN

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  09 Aug 2021

function index = findAcousticDatabaseElement(acousticdbPath,receiverName,...
    sourceName)

index = [];
if ~isempty(acousticdbPath) && exist(acousticdbPath,'file') == 2
    Structure = load(acousticdbPath,'AcoConfig');
    AcoConfig = Structure.AcoConfig;
    
    % Receiver and Source Names in AUDDETCONFIG structure
    receiverNames = {AcoConfig.receiverName}';
    sourceNames = {AcoConfig.sourceName}';
  
    % Identify Repeated RECEIVERNAME/SOURCENAME Combinations in AUDDETCONFIG
    isRecInAcousticdb = ismember(receiverNames,receiverName);
    isSouInAcousticdb = ismember(sourceNames,sourceName);
    index = find(isRecInAcousticdb & isSouInAcousticdb);
end
