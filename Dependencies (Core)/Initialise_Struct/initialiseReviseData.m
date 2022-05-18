%  RevData = INITIALISEREVISEDATA()
%
%  DESCRIPTION
%  Initialises the revise data structure REVDATA. All the fields in this 
%  structure are set as empty ([]).
%
%  The fields in REVDATA are described below.
%
%  NOTE!: This function is currently unused until a new version of the 
%  Revision GUI module compatible with the current version of the software
%  is developed.
%
%  REVDATA
%  =======
%  - idet: indices of unclassified detections.
%  - ival: indices of valid detections.
%  - iwro: indices of wrong detections.
%  - isat: indices of saturating detections.
%  - imrk1: index of left marker of selection window.
%  - imrk2: index of right marker of selection window.
%  - showSelec: TRUE if selection is shown.
%  - showBckgnd: TRUE is background noise is shown
%  - showThres: TRUE if amplitude threshold selection window is shown.
%  - threshold: absolute amplitude threshold.
%  - thresDir: direction of the vertical selection area referred to threshold.
%  - snapOpt: TRUE for the selection bar to move only to valid detections
%    when pressing the 'next' or 'previous' buttons.
%  - playTimeOpt: TRUE if play duration is enabled
%  - playTime: play duration, in seconds
%  - playSpeed: play speed by original speed ratio (e.g. 2 for twice the speed)
%  - soundType: type of sound ('transient', 'continuous')
%  - ipropName: index of property name.
%  - ipropValue: index of property value
%  - graph1: string specifying the type of graph for graph 1.
%  - graph2: string specifying the type of graph for graph 2.
%  - graph3: string specifying the type of graph for graph 3.
%  - fmax: maximum frequency to display, in Hertz.
%  - rmax: maximum range to display in the 'Operations Map' graph.
%  - showOpsTxt: TRUE if the receiver, source and vessel names are to be shown
%    in the 'Operations Map'.
%  - comments: cell array of comments for each detection.
%
%  INPUT ARGUMENTS
%  - None
%
%  OUTPUT ARGUMENTS
%  - RevData: initialised revision data structure.
%
%  FUNCTION CALL
%  RevData = initialiseRevisionData()
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  18 Jun 2021

function RevData = initialiseReviseData()

RevData = struct('idet',[],'ival',[],'iwro',[],'isat',[],'imrk1',[],...
    'imrk2',[],'showSelec',[],'showBckgnd',[],'showThres',[],...
    'threshold',[],'thresDir',[],'snapOpt',[],'playTimeOpt',[],...
    'playTime',[],'playSpeed',[],'soundType',[],'ipropName',[],...
    'ipropValue',[],'graph1',[],'graph2',[],'graph3',[],'fmax',[],...
    'rmax',[],'showOpsTxt',[],'comments',[]);
