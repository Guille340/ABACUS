%  success = DELETEVESSELS(vesselNames,navigationdbPath)
%
%  DESCRIPTION
%  Deletes the vessels with names VESSELNAMES from the Navigation Database
%  (.mat) in the absolute path NAVIGATIONDBPATH. The function returns
%  a logical vector the same size as VESSELNAMES, with TRUE values indicating
%  that the corresponding vessel is found and successfully deleted.
%
%  Note that for a source of 'fleet' category the vessel information is 
%  stored in the substructure VESIMPDATA rather than in SOUIMPDATA.
%
%  INPUT ARGUMENTS
%  - vesselNames: character vector or cell array of character vectors 
%    containing the name(s) of the source(s) to be deleted. The names
%    are case-sensitive. Use VESSELNAMES = [] to delete all vessels from
%    'fleet' category (VESIMPCONFIG and VESIMPDATA are initialised).
%  - navigationdbPath: absolute path of Navigation Database (.mat).
%
%  OUTPUT ARGUMENTS
%  - success: vector of logical values. TRUE if the specified vessel is 
%    successfully deleted.
%
%  FUNCTION CALL
%  success = DELETEVESSELS(vesselNames,navigationdbPath)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%    
%  See also READSOURCEIMPORTCONFIG, SOURCEIMPORTFUN

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  04 Aug 2021

function success = deleteVessels(vesselNames,navigationdbPath)

if exist(navigationdbPath,'file') == 2
    % Load Navigation Database and Identify Vessel
    NavigationDatabase = load(navigationdbPath);
    
    % Find Vessel Names in Navigation Database
    if ischar(vesselNames)
        vesselNames = {vesselNames};
    end
    if isempty(vesselNames)
        vesselNames = NavigationDatabase.vesselList;
    end
    
    % Delete Vessels and Save Database
    isEmptyVesImpConfig = isequal(NavigationDatabase.VesImpConfig,...
        initialiseVesselImportConfig);
    nVesselsInNavigationdb = numel(NavigationDatabase.vesselList);
    success = false(max(numel(vesselNames),1));
    if ~isEmptyVesImpConfig
        isVessel = ismember(NavigationDatabase.vesselList,vesselNames);
        success = ismember(vesselNames,NavigationDatabase.vesselList);
        if any(isVessel) 
            % Delete Vessels
            if nVesselsInNavigationdb ~= sum(isVessel) 
                NavigationDatabase.vesselList(isVessel) = [];
                NavigationDatabase.VesImpConfig(isVessel) = [];
                NavigationDatabase.VesImpData(isVessel) = [];
            else % if Navigation Database is empty after vessel deletion
                NavigationDatabase.vesselList = [];
                NavigationDatabase.VesImpConfig = initialiseVesselImportConfig();
                NavigationDatabase.VesImpData = initialiseVesselImportData();
            end

            % Save Navigation Database
            save(navigationdbPath,'-struct','NavigationDatabase')
        end
    end
end
