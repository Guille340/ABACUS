%  [dc,ind] = GETDCOFFSET(x,windowLength)
%
%  DESCRIPTION
%  Returns a vector DC containing the 'dc offsets' of an input signal X over
%  non-overlapping windows of length WINDOWLENGTH. DC is calculated as the mean 
%  value of all consecutive windows within X. The function also returns the
%  sample index IND representing the centre of the processing window for each
%  offset value in DC.
%
%  WINDOWLENGTH should be selected to capture the long trend of the 'dc offset'.
%  Typically, that is the equivalent to ~10 s for the sampling rate of X. 
%  Equivalent durations of less than 1 s should be avoided.
%  
%  INPUT ARGUMENTS
%  - x: signal waveform
%  - windowLength: number of samples to average to obtain the 'DC offsets'.
%
%  OUTPUT ARGUMENTS
%  - dc: vector of dc offsets. Same units as x
%  - ind: vector of indices in X representing the centre of the dc-offset
%    processing windows.
%
%  FUNCTION CALL
%  [dc,ind] = getDcOffset(x,windowLength)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  17 Jul 2021

function [dc,ind] = getDcOffset(x,windowLength)

errorFlag = false; % initialise error flag

% Error Control: x
if ~isnumeric(x) || ~isvector(x)
    errorFlag = true;
    dc = NaN;
    ind = NaN;
    warning('X must be a numeric vector')
end

% Error Control: windowLength
if ~isnumeric(windowLength) || ~isscalar(windowLength)
    windowLength = length(x);
    warning(['WINDOWLENGTH must be a scalar number. WINDOWLENGTH = '...
        'LENGTH(X) will be used']); 
end

if ~errorFlag
    xLength = length(x);
    windowLength = round(abs(windowLength)); % WINDOWLENGTH must be positive non-decimal
    windowLength = max(min(windowLength,xLength),1); % WINDOWLENGTH must be between 1 and XLENGTH
    nWindows = floor(xLength/windowLength); % number of DC-processing windows
    ind = (0:nWindows-1)*windowLength + round(windowLength/2) + 1; % sample position of DC-processing window (centre)
    dc = mean(reshape(x(1:windowLength*nWindows),windowLength,nWindows)); % DC offset at detrend windows
end