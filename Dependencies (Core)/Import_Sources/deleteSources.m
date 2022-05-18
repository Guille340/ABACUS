%  success = DELETESOURCES(sourceNames,navigationdbPath)
%
%  DESCRIPTION
%  Deletes the sources with names SOURCENAMES from the Navigation Database
%  (.mat) in the absolute path NAVIGATIONDBPATH. The function returns a 
%  logical vector the same size as SOURCENAMES, with TRUE values indicating
%  that the corresponding source is found and successfully deleted.
%
%  INPUT ARGUMENTS
%  - sourceNames: character vector or cell array of character vectors 
%    containing the name(s) of the source(s) to be deleted. The names
%    are case-sensitive. Use SOURCENAMES = [] to delete all sources
%    (excluding vessels from 'fleet' category)
%  - navigationdbPath: absolute path of Navigation Database (.mat).
%
%  OUTPUT ARGUMENTS
%  - success: vector of logical values. TRUE if the specified source is 
%    successfully deleted.
%
%  FUNCTION CALL
%  success = DELETESOURCE(sourceNames,navigationdbPath)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%    
%  See also READSOURCEIMPORTCONFIG, SOURCEIMPORTFUN

%  VERSION 1.3
%  Date: 04 Aug 2021 
%  Author: Guillermo Jimenez Arranz  
%  - Removed functionality for deleting a source of 'fleet' category.
%    Such functionality is now part of DELETEVESSELS.
%  - Added functionality to delete multiple sources at once.
%
%  VERSION 1.2
%  Date: 19 Jun 2021 
%  Author: Guillermo Jimenez Arranz
%  - Added functionality for deleting a source of 'fleet' category.
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

function success = deleteSources(sourceNames,navigationdbPath)

if exist(navigationdbPath,'file') == 2
    % Load Navigation Database and Identify Source
    NavigationDatabase = load(navigationdbPath);
    
    % Find Source Names in Navigation Database
    if ischar(sourceNames)
        sourceNames = {sourceNames};
    end
    if isempty(sourceNames)
        sourceNames = NavigationDatabase.sourceList;
    end
    
    % Delete Sources and Save Database (if source exists)
    isEmptySouImpConfig = isequal(NavigationDatabase.SouImpConfig,...
        initialiseSourceImportConfig);
    nSourcesInNavigationdb = numel(NavigationDatabase.sourceList);
    success = false(max(nSources,1));
    if ~isEmptySouImpConfig
        isSource = ismember(NavigationDatabase.sourceList,sourceNames);
        success = ismember(sourceNames,NavigationDatabase.sourceList);
        if any(isSource)
            % Delete Sources
            if nSourcesInNavigationdb ~= sum(isSource) 
                NavigationDatabase.sourceList(isSource) = [];
                NavigationDatabase.SouImpConfig(isSource) = [];
                NavigationDatabase.SouImpData(isSource) = [];
            else % if Navigation Database is empty after source deletion
                NavigationDatabase.sourceList = [];
                NavigationDatabase.SouImpConfig = initialiseSourceImportConfig();
                NavigationDatabase.SouImpData = initialiseSourceImportData();
            end

            % Save Navigation Database
            save(navigationdbPath,'-struct','NavigationDatabase')
        end
    end
end
