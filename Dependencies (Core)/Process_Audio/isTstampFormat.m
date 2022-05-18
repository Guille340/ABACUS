%  isValid = isTstampFormat(TSTAMPFORMAT)
%
%  DESCRIPTION
%  TRUE if the character vector TSTAMPFORMAT is a valid audio timestamp format.
%  The format must not include the file extension.
%  
%  A timestamp format is considered valid if all conditions below are met:
%  1. Includes at least the year (y), month (m), day (d), hour (H), minute (M)
%     and second (S).
%  2. It includes a maximum of one wildcard '*' at the beginning or the end.
%  
%  INPUT ARGUMENTS 
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
%  - isValid: TRUE if TSTAMPFORMAT is a valid audio timestamp format.
%
%  FUNCTION CALL
%  isValid = isTstampFormat(tstampFormat)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  See also UPDATEAUDIOPROCESSCONFIG, AUDIOFILETICK

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  12 Aug 2021

function isValid = isTstampFormat(tstampFormat)

warnFlag = false;
isValid = true;

% Errot Control: TSTAMPFORMAT
if ~isempty(tstampFormat) && ischar(tstampFormat) 
    % Remove Extension (if any)
    iDot = find(tstampFormat == '.',1,'last');
    if ~isempty(iDot)
        tstampFormat = tstampFormat(1:iDot-1);
        if isempty(tstampFormat)
            warnFlag = true;
            isValid = false;
        end
    end
else
    warnFlag = true;
    isValid = false;
    warning('TSTAMPFORMAT must be a character vector')
end

if ~warnFlag
    % Remove Consecutive '*' Characters
    iChar = find(tstampFormat == '*');
    if ~isempty(iChar)
        iDeleteFormat = iChar(find(diff(iChar) == 1) + 1);
        tstampFormat(iDeleteFormat) = '';
    end

    % Verify Position of Wildcard
    iChar = find(tstampFormat == '*');
    if ~isempty(iChar)
        if iChar ~= 1 && iChar ~= nCharFormat
            isValid = false;
            warning(['The timestamp format string can only include one wildcard '...
                '''*'' at the beginning or at the end'])
        end
    end

    % Verify Format Special Characters 'ymdHMS'
    if ~all(ismember('ymdHMS',tstampFormat))
        isValid = false;
        warning(['The timestamp format string must include at least the '...
            'year (y), month (m), day (d), hour (H), minute (M) and second (S)'])
    end
end