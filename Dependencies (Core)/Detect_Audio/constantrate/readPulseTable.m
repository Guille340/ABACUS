%  PulseTable = readPulseTable(filePath)
%
%  DESCRIPTION
%  Reads the information from the Pulse Table (.csv) stored in '<ROOTDIR>\
%  navigationdb'. 
%
%  A Pulse Table is a .csv file containing information required for
%  the Constant Rate detection (see DETECTORCONSTANTRATE). The table
%  must contain the fields 'audioname','firstpulse_s', and 
%  'pulseinterval_ms' (case and order insensitive). The .csv file is populated 
%  manually with the information obtained after inspecting the audio files
%  and determining the pulse interval and time of first pulse.
%
%  An example of the first few lines of a typical Pulse Table file is
%  shown below. Note that the header (first line) includes the properties
%  and each consecutive line relates to a different audio file.
%
%  FirstPulse_s,PulseInterval_ms,AudioName
%  0.790,1000,20140406_172730_9730629_0.raw2int16
%  0.394,1000,20140406_181814_4589586_268435456.raw2int16
%  0.160,1000,20140406_190857_9448543_536870912_ch1_fr96000.raw2int16
%
%  INPUT ARGUMENTS
%  - fpath: absolute path of pulse table (.csv)
%
%  OUTPUT ARGUMENTS
%  - PulseTable: structure containing the information stored in the .csv 
%    pulse table.
%
%  FUNCTION CALL
%  PulseTable = READPULSETABLE(filePath)
%
%  FUNCTION DEPENDENCIES
%  - isPulseTable
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%    
%  See also ISPULSETABLE, DETECTORCONTACTRATE

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  19 Jul 2018

function PulseTable = readPulseTable(filePath)

% Read Pulse Table (if available)
[~,fileName,fileExt] = fileparts(filePath);
PulseTable = [];
isTable = isPulseTable(filePath);
if isTable == true
    
    % Open .csv File
    fid = fopen(filePath);
    data = textscan(fid,'%s','delimiter','\n');
    data = data{1};
    header = data{1};
    data(1) = []; % remove header (column names)
    fclose(fid);

    % Remove repeated sentences
    data = unique(data,'stable');
    
    % Extract Table Fields
    fieldNames = textscan(header,'%s','delimiter',',');
    fieldNames = lower(fieldNames{1});
    nFields = numel(fieldNames);

    % Number of Commas per Line
    nLines = numel(data);
    nCommas = uint8(zeros(1,nLines));
    for m = 1:nLines
        nCommas(m) = uint8(length(find(data{m}==',')));
    end
  
    % Remove Lines with Wrong Number of Commas
    isWrongCommas = nCommas ~= nFields - 1;
    if any(isWrongCommas)
        data(isWrongCommas) = [];
        warning(['One or more lines in ''%s'' include a wrong number of '...
            'commas '',''. Those lines will be ignored'],...
            strcat(fileName,fileExt))
    end

    % Split Sentences into Fields
    nLines = numel(data);
    datatxt = textscan([char(data) repmat(',',nLines,1)]','%s','delimiter',',');
    datatxt = reshape(datatxt{1},nFields,nLines)';
    clear data
    
    % Retrieve Parameters
    for m = 1:nFields
        switch fieldNames{m}
            case 'firstpulse_s'
                iField = find(strcmp('firstpulse_s',fieldNames),1,'first');
                firstPulse = str2double(datatxt(:,iField));
            case 'pulseinterval_ms'
                iField = find(strcmp('pulseinterval_ms',fieldNames),1,'first');
                pulseInterval = str2double(datatxt(:,iField));
            case 'audioname'
                iField = find(strcmp('audioname',fieldNames),1,'first');
                audioName = datatxt(:,iField);
        end
    end
    clear datatxt
        
    % Generate Pulse Structure
    PulseTable(1).audioName = audioName;
    PulseTable(1).firstPulse = firstPulse;
    PulseTable(1).pulseInterval = pulseInterval;
else
    if isTable == -1 
        warning(['Pulse table ''%s'' was not found under ''ROOTDIR>\\'...
            'configdb'' directory'],strcat(fileName,fileExt))
    else
        warning('''%s'' is not a valid pulse table',strcat(fileName,fileExt))
    end
end
