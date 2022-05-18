%  index = FINDMIRRORELEMENT(AudDetConfig,mirrorReceiver,sourceName)
%
%  DESCRIPTION
%  Finds the index of the element in the audio detect configuration structure 
%  AUDDETCONFIG whose RECEIVERNAME and SOURCENAME fields match the inputs 
%  MIRRORRECEIVER and SOURCENAME. 
%
%  FINDMIRRORELEMENT aims at identifying the RECEIVERNAME/SOURCENAME 
%  combination from which copying ('mirroring') the detection data.  
%  RECEIVERNAME in the RECEIVERNAME/SOURCENAME element cannot be a mirror 
%  receiver itself, i.e. the element must be associated with a detection
%  algorithm to be able to mirror its results ("cannot mirror from an
%  already mirrored element").
%
%  INPUT ARGUMENTS
%  - AudDetConfig: multi-element audio detect configuration structure.
%  - mirrorReceiver: character vector specifying the name of the receiver
%    belonging to the element in AUDDETCONFIG to be mirrored.
%  - sourceName: character vector specifying the name of the source
%    belonging to the element in AUDDETCONFIG to be mirrored.
%
%  OUTPUT ARGUMENTS
%  - index: index of the element in AUDDETCONFIG matching the receiver
%    and source names MIRRORRECEIVER and SOURCENAME (element to be
%    mirrored). INDEX = [] is MIRRORRECEIVER/SOURCENAME combination is
%    not found or is found but the element has already been mirrored.
%
%  FUNCTION CALL
%  index = findMirrorElement(AudDetConfig,mirrorReceiver,sourceName)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  See also AUDIODETECTCONFIG

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  09 Aug 2021

function index = findMirrorElement(AudDetConfig,mirrorReceiver,sourceName)

index = [];
if ~isempty(mirrorReceiver) && ~isempty(sourceName)
    % Names of Receivers and Sources in AUDDETCONFIG
    receiverNames = {AudDetConfig.receiverName}';
    sourceNames = {AudDetConfig.sourceName}';
    mirrorReceivers = {AudDetConfig.mirrorReceiver}';

    % Identify Element in AUDDETCONFIG matching MIRRORRECEIVER/SOURCENAME
    isMirrorDetector = cellfun(@(x) ~isempty(x),mirrorReceivers); % elements using mirror method
    isRecInAudDet = ismember(receiverNames,mirrorReceiver);
    isSouInAudDet = ismember(sourceNames,sourceName);
    index = find(~isMirrorDetector & isRecInAudDet & isSouInAudDet);
end