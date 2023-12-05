%%% Beta Weights

try 
    data = imgview_freq;
catch 
    load("imgview_freq_bpref.mat");
    data = imgview_freq;
end


data = imgview_freq;
trlinfo = data.trialinfo;
trlinfo.rate_diff = abs(trlinfo.val_rating - trlinfo.exp_rating);
%%
% design = [ones(63,1) trlinfo.Arousal_mean trlinfo.Valence_mean];

%arousal is much less varied than valence
% best combo is Valence_mean val_rating
% Intercept makes a pretty big difference

% design = [ones(63,1) trlinfo.Valence_mean trlinfo.highcue_indx];
% design = [trlinfo.Valence_mean trlinfo.cue_observed_mean];
% design = [ones(63,1)];


design =   [ones(63,1) trlinfo.val_rating];
% design = [ones(63,1) trlinfo.Valence_mean trlinfo.cue_observed_mean];

% Check correlation between highcue_indx and cue_observed_mean

% design = [ones(63,1) trlinfo.Valence_mean trlinfo.highcue_indx];
% design = [ones(63,1) trlinfo.val_rating trlinfo.highcue_indx];
% design = [ones(63,1) trlinfo.Valence_mean trlinfo.exp_rating];
% design = [ones(63,1) trlinfo.Valence_mean trlinfo.rate_diff];
% design = [trlinfo.Valence_mean(randperm(numel(trlinfo.Valence_mean))) trlinfo.cue_observed_mean(randperm(numel(trlinfo.cue_observed_mean)))];
%%
cfg = [];
cfg.confound = design;
cfg.output = 'beta';
cfg.statistics = 'yes';
cfg.normalize = 'no';

% cfg.ftest = {'1'; '2'};
% cfg.ftest = {'1'; '2'; '3'; '1 2'; '2 3'};

data = ft_selectdata(cfg,data);
betas = ft_regressconfound_absfix(cfg, data);

% bsize = size(betas.beta(2,:,:,:))
bsize = size(betas.beta([2 3],:,:,:))

% designp = reshape(betas.prob(2,:), [], 1);

designp = [reshape(betas.prob(2,:), [], 1); reshape(betas.prob(3,:), [], 1)];

