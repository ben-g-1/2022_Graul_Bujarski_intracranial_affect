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

%% Load iEEG Data

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
cfg.lpfreq  = 200;
cfg.preproc.hpfilter = 'yes';
cfg.preproc.hpfreq = 2;
cfg.padding = 10;
%
% 
% 
% 
cfg.padtype = 'data';
cfg.bsfilter = 'yes';
cfg.bsfiltord = 3;
cfg.bsfreq = [59 61; 119 121; 179 181];
cfg.reref = 'yes';
% cfg.refmethod = 'bipolar';
cfg.refchannel = 'LTHA7';
% cfg.groupchans = 'yes';
cfg.trialfun = 'trl_singlephase';
cfg.trialdef.pre = 2.5; % Picture viewing is at T = 0
cfg.trialdef.post = 5.5;
cfg.trialdef.offset = -2.5;
cfg.trialdef.event = event;
cfg.trialdef.eventvalue = 6;
cfg.keeptrial = 'yes';

cfg = ft_definetrial(cfg);
data = ft_preprocessing(cfg);

pairorder = sortrows(data.trialinfo,"Pair","ascend");

%% Find bad channels
cfg = [];
% cfg.dataset    = eegfile;


% data = ft_preprocessing(cfg, data);
ft_databrowser(cfg, data)