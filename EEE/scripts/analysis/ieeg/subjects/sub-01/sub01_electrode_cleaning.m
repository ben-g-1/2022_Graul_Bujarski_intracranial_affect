%% Identifying bad electrodes

subjectnum = '01';
sessionnum = '01';

%%%%
gitdir = 'C:\Users\bgrau\GitHub\ieeg_affect\EEE';
projdir = 'C:\Users\bgrau\Dropbox (Dartmouth College)\2023_Graul_EEE';
scriptdir = fullfile(gitdir, 'scripts', 'analysis');
datadir = fullfile(projdir, 'Data', 'raw', ['sub-',  num2str(subjectnum)], ['ses-', num2str(sessionnum)]);
procdir = fullfile(projdir, 'Data', 'processed', ['sub-',  num2str(subjectnum)]);
cleandir = fullfile(procdir, 'preproc_imgs');
if ~exist(cleandir, "dir")
    mkdir(cleandir)
end

eegfile = fullfile(datadir, ['EEE_', subjectnum, '_deidentified.EDF']);

cd(procdir);

addpath(scriptdir);

load(fullfile(procdir, ['sub-', subjectnum, '_event_clean.mat']));

%% iEEG Channels

hdr = ft_read_header(eegfile);

eegchan          = strcat('-', ft_channelselection({'eeg'}, hdr.label)); 
cfg.channel    = ft_channelselection({'all', '-PR', '-Pleth', '-TRIG', ...
    '-OSAT', '-EKG*', '-C*', '-*DC*', eegchan{:}}, hdr.label);


% get names of depth channels only
depths = {};
for i = 1:numel(cfg.channel)
    depths{i} = cfg.channel{i}(isstrprop(cfg.channel{i},'alpha')); 
end


depths = unique(depths)';
chans = cfg.channel;

%% Load iEEG Data

cfg = [];
cfg.dataset = eegfile;
cfg.channel = chans;
cfg.trialfun = 'trl_fullrun';
cfg.trialdef.pre = 20; 
cfg.trialdef.post = 20;
cfg.trialdef.offset = -20; 
cfg.trialdef.event = event;

cfg = ft_definetrial(cfg);

% cfg.bsfilter       = 'yes';
% % cfg.bsfiltord      = 2;
% cfg.bsfreq         = [58 62; 118 122; 178 182]; %definitely needed

% cfg.dftfilter = 'yes';
% cfg.dftfreq   = [60 120 180];

cfg.lpfilter       = 'yes';
cfg.lpfiltord      = 2;
cfg.lpfreq         = 200;

fullrun            = ft_preprocessing(cfg);
% save(fullfile(procdir, ['sub-',  num2str(subjectnum), '_fullrun']), "fullrun")

beep on; beep

%% 
cfg = [];
cfg = ft_databrowser(cfg,fullrun);

%%% NOTES
% Some extremely large spikes in hippocampus
% Two likely seizures

%% Visualize channel correlations

dat = fullrun.trial{1,1}';
[r,~] = corrcoef(dat);
figure;
badcorr = imagesc(r);
saveas(badcorr, fullfile(cleandir, "initial_chan_correlation.png"))

% 117 and 29 are perfectly correlated

%%% Largest numbers first
dat(:, 117) = [];
dat(:, 29)  = [];
%%%
[r,~] = corrcoef(dat);
figure;
goodcorr = imagesc(r);
saveas(goodcorr, fullfile(cleandir, "clean_chan_correlation.png"))

goodchans = {'all', char('-' + string(fullrun.label{29})), char('-' + string(fullrun.label{117}))};
%% Break up into trials

cfg = [];
cfg.dataset = eegfile;
cfg.trialfun = 'trl_alltrials';
cfg.trialdef.event = event;

cfg = ft_definetrial(cfg);

alltrials = ft_redefinetrial(cfg, fullrun);

%% 
cfg = [];
% cfg.channel = goodchans;
cfg = ft_databrowser(cfg,alltrials);
%% PSD
% First process all channels for both types

cfg               = [];
cfg.method        = 'mtmfft';
cfg.taper         = 'hanning';
cfg.pad           = 'nextpow2';
cfg.foilim        = [1 200];
cfg.tapsmofrq     = 0.5;
cfg.keeptrials    = 'yes';
% cfg.channel       = goodchans;

freq_segmented = ft_freqanalysis(cfg, alltrials);

%%
cfg = [];
cfg.avgoverrpt = 'yes';
cfg.keeprptdim = 'no';
cfg.nanmean    = 'yes';
cfg.channel    = goodchans;
freq_spectrum  = ft_selectdata(cfg, freq_segmented);

psd = 10*log10(freq_spectrum.powspctrm);
freqs = freq_spectrum.freq;

figure;
badpsd = imagesc(freqs, 1:numel(freq_spectrum.label), psd);
% saveas(badpsd, fullfile(cleandir, "initial_chan_psd.png"))

%%
% 28, 29, 30 too consistently bad correlation
% 40, 41, 64, 65, 66, 143, 144, 145, 146 are too consistent through broadband
betterchans = {'all', ...
    char('-' + string(fullrun.label{29})), ...
    char('-' + string(fullrun.label{117})), ...
    char('-' + string(freq_segmented.label{28})), ... %is now relative to the improved channels
    char('-' + string(freq_segmented.label{29})), ...
    char('-' + string(freq_segmented.label{30})), ...
    char('-' + string(freq_segmented.label{40})), ...
    char('-' + string(freq_segmented.label{41})), ...
    char('-' + string(freq_segmented.label{64})), ...
    char('-' + string(freq_segmented.label{65})), ...
    char('-' + string(freq_segmented.label{66})), ...
    char('-' + string(freq_segmented.label{143})), ...
    char('-' + string(freq_segmented.label{144})), ...
    char('-' + string(freq_segmented.label{145}))}

cfg = [];
cfg.avgoverrpt = 'yes';
cfg.keeprptdim = 'no';
cfg.nanmean    = 'yes';
cfg.channel    = betterchans;
freq_spectrum  = ft_selectdata(cfg, freq_segmented);

psd = 10*log10(freq_spectrum.powspctrm);
freqs = freq_spectrum.freq;

figure;
goodpsd = imagesc(freqs, 1:numel(freq_spectrum.label), psd);
saveas(goodpsd, fullfile(cleandir, "clean_chan_psd.png"))

% save(fullfile(procdir, ['sub-',  num2str(subjectnum), '_psd']), "freq_segmented")

%% Remove chans with more than 2 std
cfg = [];
cfg.method = 'summary';
cfg.channel = betterchans;

cleanrun = ft_rejectvisual(cfg, alltrials);

%% check trials for full run

cfg = [];
cfg.method = 'trial';
recleanrun_final = ft_rejectvisual(cfg, cleanrun);

cleanchans = recleanrun_final.label;
cleantrials = recleanrun_final.trialinfo.trial;
%%
cfg = [];
cfg.channel = cleanchans;
cfg.trials = cleantrials;
ft_databrowser(cfg,alltrials)


%%
save(fullfile(procdir, ['sub-',  num2str(subjectnum), '_cleanchans']), "cleanchans")
save(fullfile(procdir, ['sub-',  num2str(subjectnum), '_cleantrials']),"cleantrials")
save(fullfile(procdir, ['sub-',  num2str(subjectnum), '_depth_names.mat']), "depths")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

