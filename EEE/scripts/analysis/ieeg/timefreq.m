%%
cfg = [];
cfg.reref = 'yes';
cfg.refmethod = 'bipolar';
cfg.refchannel = 'all';
cfg.groupchans = 'yes';

full = ft_preprocessing(cfg, data);

cfg.trials      = (event.conform == 1);
conform = ft_preprocessing(cfg, data);

cfg.trials      = (event.conform == 0);
diverge = ft_preprocessing(cfg, data);

cfg.trials    = (event.val_type == 1);
hival  = ft_preprocessing(cfg, data);

cfg.trials    = (event.val_type == -1);
loval  = ft_preprocessing(cfg, data);

cfg.trials    = (event.highcue_indx == 1);
hicue  = ft_preprocessing(cfg, data);

cfg.trials    = (event.highcue_indx == -1);
locue  = ft_preprocessing(cfg, data);

%%


% spectral decomposition
    timres          = .02; % 50 ms steps
    cfg             = [];
    cfg.output      = 'pow';
    % cfg.output      = 'powandcsd';
    cfg.method      = 'mtmconvol';
    cfg.taper       = 'dpss';
    cfg.foi         = 45:5:200;
    cfg.tapsmofrq   = 10;
    cfg.t_ftimwin   = .2*ones(length(cfg.foi),1); % 300 ms
    cfg.toi         = data.time{1}(1):timres:data.time{1}(end);  % begin to end of experiment
    cfg.keeptrials  = 'yes';
    cfg.pad         = 'nextpow2';

%%
    full_hifreq = ft_freqanalysis(cfg, full);
%%
    conform_hifreq = ft_freqanalysis(cfg, conform);
    diverge_hifreq = ft_freqanalysis(cfg, diverge);
%%
    hival_hifreq = ft_freqanalysis(cfg, hival);
    loval_hifreq = ft_freqanalysis(cfg, loval);
%%
    hicue_hifreq = ft_freqanalysis(cfg, hicue);
    locue_hifreq = ft_freqanalysis(cfg, locue);

    %%
cfg.foi  = 3:4:43;
cfg.taper = 'hanning';

    full_lofreq = ft_freqanalysis(cfg, data);
%%
    conform_lofreq = ft_freqanalysis(cfg, conform);
    diverge_lofreq = ft_freqanalysis(cfg, diverge);
%%
    hival_lofreq = ft_freqanalysis(cfg, hival);
    loval_lofreq = ft_freqanalysis(cfg, loval);
%%
    hicue_lofreq = ft_freqanalysis(cfg, hicue);
    locue_lofreq = ft_freqanalysis(cfg, locue);
%% Connectivity 
% cfg = [];
% cfg.method = 'coh';
% conn1 = ft_connectivityanalysis(cfg, hival_freq);
% conn2 = ft_connectivityanalysis(cfg, loval_freq);
% 
% figure
% hold on
% plot(conn1.freq, conn1.cohspctrm, 'b');
% plot(conn2.freq, conn2.cohspctrm, 'r');
% legend({sprintf('snr = %f', snr1), sprintf('snr = %f', snr2)});    
    
%%
cfg           = [];
% cfg.operation = '(x1-x2) / (x1)';
cfg.operation = '(x1 - x2)';
cfg.parameter = 'powspctrm';
cfg.channel = 'RTA1-RTA2';

difference_freq = ft_math(cfg, hival_freq, loval_freq);


 %%
% cfg = [];
% cfg.baseline = [-1 -0.1];
% cfg.parameter = 'powspctrm';
% % cfg.baselinetype = 'relchange';
% % cfg.zlim = [-300 300];
% 
% for c = 95:100
%     % cfg.channel = reref.label{55};
% cfg.channel = reref.label{c}; % top figure
%     % freq             = ft_freqbaseline(cfg,tfr)
%     figure; 
% %     hold on
% %     xlabel('Time (s)');
% %     ylabel('Frequency (Hz)');
%     ft_singleplotTFR(cfg, tfr);
%     ft_singleplotTFR(cfg, tfr_lo);
% 
%     ft_singleplotTFR(cfg, difference_gamma);
% end

