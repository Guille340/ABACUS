%  isTrue = ISVESSELDATABASE(vesseldbPath)
%
%  DESCRIPTION
%  TRUE if the file in absolute path VESSELDBPATH exits and is a Vessel 
%  Database. FALSE if VESSELDBPATH exists but is not a Vessel Database.
%  -1 if VESSELDBPATH does not exist.
%
%  A Vessel Database is a .csv file containing information for several
%  vessels. This information is used to fill the gaps existing in the AIS 
%  data regarding vessel properties.
%
%  A file is considered a Vessel Database if: 
%   1. It is a .csv file.
%   2. The header (first line) includes the 'mmsi' field.
%   3. All the names in the header (first line) are valid fields.
%
%  The Vessel Database must contain the 'mmsi' field and one or more of
%  the following: 'vesselName','vesselLength','vesselBeam','vesselDraft', 
%  and 'vesselGrossTonnage'. It is advisable to include 'vesselName' 
%  whenever possible.
%  
%  INPUT ARGUMENTS 
%  - vesseldbPath: absolute path of Vessel Database (.csv).
%
%  OUTPUT ARGUMENTS
%  - isTrue: TRUE is the specified file is a Vessel Database, FALSE if it's 
%    not a Vessel Database, and -1 if it doesn't exist.
%
%  FUNCTION CALL
%  isTrue = ISVESSELDATABASE(vesseldbPath)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  See also READVESSELDATABASE

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  12 Jul 2021

function isTrue = isVesselDatabase(vesseldbPath)

isTrue = -1; % initialise to -1 (= non-existent file)

if exist(vesseldbPath,'file') == 2
    % Read Header from .csv File (first line)
    fid = fopen(vesseldbPath);
    data = textscan(fid,'%s','delimiter','\n');
    header = data{1}{1};
    fclose(fid);

    % Extract Field Names from Header
    fieldNames = textscan(header,'%s','delimiter',',');
    fieldNames = fieldNames{1};
    fieldNames_valid = {'mmsi','vesselName','vesselLength','vesselBeam',...
        'vesselDraft','vesselGrossTonnage'};

    % Verify Database
    isTrue = all(ismember(fieldNames,fieldNames_valid)) ...
        && ismember('mmsi',fieldNames);
end
