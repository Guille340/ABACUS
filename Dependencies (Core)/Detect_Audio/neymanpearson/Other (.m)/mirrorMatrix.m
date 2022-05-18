function T = mirrorMatrix(X,direction)

% Error Control: Square Matrix
if size(X,1) ~= size(X,2)
    error('X must be a square matrix')
end

% Error Control: Mirroring Direction
if ~ismember(direction,{'ud','du'})
    direction = 'ud';
    warning(['Non-valid DIRECTION string. DIRECTION = %s will '...
        'be used'],direction)
end

if strcmp(direction,'ud')
    [T,I] = upperTriangle(X,0);
    T = T';
    T(I) = X(I);
else % DIRECTION = 'du'
    [T,I] = lowerTriangle(X,0);
    T = T';
    T(I) = X(I);
end
