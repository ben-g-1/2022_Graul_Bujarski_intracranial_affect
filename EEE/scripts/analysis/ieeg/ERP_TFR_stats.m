%%%%%%%%%%%%
subjectnum = '01';
sessionnum = '01';

phase = 6;   %phase 1-8
window = [-1 1];  % time of interest
window_bl = [window(1)+0.7 window(1)+0.9];
window_view = [window(1)+0.9 window(2)-0.7];
timeres = 0.01;
condition = 'cond_full_early_alltrial_stats';
freqtype = 'TAB';  % 'hi_gamma' 'lo_gamma', 'TAB', 'theta', 'alpha', 'beta', 'alphabeta', 'full_broadband'
comparison = 'arousal'; %'cuetype' 'valtype' 'cueconverge' 'cueagree' 'cuetype_valneg', 'arousal


%%%%%%%%%%%%
% Found results: beta + cueagree (imgview)
%%

%%% Comparison Conditions %%%

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


%%%
gitdir = 'C:\Users\bgrau\GitHub\ieeg_affect\EEE';
projdir = 'C:\Users\bgrau\Dropbox (Dartmouth College)\2023_Graul_EEE';
scriptdir = fullfile(gitdir, 'scripts', 'analysis');
datadir = fullfile(projdir, 'Data', 'raw', ['sub-',  num2str(subjectnum)], ['ses-', num2str(sessionnum)]);
procdir = fullfile(projdir, 'Data', 'processed', ['sub-',  num2str(subjectnum)]);
analyzedir = fullfile(projdir, 'Analyses', 'ieeg', 'subjects', ['sub-',  num2str(subjectnum)]);
conddir = fullfile(analyzedir, condition);

eegfile = fullfile(datadir, ['EEE_', subjectnum, '_deidentified.EDF']);

addpath(genpath(scriptdir));

load(fullfile(procdir, ['sub-', subjectnum, '_event_clean.mat']));
load(fullfile(procdir, ['sub-', subjectnum, '_cleanchans.mat']));
load(fullfile(procdir, ['sub-', subjectnum, '_cleantrials.mat']));
load(fullfile(procdir, ['EEE_sub-', subjectnum, '_elec_acpc_f.mat']));

if ~exist('fullrun', 'var')
    load(fullfile(procdir, ['sub-', subjectnum, '_fullrun.mat']));
end

fullrun.elec = elec_acpc_f;

%%
cfg = [];
cfg.dataset = eegfile;
cfg.trialfun = 'trl_singlephase';
cfg.trialdef.pre = abs(window(1)); 
cfg.trialdef.post = window(2);
cfg.trialdef.offset = window(1); % Picture viewing is at T = 0
cfg.trialdef.event = event;
cfg.trialdef.eventvalue = phase;

cfg = ft_definetrial(cfg);

cfg.trials = cleantrials;
cfg.channel = cleanchans;

cfg.dftfilter = 'yes';
cfg.dftfreq   = [60 120 180];

cfg.demean = 'yes';

cfg.lpfilter = 'yes';
cfg.lpfreq = 30;

cfg.hpfilter = 'yes';
cfg.hpfreq = 2;

if exist('data_init', 'var')
    data_init = ft_preprocessing(cfg);
end

cond_full = ft_selectdata(cfg, data_init);

cond_full.elec = elec_acpc_f;
event = cond_full.trialinfo;

