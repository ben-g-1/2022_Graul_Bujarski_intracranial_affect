%%% Permutation Testing on Discovery (Global Beta Variance)

% Steps: 
% Load time/frequency data
% Create design matrix
% Calculate beta weights for all time/frequency combinations
    % Per channel and per design feature
% Write .mat object for combining with others


% First make sure that variables are passing correctly

disp('Script loaded');

chans
outpath
datpath = string(datpath)

% Load in the data
load(datpath);
disp('Data loaded');

cd(outpath);
disp('Changed dirs');

switch chans
    case  "1"
        a = 1;
        b = 25;
        chunk_size = numel(a:b);
    case "2"
        a = 26;
        b = 50;
        chunk_size = numel(a:b);
    case "3"
        a = 51;
        b = 75;
        chunk_size = numel(a:b);
    case "4"
        a = 76;
        b = 100;
        chunk_size = numel(a:b);
    case "5"
        a = 101;
        b = 121;
        chunk_size = numel(a:b);
end

% Check that chunking worked
fprintf('First Chan: %d', a);
fprintf('Last Chan: %d', b);
fprintf('Group: %d', chunk_size);

 
data = imgview_freq;
trlinfo = data.trialinfo;

%Create Design Matrix
design = [trlinfo.Valence_mean trlinfo.cue_observed_mean];

[n,p] = size(design); 

% Normalize Design Matrix for comparison
design_norm = design;
for c = 1:p
AVG = mean(design(:,c));
STD = std(design(:,c),0,1);
if abs(STD/AVG)<10*eps
    fprintf('confound %s is a constant \n', num2str(c));
else
    design_norm(:,c) = (design(:,c) - AVG) / STD;
end
clear AVG STD;
end

%%% GLOBAL BSE TESTING
%creates norm and base, which are then added to 'glb' structure
glb = struct;

X = design;
[n,p] = size(X);
Y = reshape(imgview_freq.powspctrm, n, []);

