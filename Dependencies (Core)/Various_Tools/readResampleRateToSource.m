%  fr2sou = READRESAMPLERATETOSOURCE(filePath)
%
%  DESCRIPTION
%  Read the content of the 'Resample Rate to Source' JSON file in FILEPATH and
%  returns its content in structure FR2SOU.
%
%  A 'Resample Rate to Source' file holds the relationship between the name of
%  a source and the sampling rate of the audio file (after resampling). The 
%  file is created manually before any data import or processing is carried 
%  out. 
%
%  The relationship once established cannot change. That is why it is very 
%  important to plan in advance which source names will be assigned to which 
%  resampling rate. The relationship can be modified, but that will involve
%  the controlled deletion of data in the Acoustic Databases in '<ROOT.BLOCK>\
%  acousticdb' to maintain consistency with the information in the 'Resample 
%  Rate to Source' file (see UPDATEACOUSTICDATABASES for further details).
%  
%  The FR2SOU structure contains the fields RESAMPLERATE and SOURCENAME. 
%
%  INPUT ARGUMENTS
%  - filePath: absolute path of the 'Resample Rate to Source' JSON file.
%
%  OUTPUT ARGUMENTS
%  - ch2rec: resample rate to source structure that determines the relationship
%    between a SOURCENAME and an audio file RESAMPLERATE. 
%
%  FUNCTION CALL
%  fr2sou = readResampleRateToSource(filePath)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  16 Jul 2021

function fr2sou = readResampleRateToSource(filePath)

if exist(filePath,'file') == 2
    fr2sou = jsondecode(fileread(filePath));
    if numel(fr2sou.sourceName) ~= numel(unique(fr2sou.sourceName))
        fr2sou = [];
        warning(['The ''resampleRateToSource.json'' file contains one '...
            'or more repeated source names'])
    end
else
    fr2sou = [];
    warning(['FILEPATH does not exist. Without ''resampleRateToSource.json'''...
        ' file the Audio Databases to be used for detection cannot be '...
        'identified'])
end
