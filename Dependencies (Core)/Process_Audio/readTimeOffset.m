%  [tick,timeOffset] = READTIMEOFFSET(filePath)
%
%  DESCRIPTION
%  Reads the time offset and timestamp information from the Time Offset (.csv) 
%  file in absolute path FILEPATH
%
%  A Time Offset (.csv) file informs about the offset that exists in the PC
%  time at different instants with respect to UTC. The table contains two
%  fields: 'Timestamp_yyyymmddTHHMMSS' and 'TimeOffset_s'. The first is a 
%  timestamp with format 'yyyymmddTHHMMSS', where "y,m,d,H,M,S" represent one 
%  digit of the year, month, day, hour, minute and second and T is a special 
%  character indicating the start of the time format. The second is the offset
%  of the PC time with respect to UTC, in seconds (<UTCTime> = <PCTime> 
%  - TIMEOFFSET_s).  
%
%  The information in the Time Offset file is used to correct the PC time so 
%  that the audio data can be synced with the navigation information for each 
%  processed sound event. Time offsets of standard PC audio cards with cheap 
%  oscillators are typically of the order of 10 microseconds per second (~0.9
%  seconds per day). Thus, the time offset can be considered constant within an 
%  audio file and in most cases using a constant time offset or even a constant 
%  time offset for each audio file is sufficient.
%
%  In some extreme cases, the recording platform may have experienced frequent 
%  loss of large audio packages. In that scenario, you may want to specify time 
%  offsets within the audio files (if those offsets can be found in some way).
%
%  An example of the first few lines of a typical Time Offset file is shown 
%  below. Note that the header (first line) includes the fields and each 
%  consecutive line relates to a different timestamp.
%
%  Timestamp_yyyymmddTHHMMSS,TimeOffset_s
%  20210801T102000,3600
%  20210801T102100,3601
%  20210801T102200,3602
%
%  INPUT ARGUMENTS
%  - filePath: absolute path of time offset information table (.csv)
%
%  OUTPUT ARGUMENTS
%  - tick: vector of ticks in seconds referred to '00 Jan 0000'. The ticks are 
%    the absolute numeric representation of the timestamp character vectors
%    in the time offset file.
%  - timeOffset: vector of time offsets in seconds associated with each tick.
%
%  FUNCTION CALL
%  [tick,timeOffset] = readTimeOffset(filePath)
%
%  FUNCTION DEPENDENCIES
%  - isTimeOffsetFile
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%    
%  See also ISTIMEOFFSETFILE, AUDIOPROCESSFUN

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  09 Aug 2018

function [tick,timeOffset] = readTimeOffset(filePath)

% Read Time Offset File (if available)
if isTimeOffsetFile(filePath)
    
    % Open .csv File
    fid = fopen(filePath);
    data = textscan(fid,'%s','delimiter','\n');
    data = data{1};
    header = data{1};
    data(1) = []; % remove header (column names)
    fclose(fid);

    % Remove repeated sentences
    data = unique(data,'stable');
    nLines = numel(data);
    
    if nLines > 0
    
        % Extract Table Fields
        fieldNames = textscan(header,'%s','delimiter',',');
        fieldNames = lower(fieldNames{1});
        nFields = numel(fieldNames);

        % Split Sentences into Fields
        datatxt = textscan([char(data) repmat(',',nLines,1)]','%s',...
            'delimiter',',');
        datatxt = reshape(datatxt{1},nFields,nLines)';
        clear data

        % Retrieve Parameters
        for m = 1:nFields
            switch fieldNames{m}
                case 'timestamp_yyyymmddthhmmss'
                    iField = find(strcmp('timestamp_yyyymmddthhmmss',...
                        fieldNames),1,'first');
                    tstamp = datatxt(:,iField);
                    tick = datenum(tstamp,'yyyymmddTHHMMSS')*86400;
                case 'timeoffset_s'
                    iField = find(strcmp('timeoffset_s',fieldNames),1,'first');
                    timeOffset = str2double(datatxt(:,iField));
            end
        end
        clear datatxt

        % Remove Sentences with Duplicated Timestamp
        [~,iUnique] = unique(tstamp);
        tick = tick(iUnique);
        timeOffset = timeOffset(iUnique);
    else
        tick = [];
        timeOffset = 0;
        warning(['The time offset file ''timeOffset.csv'' in <ROOTDIR>\\'...
            'configdb\\ contains no data lines'])
    end
else
    tick = [];
    timeOffset = 0;
    warning(['No time offset file ''timeOffset.csv'' was found under '...
        '''<ROOTDIR>/configdb'''])
end
