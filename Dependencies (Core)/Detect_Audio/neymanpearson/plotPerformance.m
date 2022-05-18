%  PLOTPERFORMANCE(PerformanceData,outputFolder)
% 
%  DESCRIPTION
%  Plots the Receiver Operating Curves (ROC) using the right-tail probability
%  curves stored in the multi-element structure PERFORMANCEDATA for the various
%  signal-to-noise ratios. Each element in PERFORMANCEDATA corresponds to one
%  SNR. The figures are saved as *.png files in directory OUTPUTFOLDER.
% 
%  INPUT ARGUMENTS (Fixed)
%  - PerformanceData: multi-element structure containing the following fields.
%    Each element corresponds to a signal-to-noise ratio from -50 dB to 50 dB
%    in 1 dB steps (101 elements). Generated with CHARACTERISEPERFORMANCE (see
%    function's help for further details).
%  - outputFolder: directory to store the ROC figures.
%    
%  OUTPUT VARIABLES
%  - None
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  FUNCTION CALL
%  1. plotPerformance(PerformanceData,outputFolder)

%  VERSION 1.0
%  Date: 23 Sep 2021
%  Author: Guillermo Jimenez Arranz
%  Email: gjarranz@gmail.com

function plotPerformance(PerformanceData,outputFolder)

% Error Control: Detector Performance Structure
PerformanceFields_valid = fieldnames(initialisePerformanceData);
PerformanceFields = fieldnames(PerformanceData);
isValidStruct = all(ismember(PerformanceFields_valid,PerformanceFields)) ...
    && all(ismember(PerformanceFields,PerformanceFields_valid));
if ~isValidStruct
    warning('PERFORMANCEDATA is not a valid structure')    
end

% Error Control: Output Directory
if ischar(outputFolder)
    success = mkdir(outputFolder);
    if ~success
        warning('OUTPUTFOLDER is not a valid directory')
    end
else
    warning('OUTPUTFOLDER must be a character string')
end
      
% General Variables
nElements = numel(PerformanceData);
snrLevels = [PerformanceData.snrLevel];

% PLOT RECEIVER OPERATING CHARACTERISTIC (All SNR)
figure
hold on
plot([0 1],[0 1],'k:')
xlabel('Probability of False Alarm')
ylabel('Probability of Detection')
title({sprintf('Receiver Operating Characteristic ');...
    sprintf('\\rm\\fontsize{10}SNR = %d to %d dB',...
    min(snrLevels),max(snrLevels))})
box on
axis([0 1 0 1])
pbaspect([1 1 1])
for n = nElements:-1:1  
    % Plot ROC
    plot(PerformanceData(n).rtpFalseAlarm,PerformanceData(n).rtpDetection,...
        'color','k','linewidth',1.5);
end

% Save Figure
figureName = 'ROC (SNR = all).png';
figurePath = fullfile(outputFolder,figureName);
set(gcf,'PaperPositionMode','auto')
print(figurePath,'-dpng','-r250')    
close(gcf)

% PLOT RECEIVER OPERATING CHARACTERISTIC (Individual SNR)
for n = 1:nElements
    % Current SNR Level
    snrLevel = snrLevels(n);
    
    % Plot ROC
    figure
    hold on
    plot([0 0],[1 1],'k:')
    plot(PerformanceData(n).rtpFalseAlarm,...
        PerformanceData(n).rtpDetection,'k','linewidth',1.5)
    xlabel('Probability of False Alarm')
    ylabel('Probability of Detection')
    title({'Receiver Operating Characteristic';...
        sprintf('\\rm\\fontsize{10}SNR = %0.1f dB',snrLevel)})
    axis([0 1 0 1])
    pbaspect([1 1 1])
    box on

    % Save Figure
    figureName = sprintf('%0.2d ROC (SNR = %0.1f dB).png',n,snrLevel);
    figurePath = fullfile(outputFolder,figureName);
    set(gcf,'PaperPositionMode','auto')
    print(figurePath,'-dpng','-r250')    
    close(gcf)
end
