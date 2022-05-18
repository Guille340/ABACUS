%  success = RENAMESOURCE(sourceName,sourceNameNew,navigationdbPath)
%
%  DESCRIPTION
%  Looks up for the source with name SOURCENAME in the Navigation Database
%  with absolute path NAVIGATIONDBPATH and renames it to SOURCENAMENEW. The 
%  function returns TRUE if the source is found and successfully renamed.
%
%  INPUT ARGUMENTS
%  - sourceName: name of the source to be renamed.
%  - sourceNameNew: new name for the source.
%  - navigationdbPath: absolute path of Navigation Database (.mat).
%
%  OUTPUT ARGUMENTS
%  - success: TRUE if the specified source is successfully renamed.
%
%  FUNCTION CALL
%  success = RENAMESOURCE(sourceName,sourceNameNew,navigationdbPath)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%    
%  See also SOURCEIMPORTFUN

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  12 Jul 2021

function success = renameSource(sourceName,sourceNameNew,navigationdbPath)

if exist(navigationdbPath,'file') == 2
    % Load Navigation Database and Identify Source
    NavigationDatabase = load(navigationdbPath);
    [~,iSource] = ismember(sourceName,NavigationDatabase.sourceList);
    
    % Rename Source and Save Database (if source exists)
    success = false;
    if iSource
        if strcmp(NavigationDatabase.SouImpConfig(iSource).sourceCategory,...
                'fleet')
            nVessels = numel(NavigationDatabase.VesImpDat);
            for m = 1:nVessels
                NavigationDatabase.VesImpData(m).SouImpConfig.sourceName =...
                    sourceNameNew;
            end 
        else
            NavigationDatabase.SouImpData(iSource).SouImpConfig.sourceName =...
                sourceNameNew;
        end
        NavigationDatabase.sourceList{iSource} = sourceNameNew;
        NavigationDatabase.SouImpConfig(iSource).sourceName = sourceNameNew;
        save(navigationdbPath,'-struct','NavigationDatabase')
        success = true;
    end
end
