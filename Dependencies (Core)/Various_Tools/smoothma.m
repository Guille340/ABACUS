%  y = SMOOTHMA(x,winLength,varargin)  
%
%  DESCRIPTION
%  Moving average smoothing algorithm.
%
%  INPUT ARGUMENTS
%  - x: input signal (vector or matrix). If x is a matrix, smoothing
%    will be applied to each column.
%  - winLength: length of averaging window, in number of samples
%  - avgMethod (varargin{1}): window averaging method. Two options:
%    ¬ 'avg': average (DEFAULT)
%    ¬ 'rms': root-mean square
%  - extrapVal (varargin{2}): values used outside the margins of x
%    to calculate the average in the edges. Three options:
%    ¬ 'avg' = average of first and last winLength/2 values(DEFAULT)
%    ¬ 'copy' = repeat first and last value
%    ¬ 'zero' = populate with zeros
%
%  OUTPUT ARGUMENTS
%  - y: smoothed signal, with same length as x
% 
%  INTERNALLY CALLED FUNCTIONS
%  - None
% 
%  FUNCTION CALLS
%  1. y = SMOOTHMA(x,winLength)
%     ¬ avgMethod = 'avg', extrapVal = 'avg'
%
%  2. y = SMOOTHMA(x,winLength,avgMethod)
%     ¬ extrapVal = 'avg'
%
%  3. y = SMOOTHMA(x,winLength,avgMethod,extrapVal)

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  28 Apr 2020

function y = smoothma(x,winLength,varargin)  
    switch nargin
        case {0 1}
            error('Not enough input arguments')
        case 2
            avgMethod = 'avg'; % averaging method ('avg' = average, 'rms' = root-mean square
            extrapVal = 'avg'; % extrapolation value (
        case 3
            avgMethod = varargin{1};
            extrapVal = 'avg';
        case 4
            avgMethod = varargin{1};
            extrapVal = varargin{2};
        otherwise
            error('Too many output arguments')
    end
            
    % Error Control
    if winLength < 1
        winLength = 1;
        warning('Negative WINLENGTH. Smoothing not applied')
    elseif winLength == 1
        warning(['WINLENGTH = 1 results in no smoothing. Choose a value'...
        'higher than 1'])
    end
    
    % Identify Input
    isRowVector = false;
    if isvector(x)
        isRowVector = isrow(x); % true if x is a vector of dimensions 1xn
        if isRowVector, x = x'; end
    end
    ncol = size(x,2);
    
    % Populate signal edges with constant value before smoothing
    if winLength > 1
        npad1 = ceil((winLength-1)/2);
        npad2 = (winLength-1) - npad1;
        switch extrapVal
            case 'avg'
                val1 = mean(x(1:winLength-npad1,:));
                val2 = mean(x(end-(winLength-npad2)+1:end,:));
            case 'copy'
                val1 = x(1,:);
                val2 = x(end,:);
            case 'zero'
                val1 = zeros(1,ncol);
                val2 = zeros(1,ncol);
            otherwise
                error('Non-recognised string for input argument EXTRAPVAL')
        end

        x = [val1.*ones(npad1,ncol); x; val2.*ones(npad2,ncol)];

        switch avgMethod
            case 'avg'
                csum = cumsum(x);
                y = (csum(winLength:end,:) - [zeros(1,ncol); csum(1:end-winLength,:)])/winLength;
            case 'rms'
                csum = cumsum(x.^2);
                y = sqrt((csum(winLength:end) - [0; csum(1:end-winLength)])/winLength);
            otherwise
                error('Non-recognised string for input argument AVGMETHOD')
        end
        
        % Restore original dimension of x
        if isRowVector
            y = y';
        end
            
    else
        y = x;
    end
    