base.best = X\Y;
dfe = n - p;
err = Y - X * base.best;
mse = sum((err).^2)/dfe;
covar = diag(X'*X)';
bvar = repmat(mse', 1, size(covar,2))./repmat(covar,size(mse,2),1);
base.tval = (base.best'./ sqrt(bvar))';
base.prob = (1-tcdf(abs(base.tval), dfe))*2;

base.adj_prob = reshape(base.prob, [], 1);
[base.h, base.crit_p, base.adj_ci_cvrg, base.adj_p]=fdr_bh(base.adj_prob,.05,'pdep','yes');

X = design_norm;
[n,p] = size(X);
Y = reshape(imgview_freq.powspctrm, n, []);

norm.best = X\Y;
dfe = n - p;
err = Y - X * norm.best;
mse = sum((err).^2)/dfe;
covar = diag(X'*X)';
bvar = repmat(mse', 1, size(covar,2))./repmat(covar,size(mse,2),1);
norm.tval = (norm.best'./ sqrt(bvar))';
norm.prob = (1-tcdf(abs(norm.tval), dfe))*2;

adj_prob = reshape(norm.prob, [], 1);
[norm.h, norm.crit_p, norm.adj_ci_cvrg, norm.adj_p]=fdr_bh(adj_prob,.05,'pdep','yes');

glb.base = base;
glb.norm = norm;


%%% LOCAL BSE TESTING
% creates lcl structure
lcl = struct();
base = struct();
norm = struct();

% Basic
for j = a:b
    for k = 1:size(imgview_freq.powspctrm, 3)
        for l = 1:size(imgview_freq.powspctrm, 4)

            X = design;
            Y = squeeze(imgview_freq.powspctrm(:,j,k,l));

            [n, p] = size(X); % record rows and columns
            
            gram = X' * X; % Gram matrix
        
            invgram = gram^(-1);
        
            err_freedom = n - p; % requires n > p, or number of observations > parameters
        
            % Beta
            best = invgram * X' * Y; % beta hat
        
            % Residuals
            res = Y - X * best;
        
            var_res = res' * res ./ err_freedom * invgram;
            var_sq = res' * res ./ err_freedom;
        
            % Variance of Beta
            var_coeff = var_res^2 * invgram;
        
            % Standard Error of Coefficients
            SE_coeff = sqrt(diag(var_coeff));
        
            % Calculate the sum of squared residuals
            sumsqerr = res' * res;
        
            % Calculate the total sum of squares
            sumsqtotal = (Y - mean(Y))' * (Y - mean(Y));
        
            % Coefficient of Determination (R-squared)
            r2 = 1 - sumsqerr / sumsqtotal;
        
            % Calculate t-statistics and p-values for each coefficient
            tstat = best' ./ SE_coeff';
            pval = (1 - tcdf(abs(tstat), err_freedom)) * 2;
            
            for t = 1:p
                base.best(t, j, k, l) = best(t);
                base.stat(t, j, k, l) = tstat(t);
                base.prob(t, j, k, l) = pval(t);
            end


        end
    end
end


fullp = reshape(base.prob, [], 1);

[base.h, base.crit_p, base.adj_ci_cvrg, base.adj_p]=fdr_bh(fullp,.05,'pdep','yes');

lcl.base = base;

% Normalized
for j = a:b
    for k = 1:size(imgview_freq.powspctrm, 3)
        for l = 1:size(imgview_freq.powspctrm, 4)

            X = design_norm;
            Y = squeeze(imgview_freq.powspctrm(:,j,k,l));

            [n, p] = size(X); % record rows and columns
            
            gram = X' * X; % Gram matrix
        
            invgram = gram^(-1);
        
            err_freedom = n - p; % requires n > p, or number of observations > parameters
        
            % Beta
            best = invgram * X' * Y; % beta hat
        
            % Residuals
            res = Y - X * best;
        
            var_res = res' * res ./ err_freedom * invgram;
            var_sq = res' * res ./ err_freedom;
        
            % Variance of Beta
            var_coeff = var_res^2 * invgram;
        
            % Standard Error of Coefficients
            SE_coeff = sqrt(diag(var_coeff));
        
            % Calculate the sum of squared residuals
            sumsqerr = res' * res;
        
            % Calculate the total sum of squares
            sumsqtotal = (Y - mean(Y))' * (Y - mean(Y));
        
            % Coefficient of Determination (R-squared)
            r2 = 1 - sumsqerr / sumsqtotal;
        
            % Calculate t-statistics and p-values for each coefficient
            tstat = best' ./ SE_coeff';
            pval = (1 - tcdf(abs(tstat), err_freedom)) * 2;
            
            for t = 1:p
                norm.best(t, j, k, l) = best(t);
                norm.stat(t, j, k, l) = tstat(t);
                norm.prob(t, j, k, l) = pval(t);
            end


        end
    end
end


fullp = reshape(norm.prob, [], 1);

[norm.h, norm.crit_p, norm.adj_ci_cvrg, norm.adj_p]=fdr_bh(fullp,.05,'pdep','yes');

lcl.norm = norm;

%%% PERMUTATION TESTING
perms = 10000;

chans = size(data.powspctrm, 2);
freqs = size(data.powspctrm, 3);
times = size(data.powspctrm, 4);

t_null = struct;

for k = a:b % channels in this chunk
    for ii = 1:perms
        null_design = zeros(n, p); % Initialize null_design
        for i = 1:p % number of categories in design
            null_design(:,i) = datasample(design(:,i), n, 'Replace', false);
        end
        
        X = null_design;
        Y = reshape(data.powspctrm, n, []);
        
        best = X\Y;
        dfe = n - p;
        err = Y - X * best;
        mse = sum((err).^2)/dfe;
        covar = diag(X'*X)';
        bvar = repmat(mse', 1, size(covar,2))./repmat(covar,size(mse,2),1);
        tval = (best'./ sqrt(bvar))';
        tval = reshape(tval, [p, chans, freqs, times]);

        for v = 1:p
            t_null.max{v} = max(abs(squeeze(tval(v,k,:,:))));
        end
    end
    
    for v = 1:p
    t_null.thresh{v, k} = prctile([t_null.max{v}], 95); % Threshold computation
    end
end


all_tests = struct();
all_tests.glb = glb;
all_tests.lcl = lcl;
all_tests.perm = t_null; % This is the global dfe


% Save example 
filename = sprintf("Group_%s.mat", chans)
save(filename, 'all_tests')

quit
