%  VesselDatabase = READVESSELDATABASE(filePath)
%
%  DESCRIPTION
%  Reads the vessel information from the Vessel Database (.csv) in absolute
%  path FILEPATH. A Vessel Database contains the MMSI number, name, dimensions 
%  and weight of a number of vessels. This database is stored in the same 
%  directory as the Navigation Database (.mat) ('<ROOT.BLOCK>\navigationdb').
%
%  The Vessel Database must contain two or more of the following fields: 
%  'mmsi','vesselName','vesselLength','vesselBeam','vesselDraft', and 
%  'vesselGrossTonnage'. The fields appear as comma-separated words in 
%  the first line of the .csv file. The 'mmsi' field must always be present.
%  The order of the fields in the .csv file does not affect the validity
%  of the file. It is advisable to include 'vesselName' whenever possible.
%
%  The .csv file is populated manually by linking the MMSI numbers
%  from the recorded AIS data to the corresponding vessel information
%  from a source such as Marine Traffic (https://www.marinetraffic.com/).
%
%  An example of the first few lines of a typical Vessel Database file is
%  shown below. Note that the header (first line) includes the properties
%  and each consecutive line relates to a different vessel.
%
%  mmsi,vesselName,vesselLength,vesselBeam,vesselDraft,vesselGrossTonnage
%  218582000,MSC Charleston,324.9,42.8,,89954
%  232005097,Autonaut Islay,,,,
%  236483000,Sanco Star,80,16,,3953
%  239962000,Makronissos,244,42,,57062
%  240953000,United Grace,250,44,,62775
%
%  A Vessel Database is not strictly needed, but it becomes particularly 
%  useful when representing the vessels in the Operations Map, with their
%  particular sizes and names. If a Vessel Database does not exist, the AIS 
%  data itself will be used to fill in any vessel-related information other 
%  than position (typically name and draft). Note that AIS files may not 
%  include detailed information about the vessels (MMSI and position are
%  the only properties that are guaranteed to be always available).
%
%  INPUT ARGUMENTS
%  - filePath: absolute path of vessel information table (.csv)
%
%  OUTPUT ARGUMENTS
%  - VesselDatabase: structure containing the source (vessel) information 
%    stored in the .csv table.
%
%  FUNCTION CALL
%  VesselDatabase = readVesselDatabase(filePath)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%    
%  See also ISVESSELDATABASE, SOURCEIMPORTFUN

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  19 Jul 2018

function VesselDatabase = readVesselDatabase(filePath)

% Initialise Vessel Database
VesselDatabase = struct('mmsi',[],'vesselName',[],'vesselLength',[],...
    'vesselBeam',[],'vesselDraft',[],'vesselGrossTonnage',[]);

% Read Vessel Database (if available)
isVesseldb = isVesselDatabase(filePath);
if exist(filePath,'file') == 2 && isVesseldb
    
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
    fieldNames = fieldNames{1};
    nFields = numel(fieldNames);

    % Remove Lines with Wrong Number of Commas
    nVessels = numel(data);
    nCommas = uint8(zeros(1,nVessels));
    for m = 1:nVessels
        nCommas(m) = uint8(length(find(data{m}==',')));
    end
    data(nCommas ~= nFields-1) = [];

    % Split Sentences into Fields
    datatxt = textscan([char(data) repmat(',',nVessels,1)]','%s','delimiter',',');
    datatxt = reshape(datatxt{1},nFields,nVessels)';
    clear data
    
    % Retrieve Parameters
    for m = 1:nFields
        switch fieldNames{m}
            case 'mmsi'
                iField = find(strcmp('mmsi',fieldNames),1,'first');
                mmsi = str2double(datatxt(:,iField));
            case 'vesselName'
                iField = find(strcmp('vesselName',fieldNames),1,'first');
                vesselName = deblank(datatxt(:,iField));
            case 'vesselLength'
                iField = find(strcmp('vesselLength',fieldNames),1,'first');
                vesselLength = str2double(datatxt(:,iField));
            case 'vesselBeam'
                iField = find(strcmp('vesselBeam',fieldNames),1,'first');
                vesselBeam = str2double(datatxt(:,iField));
            case 'vesselDraft'
                iField = find(strcmp('vesselDraft',fieldNames),1,'first');
                vesselDraft = str2double(datatxt(:,iField));
            case 'vesselGrossTonnage'
                iField = find(strcmp('vesselGrossTonnage',fieldNames),1,...
                    'first');
                vesselGrossTonnage = str2double(datatxt(:,iField));
        end
    end
    clear datatxt
                
    % Remove Sentences with Duplicated and Non-Valid MMSI
    if ~isempty(mmsi)
        % Find Indices for Valid and Unique Sentences
        nDigits = floor(log10(mmsi)) + 1;
        iValidMmsiLogical = nDigits == 9;
        [~,iUniqueMmsi] = unique(mmsi,'stable');
        iUniqueMmsiLogical = false(size(mmsi));
        iUniqueMmsiLogical(iUniqueMmsi) = true;
        iValid = iValidMmsiLogical & iUniqueMmsiLogical;   
        
        % Remove Non-Valid and Duplicated-MMSI Sentences
        mmsi = mmsi(iValid);
        vesselName = vesselName(iValid);
        vesselLength = vesselLength(iValid);
        vesselBeam = vesselBeam(iValid);
        vesselDraft = vesselDraft(iValid);
        vesselGrossTonnage = vesselGrossTonnage(iValid);
    else
        mmsi = [];
        vesselName = '';
        vesselLength = [];
        vesselBeam = [];
        vesselDraft = [];
        vesselGrossTonnage = [];
        warning(['The MMSI field was not found in the Vessel Database '...
            '''vesseldb.csv''. The Vessel Database will be ignored'])
    end
        
    % Generate Vessel Database Structure
    VesselDatabase(1).mmsi = mmsi;
    VesselDatabase(1).vesselName = vesselName;
    VesselDatabase(1).vesselLength = vesselLength;
    VesselDatabase(1).vesselBeam = vesselBeam;
    VesselDatabase(1).vesselDraft = vesselDraft;
    VesselDatabase(1).vesselGrossTonnage = vesselGrossTonnage;
    
else
    warning(['No Vessel Database ''vesseldb.csv'' was found under '...
        '''<ROOT.BLOCK>/configdb''. An attempt will be made to '...
        'extract the vessel information from the AIS file(s)'])
end
