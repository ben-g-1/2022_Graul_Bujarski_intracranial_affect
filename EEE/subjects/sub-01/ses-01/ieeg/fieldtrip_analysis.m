subjdir = 'C:\Users\bgrau\GitHub\ieeg_affect\EEE\subjects\sub-01'
sesdir = fullfile(subjdir, 'ses-01', 'ieeg')

eegfile = fullfile(sesdir, 'EEEPT#1.EDF')

% define trials
cfg            = [];
cfg.dataset    = eegfile;
cfg.continuous = 'yes';
cfg.channel    = 'all';


data           = ft_preprocessing(cfg);

%%
cfg.viewmode   = 'vertical';
ft_databrowser(cfg, data);



%%
% Photodiode is 259, DC3
%   DC3 Scale: [ -500000  5566048 ]
% Other DC channels seem empty, but I know we plugged in DC4. Reference?
% NoniEEG channels:
% emptychan = {'C182','C183','C184','C185','C186','C187','C188','C189','C190','C191','C192','C193','C194','C195','C196','C197','C198','C199','C200','C201','C202','C203','C204','C205','C206','C207','C208','C209','C210','C211','C212','C213','C214','C215','C216','C217','C218','C219','C220','C221','C222','C223','C224','C225','C226','C227','C228','C229','C230','C231','C232','C233','C234','C235','C236','C237','C238','C239','C240','C241','C242','C243','C244','C245','C246','C247','C248','C249','C250','C251','C252','C253','C254','C255','C256','DC1','DC2','DC3','DC4','DC5','DC6','DC7','DC8','DC9','DC10','DC11','DC12','DC13','DC14','DC15','DC16','TRIG','OSAT','PR','Pleth'};

extrachan = {};
rowcnt = 1;
for i = 123:128
    i_str = string(i);
    chan = strcat('-C', i_str);
    chan = convertStringsToChars(chan);
    extrachan{rowcnt} = chan;
    rowcnt = rowcnt + 1;
end
% 
rowcnt = 1;
emptychan = {};
for i = 182:256
    i_str = string(i);
    chan = strcat('-C', i_str);
    chan = convertStringsToChars(chan);
    emptychan{rowcnt} = chan;
    rowcnt = rowcnt + 1;
end

% Major Drift ['-LTHA6', '-RPAG7', '-RPAG11', '-RFC5', ]
% LTHA6 is really consistent in strong deviation. Maybe look to see if
% sinal pattern emerges correlated to any task moment?

