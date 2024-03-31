% FOOOOF Implementation, ERP, and TFR by electrode

subjectnum = '01';
sessionnum = '01';

%%%
gitdir = 'C:\Users\bgrau\GitHub\ieeg_affect\EEE';
projdir = 'C:\Users\bgrau\Dropbox (Dartmouth College)\2023_Graul_EEE';
scriptdir = fullfile(gitdir, 'scripts', 'analysis');
datadir = fullfile(projdir, 'Data', 'raw', ['sub-',  num2str(subjectnum)], ['ses-', num2str(sessionnum)]);
procdir = fullfile(projdir, 'Data', 'processed', ['sub-',  num2str(subjectnum)]);
analyzedir = fullfile(projdir, 'Analyses', 'ieeg', 'subjects', ['sub-',  num2str(subjectnum)]);

eegfile = fullfile(datadir, ['EEE_', subjectnum, '_deidentified.EDF']);

addpath(genpath(scriptdir));

load(fullfile(procdir, ['sub-', subjectnum, '_event_clean.mat']));
load(fullfile(procdir, ['sub-', subjectnum, '_cleanchans.mat']));
load(fullfile(procdir, ['sub-', subjectnum, '_cleantrials.mat']));
load(fullfile(procdir, ['EEE_sub-', subjectnum, '_elec_acpc_f.mat']));

load(fullfile(procdir, ['sub-', subjectnum, '_fullrun.mat']));

fullrun.elec = elec_acpc_f;
%%
%%%%%%%%%%%%
phase = 6;   %phase 1-8
window = [-1 2.5];  % time of interest
window_bl = [-0.5 -0.1];

window_view = [window_bl(2) window(2)-0.7];
condition = 'imgview_early_alltrial';
%%%%%%%%%%%%

conddir = fullfile(analyzedir, condition);

try
    mkdir(conddir)
    cd(conddir)
catch
    cd(conddir)
end
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
% 
% cfg.bsfilter        = 'yes';
% cfg.bsfiltord     = 3;
% cfg.bsfreq        = [55 65; 115 125; 175 185];

cond_full = ft_preprocessing(cfg);
cond_full = ft_selectdata(cfg, cond_full);
%% Reference
% cfg = [];
% cfg.reref = 'yes';
% cfg.refmethod = 'bipolar';
% cfg.groupchans = 'yes';
% cond_full_bpref = ft_preprocessing(cfg, cond_full);

%% FOOOF
% First process all channels for both types

cfg               = [];


cfg.foilim        = [3 200];
% cfg.foi         = [5:1:57 63:1:79 81:1:117 123:1:137 143:1:151];

% cfg.dftfilter = 'yes';
% cfg.dftfreq   = [60 120 180];
% cfg.dftreplace = 'zero';
% cfg.dftneighbourwidth = [2 2 3];



cfg.taper         = 'dpss';
% cfg.pad           = 'nextpow2';
cfg.tapsmofrq     = 0.5; 
cfg.method        = 'mtmfft';

cfg.output        = 'fooof_aperiodic';
fractal           = ft_freqanalysis(cfg, cond_full);

cfg.output        = 'pow';
original          = ft_freqanalysis(cfg, cond_full);


%% Decompose into Frequencies

cfg             = [];
% cfg.channel     = 'all';
% cfg.channel       = 'RTA1';
% cfg.trials         = 1;

cfg.output      = 'pow';
cfg.method      = 'mtmconvol';
cfg.foi         = [4:200];

% cfg.bsfilt      = 'yes';
% cfg.bsfreq      = [58 62; 118 122];

cfg.pad           = 'nextpow2';
cfg.t_ftimwin   = 5./cfg.foi;
cfg.tapsmofrq   = 0.4 *cfg.foi;
cfg.toi         = window(1):0.01:window(2);
cfg.taper       = 'hanning';
cfg.keeptrials  = 'yes';

% cfg.hpfilt = 'yes';
% cfg.hpfreq = 2; 

cond_full_freq    = ft_freqanalysis(cfg, cond_full);


%%
% Create one per channel
% chan = 100;
for chan = 1%:numel(cleanchans)
cfg               = [];
cfg.channel       = chan;
cfg.parameter     = 'powspctrm';
cfg.operation     = 'x2-x1';
oscillatory = ft_math(cfg, fractal, original);

cfg.operation     = 'x2./x1';  % equivalent to 10^(log10(x2)-log10(x1))
oscillatory_alt = ft_math(cfg, fractal, original);
 
% display the spectra on a log-log scale
f1 = figure();
f1.Position = [1 200 800 800];
subplot(1,2,1); hold on;
plot((original.freq), log(original.powspctrm(chan,:)),'k');
plot((fractal.freq), log(fractal.powspctrm(chan,:)));
plot((fractal.freq), log(oscillatory.powspctrm(chan,:)));

% plot(log((original.freq)), log(original.powspctrm(chan,:)),'k');
% plot(log((fractal.freq)), log(fractal.powspctrm(chan,:)));
% plot(log((fractal.freq)), log(oscillatory.powspctrm(chan,:)));

xlabel('freq'); ylabel('log-power'); grid on;
legend({'original','fractal','oscillatory = spectrum-fractal'},'location','southwest');
title([original.label{chan} ' mixed signal']);

subplot(1,2,2); hold on;
plot((oscillatory_alt.freq), (oscillatory_alt.powspctrm(chan,:)));
xlabel('freq'); ylabel('power'); grid on;
title([cleanchans{chan} ' Power']);
% pause(0.3);
hold off;

%%
trialinfo = cond_full.trialinfo;
cfg = [];
cfg.avgoverfreq = 'yes';
cfg.keeptrials = 'yes';
cfg.channel = chan;
cfg.latency = window_view;
cfg.baseline = window_bl;

