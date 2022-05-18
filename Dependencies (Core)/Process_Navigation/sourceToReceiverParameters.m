%  SouRecPar = SOURCETORECEIVERPARAMETERS(SouNavPar,RecNavPar)
%
%  DESCRIPTION
%  Calculates the relative navigation parameters between source and receiver.
%  The function uses the source and receiver navigation parameter structures
%  SOUNAVPAR and RECNAVPAR generated with GETNAVIGATIONPARAMETERS to compute
%  the distance and bearing between source and receiver, the heading of the
%  source and the directivity angle of the source. 
%
%  The distance and bearing are calculated with Vincenty's method. The source
%  heading is set as equal to the source's cource over ground. The directivity
%  angle of the source is the angle between source and receiver referred to
%  source heading. The results are returned in four-field structure SOURECPAR.
%
%  INPUT ARGUMENTS
%  - SouNavPar: source navigation parameter structure. Generated with 
%    GETNAVIGATIONPARAMETERS.
%  - NavImpDataOne: receiver navigation parameter structure. Generated with 
%    GETNAVIGATIONPARAMETERS.
%
%  OUTPUT ARGUMENTS
%  - SouRecPar: source-to-receiver navigation parameter structure. It contains
%    the following four fields,
%    ¬ 'sou2recDistance': source to receiver distance, in metres.
%    ¬ 'sou2recBearing': source to receiver bearing, in degrees (0 N, 90 E)
%    ¬ 'sourceHeading': source heading, in degress (0 N, 90 E)
%    ¬ 'sourceEmitAngle': source directivity angle, in degrees (0 N, 90 E)
%
%  FUNCTION CALL
%  SouRecPar = sourceToReceiverParameters(SouNavPar,RecNavPar)
%
%  FUNCTION DEPENDENCIES
%  - vincenty
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%  - Geo Formulas (Distance & Bearing)
%
%  See also GETNAVIGATIONPARAMETERS, NAVIGATIONPROCESSFUN

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  12 Aug 2021

function SouRecPar = sourceToReceiverParameters(SouNavPar,RecNavPar)

% Calculate Source To Receiver Parameters (Vincenty)
[sou2RecDistance,sou2RecBearing] = vincenty(SouNavPar.latitude,...
    SouNavPar.longitude,RecNavPar.latitude,RecNavPar.longitude,'WGS84',false);
sourceHeading = SouNavPar.course;
sourceEmitAngle = sou2RecBearing - sourceHeading;

% Populate Output Structure
SouRecPar.sou2recDistance = sou2RecDistance;
SouRecPar.sou2recBearing = sou2RecBearing;
SouRecPar.sourceHeading = sourceHeading;
SouRecPar.sourceEmitAngle = sourceEmitAngle;

% ALTERNATIVE METHOD (only accurate for short source-receiver distances)
% % Calculate Source To Receiver Parameters (Trigonometry)
% xOffset = (RecNavPar.longitude - SouNavPar.longitude)* ...
%     cos(mean([SouNavPar.latitude,RecNavPar.latitude],'omitnan')*pi/180)*111000;
% yOffset = (RecNavPar.latitude - SouNavPar.latitude)*111000;
% sou2RecBearing = atan2(xOffset,yOffset)*180/pi;
% sou2RecDistance = sqrt(xOffset.^2 + yOffset.^2);
% sourceHeading = SouNavPar.course;
% sourceEmissionAngle = sou2RecBearing - sourceHeading;
