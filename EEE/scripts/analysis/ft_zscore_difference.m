function [conddif] = ft_zscore_difference(data, grouptype, valA, valB)

% FT_ZSCORE_DIFFERENCE returns a single FieldTrip structure calculated from 
% the difference of z-scored power from a powspctrm object. 
% 
% Use as
%     [conddif] = ft_zscore_difference(data, grouptype, valA, valB);
% grouptype: 'highcue_indx', 'val_type;


%%%%%%%
trialinfo = data.trialinfo;
condcol = trialinfo(:, grouptype);

% find high and low valence trials 
condA = condcol(:,1) == valA;
condA = table2array(condA);
cfg = [];
cfg.trials = condA;
condA = ft_selectdata(cfg, data);
%%
condB = condcol(:,1) == valB;
condB = table2array(condB);
cfg = [];
cfg.trials = condB;
condB = ft_selectdata(cfg, data);

%%
% z score for equal contributions
condA = ft_zscore_pow(condA);
condB = ft_zscore_pow(condB);
%%
% average frequency contribution
cfg             = [];
cfg.avgoverfreq = 'yes';
cfg.avgoverrpt  = 'yes';
cfg.nanmean     = 'yes';
avg_condA = ft_selectdata(cfg, condA);
avg_condB = ft_selectdata(cfg, condB);

%%
% calculate difference between 
cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = '(x1-x2)';
conddif = ft_math(cfg, avg_condA, avg_condB);
end