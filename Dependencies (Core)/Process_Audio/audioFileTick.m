%  fileTick = AUDIOFILETICK(fileName,tstampFormat)
%
%  DESCRIPTION
%  Returns the absolute time of the start of the audio file FILETICK, in 
%  seconds, referred to ’00 Jan 0000’. The name in the audio file represents 
%  the timestamp (date and time) of its first sample. The function takes the 
%  name of the audio file AUDIONAME and the naming format TSTAMPFORMAT of the 
%  audio file to calculate FILETICK.
%
%  INPUT ARGUMENTS
%  - fileName: name of the audio file (with or without extension).
%  - tstampFormat: naming format of the audio file. The characters y, m,d, H, 
%    M, S and F are reserved to represent individual digits of the year, month, 
%    day, hour, minute, second and mantissa (floating part decimal second). The
%    wildcard '*' can be used to ignore any characters at the start or end
%    of the file. For example, Seiche systems use three timestamp formats: 
%    ¬ '*yyyymmdd_HHMMSS_FFF' for PAMGuard.
%    ¬ 'yyyymmdd_HHMMSS_FFF*' for SeicheSSV. 
%    ¬ '*yyyymmdd_HHMMSS' for Wildlife Acoustics ARU.
%
%  OUTPUT ARGUMENTS
%  - fileTick: absolute start time (tick) of the audio file, in seconds 
%    referred to ’00 Jan 0000’.
%
%  INTERNALLY CALLED FUNCTIONS
%  - None
%
%  FUNCTION CALLS
%  fileTick = AUDIOFILETICK(fileName,tstampFormat)
%     For zero-sample timestamp embedded in the file's name:
%     ¬ tstampFormat = '*yyyymmdd_HHMMSS_FFF' for PAMGuard.
%     ¬ tstampFormat = 'yyyymmdd_HHMMSS_FFF*' for SeicheSSV. 
%     ¬ tstampFormat = '*yyyymmdd_HHMMSS' for Wildlife Acoustics ARU.

%  VERSION 1.2 (08 Aug 2021)
%  - Simplified version using only an starting or ending wildcard '*'.
%  - Removed option to extract the "last modified" time.
%
%  VERSION 1.1 (19 Mar 2021)
%  - Added option to extract the "last modified" time, in seconds, with
%    millisecond precision. Useful when PAMGuard is used to process an
%    audio file recorded with other software.
%
%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  18 Mar 2021

function fileTick = audioFileTick(fileName,tstampFormat)

% Remove Extension (if any) from FILENAME
iDot = find(fileName == '.',1,'last');
if ~isempty(iDot)
    fileName = fileName(1:iDot-1);
end

% Remove Extension (if any) from TSTAMPFORMAT
iDot = find(tstampFormat == '.',1,'last');
if ~isempty(iDot)
    tstampFormat = tstampFormat(1:iDot-1);
end

if ~isempty(tstampFormat)    
    % Remove Consecutive '*' Characters
    iChar = find(tstampFormat == '*');
    if ~isempty(iChar)
        iDeleteFormat = iChar(find(diff(iChar) == 1) + 1);
        tstampFormat(iDeleteFormat) = '';
    end
         
    % Extract Timestamp Format and Trimmed File Name
    iChar = find(tstampFormat == '*'); % recalculate wildcard index
    nChar = length(iChar); % number of wildcards (0 or 1)
    nCharFileName = length(fileName); % length of FILENAME
    nCharFormat = length(tstampFormat) - nChar; % length of TSTAMPFORMAT without '*'
    if nChar % if one wildcard '*'
        if iChar == 1 
            tstampFormat = tstampFormat(2:end);
            fileName = fileName(nCharFileName - nCharFormat + 1:nCharFileName);
        elseif iChar == nCharFormat+1
            tstampFormat = tstampFormat(1:end-1);
            fileName = fileName(1:nCharFormat);
        else
            error('TSTAMPFORMAT not supported')
        end
    end
    
    % Verify Timestamp Format
    iSeparators = ~ismember(tstampFormat,'dmyHMSF');
    if ~all(strcmp(fileName(iSeparators),tstampFormat(iSeparators)))
        error('The format string TSTAMPFORMAT does not match the FILENAME')
    end

    % Calculate Tick (initial time of file, ref '00 Jan 0000' [s])
    fileTick = datenum(fileName,tstampFormat)*86400; 
    
else % if TSTAMPFORMAT is empty
    error('TSTAMPFORMAT not supported')
end
