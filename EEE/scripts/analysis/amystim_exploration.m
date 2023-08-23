eegfile = 'C:\Users\bgrau\OneDrive\Desktop\Amygdala Stimulation Study\EEG Data\EMO11R21PT11.ENCODING.EDF';

cfg = [];
cfg.dataset = eegfile;
cfg.continuous = 'yes';

hdr = ft_read_header(cfg.dataset);
%%

 
% Find bad channels
% badchan = {'-LTHA6', '-RPAG7', '-RPAG11', '-RFC5','-LTA2', '-LTA5', '-RPAG8', '-RPRS13', '-LTA8', '-RPAG3', '-RTF2','-LTHA1', '-LTHA2', '-RTF4', '-RPRS15'};
badchan = {'-LFC5', '-RPRS5'};


eegchan          = strcat('-', ft_channelselection({'eeg'}, hdr.label));

chans    = ft_channelselection({'all', '-PR', '-Pleth', '-TRIG', ...
    '-OSAT', '-*DC*', '-C*', badchan{:}, eegchan{:}}, hdr.label);
% ,    emptychan{:}, extrachan{:}

cfg.channel = chans;


%%
cfg.dataset      = eegfile;

% trigger detection 
hdr              = ft_read_header(cfg.dataset);
event            = ft_read_event(cfg.dataset, 'detectflank', 'both', 'chanindx', find(ismember(hdr.label, 'DC3')));
idx              = [];
for e = 1:numel(event)
  if isequal(event(e).type, 'annotation')
    idx = [idx e]; % events to be tossed
  end
end

event(idx)       = [];
%%
% event.phase = [];
for i = 1:2:numel([event.sample])
    event(i).duration = event(i+1).sample - event(i).sample;
    event(i).duration = event(i).duration/hdr.Fs; 
end
idx = 2:2:numel([event.sample]);

event(idx)   = [];
event = rmfield(event, 'offset');

%%
c = 1;
for i = 1:numel([event.sample])
    event(i).imgnum = i;
    event(i).phase = c;
    if c < 4
        event(i).onstim = 0;
    else
        event(i).onstim = 1;
    end
    c = c + 1;
    if c == 9
        c = 1;
    end
end
%%
cfg = [];
cfg.trialfun = 'trl_singlephase';
cfg.dataset = eegfile;
cfg.trialdef.event = event;
cfg.trialdef.eventvalue = 0;
cfg.trialdef.pre = 2;
cfg.trialdef.post = 6;
cfg.trialdef.offset = -2;

cfg = ft_definetrial(cfg);
nostim = ft_preprocessing(cfg);

% % read the header information and import events 
% hdr   = ft_read_header(cfg.dataset);
% etable = struct2table(cfg.trialdef.event);
% eventvalue = cfg.trialdef.eventvalue;
%%
cfg = [];
cfg.reref = 'yes';
cfg.refmethod = 'bipolar';
cfg.refchannel = 'all';
% cfg.demean         = 'yes';
cfg.baselinewindow = 'all';
% cfg.lpfilter       = 'yes';
% cfg.lpfreq         = 150;
% cfg.hpfilter       = 'yes';
% cfg.hpfreq         = 0.3;
% cfg.padding        = .5;
% cfg.padtype        = 'data';
cfg.bsfilter       = 'yes';
cfg.bsfiltord      = 3;
cfg.bsfreq         = [59 61; 119 121; 179 181];
cfg.channel = chans;

nostim = ft_preprocessing(cfg, nostim);
%%% DC3 is messier signal. Amplitude seems to indicate stim/no stim, with
%%% thicker band as stim
%%% DC4 is photodiode? Only shows 53 events

%%% 5 stim: Pt 11, 10 
%%% No stim: Pt 12

%%
cfg  = [];
cfg.viewmode = 'vertical';
% ft_databrowser(cfg, nostim)


%%
% spectral decomposition
    timres          = .0005; % 10 ms steps
    cfg             = [];

    cfg.output      = 'pow';
    cfg.method      = 'mtmconvol';
    cfg.taper       = 'dpss';
    % cfg.foi         = 4:5:200; % 4 to 200
    cfg.toi         = nostim.time{1}(1):timres:nostim.time{1}(end);  % begin to end of defined event

    cfg.foi =   [4:1:30 31:3:59 61:3:118 121:3:178 181:3:199];
    
    
    % cfg.foi  = [30:5:55];
    cfg.channel = 'RTA1-RTA2';
    % cfg.trials = [3:3:24];


    cfg.tapsmofrq   = 10;
    cfg.t_ftimwin   = .2*ones(length(cfg.foi),1); % 200 ms
    cfg.keeptrials  = 'yes';
    cfg.pad         = 'nextpow2';

nostim_freq = ft_freqanalysis(cfg, nostim);
%%
nostim_freq_z = ft_zscore_pow(nostim_freq);

cfg = [];
% cfg.channel = 'RFC1-RFC2';
% cfg.baseline = [-.5 0];
cfg.parameter = 'powspctrm';
cfg.baselinetype = 'zscore';
% cfg.ylim = [0 15];
% cfg.zlim = [-5 5];

ft_singleplotTFR(cfg, nostim_freq);
% ft_singleplotTFR(cfg, nostim_freq_z);

%%
[sigelecs, sigelecs_labels] = zscore_thresholds(nostim_freq_z,  'max', 0.7);

% visualize zscore
figure;

xlabel('Time (s)')
ylabel('zscore power ratio')
title({'Z-score Broadband Shift for Right Amygdala'; ...
    'Image View Without Stim'})
set(gca, 'FontSize', 28)
% xlim([-2.4 5.4])
hold on;
for c = 1:length(nostim_freq_z.label)
  avg = squeeze(nanmean(nostim_freq_z.powspctrm(:,c,1,:),1));
    % avg = squeeze(nanmean(nostim_freq_z.powspctrm(c,1,:),1));

  plot(nostim_freq_z.time, avg)
end 
legend('LFC9-LFC10')