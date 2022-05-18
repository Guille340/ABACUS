%  NavigationParameters = GETNAVIGATIONPARAMETERS(signalUtcTick,..
%     NavImpDataOne,varargin)
%
%  DESCRIPTION
%  Calculates the navigation parameters (latitude, longitude, course and speed)
%  for a specific receiver, source or vessel at the instants of each detected
%  sound event. 
%
%  NAVIMPDATAONE is a Navigation Database substructure containing the position
%  information for a specific receiver, source or vessel (i.e. RECIMPDATA,
%  SOUIMPDATA or VESIMPDATA).
%
%  GETNAVIGATIONPARAMETERS accepts a number of variable input arguments related 
%  to the processing approach. These are not compulsory for running the 
%  function but are recommended. The parameters are given as property/value
%  pairs. The available properties are: 'Offset', 'OffsetMode', 'SmoothWindow',
%  'MaxTimeGap', and 'InterpMethod'. The first two are given in the receiver,
%  source and vessel import configuration structures in the Navigation
%  Database (RECIMPCONFIG, SOUIMPCONFIG, VESIMPCONFIG), and the remaining
%  ones are part of the navigation process config structure (NAVPROCONFIG).
%
%  GETNAVIGATIONPARAMETERS loads the position and time information contained 
%  in structure NAVIMPDATAONE (PC tick, UTC tick, latitude, longitude) and
%  computes the navigation parameters at the times of the detections by
%  linking the UTC times of the position data in NAVIMPDATAONE with the UTC
%  ticks of the audio detections in SIGNALUTCTICK. 
%
%  An horizontal offset is applied to the receiver, source or vessel according 
%  to the 'Offset' and 'OffsetMode' properties. Certain degree of spatial
%  smoothing is applied through property 'SmoothWindow' to reduce the position
%  noise associated with a slowly moving platform and in that way improve the 
%  accuracy of the navigation parameters. The interpolation method is given
%  by 'InterpMethod' (e.g. 'linear' or 'nearest'). To avoid interpolating
%  within long periods that show no data (e.g. standby or poor satellite 
%  signal), the property 'MaxTimeGap' set the maximum time gap for which
%  interpolation is allowed.
%
%  The function returns a NAVIGATIONPARAMETERS structure containing the times
%  (UTC, PC), latitude, longitude, course and speed calculated at the times
%  of the detections SIGNALUTCTICK, within the limitations of the interpolation 
%  method of choice.
%
%  INPUT ARGUMENTS
%  - signalUtcTick: vector of UTC ticks at the times of the detections, in
%    seconds referred to '00 Jan 0000'. 
%  - NavImpDataOne: one-element receiver, source or vessel import data
%   structure (RECIMPDATA, SOUIMPDATA, or VESIMPDATA).
%
%  INPUT PROPERTIES (Variable Input Arguments)
%  The strings below represent function properties. Any number can be included
%  in the call. These must be specified after the second input argument,
%  (NAVIMPDATAONE), and each of them must be followed by their corresponding 
%  value separated by comma.
%  - 'Offset': two-element numeric vector (x,y) representing the position of 
%    the receiver or source, in meters, relative to the position of the 
%    positioning device in the towing platform. The values are positive 'up'
%    (y) and 'right' (x). This property is part of the receiver, source and
%    vessel import configuration structures (RECIMPCONFIG, SOUIMPCONFIG, and
%    VESIMPCONFIG). 
%  - 'OffsetMode': character vector indicating the nature of the physical
%    connection between the receiver or source and the towing platform.
%    This property is part of the receiver, source and vessel import 
%    configuration structures (RECIMPCONFIG, SOUIMPCONFIG, and VESIMPCONFIG). 
%    ¬ 'hard': the receiver or source remains at the same relative position 
%      from the towing platform at all times (e.g. SBP, vertically-deployed
%      hydrophone).
%    ¬ 'soft': the receiver is loosely connected to the towing platform,
%      changing its relative position as the former moves in different
%      directions (e.g. vessel-towed hydrophone array or airgun array).
%  - 'SmoothWindow': time window used for averaging position information,
%    in seconds. Using a SMOOTHWINDOW of several seconds will help improve the 
%    accuracy of the navigation parameters. The slower the platform, the longer 
%    the averaging period (recommended 10-30 s).
%  - 'MaxTimeGap': maximum time interval, in seconds, between two consecutive 
%    sentences for applying spatial interpolation to a sound event detected 
%    within that period. If the period exceeds MACTIMEGAP and a sound event is 
%    detected within it, the navigation parameters for that sound event are 
%    set to NaN.
%  - 'InterpMethod': interpolation method used for calculating the position
%    of a detected sound event. See INTERP1 for available methods.
%
%  OUTPUT ARGUMENTS
%  - NavigationParameters: structure containing the navigation parameters
%    associated with the detection times SIGNALUTCTICK for the input receiver,
%    source, or vessel. It contains the following fields,
%    ¬ utcTick: UTC tick of the detection, in seconds referred to '00 Jan 0000'.
%    ¬ pcTick: PC tick of the detection, in seconds referred to '00 Jan 0000'.
%    ¬ latitude: latitude at the time of the detections, in degrees.
%    ¬ longitude: longitude at the time of the detections, in degrees.
%    ¬ course: course over ground at the time of the detections, in degrees.
%    ¬ speed: speed over ground at the time of the detections, in m/s.
%
%  FUNCTION CALL
%  1. NavigationParameters = getNavigationParameters(signalUtcTick,...
%        NavImpDataOne)
%
%      Property Name            Property Value (DEFAULT)
%      ----------------------------------------------------
%      'Offset'                 [0 0]
%      'OffsetMode'             'hard'
%      'SmoothWindow'           0
%      'MaxTimeGap'             600
%      'InterpMethod'           'linear'
%
%  2. NavigationParameters = getNavigationParameters(...,PROPERTYNAME,
%        PROPERTYVALUE)
%
%  FUNCTION DEPENDENCIES
%  - vincenty
%  - vincentyDirect
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%  - Geo Formulas (Distance & Bearing)
%
%  See also SOURCETORECEIVERPARAMETERS, NAVIGATIONPROCESSFUN

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  12 Aug 2021