%% time-frequency 
    cfg             = [];

    cfg.keeptrials  = 'yes';

    cfg.method      = 'mtmconvol';
    switch freqtype 
        case'hi_gamma'
            cfg.foi        = 80:5:150; % 80 - 150 Hz, leave out harmonics of 60 Hz
        case 'lo_gamma' 
            cfg.foi        = 30:5:90;
        case 'broadband_gamma'
            cfg.foi         = 30:5:150;
        case 'TAB'
            cfg.foi        = 5:1:30;
        case 'theta'
            cfg.foi        = 5:1:8;
        case 'alpha'
            cfg.foi        = 8:1:13;
        case 'beta'
            cfg.foi        = 14:1:30;
        case 'alphabeta'
            cfg.foi     = 8:30;
        case 'full_broadband'
            cfg.foi        = [14:1:30 30:5:55 65:5:115 125:5:150];
    end

    cfg.width      = 10 * ones(1,length(cfg.foi));
    cfg.tapsmofrq     = 10; 
    cfg.pad         = 'nextpow2';

    if max(cfg.foi) > 40
        cfg.taper = 'dpss';
    else
       cfg.taper = 'hanning';
    end

    cfg.t_ftimwin  = 7./cfg.foi; %7 cycles


    cfg.toi         = [window_view(1):0.05:window_view(2)]; %all samples

    TFR_allcond     = ft_freqanalysis(cfg, cond_full);

%%
% for cond = 1:numel(comparisons)
    % comparison = comparisons{cond};
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
    case 'arousal'
        cond1 = event.Arousal_mean > 50;
        cond2 = event.Arousal_mean < 50;
    otherwise 
        error('Invalid comparison type entered.')
end %comparison switch
%% ERP Baselines

cfg = [];
cfg.keeptrials = 'yes';
cfg.baseline = window_bl;
% cfg.avgoverrpt = 'yes';

cfg.trials = cond1;

ERP_condA = ft_timelockanalysis(cfg, cond_full);

cfg.trials = cond2;

ERP_condB = ft_timelockanalysis(cfg, cond_full);

cfg.trials = 'all';
ERP_allcond = ft_timelockanalysis(cfg,cond_full);
%%
cfg = [];
cfg.avgoverrpt = 'yes';
ERP_condA_avg = ft_selectdata(cfg, ERP_condA);
ERP_condB_avg = ft_selectdata(cfg, ERP_condB);
ERP_allcue_avg = ft_selectdata(cfg, ERP_allcond);

%% Plot ERPs
cfg = [];
% cfg.channel = 'LFC9';
cfg.figure = gcf;
cfg.latency = [0 1];
cfg.xlim  = [0 1];

figure;
subplot(1,2,1)
ft_singleplotER(cfg, ERP_allcond)
subplot(1,2,2)
ft_singleplotER(cfg, ERP_condA, ERP_condB)

cfg = [];
cfg.xlim  = [0 1];
cfg.layout = layoutShafts;
ft_multiplotER(cfg, ERP_allcond)
ft_multiplotER(cfg, ERP_condA, ERP_condB)

%%
    cfg = [];
    % cfg.avgoverfreq = 'yes';
    % cfg.avgovertime = 'yes';
    cfg.avgoverrpt  = 'no';
    cfg.trials      = cond1;
    TFR_condA       = ft_selectdata(cfg, TFR_allcond);

    cfg.avgoverrpt = 'yes';
    TFR_condA_avg       = ft_selectdata(cfg, TFR_allcond);


    cfg.avgoverrpt  = 'no';
    cfg.trials      = cond2;
    TFR_condB       = ft_selectdata(cfg, TFR_allcond);

    cfg.avgoverrpt = 'yes';
    TFR_condB_avg       = ft_selectdata(cfg, TFR_allcond);

    cfg.avgoverrpt = 'yes';
    cfg.operation = '(x1 - x2)/(x1+x2)';
    cfg.parameter     = 'powspctrm';
    TFR_conddiff = ft_math(cfg, TFR_condA_avg, TFR_condB_avg);



    %%
f = figure;
f.Position = [300 300 1200 600];
cfg         = [];
cfg.figure  = gcf;
% cfg.zlim    = [-0.15 0.15];

subplot(1,4,1)
cfg.xlim = window_view;
cfg.baseline = window_bl;
cfg.baselinetype = 'normchange';
cfg.title = string([comparison ' ' freqtype]);
ft_singleplotTFR(cfg, TFR_allcond)

