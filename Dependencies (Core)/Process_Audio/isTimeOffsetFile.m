%  isTrue = ISTIMEOFFSETFILE(filePath)
%
%  DESCRIPTION
%  TRUE if the file with absolute path FILEPATH exits and is a Time Offset
%  (.csv) file. FALSE if FILEPATH exists but is not a Time Offset file.
%  -1 if FILEPATH does not exist.
%
%  A Time Offset (.csv) file informs about the offset that exists in the PC
%  time at different instants with respect to UTC. This information is used
%  to correct the PC times and allow for precise syncing between detected
%  audio events and navigation data.
%
%  A file is considered a Time Offset table if: 
%   1. It is a .csv file.
%   2. The header (first line) includes the 'timestamp_yyyymmddthhmmss'
%      and 'timeoffset_s' fields.
%   3. All the names in the header (first line) are valid fields.
%  
%  INPUT ARGUMENTS 
%  - filePath: absolute path of Time Offset file (.csv).
%
%  OUTPUT ARGUMENTS
%  - isTrue: TRUE if the specified file is a Time Offset file, FALSE if 
%    is not, and -1 if the file doesn't exist.
%
%  FUNCTION CALL
%  isTrue = isTimeOffsetFile(filePath)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  See also READTIMEOFFSET

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  12 Aug 2021

function isTrue = isTimeOffsetFile(filePath)

isTrue = -1; % initialise to -1 (= non-existent file)

if exist(filePath,'file') == 2
    % Read Header from .csv File (first line)
    fid = fopen(filePath);
    data = textscan(fid,'%s','delimiter','\n');
    header = data{1}{1};
    fclose(fid);

    % Extract Field Names from Header
    fieldNames = textscan(header,'%s','delimiter',',');
    fieldNames = lower(fieldNames{1});
    fieldNames_valid = {'timestamp_yyyymmddthhmmss','timeoffset_s'};

    % Verify Database
    isTrue = all(ismember(fieldNames,fieldNames_valid)) ...
        && all(ismember(fieldNames_valid,fieldNames));
end
