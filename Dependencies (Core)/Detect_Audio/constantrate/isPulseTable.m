%  isTrue = ISPULSETABLE(filePath)
%
%  DESCRIPTION
%  TRUE is the file with absolute path FILEPATH exits and is a Pulse 
%  Table. FALSE if FILEPATH exists but is not a Pulse Table.
%  -1 if FILEPATH does not exist.
%
%  A Pulse Table is a .csv file containing information required for
%  the Constant Rate detection (see DETECTORCONSTANTRATE). The table
%  must contain the fields 'audioname','firstpulse_s', and 
%  'pulseinterval_ms' (case and order insensitive).
%
%  A file is considered a Pulse Table if: 
%   1. It is a .csv file.
%   2. The header (first line) includes the fields 'audioname','firstpulse_s', 
%      and 'pulseinterval_ms'.
%   3. All the names in the header (first line) are valid fields.
%  
%  INPUT ARGUMENTS 
%  - filePath: absolute path of Pulse Table (.csv).
%
%  OUTPUT ARGUMENTS
%  - isTrue: TRUE is the specified file is a Pulse Table, FALSE if it's not 
%    a Pulse Table, and -1 if it doesn't exist.
%
%  FUNCTION CALL
%  isTrue = isPulseTable(filePath)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  See also READPULSETABLE

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  06 Aug 2021

function isTrue = isPulseTable(filePath)

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
    fieldNames_valid = {'audioname','firstpulse_s','pulseinterval_ms'};

    % Verify Database
    isTrue = all(ismember(fieldNames,fieldNames_valid)) ...
        && all(ismember(fieldNames_valid,fieldNames));
end
