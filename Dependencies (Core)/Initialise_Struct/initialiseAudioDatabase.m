%  AudioDatabase = INITIALISEAUDIODATABASE()
%
%  DESCRIPTION
%  Initialises the AUDIODATABASE structure. The initialised structure contains 
%  all the fields and subfields down to the lowest level. All fields that are 
%  not structures are set as empty ([]).
%
%  AUDIODATABASE contains two structures: AUDIMPCONFIG and AUDIMPDATA. Both are 
%  one-element structures. Note that AUDIMPCONFIG and AUDIMPDATA contain no 
%  information, other than the structure fields.
%
%  For details about the fields in AUDIMPCONFIG and AUDIMPDATA see functions
%  INITIALISEAUDIOIMPORTCONFIG and INITIALISEAUDIOIMPORTDATA.
%
%  INPUT ARGUMENTS
%  - None
%
%  OUTPUT ARGUMENTS
%  - AudioDatabase: initialised Audio Database structure.
%
%  FUNCTION CALL
%  AudioDatabase = initialiseAudioDatabase()
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

function AudioDatabase = initialiseAudioDatabase()

AudImpConfig = initialiseAudioImportConfig();
AudImpData = initialiseAudioImportData();

AudioDatabase.AudImpConfig = AudImpConfig;
AudioDatabase.AudImpData = AudImpData;