subplot(1,4,2)
cfg.title = 'condA';
ft_singleplotTFR(cfg, TFR_condA)

subplot(1,4,3)
cfg.title = 'condB';
ft_singleplotTFR(cfg, TFR_condB)

subplot(1, 4, 4)
cfg.baseline = 'no';
cfg.title = 'cond diff (norm)';
ft_singleplotTFR(cfg, TFR_conddiff)

pause(0.3);

%%
% figure;
cfg = [];
% cfg.demean = 'yes';
% cfg.figure = gcf;
cfg.baseline = window_bl;
% cfg.avgoverfreq = 'yes';
ft_singleplotER(cfg, TFR_condA, TFR_condB)
% ft_singleplotER(cfg, TFR_condA_avg, TFR_condB_avg)

% ft_singleplotER(cfg, TFR_condB)
% ft_singleplotER(cfg, TFR_condA_bl)
% end %condition loop
%%
cfg = [];
cfg.channel = {'all', '-RPRS9', '-RPXA3', '-LTHA6', '-RTHA12'};
cfg.layout = layoutShafts;
cfg.xlim = [ 4 6];

cfg.zlim = [-.5 .5];
ft_multiplotTFR(cfg, TFR_conddiff)

% cfg.baseline = [-0.4 -0.1];
cfg.baseline = [3.51 3.9];
cfg.baselinetype = 'relchange';
% cfg.ylim = [40 80];
cfg.zlim = [-1 2];
ft_multiplotTFR(cfg, TFR_allcond)


%%

    
    % TFR_condA = rmfield(ERP_condA, {'trial'});
    % TFR_condB = rmfield(ERP_condB, {'trial'});


    
% disp('Initiating frequency correlation...')
%     freqcorr = reshape(TFR_condA.freq.^2,[1 1 length(TFR_condA.freq)]);
% 
%     freqcorr_condA = repmat(freqcorr,[size(TFR_condA.powspctrm,1) size(TFR_condA.powspctrm,2) 1 length(TFR_condA.time)]);
%     freqcorr_condB = repmat(freqcorr,[size(TFR_condB.powspctrm,1) size(TFR_condB.powspctrm,2) 1 length(TFR_condB.time)]);
% 
% TFR_condA.trial = squeeze(nanmean(TFR_condA.powspctrm(:,:,:,:) .* freqcorr_condA,3));
% TFR_condB.trial = squeeze(nanmean(TFR_condB.powspctrm(:,:,:,:) .* freqcorr_condB,3));
% 
% disp('Frequency correlation complete')

% Baseline correction
cfg = [];
cfg.baseline = window_bl;
cfg.keeptrials = 'yes';
% cfg.avgoverrpt = 'yes';    

TFR_condA_bl = ft_timelockanalysis(cfg, TFR_condA);
TFR_condB_bl = ft_timelockanalysis(cfg, TFR_condB);

%
% cfg = [];
% cfg.xlim = [0 1];
% cfg.layout = 'vertical';
% chns = ft_channelselection('RTA*', TFR_condA.label);
%  cfg.channel = 1;
%  figure, ft_singleplotER(cfg, TFR_condA_bl,TFR_condB_bl)
% %%
% for i = 1:numel(chns)
% cfg.channel = chns{i};
% figure, ft_singleplotER(cfg, TFR_condA_bl,TFR_condB_bl)
% end

% cfg.channel = ft_channelselection('LTA*', TFR_condA.label);
% figure, ft_multiplotER(cfg, TFR_condA_bl)

%% Stats on ERP and HGP
sig = 0;
sigchans = [];
checkchans = [];
% for chan = 1:numel(cleanchans)
cfg                  = [];

% cfg.baseline = window_bl;


cfg.channel         = cleanchans;
cfg.channel          = {'RFC*'};

