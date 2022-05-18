%  success = RENAMERECEIVER(receiverName,receiverNameNew,navigationdbPath)
%
%  DESCRIPTION
%  Looks up for the receiver with name RECEIVERNAME in the Navigation Database
%  with absolute path NAVIGATIONDBPATH and renames it to RECEIVERNAMENEW. The 
%  function returns TRUE if the receiver is found and successfully renamed.
%
%  INPUT ARGUMENTS
%  - receiverName: name of the receiver to be renamed.
%  - receiverNameNew: new name for the receiver.
%  - navigationdbPath: absolute path of Navigation Database (.mat).
%
%  OUTPUT ARGUMENTS
%  - success: TRUE if the specified receiver is successfully renamed.
%
%  FUNCTION CALL
%  success = RENAMERECEIVER(receiverName,receiverNameNew,navigationdbPath)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%    
%  See also RECEIVERIMPORTFUN

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  12 Jul 2021

function success = renameReceiver(receiverName,receiverNameNew,navigationdbPath)

if exist(navigationdbPath,'file') == 2
    % Load Navigation Database and Identify Receiver
    NavigationDatabase = load(navigationdbPath);
    [~,iReceiver] = ismember(receiverName,NavigationDatabase.receiverList);
    
    % Rename Receiver and Save Database (if receiver exists)
    success = false;
    if iReceiver
        NavigationDatabase.RecImpData(iReceiver).RecImpConfig.receiverName = receiverNameNew;
        NavigationDatabase.receiverList{iReceiver} = receiverNameNew;
        NavigationDatabase.RecImpConfig(iReceiver).receiverName = receiverNameNew;
        save(navigationdbPath,'-struct','NavigationDatabase')
        success = true;
    end
end
