%  AudImpConfigOne = VERIFYAUDIOIMPORTCONFIG(AudImpConfigOne)
%
%  DESCRIPTION
%  Updates the INPUTSTATUS field in the one-element audio import configuration 
%  structure AUDIMPCONFIGONE. INPUTSTATUS is an error flag used to check if
%  AUDIMPCONFIG contains all the necessary information to import and resample 
%  the audio files in the paths and folders listed in 'audioPaths.json' in 
%  directory '<ROOTDIR>\configdb'. If INPUTSTATUS = FALSE, no audio files
%  will be imported.
% 
%  VERIFYAUDIOIMPORTCONFIG and UPDATEAUDIOIMPORTCONFIG are both called
%  within READAUDIODETECTCONFIG. Whilst UPDATEAUDIODETECTCONFIG populates 
%  the individual fields in the audio detect config structure and checks the
%  validity of those individual values, VERIFYAUDIODETECTCONFIG verifies 
%  whether the populated structure contains sufficient information to process 
%  the Audio Database (.mat). The two functions provide two different levels 
%  of error control whose outcome is combined in a single flag (INPUTSTATUS).
%
%  INPUT ARGUMENTS
%  - AudImpConfigOne: audio import configuration structure.
%
%  OUTPUT ARGUMENTS
%  - AudImpConfigOne: audio import configuration structure with updated 
%    INPUTSTATUS field.
%
%  FUNCTION CALL
%  AudImpConfigOne = VERIFYAUDIOIMPORTCONFIG(AudImpConfigOne)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  See also READAUDIOIMPORTCONFIG, UPDATEAUDIOIMPORTCONFIG

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  06 Jul 2021

function AudImpConfigOne = verifyAudioImportConfig(AudImpConfigOne)

inputStatus = true;

if isempty(AudImpConfigOne.channel) || isempty(AudImpConfigOne.resampleRate)
    inputStatus = false;
end
if strcmp(AudImpConfigOne.audioFormat,'raw') ...
        && ((isempty(AudImpConfigOne.sampleRate) ...
        || isempty(AudImpConfigOne.bitDepth) ...
        || isempty(AudImpConfigOne.numChannels) ...
        || isempty(AudImpConfigOne.endianness)))
    inputStatus = false;
end
AudImpConfigOne.inputStatus = inputStatus;
