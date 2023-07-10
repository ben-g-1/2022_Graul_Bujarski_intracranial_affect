cfg = [];
cfg.dataset = eegfile;
cfg.channel = chans;
% cfg.trialfun = 'trl_singlephase';
cfg.trialfun = 'trl_multiphase';

% cfg.trialfun = 'trl_rating'
cfg.trialdef.pre = 2.5;
cfg.trialdef.post = 14;
cfg.trialdef.event = event_full;
cfg.trialdef.eventvalue = 2;
cfg.keeptrial = 'yes';

cfg = ft_definetrial(cfg);

%%
cfg.demean = 'yes';
cfg.baselinewindow = 'all';
cfg.lpfilter = 'yes';
cfg.lpfreq  = 200;
% cfg.padding = 2;
% cfg.padtype = 'data';
cfg.bsfilter = 'yes';
cfg.bsfiltord = 3;
cfg.bsfreq = [59 61; 119 121; 179 181];
cfg.channel = {'RTA1' 'RTA2'}

data = ft_preprocessing(cfg);

event = data.cfg.event;