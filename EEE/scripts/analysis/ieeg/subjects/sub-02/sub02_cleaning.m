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

subjectnum = '02';
sesdir = '//dartfs-hpc/rc/lab/C/CANlab/labdata/data/EEE/ieeg/raw/sub-02/ses-01';

eegfile = [sesdir,  '/EEE_', subjectnum, '_deidentified.EDF'];

% Find and label unneeded channels
cfg            = [];
cfg.dataset    = eegfile;
cfg.continuous = 'yes';

% hdr            = ft_read_header(cfg.dataset);

%   Scalp EEG
eegchan          = strcat('-', ft_channelselection({'eeg'}, hdr.label));

% reference channel: LTHA7
badchan = {}%{'-RTP15', '-RIB10', '-LTHA6','-LTHA7', '-LTHA8','-LTHA9','-LTHA10', '-LTHA11', '-LTHA12'};

cfg.channel    = ft_channelselection({'all', '-PR', '-Pleth', '-TRIG', ...
    '-OSAT', '-*DC*', '-C*', eegchan{:}}, hdr.label); %badchan{:};


%%

% cfg.trialfun = 'trl_fullrun';
% cfg.trialdef.pre = 15; 
% cfg.trialdef.post = 15;
% cfg.trialdef.event = event;
% cfg.keeptrial = 'yes';
% 
% cfg = ft_definetrial(cfg);


% cfg.demean = 'yes'; 
% cfg.detrend = 'yes';
% cfg.demean = 'no';
cfg.baselinewindow = 'all';
cfg.lpfilter = 'yes';
cfg.lpfreq  = 150;
cfg.hpfilter = 'yes';
cfg.hpfreq = 3;
% cfg.padding = 10;
%
% 
% 
% 
cfg.padtype = 'data';
cfg.bsfilter = 'yes';
cfg.bsfiltord = 3;
cfg.bsfreq = [59 61; 119 121];%; 179 181];
cfg.reref = 'yes';

cfg.refchannel = 'LTHA7';
% cfg.refmethod = 'bipolar';
% cfg.groupchans = 'yes';

cfg.trialfun = 'trl_singlephase';
cfg.trialdef.pre = 3; % Picture viewing is at T = 0
cfg.trialdef.post = 5;
cfg.trialdef.offset = -3;
cfg.trialdef.event = event;
cfg.trialdef.eventvalue = 6;
cfg.keeptrial = 'yes';

cfg = ft_definetrial(cfg);
data = ft_preprocessing(cfg);

pairorder = sortrows(data.trialinfo,"Pair","ascend");

%% Find bad channels
cfg = [];
clean_data = ft_rejectvisual(cfg,data);

cleanchans = clean_data.label;
% removed: RTHB3, RTP15, LTHA7, LTHA8, LTHA12

% reference channel: LTHA7
% badchan = {'-RTP15', '-RIB10', '-LTHA6','-LTHA7',
% '-LTHA8','-LTHA9','-LTHA10', '-LTHA11', '-LTHA12'}; from visual
% inspection

%%
cfg            = [];
cfg.dataset    = eegfile;
cfg.continuous = 'yes';

cfg.channel    = ft_channelselection(cleanchans, hdr.label);

% cfg.demean = 'yes'; 
% cfg.detrend = 'yes';

cfg.baselinewindow = 'all';
cfg.lpfilter = 'yes';
cfg.lpfreq  = 200;
cfg.hpfilter = 'yes';
cfg.hpfreq = 3;

cfg.padtype = 'data';
cfg.bsfilter = 'yes';
% cfg.bsfiltord = 3;
cfg.bsfreq = [58 62; 118 122; 178 182];
% cfg.dftfreq = [60 120 180];
cfg.reref = 'yes';

cfg.refmethod = 'bipolar';
cfg.groupchans = 'yes';

cfg.trialfun = 'trl_singlephase';
cfg.trialdef.pre = 3; % Picture viewing is at T = 0
cfg.trialdef.post = 5;
cfg.trialdef.offset = -3;
cfg.trialdef.event = event;
cfg.trialdef.eventvalue = 6;
cfg.keeptrial = 'yes';

cfg = ft_definetrial(cfg);
data = ft_preprocessing(cfg);
