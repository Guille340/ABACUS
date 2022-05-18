%  AudProConfigOne = VERIFYAUDIOPROCESSCONFIG(AudImpConfigOne)
%
%  DESCRIPTION
%  Updates the INPUTSTATUS field in the one-element audio process configuration 
%  structure AUDPROCONFIGONE. INPUTSTATUS is an error flag used to check if
%  AUDPROCONFIG contains all the necessary information to process sound events
%  from the audio files in the paths and folders listed in 'audioPaths.json', 
%  in directory '<ROOT.BLOCK>\configdb'. If INPUTSTATUS = FALSE, no processing
%  of acoustic metrics will be carried out.
%
%  VERIFYAUDIOPROCESSCONFIG and UPDATEAUDIOPROCESSCONFIG are both called within 
%  READAUDIODETECTCONFIG. Whilst UPDATEAUDIOPROCESSCONFIG populates the 
%  individual fields in the audio process configuration structure and checks 
%  the validity of those individual values, VERIFYAUDIOPROCESSCONFIG verifies 
%  whether the populated structure contains sufficient information to process 
%  the Audio Database (.mat). The two functions provide two different levels 
%  of error control. Their outcome is combined in a single flag (INPUTSTATUS).
%
%  INPUT ARGUMENTS
%  - AudProConfigOne: one-element audio process configuration structure.
%
%  OUTPUT ARGUMENTS
%  - AudProConfigOne: one-element audio process configuration structure with 
%    updated INPUTSTATUS field.
%
%  FUNCTION CALL
%  AudProConfigOne = VERIFYAUDIOPROCESSCONFIG(AudProConfigOne)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  See also READAUDIOPROCESSCONFIG, UPDATEAUDIOPROCESSCONFIG

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  20 Jul 2021

function AudProConfigOne = verifyAudioProcessConfig(AudProConfigOne)

inputStatus = true;
if isempty(AudProConfigOne.channel) ...
        || isempty(AudProConfigOne.resampleRate) ...
        || isempty(AudProConfigOne.receiverName) ...
        || isempty(AudProConfigOne.sourceName) ...
        || isempty(AudProConfigOne.audioTimeFormat)
    inputStatus = false;
end
AudProConfigOne.inputStatus = inputStatus;

