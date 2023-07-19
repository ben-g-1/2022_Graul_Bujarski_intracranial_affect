%%%
grouptype = 'highcue_indx';
trialinfo = imgview_freq.trialinfo;
condcol = trialinfo(:, grouptype);

%%%
%%
% find high and low valence trials 
condA = condcol(:,1) == 1;
condA = table2array(condA);
cfg = [];
cfg.trials = condA;
condA = ft_selectdata(cfg, imgview_freq);
%%
condB = condcol(:,1) == -1;
condB = table2array(condB);
cfg = [];
cfg.trials = condB;
condB = ft_selectdata(cfg, imgview_freq);

%%
% z score for equal contributions
condA = ft_zscore_pow(condA);
condB = ft_zscore_pow(condB);
%%
% average frequency contribution
cfg             = [];
cfg.avgoverfreq = 'yes';
cfg.nanmean     = 'yes';
avg_condA = ft_selectdata(cfg, condA);
avg_condB = ft_selectdata(cfg, condB);

%%
% calculate difference between 
cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = '(x1-x2)';
conddif = ft_math(cfg, avg_condA, avg_condB);

