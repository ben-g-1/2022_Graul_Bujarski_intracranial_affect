%% FOOOOF Implementation  
subjectnum = '03';


sesdir = ['//dartfs-hpc/rc/lab/C/CANlab/labdata/data/EEE/ieeg/raw/sub-', subjectnum, '/ses-01'];
eegfile = [sesdir,  '/EEE_', subjectnum, '_deidentified.EDF'];

subjdir = 'C:\Users\bgrau\Dropbox (Dartmouth College)\2023_Graul_EEE\Data\raw\sub-01';
sesdir = fullfile(subjdir, 'ses-01');

eegfile = fullfile(sesdir, ['EEE_PT-', subjectnum, '_BG_deidentified.EDF']);

%load event_full
load("C:\Users\bgrau\Dropbox (Dartmouth College)\2023_Graul_EEE\Data\processed\sub-01\sub-01_event_clean.mat");
%load chans
load("C:\Users\bgrau\Dropbox (Dartmouth College)\2023_Graul_EEE\Data\processed\sub-01\sub-01_all_elecs.mat");

cfg = [];
cfg.dataset = eegfile;
% cfg.channel = chans;

%%
% for v = 1:8
% for chan = 133%numel(chans)
% chan = 53;
cfg = [];
cfg.dataset = eegfile;
cfg.trialfun = 'trl_singlephase';
cfg.trialdef.pre = 0; 
cfg.trialdef.post = 1.5;
cfg.trialdef.offset = 0; % Picture viewing is at T = 0
cfg.trialdef.event = event_full;
cfg.trialdef.eventvalue = 6;

cfg = ft_definetrial(cfg);

% cfg = [];
cfg.channel       = chans;

cfg.bsfilter       = 'yes';
cfg.bsfiltord      = 3;
cfg.bsfreq         = [58 62; 118 122; 178 182];
% cfg.reref = 'yes';
% cfg.refmethod = 'bipolar';
% cfg.refchannel = 'LTHA7';


data = ft_preprocessing(cfg);
%%

cfg = [];
cfg.channel = 'RTA1';
cfg.trials = [1:61 63 64];
imgview = ft_selectdata(cfg, data);


cfg = [];
cfg.keeptrials = 'no';
ft_singleplotER(cfg, imgview)

%%
v = 6;
% FOOOF

cfg               = [];

cfg.foilim        = [1 200];
cfg.pad           = 'nextpow2';
cfg.tapsmofrq     = 2; 
cfg.method        = 'mtmfft';
cfg.output        = 'fooof_aperiodic';
fractal = ft_freqanalysis(cfg, imgview);
cfg.output        = 'pow';
original = ft_freqanalysis(cfg, imgview);


cfg               = [];
cfg.parameter     = 'powspctrm';
cfg.operation     = 'x2-x1';
oscillatory = ft_math(cfg, fractal, original);

cfg               = [];
cfg.parameter     = 'powspctrm';
cfg.operation     = 'x2./x1';  % equivalent to 10^(log10(x2)-log10(x1))
oscillatory_alt = ft_math(cfg, fractal, original);

% display the spectra on a log-log scale
figure(); 
subplot(1,2,1); hold on;
plot((original.freq), log(original.powspctrm),'k');
plot((fractal.freq), log(fractal.powspctrm));
plot((fractal.freq), log(oscillatory.powspctrm));

xlabel('log-freq'); ylabel('log-power'); grid on;
legend({'original','fractal','oscillatory = spectrum-fractal'},'location','southwest');
title([chans{chan} ' mixed signal']);

% if F~=0 && O==0
%   title('pure fractal signal');
% elseif F==0 && O~=0
%   title('pure oscillatory signal');
% elseif F~=0 && O~=0
% end
subplot(1,2,2); hold on;
plot((oscillatory_alt.freq), (oscillatory_alt.powspctrm));
% plot((original.freq), (original.powspctrm),'k');
% plot((fractal.freq), (fractal.powspctrm));

% plot(log(original.freq), log(original.powspctrm),'k');
% plot(log(fractal.freq), log(fractal.powspctrm));
% plot(log(oscillatory_alt.freq), log(oscillatory_alt.powspctrm));
xlabel('freq'); ylabel('power'); grid on;
% legend({'original','fractal','oscillatory = spectrum/fractal'},'location','southwest');
title([chans{chan} num2str(v) ' Power']);
pause(0.1);
% end
% end

cfg = [];
cfg.parameter = 'powspctrm';
ft_singleplotTFR(cfg, oscillatory);