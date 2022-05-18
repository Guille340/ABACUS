%  RecImpConfig = DISCARDREPEATEDRECEIVERS(RecImpConfig,navigationdbPath)
%
%  DESCRIPTION
%  Removes from the multi-element receiver configuration structure 
%  RECIMPCONFIG any receiver with name identical to any receiver in the 
%  Navigation Database or in RECIMPCONFIG itself. 
%
%  INPUT ARGUMENTS 
%  - RecImpConfig: full multi-element receiver configuration structure. 
%    This structure contains the configuration information from all
%    the 'receiverImportConfig*.json' files. RECIMPCONFIG is generated 
%    with READRECEIVERIMPORTCONFIG.
%  - navigationdbPath: absolute path of Navigation Database (.mat).
%
%  OUTPUT ARGUMENTS
%  - RecImpConfig: updated full multi-element receiver configuration 
%    structure. Any receiver in RECIMPCONFIG with name identical to a 
%    receiver in the Navigation Database or RECIMPCONFIG itself are 
%    discarded.
%
%  FUNCTION CALL
%  RecImpConfig = DISCARDREPEATEDRECEIVERS(RecImpConfig,navigationdbPath)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  See also READRECEIVERIMPORTCONFIG, RECEIVERIMPORTFUN

%  VERSION 1.3
%  Date: 04 Aug 2021
%  Author: Guillermo Jimenez Arranz%  
%  - Removed functionality to discard receivers based on identical
%    settings. Only receivers with identical names are discarded.
%
%  VERSION 1.2
%  Date: 03 Aug 2021
%  Author: Guillermo Jimenez Arranz 
%  - Removed renaming functionality. Now, a receiver with name already 
%    existing in the Navigation Database of RECIMPCONFIG itself is 
%    directly removed from RECIMPCONFIG. Renaming is no longer an option
%    as it can cause conflict with the names in 'channelToReceiver.json'
%    (any receiver name to process must be included beforehand in file
%    'channelToReceiver.json').
%
%  VERSION 1.1
%  Date: 11 Jul 2021
%  Author: Guillermo Jimenez Arranz  
%  - Function simplified by calling RENAMEEXISTINGSTRING.
%
%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  09 Jul 2021

function RecImpConfig = discardRepeatedReceivers(RecImpConfig,navigationdbPath)

% ### VERIFY 'RecImpConfig' AGAINST NAVIGATION DATABASE ###
% Retrieve List of Receivers from Navigation Database (if exists)
navigationdbExists = exist(navigationdbPath,'file') == 2;
isEmptyRecImpConfig = true;
if navigationdbExists
    % Load Data and Receiver Names from Navigation Database
    Structure = load(navigationdbPath,'RecImpConfig');
    RecImpConfigInNavigationdb = Structure.RecImpConfig;
    Structure = load(navigationdbPath,'receiverList');
    receiverNamesInNavigationdb = Structure.receiverList;
    isEmptyRecImpConfig = isequal(RecImpConfigInNavigationdb,...
        initialiseReceiverImportConfig);
end

% If Receiver-Related Part of the Navigation Database has been Populated
if navigationdbExists && ~isEmptyRecImpConfig    
    % Remove Receivers with Duplicated Names in Navigation DB
    nReceivers = numel(RecImpConfig);
    isRepeated = false(nReceivers,1);
    for m = nReceivers:-1:1
        receiverName = RecImpConfig(m).receiverName; % current receiver
        isRepeated(m) = ismember(receiverName,receiverNamesInNavigationdb);
    end
    RecImpConfig = RecImpConfig(~isRepeated);
    if any(isRepeated)
        warning(['The receiver names in one or more receiver import '...
        'configuration scripts ''receiverImportConfig_<CHAR>.json'' '...
        'are already available in the Navigation Database. These '...
        'scripts will be ignored'])
    end
end

% ### VERIFY 'RecImpConfig' AGAINST 'RecImpConfig' ###
% Update Name of Receivers with Duplicated Names in RecImpConfig
nReceivers = numel(RecImpConfig);
isRepeated = false(nReceivers,1);
for m = nReceivers:-1:2
    receiverName = RecImpConfig(m).receiverName; % current receiver
    receiverNames = {RecImpConfig(1:m-1).receiverName};
    isRepeated(m) = ismember(receiverName,receiverNames);
end
RecImpConfig = RecImpConfig(~isRepeated);
if any(isRepeated)
    warning(['The receiver names in two or more receiver import '...
        'configuration scripts ''receiverImportConfig_<CHAR>.json'' '...
        'are identical. These scripts will be ignored'])
end