% Minor Drift ['-LTA5', '-RPAG8', '-RPRS13', '-LTA8', '-RPAG3', '-RTF2']
% Major Spike ['-LTHA1', '-LTHA2', '-RTF4', '-RPRS15', '-LTA2',   
% Scalp EEG 163:181
scalpchan = {'FP1','F7','T3','T5','O1','F3','C3','P3','FP2','F8','T4','T6','O2','F4','C4','P4','Fz','Cz','Pz'};
rm_scalpchan = {'-FP1','-F7','-T3','-T5','-O1','-F3','-C3','-P3','-FP2','F8','-T4','-T6','-O2','-F4','-C4','-P4','-Fz','-Cz','-Pz'};
% C182:C256 seem empty?
% C123:128 not empty, but signal is small. Lacking label?
% All are 'unknown' signal type except scalp EEG, TRIG incorrect as trigger
eegchan          = strcat('-', ft_channelselection({'eeg'}, data.label));

badchan = {'-LTHA6', '-RPAG7', '-RPAG11', '-RFC5','-LTA5', '-RPAG8', '-RPRS13', '-LTA8', '-RPAG3', '-RTF2','-LTHA1', '-LTHA2', '-RTF4', '-RPRS15', '-LTA2'};
cfg.channel    = ft_channelselection({'all', '-*DC*', '-PR', '-Pleth', '-TRIG', '-OSAT', badchan{:}, eegchan{:}, emptychan{:}, extrachan{:}}, data.label);
% '-*DC*',

%%

data           = ft_preprocessing(cfg);
ft_databrowser(cfg, data);

%% define trials with upflank
cfg              = [];
cfg.dataset      = eegfile;

% trigger detection (appear to be 3-sec long)
hdr              = ft_read_header(cfg.dataset);
event            = ft_read_event(cfg.dataset, 'detectflank', 'both', 'chanindx', find(ismember(hdr.label, 'DC3')));
idx              = [];
for e = 1:numel(event)
  if isequal(event(e).type, 'annotation')% | ~isequal(event(e).type, 'DC3_down')
    idx = [idx e]; % events to be tossed
  end
end


event(idx)       = [];
trigs            = [event.sample]';
%%


% trial definition
pre              = round(1 * hdr.Fs);
post             = round(1 * hdr.Fs);
cfg.trl          = [trigs-pre trigs+post+1 ones(numel(trigs),1)*-pre]; % 1 seconds before and after trigger onset
cfg.trl(any(cfg.trl>hdr.nSamples,2),:) = []; % ensure presence of samples

% First event starts at 213.6484 seconds
% With up flank, this is event 15. First 14 are tutorial. Event 271 is junk
% Leaves 256 events
%   4 boxes per trial (cue, rate, image, rate)
%   8 trials per block
%   8 blocks
% Events:
% Fix time = Event 1 - fix jitter
% Cue time = Event 2 - Event 1 
%   Should equal image jitter time
% Rate time = Rate time - Event 2
% Fix time = Event 3 - fix jitter 
% Image time = Event 4 - Event 3
% Rate time = Rate time - Event 4
% This is repeated 8 times
%% Up and down flanks
% Isn't working- returns empty matrix
cfg              = [];
cfg.dataset      = eegfile;

% trigger detection (appear to be 3-sec long)
hdr              = ft_read_header(cfg.dataset);
event            = ft_read_event(cfg.dataset, 'detectflank', 'both', 'chanindx', find(ismember(hdr.label, 'DC3')));
idx              = [];

%%

for i = 1:length([event.sample])
    event(i).timestamp = event(i).sample / 512;
    if i < length([event.sample])
        event(i).duration = event(i+1).timestamp - event(i).timestamp;
    end
end

t = 1;
trial = 0;
for i = 1:length([event.sample])
    event(i).trial = trial;
    if t == 1 || t == 5
        event(i).label = 'break';
        t = t + 1;
    elseif t == 2
        event(i).label = 'exp';
        t = t + 1;
    elseif t == 3 || t == 7
        event(i).label = 'flip';
        t = t + 1;
    elseif t == 4
        event(i).label = 'exp_rate';
        t = t + 1;
    elseif t == 6
        event(i).label = 'img';
        t = t + 1;
    else 
        event(i).label = 'img_rate';
        t = 1;
        trial = trial + 1;
    end
    if i < 28 || i > length([event.sample])-3
        event(i).label = [];
        event(i).trial = 0;
        trial = 1;
        t = 1;
    end
end
%%
idx = [];
for e = 1:numel(event)
  if ~isequal(event(e).label, 'img')
    idx = [idx e]; % events to be tossed
  end
end
%%
event(idx)       = [];
imgs            = [event.sample]';

% trial definition
pre              = round(1 * hdr.Fs);
post             = round(3 * hdr.Fs);
cfg.trl          = [imgs-pre imgs+post+1 ones(numel(trigs),1)*-pre]; % 1 seconds before and after trigger onset
% cfg.trl(any(cfg.trl>hdr.nSamples,2),:) = []; % ensure presence of samples

%%
duration = []

%%
% for num = 1:30
%     duration(num,:) = (cfg.trl(num,2)-cfg.trl(num+1,1))/512*-1
% end

for i = 1:length([event.sample])
    event(i).timestamp = event(i).sample / 512;
    if i < length([event.sample])
        event(i).duration = event(i+1).timestamp - event(i).timestamp;
    end
end

%%
for i = 1: length([event.trial])
    if event(i).trial ~= 0
        event_2(i) = event(i)
    end
end
cfg = event;
% first event is 28. Is a fixation cross- maybe call these 'break'
% To delete trials outside 1-64
% cfg(1:27) = [];
%%
t = 1;
trial = 0;
for i = 1:length([event.sample])
    event(i).trial = trial;
    if t == 1 || t == 5
        event(i).label = 'break';
        t = t + 1;
    elseif t == 2
        event(i).label = 'exp';
        t = t + 1;
    elseif t == 3 || t == 7
        event(i).label = 'flip';
        t = t + 1;
    elseif t == 4
        event(i).label = 'exp_rate';
        t = t + 1;
    elseif t == 6
        event(i).label = 'img';
        t = t + 1;
    else 
        event(i).label = 'img_rate';
        t = 1;
        trial = trial + 1;
    end
    if i < 28 || i > length([event.sample])-3
        event(i).label = [];
        event(i).trial = 0;
        trial = 1;
        t = 1;
    end
end

%% TO DO
% Add columns:
% Trial number 1:64
% Category type (expectation, anticipation, etc. - check whiteboard)
% High or low cue
% Picture pair number
% High or low rating
% 

% Dial in threshold for diode? Seems to be consistently a bit slow
%%
% 
% while a < 10
% abs(stim_table.imageJitter(a) - duration(b,b))
% b = b+1
% abs(stim_table.

%% Only iEEG Data
cfg            = [];
cfg.dataset    = eegfile;
cfg.continuous = 'yes';
cfg.viewmode   = 'vertical';
cfg.channel    = ft_channelselection({'all', '-*DC*', '-PR', '-Pleth', '-TRIG', '-OSAT', emptychan{:}, extrachan{:}}, data.label);
data           = ft_preprocessing(cfg);

%% 

event = drop(event.trial == 0)
%%
cfg.channel      = ft_channelselection({'all', '-*DC*', '-PR', '-Pleth', '-TRIG', '-OSAT', '-C2*', eegchan{:}, badchan{:}}, data.label);


%%
data_2 = cfg;


cfg              = [];
cfg.method       = 'mtmconvol';
cfg.toi          = -.9:.1:1.9;
cfg.foi          = 5:80:160;
cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.2;
cfg.taper        = 'hanning';
cfg.output       = 'pow';
cfg.keeptrials   = 'no';
freq             = ft_freqanalysis(cfg, data);
% freq             - ft_freqbaseline(cfg,data)
%%
cfg = [];
cfg.baseline = [-1 -0.1];
cfg.parameter = 'powspctrm';
cfg.baselinetype = 'absolute';
cfg.zlim = [-2 2];
cfg.channel = 'RTA2'; % top figure
% freq             - ft_freqbaseline(cfg,freq)
figure; ft_singleplotTFR(cfg, freq);
