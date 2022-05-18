%  AudDetConfigOne = VERIFYAUDIODETECTCONFIG(AudDetConfigOne)
%
%  DESCRIPTION
%  Updates the INPUTSTATUS field in the one-element audio detect configuration 
%  structure AUDDETCONFIGONE. INPUTSTATUS is an error flag used to check if
%  AUDDETCONFIG contains all the necessary information to detect sound events
%  on the audio files in the paths and folders listed in 'audioPaths.json', 
%  in directory '<ROOT.BLOCK>\configdb'. If INPUTSTATUS = FALSE, no detection
%  will be carried out.
%
%  VERIFYAUDIODETECTCONFIG and UPDATEAUDIODETECTCONFIG are both called within 
%  READAUDIODETECTCONFIG. Whilst UPDATEAUDIODETECTCONFIG populates the 
%  individual fields in the audio detect configuration structure and checks 
%  the validity of those individual values, VERIFYAUDIODETECTCONFIG verifies 
%  whether the populated structure contains sufficient information to process 
%  the Audio Database (.mat). The two functions provide two different levels 
%  of error control. Their outcome is combined in a single flag (INPUTSTATUS).
%
%  INPUT ARGUMENTS
%  - AudDetConfigOne: one-element audio detect configuration structure.
%
%  OUTPUT ARGUMENTS
%  - AudDetConfigOne: one-element audio detect configuration structure with 
%    updated INPUTSTATUS field.
%
%  FUNCTION CALL
%  AudDetConfigOne = VERIFYAUDIODETECTCONFIG(AudDetConfigOne)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  See also READAUDIOPROCESSCONFIG, UPDATEAUDIODETECTCONFIG

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  20 Jul 2021

function AudDetConfigOne = verifyAudioDetectConfig(AudDetConfigOne)

inputStatus = true;

if isempty(AudDetConfigOne.channel) ...
        || isempty(AudDetConfigOne.resampleRate) ...
        || isempty(AudDetConfigOne.receiverName) ...
        || isempty(AudDetConfigOne.sourceName)
    inputStatus = false;
end

DetectParameters = AudDetConfigOne.DetectParameters;
if ~isempty(DetectParameters)
    switch AudDetConfigOne.detector
        case 'slice'
            if isempty(DetectParameters.windowDuration)
                inputStatus = false;
            end
        case 'movingaverage'
            if isempty(DetectParameters.windowDuration)
                inputStatus = false;
            end 
        case 'neymanpearson'
            if isempty(DetectParameters.windowDuration) ...
                    || isempty(DetectParameters.kernelDuration) ...
                    || (isempty(DetectParameters.trainFolder) ...
                    && ~strcmpi(DetectParameters.detectorType,'ed'))
                inputStatus = false;
            end             
        case 'constantrate'
            if isempty(DetectParameters.windowDuration) ...
                    || isempty(DetectParameters.fileName)
                inputStatus = false;
            end
    end
end

if isempty(AudDetConfigOne.mirrorReceiver) ...
        && (isempty(AudDetConfigOne.detector) || isempty(DetectParameters)) 
    inputStatus = false;
end 
    
AudDetConfigOne.inputStatus = inputStatus;
