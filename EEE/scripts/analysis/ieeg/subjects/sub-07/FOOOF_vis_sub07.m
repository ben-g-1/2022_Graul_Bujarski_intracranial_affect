% FOOOOF Implementation  

subjectnum = '07';
sessionnum = '01';

%%%
gitdir = 'C:\Users\bgrau\GitHub\ieeg_affect\EEE';
projdir = 'C:\Users\bgrau\Dropbox (Dartmouth College)\2023_Graul_EEE';
scriptdir = fullfile(gitdir, 'scripts', 'analysis');
datadir = fullfile(projdir, 'Data', 'raw', ['sub-',  num2str(subjectnum)], ['ses-', num2str(sessionnum)]);
procdir = fullfile(projdir, 'Data', 'processed', ['sub-',  num2str(subjectnum)]);

eegfile = fullfile(datadir, ['EEE_', subjectnum, '_deidentified.EDF']);

addpath(scriptdir);

load(fullfile(procdir, ['sub-', subjectnum, '_event_clean.mat']));
load(fullfile(procdir, ['sub-', subjectnum, '_chans_clean.mat']));

load(fullfile(procdir, ['sub-', subjectnum, '_fullrun.mat']));

%%
for eventval = 1:8
cfg = [];
cfg.dataset = eegfile;
cfg.channel = cleanchans;
cfg.trialfun = 'trl_singlephase';
cfg.trialdef.pre = 1; 
cfg.trialdef.post = 1;
cfg.trialdef.offset = -1; % Picture viewing is at T = 0
cfg.trialdef.event = event;
cfg.trialdef.eventvalue = eventval;

cfg = ft_definetrial(cfg);

imgview = ft_redefinetrial(cfg, fullrun);

%% Visualize channel correlations

cfg = [];
cfg.keeptrials = 'no';
cfg.avgoverrpt     = 'yes';

imgcorr = ft_selectdata(cfg, imgview);

dat = imgcorr.trial{1,1}';
[r,p] = corrcoef(dat);
figure;
imagesc(r)

%% FOOOF
% First process all channels for both types

cfg               = [];

cfg.channel       = 'all';
cfg.foilim        = [3 200];
cfg.pad           = 'nextpow2';
cfg.tapsmofrq     = 2; 
cfg.method        = 'mtmfft';
cfg.output        = 'fooof_aperiodic';
fractal = ft_freqanalysis(cfg, imgview);

cfg.output        = 'pow';
original = ft_freqanalysis(cfg, imgview);
%% Create one per channel

for chan = 1:2%numel(chans)
cfg               = [];
cfg.channel       = chan;
cfg.parameter     = 'powspctrm';
cfg.operation     = 'x2-x1';
oscillatory = ft_math(cfg, fractal, original);

cfg.operation     = 'x2./x1';  % equivalent to 10^(log10(x2)-log10(x1))
oscillatory_alt = ft_math(cfg, fractal, original);
 
% display the spectra on a log-log scale
f = figure();
f.Position = [600 200 1000 800];
subplot(1,2,1); hold on;
plot((original.freq), log(original.powspctrm(chan,:)),'k');
plot((fractal.freq), log(fractal.powspctrm(chan,:)));
plot((fractal.freq), log(oscillatory.powspctrm(chan,:)));

xlabel('freq'); ylabel('log-power'); grid on;
legend({'original','fractal','oscillatory = spectrum-fractal'},'location','southwest');
title([cleanchans{chan} ' mixed signal']);

subplot(1,2,2); hold on;
plot((oscillatory_alt.freq), (oscillatory_alt.powspctrm(chan,:)));
xlabel('freq'); ylabel('power'); grid on;
title([cleanchans{chan} ' Power']);
pause(0.1);
hold off;
end
end