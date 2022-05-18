%  NavProConfigOne = VERIFYNAVIGATIONPROCESSCONFIG(AudImpConfigOne)
%
%  DESCRIPTION
%  Updates the INPUTSTATUS field in the one-element navigation process 
%  configuration structure NAVPROCONFIGONE. INPUTSTATUS is an error flag used 
%  to check if NAVPROCONFIG contains all the necessary information to process 
%  the navigation parameters of receiver, sources and vessels at the times of
%  the detections. If INPUTSTATUS = FALSE, no processing of navigation 
%  parameters will be carried out.
%
%  VERIFYNAVIGATIONPROCESSCONFIG and UPDATENAVIGATIONPROCESSCONFIG are both 
%  called within READNAVIGATIONDETECTCONFIG. UPDATENAVIGATIONPROCESSCONFIG 
%  populates the individual fields in the navigation process configuration 
%  structure and checks the validity of those individual values, whereas
%  VERIFYNAVIGATIONPROCESSCONFIG verifies whether the populated structure 
%  contains sufficient information to process navigation data. The two 
%  functions provide two different levels of error control. Their outcome is 
%  combined in a single flag (INPUTSTATUS).
%
%  INPUT ARGUMENTS
%  - NavProConfigOne: one-element navigation process configuration structure.
%
%  OUTPUT ARGUMENTS
%  - NavProConfigOne: one-element navigaiton process configuration structure 
%    with updated INPUTSTATUS field.
%
%  FUNCTION CALL
%  NavProConfigOne = VERIFYNAVIGATIONPROCESSCONFIG(NavProConfigOne)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  See also READNAVIGATIONPROCESSCONFIG, UPDATENAVIGATIONPROCESSCONFIG

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  20 Jul 2021

function NavProConfigOne = verifyNavigationProcessConfig(NavProConfigOne)

inputStatus = true;
if isempty(NavProConfigOne.channel) ...
        || isempty(NavProConfigOne.resampleRate) ...
        || isempty(NavProConfigOne.receiverName) ...
        || isempty(NavProConfigOne.sourceName)
    inputStatus = false;
end
NavProConfigOne.inputStatus = inputStatus;

