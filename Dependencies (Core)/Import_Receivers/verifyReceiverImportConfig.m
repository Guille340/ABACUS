%  RecImpConfigOne = VERIFYRECEIVERIMPORTCONFIG(RecImpConfigOne)
%
%  DESCRIPTION
%  Updates the INPUTSTATUS field in the one-element receiver import 
%  configuration structure RECIMPCONFIGONE. INPUTSTATUS is an error flag used 
%  to check if RECIMPCONFIG contains all the necessary information to import 
%  the receiver information and store it in the Navigation Database 
%  'navigationdb.json' in directory '<ROOT.BLOCK>\navigationdb'. Any receiver 
%  with INPUTSTATUS = FALSE will not be processed.
%
%  VERIFYRECEIVERIMPORTCONFIG and UPDATERECEIVERIMPORTCONFIG are both called
%  within READRECEIVERIMPORTCONFIG. Whilst UPDATERECEIVERIMPORTCONFIG populates 
%  the individual fields in the receiver import config structure and checks the
%  validity of those individual values, VERIFYRECEIVERIMPORTCONFIG verifies 
%  whether the populated structure contains sufficient information to import 
%  the receiver data. The two functions provide two different levels of error 
%  control whose outcome is combined in a single flag (INPUTSTATUS).
%
%  INPUT ARGUMENTS
%  - RecImpConfigOne: receiver configuration structure.
%
%  OUTPUT ARGUMENTS
%  - RecImpConfigOne: receiver configuration structure with updated INPUTSTATUS 
%    field.
%
%  FUNCTION CALL
%  RecImpConfigOne = VERIFYRECEIVERIMPORTCONFIG(RecImpConfigOne)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  See also READRECEIVERIMPORTCONFIG, UPDATERECEIVERIMPORTCONFIG 

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  09 Jul 2021

function RecImpConfigOne = verifyReceiverImportConfig(RecImpConfigOne)

inputStatus = true;

if isempty(RecImpConfigOne.receiverName)
    inputStatus = false;
end
if isempty(RecImpConfigOne.receiverCategory)
    inputStatus = false;
end
if strcmp(RecImpConfigOne.receiverCategory,'fixed') % if position is set manually
    if isempty(RecImpConfigOne.latitude) || isempty(RecImpConfigOne.longitude)
        inputStatus = false;
    end
else % if position is determined from files ('towed')
    if isempty(RecImpConfigOne.positionPaths)
        inputStatus = false;
    else
        if isempty(RecImpConfigOne.positionPlatform)
            inputStatus = false;
        end
        switch RecImpConfigOne.positionFormat
            case 'ais'
                if isempty(RecImpConfigOne.mmsi)
                    inputStatus = false;
                end
            case 'p190'
                if isempty(RecImpConfigOne.vesselId)
                    inputStatus = false;
                end   
        end
    end
end
if isempty(RecImpConfigOne.depth) && (isempty(RecImpConfigOne.depthSensor)...
        || isempty(RecImpConfigOne.depthDirectories))
    inputStatus = false;
end

RecImpConfigOne.inputStatus = inputStatus;
