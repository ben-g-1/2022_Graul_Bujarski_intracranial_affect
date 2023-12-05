function [structout] = glm_corr(design, data)
% Needs to have an intercept
% Creates a structure with the following items:
% best: beta estimates, with row 1 corresponding to intercept etc.
% tval: t values, same structure as beta estimates
% prob: p values based on degrees of freedom from design matrix size
% h: significance following Benjamini & Yekutieli (2001) false discovery
%       rate correction
% crit_p: new p threshold following FDR assuming original threshold of 0.05 
% adj_ci_cvrg: adjusted conference interval following FDR
% adj_p: adjusted p values following FDR

% v 1.0
% Ben Graul 12/5/23

X = design;
[n,p] = size(X);
Y = reshape(data, n, []);

base.best = X\Y;
dfe = n - p;
err = Y - X * base.best;
mse = sum((err).^2)/dfe;
covar = diag(X'*X)';
bvar = repmat(mse', 1, size(covar,2))./repmat(covar,size(mse,2),1);
base.tval = (base.best'./ sqrt(bvar))';
base.full_prob = (1-tcdf(abs(base.tval), dfe))*2;

base.prob = reshape(base.full_prob(2:p,:), [], 1);
for i = 1:numel(base.prob)
    if base.prob(i,1) > 0.05
        base.h(i,1) = 0;
    else
        base.h(i,1) = 1;
    end %if
end %for

[base.adj_h, base.crit_p, base.adj_ci_cvrg, base.adj_p]=fdr_bh(base.prob,.05,'dep','yes');

structout = base;

end %function glm_corr