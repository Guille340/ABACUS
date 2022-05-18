function [U,I] = lowerTriangle(X,k)

% Variable Arguments
if nargin == 1
    k = 0;
end

% Error Control
if ~isnumeric(k) || ~isscalar(k) || rem(k,1)
k = 0;
warning(['K must be an scalar integer number. K = 0 will '...
    'be used (i.e. main diagonal)'])
end

% Error Controls
[nRows,nCols] = size(X);
if k < -nRows || k > nCols
    k = 0;
    warning('K out of limits. K = 0 will be used')
end

% Extract Upper Triangular Matrix
maxBytes = 50*1024^2; % 50 MB
nBytesPerElement = 8; % double precision
nColsPerBlock = floor(maxBytes /(nRows*nBytesPerElement));
cnt = 0;
nBlocks = ceil(nCols/nColsPerBlock);
I = [];
for m = 1:nBlocks-1
    cols = (m-1)*nColsPerBlock+1: m*nColsPerBlock;
    rows = (1:nRows)';
    mask = cols - rows <= k;
    ind = find(mask) + (m-1)*nColsPerBlock*nRows;
    i1 = cnt + 1;
    i2 = cnt + length(ind);
    I(i1:i2,1) = ind;
    cnt = i2;  
end
cols = (nBlocks-1)*nColsPerBlock+1: nCols;
rows = (1:nRows)';
mask = cols - rows <= k;
ind = find(mask) + (nBlocks-1)*nColsPerBlock*nRows;
i1 = cnt + 1;
i2 = cnt + length(ind);
I(i1:i2,1) = ind;
U = zeros(nRows,nCols);
U(I) = X(I);
