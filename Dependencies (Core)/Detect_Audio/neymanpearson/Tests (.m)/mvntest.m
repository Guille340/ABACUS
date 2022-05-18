N = 3;
M = 3;
alpha = 1e-5;

X = randn(M,N);
X_mean = mean(X);
X = X - X_mean;
X = X./sqrt(mean(sum(X.^2)/size(X,1)));
S = (X'*X)/size(X,1);
F = mean(diag(S)) * eye(size(S));

% Terms
% term1 = N/2 * log(2*pi);
% term2 = 0;
% term3 = 0;
% for k = 1:M
%     x = X(k,:);
%     Sk = M/(M-1)*S - 1/(M-1)*(x'*x);
%     R = (1 - alpha)*Sk + alpha*F;
% 
%     evr = eig(R);
%     term2(k) = 1/2 * sum(log(evr));
% 
%     Ri = R^-1;
%     term3(k) = 1/2 * x*Ri*x';
%     
%     y0(k) = term1 + term2(k) + term3(k);
% end

% Terms
term1 = (2*pi)^(-N/2);
term2 = nan(1,M);
term3 = nan(1,M);
for k = 1:M
    x = X(k,:);
    Sk = M/(M-1)*S - 1/(M-1)*(x'*x);
    R = (1 - alpha)*Sk + alpha*mean(diag(Sk))*F;

    R_det = det(R);
    term2(k) = R_det^-0.5;

    Ri = R^-1;
    term3(k) = exp(-0.5*(x*Ri*x'));
end
y = term1.*term2.*term3;
y_mat = mvnpdf(X);
pdfmax = term1*term2;

% figure, scatter3(X(:,1),X(:,2),y,5,'b','filled')
figure, scatter(X(:,1),y,5,'b','filled')
% hold on, scatter3(X(:,1),X(:,2),y_mat,5,'m','filled')

