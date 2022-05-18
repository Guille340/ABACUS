%  noiseVar = NOISEVARIANCE(X)
% 
%  DESCRIPTION
%  Calculates the variance of the background noise in the matrix of audio
%  observations X. Matrix X contains consecutive, non-overlapping, equal-
%  length segments from a processed audio file. The observations are arranged
%  in columns.
%  
%  NOISEVARIANCE calculates the standard deviation of the observations. The 
%  histogram of standard deviations is then computed. The standard deviation
%  of the background noise is selected as the value associated with 10% of the 
%  maximum number of counts in the histogram. NOISEVAR is the squared value of 
%  the noise standard deviation.
%
%  This method works reasonably well in most scenarios, from low to high noise 
%  variance (narrower to wider primary histogram lobes). However, the number
%  of observations must be at least 1000, so that the histogram curve becomes 
%  a realistic representation of the distribution of noise standard deviations. 
%
%  This approach assumes that the noise dominates most observations. This is a 
%  reasonable assumption considering that target sound events represent only a 
%  small fraction of any period of analysis.
% 
%  INPUT ARGUMENTS (Fixed)
%  - X: matrix of audio observations. Observations are arranged in columns.
%    
%  OUTPUT VARIABLES
%  - noiseVar: variance of background noise in X.
%
%  FUNCTION DEPENDENCIES
%  - None
%
%  FUNCTION CALL
%  1. noiseVar = noiseVariance(X)

%  VERSION 1.0
%  Date: 23 Sep 2021
%  Author: Guillermo Jimenez Arranz
%  Email: gjarranz@gmail.com

function noiseVar = noiseVariance(X)

% Compute Standard Deviation of Background Noise in AUDIODATA
xstd = std(X);

% Histogram of Noise Standard Deviations
factor = 10^floor(log10(max(xstd)));
xstd_max = ceil(max(xstd)/factor)*factor;
xstd_num = 100;
xstd_step = xstd_max/xstd_num;
edges = 0:xstd_step:xstd_max;
counts = histcounts(xstd,edges);
maxCounts = max(counts);

% Calculate Noise Standard Deviation
halfWidthRatio = 0.1; % the lower the larger estimated noise variance
iHalfCounts = length(counts) - find(fliplr(counts) > halfWidthRatio ...
    * maxCounts,1,'first') + 1;
noiseStd = interp1([counts(iHalfCounts) counts(iHalfCounts+1)],...
    [edges(iHalfCounts) edges(iHalfCounts+1)],halfWidthRatio*maxCounts);
noiseVar = noiseStd^2;