[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(designp,.05,'pdep','yes');



%%
% adj_p = reshape(adj_p, 1, numel(bsize));
betas.adj_h = adj_p;
for i = 1:numel(adj_p)
    if adj_p(i, 1) > 0.05
        betas.adj_h(i, 1) = 0;
    else
        betas.adj_h(i, 1) = 1;
    end
end

betas.adj_h = reshape(betas.adj_h, bsize);

%%
betas.h = designp;
for i = 1:numel(betas.h)
    if betas.h(i,1) > 0.05
        betas.h(i,1) = 0;
    else
        betas.h(i,1) = 1;
    end
end

betas.h = reshape(betas.h, bsize);
%%
d_factor = 1;


cfg = [];
cfg.avgoverrpt = 'yes';
cfg.baseline = 'yes';
cfg.baselinetype = 'zscore';

bl_data = ft_freqbaseline(cfg, data);
mask_data = ft_selectdata(cfg, data);

% mask_data = ft_selectdata(cfg, bl_data);

mask_p = squeeze(betas.h(d_factor, :,:,:));
sum(sum(sum(mask_p)))

%%


for chan = 1:numel(mask_data.label)
    mask_data.mask(chan, :, :) = mask_data.powspctrm(chan, :, :) .* mask_p(chan,:,:);
end

mask_data.h = mask_p;

mask_data.b1 = squeeze(betas.beta(1,:,:,:));
mask_data.t1 = squeeze(betas.stat(1,:,:,:));

mask_data.b2 = squeeze(betas.beta(2,:,:,:));
mask_data.t2 = squeeze(betas.stat(2,:,:,:));


% 
% mask_data.b3 = squeeze(betas.beta(3,:,:,:));
% mask_data.t3 = squeeze(betas.stat(3,:,:,:));

mask_data.h_log = mask_data.h > 0;

fprintf('Masking complete.')



%%
c = 1;
sigchans = {};
for i = 1:numel(mask_data.label)
    channame = mask_data.label{i};
    if sum(sum(mask_p(i,:,:))) > 150
    
        sigchans{c} = channame;
        c = c + 1;
    end
end
sigchans


%%
cfg = [];
for chan = 1:numel(sigchans)
    cfg.channel = sigchans{chan};
    % cfg.channel = 'RTA1-RTA2';
    
    cfg.parameter = 't1';
    cfg.maskparameter = 'h';




    % cfg.parameter = 'powspctrm';
    % cfg.maskparameter = 'h_log';
    % cfg.maskstyle = 'outline';
    % cfg.maskalpha = .8;
    % cfg.xlim = [-0.2 2];

    % cfg.colormap = 'RdBu';
    % cfg.zlim = [-2 2];

    % cfg.parameter = 'powspctrm';
    % cfg.baseline = 'yes';
    % cfg.baselinetype = 'zscore';

    ft_singleplotTFR(cfg, mask_data)
       fig = gcf;
       fig.Position = [700 500 560 420];

end


%% Permutation Testing
perm_num = 3;
t_null = {perm_num};
for k = 1:5%numel(betas.label)
   % t_val = betas.stat(2,k,:,:);
for i = 1:perm_num
    betas_null = {};

        perm_2 = datasample(design(:,2), numel(design(:,2)), 'Replace', false);
        perm_3 = datasample(design(:,3), numel(design(:,3)), 'Replace', false);
        null_design = [ones(63,1), perm_2, perm_3];

    cfg = [];
    cfg.channel = k;

    cfg.confound = null_design;
    cfg.reject = [0 0];
    cfg.output = 'beta';
    cfg.statistics = 'yes';

    dat = ft_selectdata(cfg,data);
    betas_null = ft_regressconfound_absfix(cfg, dat);
    t_null{i, k} = (betas_null.stat);

end
end
%% Permutation Testing w/o ft function



for i = 1:p
    null_design(:,i) = datasample(design(:,i), n, 'Replace', false);
end
%%
[n,p] = size(design);

perms = 100;

chans = size(data.powspctrm, 2);
freqs = size(data.powspctrm, 3);
times = size(data.powspctrm, 4);

t_null = struct;


for k = 1:2 % channels
    for ii = 1:perms
        % Create null matrix
        for i = 1:p %number of categories in design
            null_design(:,i) = datasample(design(:,i), n, 'Replace', false);
        end
        X = null_design;
        Y = reshape(imgview_freq.powspctrm, n, []);
        
        best = X\Y;
        dfe = n - p;
        err = Y - X * best;
        mse = sum((err).^2)/dfe;
        covar = diag(X'*X)';
        bvar = repmat(mse', 1, size(covar,2))./repmat(covar,size(mse,2),1);
        tval = (best'./ sqrt(bvar))';
        tval = reshape(tval, p, chans, freqs, times);

        for v = 1:p
            t_null.max{v, k, ii} = max(max(abs(tval(v,k,:,:))));
        end

    end
    for v = 1:p
    t_null.thresh{v, k} = prctile([t_null.max{v,k,:}], 95);
    end
end
%% Permutation testing with global bvar (run on Discovery in batches of 25 channels)
[n,p] = size(design); 

perms = 10000;

chans = size(data.powspctrm, 2);
freqs = size(data.powspctrm, 3);
times = size(data.powspctrm, 4);

t_null = struct;

for k = 1:chans % channels
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

%%
% t thresholds
null_thresh = {};
for k = 1:5%numel(betas.label)
    max_null = {};
    for i = 1:perms
    max_null{i} = max(max(abs(t_null{i}(2,:,:,:))));
    end
    max_null = cell2mat(max_null);
    null_thresh{k} = prctile(max_null, 95);
    % end
end


% end
beep

%% masking
mask_t = zeros(bsize(2), bsize(3), bsize(4));
for k = 1:5%numel(betas.label)
    t_val = (squeeze(betas.stat(2,k,:,:)));
    t_val(abs(t_val) < abs(null_thresh{k})) = 0;
    t_val(t_val ~= 0) = 1;
    t_val_mask{k} = t_val;
end


%%
for chan = 1:10%:numel(t_val_mask)

    % valence_betas = squeeze(betas.beta(1,chan,:,:));
    % valence_t = squeeze(betas.stat(1,1,:,:));
    % valence_p = squeeze(betas.prob(1,1,:,:));
    
    % Normalize Frequency contributions
    % norm_val = zscore(valence_betas, 0, 2);
    % mask_val = squeeze(betas.cor_prob(1,chan,:,:)) .* norm_val;
    
    % Create a time/frequency plot using imagesc
    figure; hold on; 
    % imagesc(flipud(mask_val));
    imagesc(t_val_mask{chan});
    

    % Add labels and title
    ax = gca;
    xlabel('Time');
    ylabel('Frequency');
    ax.YTickLabel = {'4', '14', '24', '40', '70', '100', '130', '160', '190'};
    ax.XTickLabel = {'-2.5', '-1.5', '-0.5', '0.5', '1.5', '2.5', '3.5', '4.5', '5.5'};
    fig = gcf;
    fig.Position = [900 500 560 420];
    title(sprintf('Time/Frequency T Weight %s', betas.label{chan}));
    
    % trim white space
    % xlim(ax, [200 700])

    
    % Customize the colormap and set common color scale
    colormap('hsv');
    colorbar;
    clim(ax, [-5 5]);
    
    % 
    hold off;

end

%% Compare masks 
c1_comp = t_val_mask{1} - squeeze(mask_p(1,:,:));
c1_equal = sum(sum(t_val_mask{1} == squeeze(mask_p(1,:,:))))

%%
cfg = [];
cfg.channel = 1;
testmask = ft_selectdata(cfg, mask_data);
testmaskp = mask_p(1,:,:);


%%
cfg = [];
cfg.channel = 'RTA1-RTA2';
ft_singleplotTFR(cfg, mask_data)
  fig = gcf;
    fig.Position = [900 500 560 420];


%% Testing baseline types
cfg.avgoverrpt = 'yes';
avgRTA = ft_selectdata(cfg, data);
ft_singleplotTFR(cfg, avgRTA)

  fig = gcf;
    fig.Position = [900 500 560 420];
%%
cfg.baseline = 'yes';
cfg.baselinetype = 'zscore';

ft_singleplotTFR(cfg, avgRTA)

  fig = gcf;
    fig.Position = [900 500 560 420];

cfg.baselinetype = 'relative';
ft_singleplotTFR(cfg, avgRTA)

  fig = gcf;
    fig.Position = [900 500 560 420];
    
cfg.baselinetype = 'relchange';
ft_singleplotTFR(cfg, avgRTA)

  fig = gcf;
    fig.Position = [900 500 560 420];

cfg.baselinetype = 'db';
ft_singleplotTFR(cfg, avgRTA)

  fig = gcf;
    fig.Position = [900 500 560 420];

    cfg.baselinetype = 'absolute';
ft_singleplotTFR(cfg, avgRTA)

  fig = gcf;
    fig.Position = [900 500 560 420];

    cfg.baselinetype = 'normchange';
ft_singleplotTFR(cfg, avgRTA)

  fig = gcf;
    fig.Position = [900 500 560 420];
    %%
cfg.baseline = [-2 -1.5];
ft_singleplotTFR(cfg, avgRTA)

  fig = gcf;
    fig.Position = [900 500 560 420];
    
%%


% Plan
% Use masks to identify clear norm valence responders
% Compare to valence rating provided
% Map in 3D using array 



% Interesting survivors (abs ref, val_mean: RTA1*, LTA1, RPPC3, RPRS7, RPRS11*,
% RPAG2+10, RFC10, LTHA5)






%% From ChatGPT for reshaping of matrix testing instead of a vector
my4Darray = betas.prob;
[rows, cols, depth, pages] = size(my4Darray);


% Reshape the 4D array into a matrix with three columns
reshaped_matrix = reshape(permute(my4Darray, [1, 4, 2, 3]), 3, rows * pages * cols * depth);

% Reshape the matrix back to the original shape
reshaped_back = permute(reshape(reshaped_matrix, 3, pages, cols, depth, rows), [1, 5, 3, 4, 2]);

% Check if the reshaped array matches the original size
isequal(size(my4Darray), size(reshaped_back))

%% Check Gaussian Distribution
% Assuming your data is stored in a matrix called 'existing_data'
% Check for Gaussian distribution for each column (variable)
num_vars = size(design, 2);

for i = 1:num_vars
    variable = design(:, i);
    [h, p] = kstest(variable);
    disp(['Variable ', num2str(i), ':']);
    if h == 0
        disp('The variable follows a Gaussian distribution.');
    else
        disp('The variable does not follow a Gaussian distribution.');
    end
    disp(['p-value: ', num2str(p)]);
end

%%
X = design;
% Calculate the variance inflation factors (VIF)
vif = diag(inv(X' * X))';

% Display VIF values and their interpretation
disp('Variance Inflation Factors (VIF):');
disp(vif);

% Check for multicollinearity (common rule of thumb: VIF > 5 indicates potential multicollinearity)
threshold = 3;
multicollinear_vars = find(vif > threshold);
if ~isempty(multicollinear_vars)
    disp('Potential multicollinearity in the following variables:');
    disp(multicollinear_vars);
else
    disp('No significant multicollinearity detected.');
end

%%
Y = squeeze(mask_data.powspctrm(1, :,:));
mdl = fitlm(X, Y);

% Calculate the coefficient of determination (R-squared) for X1
R_squared_X1 = mdl.Rsquared.Ordinary(1);

% Calculate the VIF for X1
VIF_X1 = 1 / (1 - R_squared_X1);

% Display the VIF for X1
fprintf('VIF for X1: %.4f\n', VIF_X1);
%%
% Your data dimensions: [1 128 28 101]
num_permutations = 100;  % Number of permutations
alpha = 0.05;  % Significance level

% Observed data (replace with your actual data)
observed_data = data;  % Your observed data for channels, frequency, and time

% Preallocate matrices to store results
observed_t_values = zeros(128, 28, 101);
significant_mask = false(128, 28, 101);

% Loop through each channel, frequency, and time point
for channel = 1:128
    for frequency = 1:5:28
        for time_point = 1:20:101
            % Extract the observed data for the current channel, frequency, and time
            % observed_values = squeeze(observed_data(1, channel, frequency, time_point));
            
            % Calculate the observed t-value
            observed_t_values(channel, frequency, time_point) = betas.stat(1,channel, frequency, time_point); % Calculate t-value
            
            % Perform permutation testing
            permuted_t_values = zeros(num_permutations, 1);
            for perm = 1:num_permutations
                % Randomly permute the data and calculate t-value
                cfg = [];
                cfg.confound = design(randperm(size(design,1)), :);
                cfg.reject = [0 0];
                cfg.output = 'beta';
                cfg.statistics = 'yes';
                
                permuted_data = ft_regressconfound_absfix(cfg, data); % Generate permuted data (shuffle observed_values)
                permuted_t_values(perm) = permuted_data.stat(1, channel, frequency, time_point);  % Calculate t-value for permuted data
            end
            
            % Calculate the threshold based on the 95th percentile
            threshold = prctile(permuted_t_values, (1 - alpha) * 100);
            
            % Check if the observed t-value is significant
            significant_mask(channel, frequency, time_point) = (observed_t_values(channel, frequency, time_point) > threshold);
        end
    end
end

% significant_mask now contains true for significant t-values and false for non-significant ones.

%% By Hand GLM
% single t/f point across trials
numperm = 500;
Y = squeeze(data.powspctrm(:,1,1,1));
Xni = trlinfo.Valence_mean;
% X = [ones(size(Xni,1),1) Xni];
X = Xni;
[n,p] = size(X);
freedom = n-p;

% sample estimates
B_hat = (X' * X)^-1 * X' * Y; % sample beta estimate
Y_hat = X * B_hat; % Predicted values
resid = Y - Y_hat;
var_resid = resid' * resid ./ freedom * (X'*X)^-1
var_sq = resid' * resid ./ freedom

B_var = var_resid^2  * (X'*X)^-1
B_SE  = sqrt(diag(B_var))

    % Calculate the sum of squared residuals
    sumsqerr = resid' * resid;

    % Calculate the total sum of squares
    sumsqtotal = (Y - mean(Y))' * (Y - mean(Y));

    % Coefficient of Determination (R-squared)
    r2 = 1 - sumsqerr / sumsqtotal;

    % Calculate t-statistics and p-values for each coefficient
    tstat = B_hat ./ B_SE
    pval = (1 - tcdf(abs(tstat), freedom)) * 2;

std(resid);
%%
t_hat = B_hat / (resid / sqrt(sum(X(:, 2:end).^2)));

% null estimates
Bnull = zeros(numperm, 1);
for i = 1:numperm
    Ynull = Y(randperm(size(Y,1)), :);
    B_null_hat = (X' * X)^-1 * X' * Ynull; % null beta estimate
    
    Bnull(i,1) = Bnullest;

end %for 

%%
numperm = 500;
Y = squeeze(data.powspctrm(:,1,1,1));
Xni = trlinfo.Valence_mean;
X = [ones(size(Xni, 1), 1), Xni]; % Include the intercept term
%%
[n, p] = size(X);
freedom = n - p;

% Sample estimates
B_hat = (X' * X)^-1 * X' * Y % Sample beta estimate
Y_hat = X * B_hat; % Predicted values
resid = Y - Y_hat;
var_resid = resid' * resid / freedom * (X' * X)^-1;
var_sq = resid' * resid / freedom;

B_var = var_resid^2 * (X' * X)^-1;
B_SE = sqrt(diag(B_var));

% Calculate the sum of squared residuals
sumsqerr = resid' * resid;

% Calculate the total sum of squares
sumsqtotal = (Y - mean(Y))' * (Y - mean(Y));

% Coefficient of Determination (R-squared)
r2 = 1 - sumsqerr / sumsqtotal;

% Calculate t-statistics and p-values for each coefficient
tstat = B_hat ./ B_SE
pval = (1 - tcdf(abs(tstat), freedom)) * 2

std_resid = std(resid);
%%
% Permutation test
t_null = zeros(numperm, 2);
for i = 1:numperm
    Ynull = Y(randperm(n), :);
    B_null_hat = (X' * X)^-1 * X' * Ynull;
    resid_null = Ynull - X * B_null_hat;
    t_null(i,1) = B_hat(2) / (std(resid_null) / sqrt(sum(X(:, 2).^2)));
end

t95 = prctile(t_null(:,1), 95);


%%
% Calculate the p-value for the original tstat
p_value = sum(max(abs(t_null(:,1)) >= abs(t_null(:,2))) / numperm);

% Display the p-value
fprintf('p-value for tstat: %.4f\n', p_value);

% Determine significance based on a chosen significance level (e.g., alpha = 0.05)
alpha = 0.05;
if p_value < alpha
    fprintf('tstat is significant at the %.2f level.\n', alpha);
else
    fprintf('tstat is not significant at the %.2f level.\n', alpha);
end
%%
% Assuming you already have tstat and t_null values

% Calculate the p-value for the original tstat
p_value = sum(abs(tstat) >= abs(t_null)) / numperm;

% Display the p-value
fprintf('p-value for tstat: %.4f\n', p_value);

% Determine significance based on a chosen significance level (e.g., alpha = 0.05)
alpha = 0.05;
if p_value < alpha
    fprintf('tstat is significant at the %.2f level.\n', alpha);
else
    fprintf('tstat is not significant at the %.2f level.\n', alpha);
end

%%
for trial = 1:size(data.powspctrm, 1)
    Y = squeeze(data.powspctrm(:, 1, :, :));
    X = trlinfo.Valence_mean;
    Best{trial} = (X)/Y;
    Yest{trial} = X * Best;



end % for 
%%
X = design;
Y = squeeze(imgview_freq.powspctrm(:,1,1,1));
    [n, p] = size(X); % record rows and columns
    
    gram = X' * X; % Gram matrix

    invgram = gram^-1;

    err_freedom = n - p; % requires n > p, or number of observations > parameters

    % Beta
    b_coeff = invgram * X' * Y % beta hat

    % Residuals
    res = Y - X * b_coeff;

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
    tstat = b_coeff ./ SE_coeff
    pval = (1 - tcdf(abs(tstat), err_freedom)) * 2

%% Manual Beta Estimates
betas_man = struct();
for j = 1:size(imgview_freq.powspctrm, 2)
    for k = 1:size(imgview_freq.powspctrm, 3)
        for l = 1:size(imgview_freq.powspctrm, 4)

            X = design;
            Y = squeeze(imgview_freq.powspctrm(:,j,k,l));

            [n, p] = size(X); % record rows and columns
            
            gram = X' * X; % Gram matrix
        
            invgram = gram^(-1);
        
            err_freedom = n - p; % requires n > p, or number of observations > parameters
        
            % Beta
            b_coeff = invgram * X' * Y; % beta hat
        
            % Residuals
            res = Y - X * b_coeff;
        
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
            tstat = b_coeff' ./ SE_coeff';
            pval = (1 - tcdf(abs(tstat), err_freedom)) * 2;
            
            for t = 1:p
                betas_man.beta(t, j, k, l) = b_coeff(t);
                betas_man.stat(t, j, k, l) = tstat(t);
                betas_man.prob(t, j, k, l) = pval(t);
            end


        end
    end
end

%%
fullp = reshape(betas_man.prob(2:3,:,:,:), [], 1);

[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(fullp,.05,'pdep','yes');
%%
adj_p = reshape(adj_p, 1, numel(adj_p));
for i = 1:numel(adj_p)
    if adj_p(1, i) > 0.05
        adj_p(1, i) = 0;
    else
        adj_p(1, i) = 1;
    end
end

betas_man.cor_prob = reshape(adj_p, bsize);

%% Manual Beta Estimates round 3 
% The issue is that this method creates a global beta error and mse, while
% the other method creates a local error

%% If normalizing
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

%%
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
%%
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
%%
      dfe        = nrpt - nconf;                                              % degrees of freedom
      err        = dat - regr * beta;                                         % err = Y - X * B
      mse        = sum((err).^2)/dfe;                                         % mean squared error
      covar      = diag(regr'*regr)';                                         % regressor covariance
bvar  = repmat(mse',1,size(covar,2))./repmat(covar,size(mse,2),1); % beta variance
      tval       = (beta'./sqrt(bvar))';                                      % betas -> t-values
      prob       = (1-tcdf(abs(tval),dfe))*2;                                      % p-values