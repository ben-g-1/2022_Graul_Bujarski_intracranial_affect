%% Connectivity analysis

cfg = [];
cfg.method = 'amplcorr';
cfg.feedback = 'yes';
cfg.channel = {'RTA1', 'RTA2'};

t = ft_selectdata(cfg, imgview_freq);

stat = ft_connectivityanalysis(cfg, t);