function NavigationParameters = getNavigationParameters(signalUtcTick,...
    NavImpDataOne,varargin)

% Check Number of Input Arguments
narginchk(4,12)
nVarargin = nargin - 2;
if rem(nVarargin,2)
    error('Property and value input arguments must come in pairs')
end

% Initialise Default Parameters
offset = [0 0]; % no horizontal offset for source/receiver
offsetMode = 'hard'; % fixed offset
smoothWindow = 0; % 0 s smoothing
maxTimeGap = 600; % 10 minutes gap
interpMethod = 'linear'; % interpolation method

% Retrieve Input Variables
for m = 1:2:nVarargin
    inputProperty = lower(varargin{m}); % case insensitive
    inputProperties = lower({'Offset','OffsetMode','SmoothWindow',...
        'MaxTimeGap','InterpMethod'});
    if ~ismember(inputProperty,inputProperties)
        error('Invalid input property')
    else
        switch inputProperty
            case 'offset'
                offset = varargin{m+1};
            case 'offsetMode'
                offsetMode = varargin{m+1};
            case 'smoothwindow'
                smoothWindow = varargin{m+1};
            case 'maxtimegap'
                maxTimeGap = varargin{m+1};
            case 'interpmethod'
                interpMethod = varargin{m+1};
        end
    end
end

% Check If Structure NAVIMPDATAONE Contains All Four Essential Field Names
fieldNames_valid = {'pcTick','utcTick','latitude','longitude'};
fieldNames = fieldnames(NavImpDataOne);
if ~all(ismember(fieldNames_valid,fieldNames))
    error(['One or more of the following field names were not found in '...
        'input structure NAVIMPDATAONE: PCTICK, UTCTICK, LATITUDE, LONGITUDE'])
end

% Load Field Names from NAVIMPDATAONE
pcTick = NavImpDataOne.pcTick;
utcTick = NavImpDataOne.utcTick;
latitude = NavImpDataOne.latitude;
longitude = NavImpDataOne.longitude;

% Initialise Error Flag
errorFlag = false;

% Error Control: signalUtcTick
if ~isnumeric(signalUtcTick) || ~isvector(signalUtcTick) ...
        || any(signalUtcTick < 0)
    errorFlag = true;
end

% Error Control: utcTick
if ~isnumeric(utcTick) || ~isvector(utcTick) || any(utcTick < 0)
    errorFlag = true;
end

% Error Control: latitude
if ~isnumeric(latitude) || ~isvector(latitude)
    errorFlag = true;
end

% Error Control: longitude
if ~isnumeric(longitude) || ~isvector(longitude)
    errorFlag = true;
end

% Error Control: offset
if ~isnumeric(offset) || ~isvector(offset) || length(offset) ~= 2
    offset = [0 0]; % no horizontal offset for source/receiver
    warning(['OFFSET must be a two-element numeric vector. OFFSET = '...
        '[%0.0f %0.0f] will be used'],offset)
end

% Error Control: offsetMode
if ~ischar(offsetMode) || ~any(strcmp(offsetMode,{'soft','hard'}))
    offsetMode = 'hard'; % fixed offset
    warning(['Non-supported OFFSETMODE string. OFFSETMODE = ''%s'' will '...
        'be used'],offsetMode)
end

