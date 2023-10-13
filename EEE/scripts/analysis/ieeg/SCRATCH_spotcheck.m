%% Initialize Variables

subjectnum = '02';
sessionnum = '01';
projdir = 'C:\Users\bgrau\GitHub\ieeg_affect\EEE';
filedir = fullfile(projdir, 'assets');
scriptdir = fullfile(projdir, 'scripts', 'EEE_task');
subjdir = fullfile(projdir, 'subjects', ['sub-',  num2str(subjectnum)]);
sesdir = fullfile(subjdir, ['ses-', num2str(sessionnum)]);
datadir = fullfile(sesdir, 'ieeg');
funcdir = fullfile(scriptdir, 'functions');
imagedir = fullfile(filedir, 'oasis_pairs');

%%% iEEG Channels %%%
% 


eegfile = fullfile(datadir, ['EEE_PT-', subjectnum, '_BG.EDF']);

% Find and label unneeded channels
cfg            = [];
cfg.dataset    = eegfile;
cfg.continuous = 'yes';

hdr            = ft_read_header(cfg.dataset);

%   Scalp EEG
eegchan          = strcat('-', ft_channelselection({'eeg'}, hdr.label));

% reference channel: LTHA7
badchan = {'-RTP15', '-RIB10', '-LTHA6','-LTHA7', '-LTHA8','-LTHA9','-LTHA10', '-LTHA11', '-LTHA12'};

cfg.channel    = ft_channelselection({'all', '-PR', '-Pleth', '-TRIG', ...
    '-OSAT', '-*DC*', '-C*', badchan{:}; eegchan{:}}, hdr.label);

% cfg.trialfun = 'trl_fullrun';
% cfg.trialdef.pre = 15; 
% cfg.trialdef.post = 15;
% cfg.trialdef.event = event;
% cfg.keeptrial = 'yes';
% 
% cfg = ft_definetrial(cfg);

%%
% cfg.demean = 'yes'; 
% cfg.detrend = 'yes';
% cfg.demean = 'no';
% cfg.baselinewindow = 'all';
cfg.lpfilter = 'yes';
cfg.lpfreq  = 8;
cfg.preproc.hpfilter = 'yes';
cfg.preproc.hpfreq = 2;
% cfg.padding = 10;
%
% 
% 
% 
    cfg.channel = '{RTA*}';
cfg.padtype = 'data';
cfg.bsfilter = 'yes';
cfg.bsfiltord = 3;
cfg.bsfreq = [59 61; 119 121; 179 181];
% cfg.reref = 'yes';
% cfg.refmethod = 'bipolar';
% cfg.refchannel = 'LTHA7';
% cfg.groupchans = 'yes';
cfg.trialfun = 'trl_singlephase';
cfg.trialdef.pre = 4; % Picture viewing is at T = 0
cfg.trialdef.post = 2;
cfg.trialdef.offset = -4;
cfg.trialdef.event = event_full;
cfg.trialdef.eventvalue = 6;
cfg.keeptrial = 'yes';

cfg = ft_definetrial(cfg);
data = ft_preprocessing(cfg);


%%
cfg = [];
ft_databrowser(cfg, data)
%%
% spectral decomposition
    timres          = .01; % 10 ms steps
    cfg             = [];
    cfg.channel     =  'RIA*';

    cfg.output      = 'pow';
    cfg.method      = 'mtmconvol';
    cfg.taper       = 'dpss';
    % cfg.foi = [40 45 50 55 65 70 75 80 85 90 95 100 105 110 115 125 130 135 140 145 150 155 160 165 170 175 185 190]; % 80 - 190 Hz, leave out harmonics of 60 Hz
    % cfg.foi = [5 8 11 14 17 20 23 26 29 32 35 40 45 50 55 65 70 75 80 85 90 95 100 105 110 115 125 130 135 140 145 150 155 160 165 170 175 180 185 190]
    % cfg.foi = [4:1:30 31:2:53 70:2:118 121:2:170 181:2:199];
    cfg.foi = [3:1:30];
    cfg.tapsmofrq   = 10;
    cfg.t_ftimwin   = .2*ones(length(cfg.foi),1); % 200 ms
    cfg.toi         = data.time{1}(1):timres:data.time{1}(end);  % begin to end of defined event
    % cfg.toi         = round(data.time{1}(hdr.Fs * 1.99)):timres:round(data.time{1}(hdr.Fs * 3.51));  
    cfg.keeptrials  = 'yes';
    cfg.pad         = 'nextpow2';

    % imgview_freq_hires = ft_freqanalysis(cfg,imgview);
imgview_freq = ft_freqanalysis(cfg,data);
%%
figure; hold on;
set(gca, 'FontSize', 32)
scn_export_papersetup(400);
% cfg.title = sprintf('%s Average Image Response', cfg.channel);
% title('High Gamma Activity Following Image Onset', 'FontSize', 26)
ylabel({'Frequency (Hz)'; '2 Hz Step'}, 'FontSize', 32, 'FontWeight','bold')
xlabel({'Time After Image Onset (s)'}, 'FontSize', 32, 'FontWeight','bold')
% zlabel({'*100'});
% set(gca, 'ZTick', -2:9, 'ZTickLabel', ['-200%' '0']);

cfg = [];
cfg.title = 'Gamma Activity Following Image Onset';
cfg.fontsize = 32;
cfg.figure = gcf;
% cfg.xlim = [0 1.5]; % trim the empty space
% cfg.ylim = [35 101]; %focus on mid/high gamma
% cfg.zlim = [-2 5]; % set scale to be the same across figures
cfg.parameter = 'powspctrm';
cfg.baseline = [-0.5 -0.001];
cfg.baselinetype = 'db';

cfg.channel = 'RIA1';
cfg.trials      = 'all';
ft_singleplotTFR(cfg, imgview_freq)