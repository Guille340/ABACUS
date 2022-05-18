function T = meanvarToeplitz(X)

[M,N] = size(X);

c = nan(1,M); % first column (row values)
for m = 1:M
    i1 = 1;
    i2 = min(M - m + 1, N);
    ind = i1:i2;
    c(m) = mean(X((M+1)*(ind-1) + m));
end

r = nan(1,N); % first row (column values)
for n = 1:N
    i1 = 1;
    i2 = min(N - n + 1, M);
    ind = i1:i2;
    r(n) = mean(X(M*(n-1) + (M+1)*(ind-1) + 1));
end

c = exp(-((0:M-1)*10/M)) .* c;
r = exp(-((0:M-1)*10/M)) .* r;

T = toeplitz(c,r);

