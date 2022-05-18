%  [is1,is2,in1,in2] = GROUPKERNELS(isDetections,minKernels)
% 
%  DESCRIPTION
%  Based on the logical vector of detections ISDETECTIONS, GROUPKERNELS groups 
%  all consecutive detections into windows containing at least MINKERNELS 
%  kernels (including both "detections" and "no detections"). It means, a 
%  window always starts on a "detection" kernel but may include "no detection" 
%  kernels. 
%
%  Given two sets (1,2), each consisting of N1 and N2 consecutive kernels, and 
%  a separation of M kernels between the start of both sets, there are four 
%  possible grouping scenarios:
%  
%  1. N1 > MINKERNELS: the window contains N1 "detection kernels" (i.e., set 1).
%  2. N1 < MINKERNELS and MINKERNELS < M: the window contains MINKERNELS from
%     the start of set 1.
%  3. N1 < MINKERNELS and M + N2 >= MINKERNELS >= M: the window contains M + N2
%     kernels (i.e., set 1 and set 2).
%  3. N1 < MINKERNELS and MINKERNELS > M + N2: the window contains MINKERNELS
%     from the start of set 1.
%
%  The function returns the start and end indices (IS1,IS2) of the "detection"
%  windows. GROUPKERNELS also determines the start and end indices of the "no 
%  detection" (or noise) windows associated with each "detection" window. IS1, 
%  IS2, IN1 and IN2 are all of the same dimensions. 
%
%  For the calculation of the limits of the noise windows, the algorithm looks 
%  for any region of consecutive "no detections" of the same length as the 
%  corresponding "detection" window, starting nearby and progressing further 
%  away until a suitable "no detection" segment is found. If no noise segment 
%  is located for that particular "detection" window, the algorithm returns NaN 
%  for that element of IN1 and IN2.
% 
%  INPUT ARGUMENTS
%  - isDetections: logical vector of detections. It has a TRUE value for each 
%    kernel that has been identified as a detection.
%  - minKernels: minimum number of kernels in a window group.
%
%  OUTPUT VARIABLES
%  - is1: vector of start indices for the "detection" windows.
%  - is2: vector of end indices for the "detection" windows.
%  - in1: vector of start indices for the "no detection" (noise) windows.
%  - in2: vector of end indices for the "no detection" (noise) windows.
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  FUNCTION CALL
%  [is1,is2,in1,in2] = groupKernels(isDetections,minKernels)

%  VERSION 1.0
%  Date: 02 March 2022
%  Author: Guillermo Jimenez Arranz
%  Email: gjarranz@gmail.com

function [is1,is2,in1,in2] = groupKernels(isDetections,minKernels)

% Initialise Vectors of Kernel Indices
is1 = [];
is2 = [];
in1 = [];
in2 = [];

% Group Consecutive Detections
ig1 = find(diff([false; isDetections(:); false]) == 1); % start index of group
ig2 = find(diff([false; isDetections(:); false]) == -1) - 1; % end index of group

% Group Kernels into Windows with at Least MINKERNELS (signal)
ind = 1;
cnt = 1;
nGroups = length(ig1);
nKernels_total = length(isDetections); % total number of kernels
while ind <= nGroups
    nKernels = max(ig2(ind) - ig1(ind) + 1,minKernels); % num kernels in window
    iw1 = ig1(ind); % start index of window
    iw2 = min(iw1 + nKernels - 1,nKernels_total); % end index of window
    k = find(ig1 <= iw2+1,1,'last'); % last group to add to window
    is1(cnt) = iw1; %#ok<*AGROW>
    is2(cnt) = iw2;
    if k ~= ind && iw2<=ig2(k)
        is2(cnt) = ig2(k);        
    end
    ind = k + 1;
    cnt = cnt + 1;
end

% Group Kernels into Windows with at Least MINKERNELS (noise)
if nGroups > 0
    % # First Window
    nWindows = length(is1);
    nKernels = is2(1) - is1(1) + 1; % num kernels in first window
    in1_temp = is1(1) - nKernels;
    
    ind = 0;
    if (in1_temp < 1) && (1 + ind) < nWindows
        ind = ind + 1;
        in1_temp = is1(1 + ind) - nKernels;
        while in1_temp <= is2(ind) && (1 + ind) < nWindows
            ind = ind + 1;
            in1_temp = is1(1 + ind) - nKernels;       
        end
    end
    in1(1) = in1_temp;
    in2(1) = is1(1 + ind) - 1;
        
    if ind > 0 && in1_temp <= is2(ind)
        in1(1) = NaN;
        in2(1) = NaN;
    end

    % # Rest of Windows
    for m = 2:nWindows
        nKernels = is2(m) - is1(m) + 1; % num kernels in window
        in1_temp = is1(m) - nKernels;
        ind = 0;
        while in1_temp <= is2(m + ind - 1) && (m + ind) < nWindows
            ind = ind + 1;
            in1_temp = is1(m + ind) - nKernels;       
        end
        in1(m) = in1_temp;
        in2(m) = is1(m + ind) - 1;

        if in1_temp <= is2(m + ind - 1)
            in1(m) = NaN;
            in2(m) = NaN;
        end
    end
end