cfg.trials = find(trialinfo.val_type == 1);
condA = ft_selectdata(cfg, cond_full_freq);

cfg.trials = find(trialinfo.val_type == -1);
condB = ft_selectdata(cfg, cond_full_freq);

%%
cfg.avgoverfreq = 'no';
cfg.avgoverrpt  = 'yes';
cfg.trials = find(trialinfo.val_type == 1);
condA_avg = ft_selectdata(cfg, cond_full_freq);

cfg.trials = find(trialinfo.val_type == -1);
condB_avg = ft_selectdata(cfg, cond_full_freq);
%%
cfg = [];
cfg.operation = '(x1 - x2)/(x1 + x2)';
cfg.parameter = 'powspctrm';
normdiff = ft_math(cfg, condA_avg, condB_avg);

cfg.operation = '(x1 - x2)';
freqdiff = ft_math(cfg, condA_avg, condB_avg);

%%
f2 = figure();
f2.Position = [901 200 1000 800];

cfg = [];
cfg.figure = 'gcf';
cfg.parameter = 'powspctrm';
cfg.baseline = window_bl;

cfg.xlim = window_view;
cfg.showlegend = 'yes';
subplot(2, 2, 1); hold on;
% cfg.avgoverrpt = 'yes';
% ft_singleplotER(cfg, condB, condA)
plotERPWithShading([condA condB], 'confidence', {'hi', 'lo'}, window_view)

subplot(2,2,2);
ft_singleplotER(cfg, freqdiff)

cfg.channel = chan;
cfg.baselinetype = 'normchange';
subplot(2,2,3)
ft_singleplotTFR(cfg, cond_full_freq)

subplot(2,2,4)
cfg.channel = 1;
cfg.baseline = 'no';
% cfg.baselinetype = 'absolute';
ft_singleplotTFR(cfg, normdiff)


% saveas(f1, [cell2mat(cleanchans(chan)), '_psd.png'])
% saveas(f2, [cell2mat(cleanchans(chan)), '_ERP-TF.png'])
% close all;
end%chans

%% look at signal over trials
for trial = 1:numel(cleantrials)
%% FOOOF
% First process all channels for both types

cfg               = [];

cfg.channel       = 'RTA1';
cfg.trials         = trial;
cfg.foilim        = [3 200];
% cfg.foi         = [5:1:57 63:1:79 81:1:117 123:1:137 143:1:151];

% cfg.dftfilter = 'yes';
% cfg.dftfreq   = [60 120 180];
% cfg.dftreplace = 'zero';
% cfg.dftneighbourwidth = [2 2 3];
% 
% cfg.bsfilt        = 'yes';
% cfg.bsfiltord     = 3;
% cfg.bsfreq        = [58 62; 118 122; 178 182];

cfg.taper         = 'dpss';
cfg.pad           = 'nextpow2';
cfg.tapsmofrq     = 0.5; 
cfg.method        = 'mtmfft';

cfg.output        = 'fooof_aperiodic';
fractal           = ft_freqanalysis(cfg, cond_full);

cfg.output        = 'pow';
original          = ft_freqanalysis(cfg, cond_full);


%% Decompose into Frequencies

cfg             = [];
% cfg.channel     = 'all';
cfg.channel       = 'RTA1';
cfg.trials         = trial;

cfg.output      = 'pow';
cfg.method      = 'mtmconvol';
cfg.foi         = [4:200];

% cfg.bsfilt      = 'yes';
% cfg.bsfreq      = [58 62; 118 122];

cfg.pad           = 'nextpow2';
cfg.t_ftimwin   = 5./cfg.foi;
cfg.tapsmofrq   = 0.4 *cfg.foi;
cfg.toi         = window(1):0.01:window(2);
cfg.taper       = 'hanning';
cfg.keeptrials  = 'yes';

% cfg.hpfilt = 'yes';
% cfg.hpfreq = 2; 

cond_full_freq    = ft_freqanalysis(cfg, cond_full);


%%
cfg               = [];
cfg.channel       = chan;
cfg.parameter     = 'powspctrm';
cfg.operation     = 'x2-x1';
oscillatory = ft_math(cfg, fractal, original);

cfg.operation     = 'x2./x1';  % equivalent to 10^(log10(x2)-log10(x1))
oscillatory_alt = ft_math(cfg, fractal, original);
 
% display the spectra on a log-log scale
f1 = figure();
f1.Position = [1 200 1400 800];
subplot(1,2,1); hold on;
plot((original.freq), log(original.powspctrm(chan,:)),'k');
plot((fractal.freq), log(fractal.powspctrm(chan,:)));
plot((fractal.freq), log(oscillatory.powspctrm(chan,:)));

% plot(log((original.freq)), log(original.powspctrm(chan,:)),'k');
% plot(log((fractal.freq)), log(fractal.powspctrm(chan,:)));
% plot(log((fractal.freq)), log(oscillatory.powspctrm(chan,:)));

xlabel('freq'); ylabel('log-power'); grid on;
legend({'original','fractal','oscillatory = spectrum-fractal'},'location','southwest');
title([original.label{chan}, ' trial ', {trial}]);

cfg = [];
cfg.figure = gcf;
cfg.channel = chan;
cfg.baseline = window_bl;
cfg.xlim = window_view;
cfg.baselinetype = 'relchange';
cfg.zlim = [-5 10];
subplot(1,2,2)
ft_singleplotTFR(cfg, cond_full_freq)

pause(0.3);


% saveas(f1, [cell2mat(cleanchans(chan)), '_psd.png'])
% saveas(f2, [cell2mat(cleanchans(chan)), '_ERP-TF.png'])
% close all;

end%trials


