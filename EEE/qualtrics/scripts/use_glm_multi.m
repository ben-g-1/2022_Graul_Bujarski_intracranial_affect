% Use if loading script from GitHub
% fname = matlab.desktop.editor.getActiveFilename();
% fdir = fileparts(fname);
% cd(fdir);
% cd ../data
% ​
% load('pilot_master_long.mat')
​
load('C:\Users\bgrau\GitHub\ieeg_affect\EEE\qualtrics\data\pilot_master_long.mat');
%%
subs_cell = {};
valencerating = {};
group_cohort = [];
rownum = 1;
for i = 1:123
    for k = 1:64
        subs_cell{i}(k,:) = [master.trial(rownum), master.highcue_indx(rownum), master.img_rate(rownum) .* master.highcue_indx(rownum) master.Valence_mean(rownum)];
                % subs_cell{i}(k,:) = [master.Valence_mean(rownum), master.Pair(rownum), master.Valence_mean(rownum) .* master.Pair(rownum)];
​
        valencerating{i}(k,1) = master.img_rate(rownum);
        group_cohort(i) = master.Pair(rownum);
                % group_cohort(i) = master.highcue_indx(rownum);
​
        rownum = rownum + 1;
    end
end
group_cohort = group_cohort';
​
% Y = DV = affect rating per trial, within-person, 'ValRate' 
% X1 = 1st-level design = 'TrialNo' 'CueTypeHvsL' 'TrialNo x CueType'
% X2 = [], nothing for simple model, OR group contrasts, 3 columns to capture diffs across 4 groups, all cols mean-zero effects codes (1, -1)
​
% other potential within-person:
% Valence_mean and possibly Arousal_mean
​
EffectNames = {'Intercept' 'TrialNo' 'CueTypeHvsL' 'TrialNo x CueType' 'Valence_mean'};
​
stats = glmfit_multilevel(valencerating, subs_cell, [], 'names', EffectNames, 'beta_names', {'Pair Number'}, 'verbose', 'weighted');
​
% subs_cell = subs_cell(~cellfun('isempty', subs_cell));
​
% Plot effects
​
% Plot single columns of X against Y
​
% Check VIFs and plot summary of mean/dist VIFS
​
% Check mean inter-predictor correlation matrix and plot
​
% Add group design matrix
​
trialno = cellfun(@(x) x(:, 1), subs_cell, 'UniformOutput', false);
cuehl = cellfun(@(x) x(:, 2), subs_cell, 'UniformOutput', false);
out_stats = line_plot_multisubject(trialno, valencerating);
​
out_stats = line_plot_multisubject(cuehl, valencerating);