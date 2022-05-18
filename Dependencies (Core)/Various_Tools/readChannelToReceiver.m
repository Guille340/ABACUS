%  ch2rec = READCHANNELTORECEIVER(filePath)
%
%  DESCRIPTION
%  Read the content of the 'Channel to Receiver' JSON file in FILEPATH and
%  returns its content in structure CH2REC.
%
%  A 'Channel to Receiver' file holds the relationship between the name of
%  a receiver and the audio channel. The file is created manually before
%  any data import or processing is carried out. 
%
%  The relationship once established cannot change. That is why it is very 
%  important to plan in advance which receiver names will be assigned to which 
%  channel. The relationship can be modified, but that will involve the 
%  controlled deletion of data in the Acoustic Databases in '<ROOT.BLOCK>\
%  acousticdb' to maintain consistency with the information in the 'Resample 
%  Rate to Source' file (see UPDATEACOUSTICDATABASES for further details).
%
%  The recommended way to name the receivers is to start with the name of the 
%  platform, followed by the hydrophone number (e.g. 'Buoy1_H1' for channel 1, 
%  'Buoy1_H2' for channel 2).
%
%  The CH2REC structure contains the fields CHANNEL and RECEIVERNAME. 
%
%  INPUT ARGUMENTS
%  - filePath: absolute path of the 'Channel to Receiver' JSON file.
%
%  OUTPUT ARGUMENTS
%  - ch2rec: channel to receiver structure that determines the relationship
%    between a RECEIVERNAME and an audio file CHANNEL. 
%
%  FUNCTION CALL
%  ch2rec = readChannelToReceiver(filePath)
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

function ch2rec = readChannelToReceiver(filePath)

if exist(filePath,'file') == 2
    ch2rec = jsondecode(fileread(filePath));
    if length(ch2rec.channel) ~= length(unique(ch2rec.channel))
        ch2rec = [];
        warning(['The ''channelToReceiver.json'' file contains one '...
            'or more repeated channels'])
    end
    if numel(ch2rec.receiverName) ~= numel(unique(ch2rec.receiverName))
        ch2rec = [];
        warning(['The ''channelToReceiver.json'' file contains one '...
            'or more repeated receiver names'])
    end
else
    ch2rec = [];
    warning(['FILEPATH does not exist. Without ''channelToReceiver.json'' '...
        'file the Audio Databases to be used for detection cannot be '...
        'identified'])
end