cfg.elec            = elec_acpc_f;
cfg.method          = 'distance';
cfg.neighbourdist   = 20;
neighbors            = ft_prepare_neighbours(cfg);

cfg.neighbours       = neighbors; 


cfg.latency          = [4.1 4.4];

cfg.method           = 'montecarlo';
cfg.correctm         = 'cluster';


cfg.clusteralpha     = 0.2;
cfg.clusterstatistic = 'maxsum';
% cfg.minnbchan        = 1;

cfg.statistic        = 'ft_statfun_indepsamplesT'; % idependent samples test for statistical testing on the single-trial level
cfg.numrandomization = 2000;

% cfg.channel          = 'all';

cfg.alpha            = 0.05;


cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.correcttail      = 'prob';
tmp_var = zeros(1,size(TFR_condA.powspctrm,1) + size(TFR_condB.powspctrm,1));
tmp_var(1,1:size(TFR_condA.powspctrm,1)) = 1;
tmp_var(1,(size(TFR_condA.powspctrm,1)+1):(size(TFR_condA.powspctrm,1)+...
size(TFR_condB.powspctrm,1))) = 2;

tmp_unit = [1:size(TFR_condA.powspctrm,1), 1:size(TFR_condB.powspctrm,1)];

design = [tmp_var; tmp_unit]';

cfg.design = design;
cfg.ivar = 1;
% cfg.uvar = 2;

% Find significant channels in ERP
% stats_ERP = ft_timelockstatistics(cfg,ERP_condA,ERP_condB);
% 
% [sigchans_ERP time_ERP] = find(stats_ERP.mask);
% sigchans_ERP = unique(sigchans_ERP)



% Find significant channels in TFR
stats_TFR = ft_freqstatistics(cfg,TFR_condA,TFR_condB);
stats_TFR.raweffect = TFR_conddiff.powspctrm;




[sigchans ~] = find(stats_TFR.mask);
sigchans = unique(sigchans);
% numel(sigchans)
    if ~isempty(sigchans)
        sig = sig + 1;
        checkchans(sig) = chan
    
    
        % stats = stats_TFR;
        % 
        % figure;
        % 
        % subplot(2,1,1); 
        % hist(stats.negdistribution, 50)
        % crit = prctile(stats.negdistribution, 2.5);
        % line([crit, crit], [0 80], 'LineWidth', 2, 'Color', 'r');
        % line([stats.negclusters(1).clusterstat, stats.negclusters(1).clusterstat], 'LineWidth', 2, 'Color', 'b', 'LineStyle','--');
        % title([cleanchans(chan) 'Negative cluster T'])
        % 
        % subplot(2,1,2); hist(stats.posdistribution, 100)
        % crit = prctile(stats.posdistribution, 97.5);
        % line([crit, crit], [0 80], 'LineWidth', 2, 'Color', 'r');
        % line([stats.posclusters(1).clusterstat, stats.posclusters(1).clusterstat],  'LineWidth', 2, 'Color', 'b', 'LineStyle','--');
        % title([cleanchans(chan) 'Positive cluster T'])

% 9	58	78	86	109	115	116

% cfg = [];
% cfg.channel = chan;
%         TFR_condA_cmb = ft_freqdescriptives(cfg, TFR_condA);
%         TFR_condB_cmb  = ft_freqdescriptives(cfg, TFR_condB);
%         % Subsequently we add the raw effect (FIC-FC) to the obtained stat structure and plot the largest cluster overlayed on the raw effect.
% 
%         cfg.operation     = '(x1-x2)/(x1+x2)';
%         cfg.parameter     = 'powspctrm';
%         raweffect = ft_math(cfg, TFR_condA_cmb, TFR_condB_cmb);
%         stats_TFR.raweffect = raweffect.powspctrm;
% 
%         cfg = [];
%         % cfg.channel = chan;
% 
%         % cfg.maskparameter   = 'mask';
%         % cfg.maskstyle       = 'outline';
%         cfg.alpha  = 0.025;
%         cfg.parameter = 'raweffect';
%         % % cfg.zlim   = [-1e-27 1e-27];
%         % % cfg.layout = 'CTF151_helmet.mat';
%         ft_singleplotTFR(cfg, stats_TFR);
    % end

    pause(0.1);
    end

