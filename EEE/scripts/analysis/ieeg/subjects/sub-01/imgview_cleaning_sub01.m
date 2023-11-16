%%% Sub-01 Image Viewing (Electrode Cleaning)

cfg = [];
cfg.dataset = eegfile;
cfg.trialfun = 'trl_singlephase';
cfg.trialdef.pre = 2.5; 
cfg.trialdef.post = 5;
cfg.trialdef.offset = -2.5; % Picture viewing is at T = 0
cfg.trialdef.event = event_full;
cfg.trialdef.eventvalue = 6;
cfg.keeptrials = 'yes';
cfg.channels = chans;

cfg = ft_definetrial(cfg);



imgview = ft_redefinetrial(cfg, data);

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


