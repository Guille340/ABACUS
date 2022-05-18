%  targetOffset = GETTIMEOFFSET(tick,timeOffset,targetTick)
%
%  DESCRIPTION
%  Calculates the time offsets TARGETOFFSET linked to the ticks TARGETTICK
%  from a set of original ticks and associated time offsets (TICK, TIMEOFFSET)
%  by applying linear interpolation. Any TARGETTICK value falling outside
%  the limits [MIN(TICK) MAX(TICK)] is assigned the nearest time offset value.
%  
%  INPUT ARGUMENTS 
%  - tick: vector of ticks in seconds referred to '00 Jan 0000'. 
%  - timeOffset: vector of time offsets associated with TICK, in seconds.
%  - targetTick: vector of ticks, in seconds referred to '00 Jan 0000',at which
%    to calculate the target time offsets TARGETOFFSET. 
%
%  OUTPUT ARGUMENTS
%  - targetOffset: vector of target time offsets associated with TARGETTICK.
%
%  FUNCTION CALL
%  targetOffset = getTimeOffset(tick,timeOffset,targetTick)
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
%  12 Jul 2021

function targetOffset = getTimeOffset(tick,timeOffset,targetTick)

warnFlag = false;

% Error Control: TIMEOFFSET
if ~isnumeric(timeOffset) || ~isvector(timeOffset) || any(timeOffset < 0)
    warnFlag = true;
    warning('TIMEOFFSET must be a positive vector')
end

% Error Control: TARGETTICK
if ~isnumeric(targetTick) || ~isvector(targetTick) || any(targetTick < 0)
    warnFlag = true;
    warning('TARGETTICK must be a positive vector')
end
    
% Process Target Offset
targetOffset = [];
if ~warnFlag
    if ~isempty(tick) && length(timeOffset) > 1
        % Sort Data by Time
        [~,ind] = sort(tick);
        tick = tick(ind);
        timeOffset = timeOffset(ind);

        % Calculate TARGETOFFSET
        targetOffset_nearest = interp1(tick,timeOffset,targetTick,...
            'nearest','extrap');
        targetOffset = interp1(tick,timeOffset,targetTick,'linear');
        isNan = isnan(targetOffset);
        targetOffset(isNan) = targetOffset_nearest(isNan);
    else
        targetOffset = timeOffset;
    end
end
