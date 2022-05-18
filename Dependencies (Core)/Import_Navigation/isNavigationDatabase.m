%  isTrue = ISNAVIGATIONDATABASE(navigationdbPath)
%
%  DESCRIPTION
%  TRUE if the file in absolute path NAVIGATIONDBPATH exists and is a 
%  Navigation Database. FALSE if NAVIGATIONDBPATH exists but is not a
%  Navigation Database. -1 if NAVIGATIONDBPATH does not exist.
%
%  A Navigation Database contains settings and data from various receivers
%  and sources and is generated with functions RECEIVERIMPORTFUN and 
%  SOURCEIMPORTFUN. For futher details about its fields see function
%  INITIALISENAVIGATIONDATABASE.
%
%  INPUT ARGUMENTS 
%  - navigationdbPath: absolute path of Navigation Database (.mat).
%
%  OUTPUT ARGUMENTS
%  - isTrue: TRUE if the specified file is a Navigation Database, FALSE
%    if is not, an -1 if it does not exist.
%
%  FUNCTION CALL
%  isTrue = ISNAVIGATIONDATABASE(navigationdbPath)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)

%  VERSION 1.1
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  11 Jul 2021
%  - Updated code to make the verification of the fields in the Navigation
%    Database independent of their order.
%
%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  09 Jul 2021

function isTrue = isNavigationDatabase(navigationdbPath)

isTrue = -1; % initialise to -1 (= non-existent file)

if exist(navigationdbPath,'file') == 2
    NavigationDatabase = load(navigationdbPath); % absolute path of navigation database
    isTrue = false; % initialise output to FALSE

    % Verify Field Names in Layer 1
    NavigationFields_valid = fieldnames(initialiseNavigationDatabase);
    NavigationFields = fieldnames(NavigationDatabase);
    flag_layer1 = all(ismember(NavigationFields_valid,NavigationFields)) ...
        && all(ismember(NavigationFields,NavigationFields_valid));

    % Verify Field Names in Layer 2
    if flag_layer1
        % Verify Field Names in Field 1 of Layer 2
        RecImpConfigFields_valid = fieldnames(initialiseReceiverImportConfig);
        RecImpConfigFields = fieldnames(NavigationDatabase.RecImpConfig);
        flag1_layer2 = all(ismember(RecImpConfigFields_valid,...
            RecImpConfigFields)) && all(ismember(RecImpConfigFields,...
            RecImpConfigFields_valid));

        % Verify Field Names in Field 2 of Layer 2
        RecImpDataFields_valid = fieldnames(initialiseReceiverImportData);
        RecImpDataFields = fieldnames(NavigationDatabase.RecImpData);
        flag2_layer2 = all(ismember(RecImpDataFields_valid,...
            RecImpDataFields)) && all(ismember(RecImpDataFields,...
            RecImpDataFields_valid));

        % Verify Field Names in Field 3 of Layer 2
        SouImpConfigFields_valid = fieldnames(initialiseSourceImportConfig);   
        SouImpConfigFields = fieldnames(NavigationDatabase.SouImpConfig);
        flag3_layer2 = all(ismember(SouImpConfigFields_valid,...
            SouImpConfigFields)) && all(ismember(SouImpConfigFields,...
            SouImpConfigFields_valid));

        % Verify Field Names in Field 4 of Layer 2
        SouImpDataFields_valid = fieldnames(initialiseSourceImportData);
        SouImpDataFields = fieldnames(NavigationDatabase.SouImpData);
        flag4_layer2 = all(ismember(SouImpDataFields_valid,...
            SouImpDataFields)) && all(ismember(SouImpDataFields,...
            SouImpDataFields_valid));

        % Verify Field Names in Field 5 of Layer 2
        VesImpConfigFields_valid = fieldnames(initialiseVesselImportConfig);   
        VesImpConfigFields = fieldnames(NavigationDatabase.VesImpConfig);
        flag5_layer2 = all(ismember(VesImpConfigFields_valid,...
            VesImpConfigFields)) && all(ismember(VesImpConfigFields,...
            VesImpConfigFields_valid));

        % Verify Field Names in Field 6 of Layer 2
        VesImpDataFields_valid = fieldnames(initialiseVesselImportData);
        VesImpDataFields = fieldnames(NavigationDatabase.VesImpData);
        flag6_layer2 = all(ismember(VesImpDataFields_valid,...
            VesImpDataFields)) && all(ismember(VesImpDataFields,...
            VesImpDataFields_valid));

        % Output is TRUE if All Flags are True
        if flag1_layer2 && flag2_layer2 && flag3_layer2 && flag4_layer2 ...
                && flag5_layer2 && flag6_layer2
            isTrue = true;
        end        
    end
end
