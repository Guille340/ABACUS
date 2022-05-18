%  SouImpConfig = DISCARDREPEATEDSOURCES(SouImpConfig,navigationdbPath)
%
%  DESCRIPTION
%  Removes from the multi-element source configuration structure 
%  SOUIMPCONFIG any source with name identical to any source in the 
%  Navigation Database or in SOUIMPCONFIG itself. 
%
%  INPUT ARGUMENTS 
%  - SouImpConfig: full multi-element source configuration structure. 
%    This structure contains the configuration information from all
%    the 'sourceImportConfig*.json' files. SOUIMPCONFIG is  generated 
%    with READSOURCEIMPORTCONFIG.
%  - navigationdbPath: absolute path of Navigation Database (.mat).
%
%  OUTPUT ARGUMENTS
%  - SouImpConfig: updated full multi-element source configuration 
%    structure. Any source in SOUIMPCONFIG with name identical to a
%    source in the Navigation Database or SOUIMPCONFIG itself is discarded.
%
%  FUNCTION CALL
%  SouImpConfig = DISCARDREPEATEDSOURCES(SouImpConfig,navigationdbPath)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  See also READSOURCEIMPORTCONFIG, SOURCEIMPORTFUN

%  VERSION 1.2
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  04 Aug 2021
%  - Removed functionality to discard sources based on identical
%    settings. Only sources with identical names are discarded.
%
%  VERSION 1.1
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  11 Jul 2021
%  - Function simplified by calling RENAMEEXISTINGSTRING.
%
%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  09 Jul 2021

function SouImpConfig = discardRepeatedSources(SouImpConfig,navigationdbPath)

% ### VERIFY 'SouImpConfig' AGAINST NAVIGATION DATABASE ###
% % Load Data and Source Names from Navigation Database (if exists)
navigationdbExists = exist(navigationdbPath,'file') == 2;
isEmptySouImpConfig = true; % TRUE if SouImpConfig in Navigation Database is empty
isEmptyVesImpConfig = true; % TRUE if VesImpConfig in Navigation Database is empty
if navigationdbExists
    Structure = load(navigationdbPath,'SouImpConfig');
    SouImpConfigInNavigationdb = Structure.SouImpConfig;
    Structure = load(navigationdbPath,'VesImpConfig');
    VesImpConfigInNavigationdb = Structure.VesImpConfig;
    Structure = load(navigationdbPath,'sourceList');
    sourceNamesInNavigationdb = Structure.sourceList;
    isEmptySouImpConfig = isequal(SouImpConfigInNavigationdb,...
        initialiseSourceImportConfig);
    isEmptyVesImpConfig = isequal(VesImpConfigInNavigationdb,...
        initialiseVesselImportConfig);
end

% If Source-Related Part of the Navigation Database has been Populated
if navigationdbExists && ~isempty(sourceNamesInNavigationdb)     
    % Remove 'Fleet' Source in SouImpConfig if already in Navigation DB
    if ~isEmptyVesImpConfig
        sourceCategory = lower({SouImpConfig.sourceCategory})'; % source names in SouImpConfig
        isFleet = ismember(sourceCategory,'fleet');
        SouImpConfig(isFleet) = [];
    end
       
    % Update Name of Sources with Duplicated Names in Navigation DB
    if ~isEmptySouImpConfig
        nSources = numel(SouImpConfig);
        isRepeated = false(nSources,1);
        for m = nSources:-1:1
            sourceName = SouImpConfig(m).sourceName; % current source
            isRepeated(m) = ismember(sourceName,sourceNamesInNavigationdb);
        end
        SouImpConfig = SouImpConfig(~isRepeated);
        if any(isRepeated)
            warning(['The source names in one or more source import '...
            'configuration scripts ''sourceImportConfig_<CHAR>.json'' '...
            'are already available in the Navigation Database. These '...
            'scripts will be ignored'])
        end
    end
end

% ### VERIFY 'SouImpConfig' AGAINST 'SouImpConfig' ###
% Update Name of Sources with Duplicated Names in SouImpConfig
nSources = numel(SouImpConfig);
isRepeated = false(nSources,1);
for m = nSources:-1:2
    sourceName = SouImpConfig(m).sourceName; % current source
    sourceNames = {SouImpConfig(1:m-1).sourceName};
    isRepeated(m) = ismember(sourceName,sourceNames);
end
SouImpConfig = SouImpConfig(~isRepeated);
if any(isRepeated)
    warning(['The source names in two or more source import '...
        'configuration scripts ''sourceImportConfig_<CHAR>.json'' '...
        'are identical. These scripts will be ignored'])
end