% beep on; beep;
% end


if ~isempty(checkchans)
    for chan = 1:numel(checkchans)
        f = figure();
        cfg = [];
        cfg.channel = stats_TFR.label;
        cfg.latency = [stats_TFR.time(1) stats_TFR.time(end)];
        cfg.figure = gcf;

        sigpow = ft_selectdata(cfg, TFR_conddiff);
        stats_TFR.raweffect = sigpow.powspctrm;
        cfg.channel = stats_TFR.label(chan);


        % cfg.parameter = 'powspctrm';

        cfg.maskparameter   = 'mask';
        cfg.maskstyle       = 'outline';
        % cfg.alpha  = 0.025;
        cfg.parameter = 'raweffect';

        ft_singleplotTFR(cfg, stats_TFR);

        stats = stats_TFR;

        figure;

        subplot(2,1,1); 
        hist(stats.negdistribution, 50)
        crit = prctile(stats.negdistribution, 2.5);
        line([crit, crit], [0 80], 'LineWidth', 2, 'Color', 'r');
        line([stats.negclusters(1).clusterstat, stats.negclusters(1).clusterstat], 'LineWidth', 2, 'Color', 'b', 'LineStyle','--');
        title([stats.label(chan) 'Negative cluster T'])

        subplot(2,1,2); hist(stats.posdistribution, 100)
        crit = prctile(stats.posdistribution, 97.5);
        line([crit, crit], [0 80], 'LineWidth', 2, 'Color', 'r');
        line([stats.posclusters(1).clusterstat, stats.posclusters(1).clusterstat],  'LineWidth', 2, 'Color', 'b', 'LineStyle','--');
        title([stats.label(chan) 'Positive cluster T'])
    end
end
%%
if ~isempty(sigchans)
    for chan = 1:numel(sigchans)
        f = figure();
        % f.position = [300 300 800 800];
        cfg = [];
        cfg.channel = sigchans(chan);
        cfg.figure = gcf;
        % cfg.operation     = '(x1-x2)/(x1+x2)';
        % cfg.parameter     = 'powspctrm';
        % raweffect = ft_math(cfg, TFR_condA_cmb, TFR_condB_cmb);
        stats_TFR.raweffect = TFR_conddiff.powspctrm;

        % cfg = [];
        cfg.maskparameter   = 'mask';
        cfg.maskstyle       = 'outline';
        % cfg.alpha  = 0.025;
        cfg.parameter = 'raweffect';
        % % cfg.zlim   = [-1e-27 1e-27];
        % % cfg.layout = 'CTF151_helmet.mat';
        ft_singleplotTFR(cfg, stats_TFR);
    end
end

%%
stats = stats_TFR;

figure;

subplot(2,1,1); 
hist(stats.negdistribution, 50)
crit = prctile(stats.negdistribution, 2.5);
line([crit, crit], [0 80], 'LineWidth', 2, 'Color', 'r');
line([stats.negclusters(1).clusterstat, stats.negclusters(1).clusterstat], [0 80], 'LineWidth', 2, 'Color', 'b', 'LineStyle','--');
title('Negative cluster T')

subplot(2,1,2); hist(stats.posdistribution, 100)
crit = prctile(stats.posdistribution, 97.5);
line([crit, crit], [0 80], 'LineWidth', 2, 'Color', 'r');
line([stats.posclusters(1).clusterstat, stats.posclusters(1).clusterstat], [0 80], 'LineWidth', 2, 'Color', 'b', 'LineStyle','--');
title('Positive cluster T')

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