%%
cfg = [];
% cfg.channel = 'RTA*';
cfg.layout = 'vertical';
cfg.direction = 'BT';
cfg.width = 0.2;
cfg.showlabels = 'yes';
layoutmulti = ft_prepare_layout(cfg, conform_freq);
%%
cfg = [];
% cfg.baseline = [-inf 0];
cfg.baseline = [-3 -2.5];

cfg.baselinetype = 'relchange';
cfg.layout = layoutRTA;

ft_multiplotTFR(cfg, conform_freq)
ft_multiplotTFR(cfg, diverge_freq)

%%
cfg = [];
cfg.baseline = [-3 -2.5];
cfg.parameter = 'powspctrm';
cfg.baselinetype = 'relchange';
cfg.layout = 'vertical';
cfg.direction = 'TB';

cfg.channel    = ft_channelselection('RPAG*', conform_freq.label);

% cfg.masknans = 'yes';
% cfg.baselinetype = 'relchange';
% cfg.zlim = [-1 3];
% ft_singleplotTFR(cfg, conform_freq)
% ft_singleplotTFR(cfg, diverge_freq)

ft_multiplotTFR(cfg, conform_freq)
ft_multiplotTFR(cfg, diverge_freq)

% ft_movieplotTFR(cfg, conform_freq)
%%
freqs = {conform_freq diverge_freq hival_freq loval_freq hicue_freq locue_freq};

cfg = [];
cfg.baseline = [0.6 0.9];
% cfg.zlim = [-1 3];
% cfg.xlim = [-1 5];
cfg.parameter = 'powspctrm';
cfg.baselinetype = 'db';
cfg.showlabels = 'yes';
% cfg.figure = 'no';
cfg.layout = 'vertical';
cfg.channel = 'RPAG*';
cfg.showoutline = 'yes';
cfg.masknans   = 'yes';
cfg.fontsize = 16;
cfg.operation = '(x1 - x2) / x1';

%%
ft_multiplotTFR(cfg, full_freq)

%% t test 3d in canlab
% then replace with mixed effects analysis
help ttest3d

%%
ft_multiplotTFR(cfg, hival_freq)
ft_multiplotTFR(cfg, loval_freq)

ft_multiplotTFR(cfg, conform_freq)
ft_multiplotTFR(cfg, diverge_freq)


ft_multiplotTFR(cfg, hicue_freq)
ft_multiplotTFR(cfg, locue_freq)

%% saved in dropbox in Analysis
%%


% val_diff = ft_math(cfg, hival_freq, loval_freq);


% ft_singleplotTFR(cfg, val_diff)

%%
%conform_diff = ft_math(cfg, conform_freq, diverge_freq);
%ft_singleplotTFR(cfg, conform_diff)



%%
cfg.channel = 'RTA1-RTA2';
ft_singleplotTFR(cfg, full_hifreq)
% ft_singleplotTFR(cfg, diverge_freq)

%%
% cue_diff = ft_math(cfg, hicue_freq, locue_freq);


% ft_multiplotTFR(cfg, cue_diff)

% ft_singleplotTFR(cfg, difference_freq)


% consistent across
% 'RTA1-RTA2'
% 'LTA1-LTA3'

% Picks up in RPAG 

% different





%%
% cfg.layout = 'horizontal'


% layout = ft_prepare_layout(cfg)
for d = 1:numel(depths)
    cfg = [];
    cfg.baseline = [-1 -0.1];
    cfg.baselinetype = 'absolute'
    cfg.channel = ft_channelselection(depths{d}, hdr.label);
    cfg.layout = 'vertical';
    % cfg.direction = 'TB';
    ft_multiplotTFR(cfg, hival_freq)
end

%%
for d = 1:2%numel(depths)
    cfg = [];
    cfg.baseline = [-1 -0.1];
    cfg.baselinetype = 'relative';
    cfg.channel = ft_channelselection(depths{d}, hicue_freq.label);
    cfg.layout = 'vertical';
    % cfg.label = cfg.channel;
    cfg.showlabels = 'yes';
    % cfg.direction = 'TB';
    
    ft_multiplotTFR(cfg, hicue_freq)
    % ft_multiplotTFR(cfg, locue_freq)
    % ft_multiplotTFR(cfg, difference_freq)
end
%%
cfg.channel = 'RTA*';
ft_singleplotTFR(cfg, hival_bp_freq)
ft_singleplotTFR(cfg, loval_bp_freq)




