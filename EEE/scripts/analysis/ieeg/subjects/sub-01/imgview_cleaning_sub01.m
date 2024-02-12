%%% Sub-01 Image Viewing (Electrode Cleaning)
%%
subjectnum = '01';


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
cfg.channel = chans;

%%
cfg = [];
cfg.dataset = eegfile;
cfg.trialfun = 'trl_singlephase';
cfg.trialdef.pre = 0; 
cfg.trialdef.post = 2;
cfg.trialdef.offset = 0; % Picture viewing is at T = 0
cfg.trialdef.event = event_full;
cfg.trialdef.eventvalue = 6;
cfg.keeptrials = 'yes';
cfg.reref = 'yes';
cfg.refchannel = 'LFC5';

cfg = ft_definetrial(cfg);

imgview = ft_preprocessing(cfg);

%%
cfg = [];
cfg.trials = [1:61 63 64];
imgview = ft_selectdata(cfg, imgview);


%%
cfg = [];
% cfg.trials = {'-62'};
% cfg.method =
imgview_clean = ft_rejectvisual(cfg, imgview);
% the following channels were removed: RPXA10, RPAG8, RTHA2, RTHA3, RTF9,
% RTF10, RTF11, LPPC7

% '-LTHA6', '-RPAG7', '-RPAG11', '-RFC5','-LTA2', '-LTA5', '-RPAG8',
% '-RPRS13', '-LTA8', '-RPAG3', '-RTF2','-LTHA1', '-LTHA2', '-RTF4',
% '-RPRS15', '-RTHA3', '-RTF10', '-RTF11', '-RPRS4'
% the following trials were removed: 55, 62
%%
cfg = [];
cfg.reref = 'yes';
cfg.refmethod = 'bipolar';
cfg.groupchans = 'yes';

cfg.preproc.lpfilter = 'yes';
cfg.preproc.lpfreq  = 150;
cfg.preproc.hpfilter = 'yes';
cfg.preproc.hpfreq = 3;

cfg.preproc.bsfilter = 'yes';
cfg.preproc.bsfiltord = 3;
cfg.preproc.bsfreq = [58 62; 118 122];

cfg.demean = 'yes';

imgview_bp = ft_preprocessing(cfg, imgview_clean);
%%
cfg = [];
% % cfg.trial = '-62';
% imgview_clean_bp = ft_selectdata(cfg, imgview_bp);

ft_databrowser(cfg, imgview_bp);


