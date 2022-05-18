%  Config = DISCARDREPEATEDELEMENTS(Config)
%
%  DESCRIPTION
%  Discards from the multi-element configuration structure CONFIG any element
%  with a RECEIVERNAME/SOURCENAME combination identical to that of any of other
%  element in CONFIG. 
%
%  The function evaluates each element from last to first, meaning that in the 
%  scenario of any RECEIVERNAME/SOURCENAME combination being repeated, the 
%  elements with a lowest index are kept.
%
%  DISCARDREPEATEDELEMENTS is aimed only at configuration structures directly 
%  related to the population of Acoustic Databases, namely the audio detect, 
%  audio process and navigation process structures (see READAUDIODETECTCONFIG, 
%  READAUDIOPROCESSCONFIG and READNAVIGATIONPROCESSCONFIG).
%
%  INPUT ARGUMENTS
%  - Config: multi-element audio detect, audio process or audio navigation
%    configuration structure.
%
%  OUTPUT ARGUMENTS
%  - None
%
%  FUNCTION CALL
%  Config = discardRepeatedElements(Config)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  See also READAUDIODETECTCONFIG, READAUDIOPROCESSCONFIG, 
%  READNAVIGATIONPROCESSCONFIG

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  05 Aug 2021

function Config = discardRepeatedElements(Config)

% Receiver and Source Names in Navigation Process Config Structure
receiverNames = {Config.receiverName}';
sourceNames = {Config.sourceName}';

% Identify Repeated RECEIVERNAME/SOURCENAME Combinations in AUDDETCONFIG
nElements = numel(Config);
isRepeated = false(nElements,1);
for m = nElements:-1:2
    % Flag Repeated Receiver Names
    receiverName_m = receiverNames(m); % current receiver name
    receiverNames_m = receiverNames(1:m-1); % rest of receiver names
    isRecInConfig = ismember(receiverNames_m,receiverName_m);
    
    % Flag Repeated Source Names
    sourceName_m = sourceNames(m); % current source name
    sourceNames_m = sourceNames(1:m-1); % rest of source names
    isSouInConfig = ismember(sourceNames_m,sourceName_m);
    
    % Flag Repeated RECEIVERNAME/SOURCENAME Combinations
    isRepeated(m) = any(isRecInConfig & isSouInConfig);
end

% Remove Repeated RECEIVERNAME/SOURCENAME Combinations from AUDDETCONFIG
if any(isRepeated)
    Config(isRepeated) = [];
    warning(['One or more configuration scripts contain an identical '...
        'RECEIVERNAME/SOURNAME combination. Those scripts will be ignored'])
end
