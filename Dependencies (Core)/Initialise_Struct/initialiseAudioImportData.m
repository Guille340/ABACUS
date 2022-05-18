%  AudImpData = INITIALISEAUDIOIMPORTDATA()
%
%  DESCRIPTION
%  Initialises the audio import data structure AUDIMPDATA. All the fields in 
%  this structure are set as empty ([]).
%
%  The fields in AUDIMPDATA are described below.
%
%  AUDIMPDATA
%  ============
%  - audioPath: absolute path of the audio file.
%  - audioData: single-precision resampled audio data.
%
%  INPUT ARGUMENTS
%  - None
%
%  OUTPUT ARGUMENTS
%  - AudImpData: initialised audio import data structure.
%
%  FUNCTION CALL
%  AudImpData = initialiseAudioImportData()
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  18 Jun 2021

%  #AudImpData# (see READAUDIOIMPORTCONFIG for details)
%  - audioPath: absolute path of audio file
%  - audioData: floating-point audio data.

function AudImpData = initialiseAudioImportData()

AudImpData = struct('audioPath',[],'audioData',[]);