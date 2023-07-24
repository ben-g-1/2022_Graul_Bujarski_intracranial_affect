%% 
% Need to compare high gamma differences at decided frequencies within pairs. 
% Will leverage CANlab 3dttest and existing behavioral analysis script. 
% 
% 
% 
% For this, I will start with looking for 70-150 Hz activity in RTA1-RTA2 during 
% image viewing. Time of interest will be from -1000 ms to 1000 ms.  
% 
% 
% 
% Subject 1 had strong cue effect on picture pair 20 (Graveyard). This was trial 
% 16 (high cue) and 56 (low cue).

cfg = [];
cfg.dataset = eegfile;
cfg.channel = chans;
cfg.trialfun = 'trl_singlephase';
cfg.trialdef.pre = 2.5; % Picture viewing is at T = 0
cfg.trialdef.post = 5.5;
cfg.trialdef.offset = -2.5;
cfg.trialdef.event = event_full;
cfg.trialdef.eventvalue = 6;
cfg.keeptrial = 'yes';

cfg = ft_definetrial(cfg);

%%
% cfg.demean = 'yes'; 
% cfg.detrend = 'yes';
% cfg.demean = 'no';
% cfg.baselinewindow = 'all';
cfg.lpfilter = 'yes';
cfg.lpfreq  = 200;
cfg.preproc.hpfilter = 'yes';
cfg.preproc.hpfreq = 2;
% cfg.padding = 2;
%
% 
% 
% 
% cfg.padtype = 'data';
cfg.bsfilter = 'yes';
cfg.bsfiltord = 3;
cfg.bsfreq = [59 61; 119 121; 179 181];
% cfg.channel = 53;

data = ft_preprocessing(cfg);
%%
pairorder = sortrows(data.trialinfo,"Pair","ascend");

%%
% cfg = [];
% cfg.method = 'trial';
% 
% dummy = ft_rejectvisual(cfg,imgview);
%% Create Pair Table for Easy Reference
pairs = table();
hiorder = sortrows(pairorder, 'highcue_indx', 'descend');
pairs.pairnum = hiorder.Pair(1:32);
pairs.hitrial = hiorder.trial(1:32);
pairs.lotrial = hiorder.pair_row(1:32);
pairs.hival = hiorder.val_rating(1:32);
pairs.loval = hiorder.val_rating(33:64);
pairs.valdif = pairs.hival - pairs.loval;
pairs.hiexp = hiorder.exp_rating(1:32);
pairs.loexp  = hiorder.exp_rating(33:64);
pairs.expdif = pairs.hiexp  - pairs.loexp;

%%
cfg = [];
cfg.reref = 'yes';
cfg.refchannel = 'LTHA7';
% cfg.channel = 53; %RTA1

imgview = ft_preprocessing(cfg, data);
%%
cfg = [];
cfg.reref = 'yes';
cfg.refmethod = 'bipolar';
cfg.refchannel = 'all';
cfg.groupchans = 'yes';

% imgview_bpreref = ft_preprocessing(cfg, data);
%%
% spectral decomposition
    timres          = .001; % 10 ms steps
    cfg             = [];
    cfg.channel     =  'RTA1';

    cfg.output      = 'pow';
    cfg.method      = 'mtmconvol';
    cfg.taper       = 'dpss';
    cfg.foi = [40 45 50 55 65 70 75 80 85 90 95 100 105 110 115 125 130 135 140 145 150 155 160 165 170 175 185 190]; % 80 - 190 Hz, leave out harmonics of 60 Hz
    % cfg.foi = [5 8 11 14 17 20 23 26 29 32 35 40 45 50 55 65 70 75 80 85 90 95 100 105 110 115 125 130 135 140 145 150 155 160 165 170 175 180 185 190]
    % cfg.foi = [4:2:59 61:2:118 121:2:178 181:2:201];
    cfg.tapsmofrq   = 10;
    cfg.t_ftimwin   = .2*ones(length(cfg.foi),1); % 200 ms
    cfg.toi         = data.time{1}(1):timres:data.time{1}(end);  % begin to end of defined event
    % cfg.toi         = round(data.time{1}(hdr.Fs * 1.99)):timres:round(data.time{1}(hdr.Fs * 3.51));  
    cfg.keeptrials  = 'yes';
    cfg.pad         = 'nextpow2';

% imgview_freq_lores = ft_freqanalysis(cfg,imgview);
imgview_freq_RTA1 = ft_freqanalysis(cfg, imgview)

% The powspctrm object created has 4 dimensions: {trial channel foi toi}
%%
cfg.channel = 'RTA1';
cfg.trials      = imgview.trialinfo.highcue_indx == 1;

imgview_hicue_RTA1 = ft_selectdata(cfg, imgview);

cfg.trials      = imgview.trialinfo.highcue_indx == -1;

imgview_lowcue_RTA1 = ft_selectdata(cfg, imgview);


%%
imgview_powspctrm_RTA1 = squeeze(imgview_freq.powspctrm(:,1,:,:));
xc = imgview_powspctrm_RTA1;

%%
ii = 1;
difftable = [];

for r = 1:2:64
    if pairorder.highcue_indx(r) == 1
        j = pairorder.trial(r);
        k = pairorder.trial(r+1);
    else
        k = pairorder.trial(r);
        j = pairorder.trial(r+1);
    end
    
    difftable(ii,:,:) = xc(j,:,:) - xc(k,:,:);

    ii = ii + 1;

end

%%

OUT = ttest3d(difftable);


%%
trl15 = difftable(15,:,:);
%%
cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = '(x1 - x2)/x2';
cfg.trials = 16;
graveyard_hi_freq = ft_selectdata(cfg, imgview_freq);
cfg.trials = 56;
graveyard_lo_freq = ft_selectdata(cfg, imgview_freq);

graveyard_diff = ft_math(cfg, graveyard_hi_freq, graveyard_lo_freq);
%%
cfg = [];
cfg.channel = 'RTA1';

% cfg.xlim = [0 1.5]; % trim the empty space
cfg.ylim = [25 80]; %focus on mid/high gamma
% cfg.zlim = [0 10]; % set scale to be the same across figures
cfg.parameter = 'powspctrm';
% cfg.baseline = [-0.5 -0.01];
cfg.baselinetype = 'db';

% cfg.channel = 'RTA1';
cfg.trials      = 'all';
% cfg.title = sprintf('%s Average Image Response', cfg.channel);
% ylabel({'Frequency (Hz)'; '5 Hz Step'})
% xlabel({'Time (s)'})
ft_singleplotTFR(cfg, imgview_freq)
% ft_singleplotTFR(cfg, graveyard_diff)