%  SouImpConfigOne = VERIFYSOURCEIMPORTCONFIG(SouImpConfigOne)
%
%  DESCRIPTION
%  Updates the INPUTSTATUS field in the one-element source import configuration 
%  structure SOUIMPCONFIGONE. INPUTSTATUS is an error flag used to check if 
%  SOUIMPCONFIG contains all the necessary information to import the source 
%  informaiton and store it in the Navigation Database 'navigationdb.json' in 
%  directory '<ROOTDIR>\navigationdb'. Any source with INPUTSTATUS = FALSE will 
%  not be processed.
%
%  VERIFYSOURCEIMPORTCONFIG and UPDATESOURCEIMPORTCONFIG are both called within 
%  READSOURCEIMPORTCONFIG. Whilst UPDATESOURCEIMPORTCONFIG populates the 
%  individual fields in the source import config structure and checks the
%  validity of those individual values, VERIFYSOURCEIMPORTCONFIG verifies 
%  whether the populated structure contains sufficient information to import 
%  the source data. The two functions provide two different levels of error 
%  control whose outcome is combined in a single flag (INPUTSTATUS).
%
%  INPUT ARGUMENTS
%  - SouImpConfigOne: source configuration structure.
%
%  OUTPUT ARGUMENTS
%  - SouImpConfigOne: source configuration structure with updated INPUTSTATUS 
%    field.
%
%  FUNCTION CALL
%  SouImpConfigOne = VERIFYSOURCEIMPORTCONFIG(SouImpConfigOne)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  See also READSOURCEIMPORTCONFIG, UPDATESOURCEIMPORTCONFIG 

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  09 Jul 2021

function SouImpConfigOne = verifySourceImportConfig(SouImpConfigOne)

inputStatus = true;

if isempty(SouImpConfigOne.sourceCategory)
    inputStatus = false;
end
if strcmp(SouImpConfigOne.sourceCategory,'fixed') % position set manually
    if isempty(SouImpConfigOne.latitude) || isempty(SouImpConfigOne.longitude)
        inputStatus = false;
    end
else
    if isempty(SouImpConfigOne.positionPaths)
        inputStatus = false;
    else
        if isempty(SouImpConfigOne.positionPlatform)
            inputStatus = false;
        end
        switch SouImpConfigOne.positionFormat
            case 'ais'
                if ~strcmp(SouImpConfigOne.sourceCategory,'fleet') ...
                        && isempty(SouImpConfigOne.mmsi)
                    inputStatus = false;
                end
            case 'p190'
                if isempty(SouImpConfigOne.vesselId)
                    inputStatus = false;
                end
                % Note: 'towed' and 'vessel' require VESSELID, but SOURCEID
                % is not strictly necessary since SOURCEOFFSET is always
                % available (SOURCEOFFSET = [0 0 0] when input is incorrect)
        end
    end
end
if any(strcmp(SouImpConfigOne.sourceCategory,{'fixed','towed'})) ...
        && isempty(SouImpConfigOne.depth)
    inputStatus = false;
end

SouImpConfigOne.inputStatus = inputStatus;
