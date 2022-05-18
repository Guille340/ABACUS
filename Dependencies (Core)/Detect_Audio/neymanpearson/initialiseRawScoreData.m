%  RawScoreData = initialiseRawScoreData()
%
%  DESCRIPTION
%  Initialises the raw score data structure RAWSCOREDATA. All the fields 
%  in this structure are set as empty ([]). Function RAWSCORES generates a 
%  populated version of RAWSCOREDATA (i.e., with non-empty values).
%
%  For details about the fields in RAWSCOREDATA see RAWSCORES.
%
%  INPUT ARGUMENTS
%  - None
%
%  OUTPUT ARGUMENTS
%  - RawScoreData: initialised raw score data structure.
%
%  FUNCTION CALL
%  RawScoreData = initialiseRawScoreData()
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  02 Mar 2022

function RawScoreData = initialiseRawScoreData()

RawScoreData = struct('kernelDuration',[],'sampleRate',[],...
    'minSnrLevel',[],'snrLevels',[],'rawScoreMatrix',[]);
