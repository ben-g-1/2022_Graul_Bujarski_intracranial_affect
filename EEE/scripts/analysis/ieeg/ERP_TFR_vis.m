%% Clean ERP
% first, average over trials, otherwise we'll have problems with ft_singleplotER
cfg = [];
ERP_condA_avg = ft_timelockanalysis(cfg, ERP_condA_bl);
ERP_condB_avg   = ft_timelockanalysis(cfg, ERP_condB_bl);

% add statistical mask to data
time_idx = find(ERP_condA_bl.time == stats_ERP.time(1)) : find(ERP_condA_bl.time == stats_ERP.time(end)); % find indices of timepoints in data corresponding to timepoints in stats
ERP_condA_bl.mask = false(size(ERP_condA_bl.avg));
ERP_condA_bl.mask(:,time_idx) = stats_ERP.mask;
%%
% plot the traces
cfg               = [];
% cfg.parameter     = 'avg';
cfg.xlim          = [0 3];
cfg.channel = 'RFC10';
cfg.trials = 1;
% cfg.maskparameter = 'mask';
% cfg.channel = 45;
    figure, ft_singleplotTFR(cfg, TFR_condA)

    %%
one_elec = ft_channelselection('LTHA3', ERP_condA_bl.label);
for e = 1:numel(one_elec)
cfg.channel = one_elec(e);
figure, ft_singleplotER(cfg,ERP_condA_bl,ERP_condB_bl)
figure, ft_singleplotER(cfg,HGP_cond1_avg,HGP_cond2_avg)

end

%% RFC10
%%
% loop over significant channels and plot
for ichan = 1:length(sigchans)

    cfg.channel = sigchans(ichan);
    figure, ft_singleplotER(cfg,ERP_condA_bl,ERP_condB_bl),
end

%% CLEAN HGP
% first, average over trials, otherwise we'll have problems with ft_singleplotER
cfg = [];
HGP_cond1_avg = ft_timelockanalysis(cfg, HGP_condA_bl);
HGP_cond2_avg   = ft_timelockanalysis(cfg, HGP_condB_bl);

% add statistical mask to data
time_idx = find(HGP_cond1_avg.time == stats_HGP.time(1)) : find(HGP_cond1_avg.time == stats_HGP.time(end)); % find indices of timepoints in data corresponding to timepoints in stats
HGP_cond1_avg.mask = false(size(HGP_cond1_avg.avg));
HGP_cond1_avg.mask(:,time_idx) = stats_HGP.mask;
%%
% plot the ERP traces
cfg               = [];
cfg.parameter     = 'avg';
cfg.xlim          = [-2.8 5.8];
% cfg.maskparameter = 'mask';
% cfg.baseline = [-0.5 -0.01];
cfg.baselinetype = 'relchange';
%%
cfg.channel = 'RFC5-RFC6';
figure, ft_singleplotER(cfg,HGP_cond1_avg,HGP_cond2_avg)


%%
one_elec = ft_channelselection('RPAG*', HGP_cond1_avg.label);
for e = 1:numel(one_elec)
cfg.channel = one_elec(e);
figure, ft_singleplotER(cfg,HGP_cond1_avg,HGP_cond2_avg)
end
%%
% loop over significant channels and plot
% for ichan = 1:numel(sigchans_HGP)
% 
%     cfg.channel = sigchans_HGP(ichan);
%     figure, ft_singleplotER(cfg,HGP_cond1_avg,HGP_cond2_avg),
% end