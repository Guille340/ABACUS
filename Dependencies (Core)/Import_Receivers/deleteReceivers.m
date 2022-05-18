%  success = DELETERECEIVERS(receiverNames,navigationdbPath)
%
%  DESCRIPTION
%  Deletes the receivers with name RECEIVERNAMES from the Navigation Database
%  (.mat) in the absolute path NAVIGATIONDBPATH. The function returns a 
%  logical vector the same size as SOURCENAMES, with TRUE values indicating
%  that the corresponding receiver is found and successfully deleted.
%
%  INPUT ARGUMENTS
%  - receiverNames: character vector or cell array of character vectors 
%    containing the name(s) of the receiver(s) to be deleted. The names
%    are case-sensitive. Use RECEIVERNAMES = [] to delete all receivers.
%  - navigationdbPath: absolute path of Navigation Database (.mat).
%
%  OUTPUT ARGUMENTS
%  - success: vector of logical values. TRUE if the specified receiver 
%    is successfully deleted.
%
%  FUNCTION CALL
%  success = DELETERECEIVERS(receiverNames,navigationdbPath)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%    
%  See also READRECEIVERIMPORTCONFIG, RECEIVERIMPORTFUN

%  VERSION 1.2
%  Date: 04 Aug 2021 
%  Author: Guillermo Jimenez Arranz
%  - Added functionality to delete multiple receivers at once.
%
%  VERSION 1.1 
%  Date: 19 Jun 2021 
%  Author: Guillermo Jimenez Arranz%  
%  - Added help.
%
%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  10 Jul 2021

function success = deleteReceivers(receiverNames,navigationdbPath)

if exist(navigationdbPath,'file') == 2
    % Load Navigation Database and Identify Receiver
    NavigationDatabase = load(navigationdbPath);
    
    % Find Receiver Names in Navigation Database
    if ischar(receiverNames)
        receiverNames = {receiverNames};
    end
    if isempty(receiverNames)
        receiverNames = NavigationDatabase.receiverList;
    end
    
    % Delete Receivers and Save Database (if receiver exists)
    isEmptyRecImpConfig = isequal(NavigationDatabase.RecImpConfig,...
        initialiseReceiverImportConfig);
    nReceivers = numel(receiverNames);
    success = false(max(nReceivers,1));
    if ~isEmptyRecImpConfig
        isDelete = ismember(NavigationDatabase.receiverList,receiverNames);
        success = ismember(receiverNames,NavigationDatabase.receiverList);
        if any(isDelete)
            % Delete Receivers
            if nReceivers ~= sum(isDelete) 
                NavigationDatabase.receiverList(isDelete) = [];
                NavigationDatabase.RecImpConfig(isDelete) = [];
                NavigationDatabase.RecImpData(isDelete) = [];
            else % if Navigation Database is empty after receiver deletion
                NavigationDatabase.receiverList = [];
                NavigationDatabase.RecImpConfig = initialiseReceiverImportConfig();
                NavigationDatabase.RecImpData = initialiseReceiverImportData();
            end

            % Save Navigation Database
            save(navigationdbPath,'-struct','NavigationDatabase')
        end
    end
end
