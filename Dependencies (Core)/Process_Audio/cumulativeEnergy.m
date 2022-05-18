%  [windowLimits,cumEnergy] = CUMULATIVEENERGY(x,energy)
%
%  DESCRIPTION
%  Returns start and end samples of the window containing the portion of the 
%  input vector X with the specified ENERGY. This function also returns the 
%  cumulative energy curve used to obtain the window limits associated 
%  with energy values (1 – ENERGY)/2 and (1 + ENERGY)/2.
%
%  INPUT ARGUMENTS
%  - x: input signal (vector).
%  - energy: fraction of total energy for determining the window limits
%    from the cumulative energy curve 
%   
%  OUTPUT ARGUMENTS
%  - windowLimits: two-element vector containing the start and end samples of 
%    the windowed signal referred to the start of X (i.e. sample 1). These
%    samples are linked to the cumulative energy values (1 – ENERGY)/2 and 
%   (1 + ENERGY)/2.
%  - cumEnergy: cumulative energy curve, as fraction of the total energy.
%
%  FUNCTION CALL
%  [windowLimits,cumEnergy] = cumulativeEnergy(x,energy)
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  TOOLBOX DEPENDENCIES
%  - MATLAB (Core)
%
%  CONSIDERATIONS & LIMITATIONS
%  - The input signal X must have no DC offset for CUMULATIVENERGY to 
%    accurately calculate the window limits. The DC offset should be removed
%    before attempting to use CUMULATIVEENERGY. Any DC offset will behave as 
%    background noise, which will make the cumulative energy curve resemble 
%    a straight line, as opposed to a more desirable straight line with 
%    initial and final plateaus.
%  - CUMULATIVEENERGY will perform well on signals with good SNR. With
%    low-SNR, the start and end limits of the signal will be overestimated.
%    That is why it is recommended to bandpass-filter the signal to eliminate 
%    any noise content outside its main bandwidth.
%
%  EXAMPLE
%  For cumulative energy windowing defined by 90% of the signal energy, do
%  as follows. We'll have cumEnergy(windowLimits) = [0.05 0.95].
%  
%  % Input Parameters
%  energy = 0.9;
%  fs = 1000;
%  f = 10;
%  tau = 1; % tone duration
%
%  % Generate Signal
%  ts = 0:1/fs:1;
%  nSamples = length(t);
%  xs = [zeros(1,nSamples) sin(2*pi*f*t) zeros(1,nSamples)];
%  xn = 0.2*randn(1,3*nSamples);
%  x = xs + xn;
%  t = (0:length(x)-1)/fs;
%
%  % Cumulative Energy Window
%  [windowLimits,cumEnergy] = cumulativeEnergy(x,energy);
%
%  % Plot
%  figure
%  hold on
%  plot(t,x,'b')
%  plot(t,cumEnergy,'m','LineWidth',2)
%  plot(windowLimits/fs,cumEnergy(windowLimits),'ko','MarkerSize',5,...
%    'MarkerFaceColor','g','Color','none')
%  xlabel('Time [s]')
%  ylabel('Amplitude')
%  legend('Signal + Noise','Cum. Energy Curve','Cum. Energy Limits')
%  axis([t(1) t(end) -2 2])
%  box on

%  VERSION 1.0
%  Guillermo Jimenez Arranz
%  email: gjarranz@gmail.com
%  27 Mar 2021

function [windowLimits,cumEnergy] = cumulativeEnergy(x,energy)

cumEnergy = cumsum(x.^2)/sum(x.^2); % cumulative energy curve(signal+noise)
e1 = (1 - energy)/2; % bottom cumulative energy limit
e2 = (1 + energy)/2; % top cumulative energy limit
windowLimits(1) = find(cumEnergy > e1,1,'first');
windowLimits(2) = find(cumEnergy > e2,1,'first');
