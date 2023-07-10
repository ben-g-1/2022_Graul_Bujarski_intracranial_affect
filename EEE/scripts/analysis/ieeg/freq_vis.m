cfg = [];
pairnum = 15;

% cfg.xlim = [-3.4 0];
% cfg.xlim = [0 2];
% cfg.xlim = [0 6];

% cfg.zlim = [0 1.5];
% cfg.xlim = [1 3];

% cfg.ylim = [160 200];


% cfg.ylim = [40 60];
cfg.ylim = [70 150];



% cfg.baseline = [-3.9 -3.6];
% cfg.baseline = [-0.6 -0.1];
% cfg.baseline = [1.4 1.9];

cfg.baselinetype = 'relchange';
cfg.parameter = 'powspctrm';

%%% Pair trial comparison, same electrode
% cfg.channel = 43;
% 
% cfg.trials = pairs.hitrial(pairnum);
% cfg.title = [cfg.channel cfg.trials ]; 
% 
% ft_singleplotTFR(cfg, imgview_freq_allchan)
% 
% cfg.trials = pairs.lotrial(pairnum);
% ft_singleplotTFR(cfg, imgview_freq_allchan)
%%%

%%% Channel comparison, same trial
% cfg.trials = 5;
% cfg.trials = 34;
% 
% cfg.channel = 43;
% cfg.title = [cfg.channel cfg.trials ]; 
% ft_singleplotTFR(cfg, imgview_freq_allchan)
% cfg.channel = 44;
% cfg.title = [cfg.channel cfg.trials ]; 
% ft_singleplotTFR(cfg, imgview_freq_allchan)
% cfg.channel = 44;
% % cfg.baseline = [-0.9 -0.4];
% 
% cfg.trials = pairs.hitrial(pairnum);
% % cfg.title = [cfg.channel cfg.trials ]; 
% 
% ft_singleplotTFR(cfg, imgview_freq)
% 
% cfg.trials = pairs.lotrial(pairnum);
% % cfg.title = [cfg.channel cfg.trials ]; 
% 
% ft_singleplotTFR(cfg, imgview_freq)

cfg.channel = ft_channelselection('LTA1-LTA3', imgview_freq.label);
% cfg.title = [cfg.channel cfg.trials ];
% ft_singleplotTFR(cfg, imgview_freq)


% cfg.channel = 12;
% 
cfg.trials = pairs.hitrial(pairnum);
% cfg.title = [cfg.channel cfg.trials ]; 
% 
ft_singleplotTFR(cfg, imgview_freq)
% 
cfg.trials = pairs.lotrial(pairnum);
% cfg.title = [cfg.channel cfg.trials ]; 
% 
ft_singleplotTFR(cfg, imgview_freq)

cfg.trials = event.highcue_indx == 1;
% cfg.title = [cfg.channel cfg.trials ];
ft_singleplotTFR(cfg, imgview_freq)

cfg.trials = event.highcue_indx == -1;
% cfg.title = [cfg.channel cfg.trials ];
ft_singleplotTFR(cfg, imgview_freq)

% cfg.channel = 52;
% cfg.title = [cfg.channel cfg.trials ]; 
% 
% ft_singleplotTFR(cfg, imgview_freq_allchan)

% cfg.channel = 122;
% cfg.title = [cfg.channel cfg.trials ]; 
% ft_singleplotTFR(cfg, imgview_freq_allchan)
% 
% cfg.channel = 96;
% 
% cfg.trials = pairs.hitrial(pairnum);
% cfg.title = [cfg.channel cfg.trials ]; 
% 
% ft_singleplotTFR(cfg, imgview_freq_allchan)
% 
% cfg.trials = pairs.lotrial(pairnum);
% cfg.title = [cfg.channel cfg.trials ]; 
% 
% ft_singleplotTFR(cfg, imgview_freq_allchan)
% cfg.channel = 97;
% cfg.title = [cfg.channel cfg.trials ]; 
% ft_singleplotTFR(cfg, imgview_freq_allchan)
% cfg.channel = 98;
% 
% cfg.trials = pairs.hitrial(pairnum);
% cfg.title = [cfg.channel cfg.trials ]; 
% 
% ft_singleplotTFR(cfg, imgview_freq_allchan)
% 
% cfg.trials = pairs.lotrial(pairnum);
% cfg.title = [cfg.channel cfg.trials ]; 
% 
% ft_singleplotTFR(cfg, imgview_freq_allchan)



%%
%%% Channel comparison, same trial
cfg.xlim = [0 6];
cfg.baseline = [-0.6 -0.1];

cfg.channel = 113;
cfg.title = [cfg.channel cfg.trials ]; 
ft_singleplotTFR(cfg, imgview_freq_allchan)

cfg.channel = 114;
cfg.title = [cfg.channel cfg.trials ]; 
ft_singleplotTFR(cfg, imgview_freq_allchan)