% Error Control: smoothWindow
if ~isnumeric(smoothWindow) || ~isscalar(smoothWindow) || smoothWindow < 0
    smoothWindow = 0; % no smoothing
    warning(['SMOOTHWINDOW must be a positive scalar. No smoothing '...
        'will be applied to the navigation data (SMOOTHWINDOW = %0.0f)'],...
        smoothWindow)
end

% Error Control: maxTimeGap
if ~isnumeric(maxTimeGap) || ~isscalar(maxTimeGap) ...
        || maxTimeGap <= smoothWindow
    maxTimeGap = max(300,2*smoothWindow);
    warning(['MAXTIMEGAP must be a scalar number higher than '...
        'SMOOTHWINDOW. MAXTIMEGAP = %0.0f will be used'],maxTimeGap)
end

% Error Control: offsetMode
if ~ischar(interpMethod) || ~ismember(interpMethod,{'linear','nearest',...
        'next','previous','spline','pchip','cubic','v5cubic'})
    interpMethod = 'linear';
    warning(['INTERPMETHOD is not a valid string (see help from INTERP1 '...
        'for options). INTERPMETHOD = ''%s'' will be used'],interpMethod)
end

NavigationParameters = [];
if ~errorFlag
    % Set Wrong Latitude and Longitude Values to NaN
    iLatWrong = latitude > 90 | latitude < -90;
    iLonWrong = longitude > 360 | longitude < -180;
    latitude(iLatWrong | iLonWrong) = NaN;
    longitude(iLatWrong | iLonWrong) = NaN;
    
    % Process Parameters if Number of Fixes is 2 or More
    nFixes = length(utcTick); % number of vessel GPS fixes
    if nFixes > 1
        % Calculate Start/End Indices of UTC Smoothing Window
        utcTick2 = utcTick + smoothWindow; % expected end UTC tick for vessel
        iUtcTick = (1:nFixes)';
        iUtcTick2 = interp1(utcTick,iUtcTick,utcTick2,'nearest','extrap'); % indices of exact end UTC ticks
        iUtcTick2(iUtcTick == iUtcTick2) = ...
            min(find(iUtcTick2(iUtcTick == iUtcTick2)) + 1,nFixes); % avoid iUtcTick2 equal to iUtcTick

        % Extract Position of Towing Platform for UTC Tick Pairs
        utcTick2 = utcTick(iUtcTick2); % exact end UTC tick for vessel
        latitude2 = latitude(iUtcTick2); 
        longitude2 = longitude(iUtcTick2); 

        % Calculate Speed and Course of Towing Platform (= Towed Element)
        [dist,course] = vincenty(latitude,longitude,latitude2,longitude2,...
            'WGS84',false);
        speed = dist./(utcTick2 - utcTick);

        % Calculate Position of Towed Element
        towBearing = atan2(offset(1),offset(2))*180/pi + course;
        towDistance = sqrt(offset(1)^2 + offset(2)^2);
        [towLatitude,towLongitude,~] = vincentyDirect(latitude,longitude,...
            towBearing,towDistance,'WGS84',false);

        % Calculate PC Tick at the Time of Detections
        signalPcTick = [];
        if ~isempty(pcTick) % empty for P190
            signalPcTick = interp1(utcTick,pcTick,signalUtcTick,...
                interpMethod);
        end

        % Calculate Navigation Parameters at the Time of Detections
        towLatitude = interp1(utcTick,towLatitude,signalUtcTick,interpMethod);
        towLongitude = interp1(utcTick,towLongitude,signalUtcTick,interpMethod);
        towCourse = interp1(utcTick,course,signalUtcTick,interpMethod);
        towSpeed = interp1(utcTick,speed,signalUtcTick,interpMethod);

        % Set Interpolated Values with MAXTIMEGAP as NaN
        iDetUtcTick = floor(interp1(utcTick,iUtcTick,signalUtcTick,'linear'));
        iUtcGap = find(diff(utcTick) > maxTimeGap);
        isDetUtcInGap = ismember(iDetUtcTick,iUtcGap); % true if detection falls within time gap
        towLatitude(isDetUtcInGap) = NaN;
        towLongitude(isDetUtcInGap) = NaN;
        towCourse(isDetUtcInGap) = NaN;  
        towSpeed(isDetUtcInGap) = NaN;
    else
        signalPcTick = NaN;
        towLatitude = NaN;
        towLongitude = NaN;
        towCourse = NaN;
        towSpeed = NaN;
    end
    
    % Populate NAVIGATIONPARAMETERS Structure
    NavigationParameters.utcTick = signalUtcTick;
    NavigationParameters.pcTick = signalPcTick;
    NavigationParameters.latitude = towLatitude;
    NavigationParameters.longitude = towLongitude;
    NavigationParameters.course = towCourse;
    NavigationParameters.speed = towSpeed;
end
