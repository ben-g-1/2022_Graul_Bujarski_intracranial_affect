bsline = [-0.5 -0.01];
mc_latency = [0 2];
freqtype = 'all';  % 'hi_gamma' 'lo_gamma', 'all'
comparison = 'cuetype'; %'cuetype' 'valtype' 'cueconverge' 'cueagree' 'cuetype_valneg'

%%% Conditions %%%

%%% High vs Low Cue
%   event.highcue_indx == 1;
%   event.highcue_indx == -1;

%%% Valrate toward cue vs. Valrate diverge from cue
%   event.conform == 1;
%   event.conform == 0

%%% High valence rating vs. low valence rating
%   event.val_type == 1;
%   event.val_type == -1;

%%% Valence ratings close to expectation ratings
%   event.agree == 1;
%   event.agree == 0;

%%
cfg = [];
cfg.dataset = eegfile;
cfg.channel = chans;

cfg.trialfun = 'trl_fullrun';
cfg.trialdef.pre = 30; % Picture viewing is at T = 0
cfg.trialdef.post = 30;
cfg.trialdef.event = event_full;
cfg.continuous = 'yes';

cfg = ft_definetrial(cfg);

cfg.reref = 'yes';
% cfg.refmethod = 'bipolar';
cfg.refchannel = 'LPPC7';
% cfg.groupchans = 'yes';

data = ft_preprocessing(cfg);

% cfg = [];
% cfg.resamplefs = 1024;
% data = ft_downsample(cfg, data);
%%
cfg = [];
cfg.preproc.lpfilter = 'yes';
cfg.preproc.lpfreq  = 200;
cfg.preproc.hpfilter = 'yes';
cfg.preproc.hpfreq = 3;

cfg.preproc.bsfilter = 'yes';
cfg.preproc.bsfiltord = 3;
cfg.preproc.bsfreq = [59 61; 119 121; 179 181];

cfg.preproc.detrend = 'yes';
cfg.preproc.demean = 'yes';

data = ft_preprocessing(cfg, data);

%%
cfg = [];
cfg.dataset = eegfile;
cfg.trialfun = 'trl_singlephase';
cfg.trialdef.pre = 2.5; 
cfg.trialdef.post = 5;
cfg.trialdef.offset = -2.5; % Picture viewing is at T = 0
cfg.trialdef.event = event_full;
cfg.trialdef.eventvalue = 6;
cfg.keeptrials = 'yes';

cfg = ft_definetrial(cfg);

cfg.trl = cfg.trl;
imgview = ft_redefinetrial(cfg, data);


% event = data.cfg.event;
% pairorder = sortrows(event,"Pair","ascend");

%%
switch comparison
    case 'cuetype'
        cond1 = event.highcue_indx == 1;
        cond2 = event.highcue_indx == -1;
    case 'valtype'
        cond1 = event.val_type == 1;
        cond2 = event.val_type == -1;
    case 'cueconverge'
        cond1 = event.conform == 1;
        cond2 = event.conform == 0;
    case 'cueagree'
        cond1 = event.agree == 1;
        cond2 = event.agree == 0;
    case 'cuetype_valneg'
        cond1 = event.highcue_indx == 1 & event.val_type == -1;
        cond2 = event.highcue_indx == -1 & event.val_type == -1;
    otherwise 
        error('Invalid comparison type entered.')
        

end




%% ERP and HGP analysis

cfg = [];
cfg.keeptrials = 'yes';
% cfg.preproc.lpfilter = 'yes';
% cfg.preproc.lpfreq  = 200;
% cfg.preproc.bsfilter = 'yes';
% cfg.preproc.bsfiltord = 3;
% cfg.preproc.bsfreq = [59 61; 119 121; 179 181];

% cfg.trials = cond1;
% 
% 
% ERP_condA = ft_timelockanalysis(cfg, data);
% 
% cfg.trials = cond2;
% 
% ERP_condB = ft_timelockanalysis(cfg, data);

cfg.trials = 'all';
ERP_allcue = ft_timelockanalysis(cfg,imgview);
%%
cfg = [];
cfg.avgoverrpt = 'yes';
ERP_condA_avg = ft_selectdata(cfg, ERP_condA_bl);
ERP_condB_avg = ft_selectdata(cfg, ERP_condB_bl);
ERP_allcue_avg = ft_selectdata(cfg, imgview_ERP_bl);

%% Plot ERPs
cfg = [];
% cfg.parameter = 'trial';
cfg.channel = 'RTA1';
% cfg.xlim = [0 1.4];
% cfg.xlim = [-3 1];