cfg.channel = 96;
cfg.title = [cfg.channel cfg.trials ]; 
ft_singleplotTFR(cfg, imgview_freq_allchan)

cfg.channel = 98;
cfg.title = [cfg.channel cfg.trials ]; 
ft_singleplotTFR(cfg, imgview_freq_allchan)







% cfg.channel = 105;
% cfg.title = [cfg.channel cfg.trials ]; 
% ft_singleplotTFR(cfg, imgview_freq_allchan)
% cfg.channel = 106;
% cfg.title = [cfg.channel cfg.trials ]; 
% ft_singleplotTFR(cfg, imgview_freq_allchan)
%%%
%%

% cfg.trials = 23;
% for i = 1:numel(imgview_freq_allchan.label)
%     cfg.channel = i;

% end
% 
% Post: 10, 1, 2, 72, 112
% 
% Img: 65, 58, 57, 55, 54, 43, 113, 114, 123
% 
% Pre: 69,68, 36, 24, 23, 9, 8, 103, 109, 111, 
% 
% All: 62, 52, 37, 22, 12, 5 ,81 88
% RPPC is very non-noisy. Interesting?
% 
% relchange

% cfg.operation = '(x1-x2)';
% cfg.operation = '(x1 - x2) / (x1 + x2)';
% cfg.zlim = 'minzero';
%   cfg.xlim           = 'maxmin' or [xmin xmax] (default = 'maxmin')
%   cfg.ylim           = 'maxmin' or [ymin ymax] (default = 'maxmin')
%   cfg.zlim           = plotting limits for color dimension, 'maxmin', 'maxabs', 'zeromax', 'minzero', or [zmin zmax] (default = 'maxmin')
%   cfg.baselinetype   = 'absolute', 'relative', 'relchange', 'normchange', 'db' or 'zscore' (default = 'absolute')

%%
pairnum = 15;
cfg = [];

% cfg.baseline = [-.4 -.01];

% cfg.xlim = [3 5];
cfg.ylim = [70 150];
cfg.zlim = [0 10];
% cfg.baselinetype = 'db';
cfg.parameter = 'powspctrm';

cfg.channel = 'RTA1';
cfg.trials = pairs.hitrial(pairnum);

ft_singleplotTFR(cfg, imgview_freq)

cfg.trials = pairs.lotrial(pairnum);
ft_singleplotTFR(cfg, imgview_freq)


cfg.trials      = imgview.trialinfo.highcue_indx == 1;
ft_singleplotTFR(cfg, imgview_freq)

cfg.trials      = imgview.trialinfo.highcue_indx == -1;
ft_singleplotTFR(cfg, imgview_freq)

%%
cfg = [];
cfg.baseline = [-.4 -.1];
cfg.zlim = [-2 5];
cfg.baselinetype = 'relchange';
cfg.parameter = 'powspctrm';


%%

difference_freq = ft_math(cfg, imgview_freq_1, imgview_freq_2);

ft_singleplotTFR(cfg, difference_freq)
%%

% spectral decomposition



% for i = [1 7 8 11 12 15 18 25 27]
for i = [27 30]
    for c = [96 98 113 114]
    timres          = .05; % 50 ms steps
    cfg             = [];
    % cfg.channel     = 'RTA11-RTA12';
    cfg.channel     = c;

    cfg.output      = 'pow';
    cfg.method      = 'mtmconvol';
    cfg.taper       = 'dpss';
    cfg.foi         =  40:2:200;
    cfg.tapsmofrq   = 10;
    cfg.t_ftimwin   = .2*ones(length(cfg.foi),1); % 300 ms
    % toi start: 200ms, sample 2460
    % toi end: 1000ms, sample 4097
    cfg.toi         = data.time{1}(1):timres:data.time{1}(end);  % begin to end of experiment
    % cfg.toi         = data.time{1}(hdr.Fs * 2):timres:data.time{1}(hdr.Fs * 4);  % begin to end of experiment
    cfg.keeptrials  = 'yes';
    cfg.pad         = 'nextpow2';
    cfg.parameter = 'powspctrm';

    cfg.operation = '(x1 - x2) / (x1 + x2)';


    cfg.trials = pairs.hitrial(i-10);
    imgview_freq_1 = ft_freqanalysis(cfg, imgview);
    
    cfg.trials = pairs.lotrial(i); 
    imgview_freq_2 = ft_freqanalysis(cfg, imgview);

    difference_freq = ft_math(cfg, imgview_freq_1, imgview_freq_2);

    cfg = [];
    cfg.baselinetype = 'relchange';
    cfg.parameter = 'powspctrm';
    % cfg.baseline = round([-1.0 -0.8]);
    cfg.title = i;
    % cfg.zlim = [-7 7];
    cfg.ylim = [40 80];

    ft_singleplotTFR(cfg, difference_freq)
    end
end