% figure, ft_singleplotER(cfg, ERP_condA_bl, ERP_condB_bl)
figure, ft_singleplotER(cfg, ERP_allcue)
%% time-frequency high gamma
    cfg             = [];

    cfg.keeptrials  = 'yes';

    cfg.method      = 'tfr';
    switch freqtype 
        case'hi_gamma'
            cfg.foi = [80 85 90 95 100 105 110 115 125 130 135 140 145 150 155 160 165 170 175 180 185 190]; % 80 - 190 Hz, leave out harmonics of 60 Hz
        case 'lo_gamma' 
            cfg.foi        = [35 40 45 50 55];
        case 'all'
            cfg.foi = [5 10 15 20 25 30 35 40 45 50 55 65 70 75 80 85 90 95 100 105 110 115 125 130 135 140 145 150 155 160 165 170 175 180 185 190]
    end

    cfg.width      = 10 * ones(1,length(cfg.foi));

    cfg.toi         = data.time{2*imgview.hdr.Fs}; %all samples
    cfg.pad = 'nextpow2';



    cfg.trials = cond1;

    TFR_condA = ft_freqanalysis(cfg, data);
    
    cfg.trials = cond2;

    TFR_condB = ft_freqanalysis(cfg, data);

%%
    % cfg.trials = 'all';
    % TFR_allcue_hiG = ft_freqanalysis(cfg, data);
    % HGP_allcue_hiG = rmfield(ERP_allcue, {'trial'});
    
    HGP_condA = rmfield(ERP_condA, {'trial'});
    HGP_condB = rmfield(ERP_condB, {'trial'});


    %%
disp('Initiating frequency correlation...')
    freqcorr = reshape(TFR_condA.freq.^2,[1 1 length(TFR_condA.freq)]);

    freqcorr_condA = repmat(freqcorr,[size(TFR_condA.powspctrm,1) size(TFR_condA.powspctrm,2) 1 length(TFR_condA.time)]);
    freqcorr_condB = repmat(freqcorr,[size(TFR_condB.powspctrm,1) size(TFR_condB.powspctrm,2) 1 length(TFR_condB.time)]);

HGP_condA.trial = squeeze(nanmean(TFR_condA.powspctrm(:,:,:,:) .* freqcorr_condA,3));
HGP_condB.trial = squeeze(nanmean(TFR_condB.powspctrm(:,:,:,:) .* freqcorr_condB,3));
    
disp('Frequency correlation complete')
%%
%baseline correction
    cfg = [];
    cfg.baseline = bsline;
    

HGP_condA_bl = ft_timelockbaseline(cfg, HGP_condA);
HGP_condB_bl = ft_timelockbaseline(cfg, HGP_condB);

clear TFR*

%%
% cfg = [];
% cfg.xlim = [0 1];
% cfg.layout = 'vertical';
% chns = ft_channelselection('RTA*', HGP_condA.label);
%  cfg.channel = 1;
%  figure, ft_singleplotER(cfg, HGP_condA_bl,HGP_condB_bl)
% %%
% for i = 1:numel(chns)
% cfg.channel = chns{i};
% figure, ft_singleplotER(cfg, HGP_condA_bl,HGP_condB_bl)
% end

% cfg.channel = ft_channelselection('LTA*', HGP_condA.label);
% figure, ft_multiplotER(cfg, HGP_condA_bl)
%% Stats on ERP and HGP
cfg                  = [];
cfg.latency          = mc_latency;
cfg.parameter        = 'trial';
cfg.method           = 'montecarlo';
cfg.correctm         = 'cluster';

cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'wcm';
cfg.neighbours       = []; % no spatial information is exploited for statistical clustering
cfg.numrandomization = 300;
cfg.statistic        = 'indepsamplesT'; % idependent samples test for statistical testing on the single-trial level
cfg.channel          = 'all';
% cfg.channel          = 'RFC*';


cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.05;
cfg.correcttail      = 'prob';
cfg.design           = [ones(1,size(HGP_condA_bl.trial,1)), 2*ones(1,size(HGP_condB_bl.trial,1))];
% cfg.design = (event.Pair)';
%% Find significant channels in ERP
stats_ERP = ft_timelockstatistics(cfg,ERP_condA_bl,ERP_condB_bl);

[sigchans_ERP time_ERP] = find(stats_ERP.mask);
sigchans_ERP = unique(sigchans_ERP)



%% Find significant channels in HGP
stats_HGP = ft_timelockstatistics(cfg,HGP_condA_bl,HGP_condB_bl);

[sigchans_HGP time_HGP] = find(stats_HGP.mask);
sigchans_HGP = unique(sigchans_HGP)


%%

