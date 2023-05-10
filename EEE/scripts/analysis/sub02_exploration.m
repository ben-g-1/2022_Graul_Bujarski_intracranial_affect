%% Initial Stim Table Analysis

subjectnum = '02';
sessionnum = '01';
projdir = 'C:\Users\bgrau\GitHub\ieeg_affect\EEE';
filedir = fullfile(projdir, 'files');
scriptdir = fullfile(projdir, 'scripts', 'EVRTask');
subjdir = fullfile(projdir, 'subjects', ['sub-',  num2str(subjectnum)]);
sesdir = fullfile(subjdir, ['ses-', num2str(sessionnum)]);
funcdir = fullfile(scriptdir, 'functions');
imagedir = fullfile(filedir, 'oasis_pairs');
fname = 'stim_table.mat';
fpath = fullfile(sesdir, fname);
practice = fullfile(filedir, 'practice', 'practice_images.mat');
practicedir = fullfile(filedir, 'practice');
fpartialfill = fullfile(sesdir, 'stim_table_partial.mat');
f_all = fullfile(sesdir, 'stim_table_full.mat');

addpath(scriptdir);
addpath(funcdir);
addpath(genpath(subjdir));

 load(f_all)

%% Load iEEG Data


subjdir = 'C:\Users\bgrau\GitHub\ieeg_affect\EEE\subjects\sub-02';
sesdir = fullfile(subjdir, 'ses-01', 'ieeg');

eegfile = fullfile(sesdir, 'EEEPT#2.EDF');

% Find and label unneeded channels
cfg            = [];
cfg.dataset    = eegfile;
cfg.continuous = 'yes';
hdr            = ft_read_header(cfg.dataset);
cfg.channel    = ft_channelselection({'all', '-PR', '-Pleth', '-TRIG', ...
    '-OSAT', '-C*'}, hdr.label);
% '-*DC*',
data           = ft_preprocessing(cfg);

%% Downsample data to match other subject- maybe unnecessary?
% cfg.resamplefs  = 1024;
% data            = ft_resampledata(cfg,data);
cfg.channel = []
cfg.channel = ['DC3']
ft_databrowser(cfg, data)
%%

% extrachan = {};
% rowcnt = 1;
% for i = 123:128
%     i_str = string(i);
%     chan = strcat('-C', i_str);
%     chan = convertStringsToChars(chan);
%     extrachan{rowcnt} = chan;
%     rowcnt = rowcnt + 1;
% end
% % 
% rowcnt = 1;
% emptychan = {};
% for i = 182:256
%     i_str = string(i);
%     chan = strcat('-C', i_str);
%     chan = convertStringsToChars(chan);
%     emptychan{rowcnt} = chan;
%     rowcnt = rowcnt + 1;
% end
% eegchan          = strcat('-', ft_channelselection({'eeg'}, data.label));


% Find bad channels
% ft_databrowser(cfg,data)
% LTHA11/12, RFC4-6,
% iEEG Channels
% RPXA*, RPPC*, RPRS*, RPAG*, RTA*, RTHA*, RTF*, RTS*, RIA*, LFC*, RFC*, LTA*, LTHA*
%%
cfg.dataset      = eegfile;

% trigger detection (appear to be 3-sec long)
hdr              = ft_read_header(cfg.dataset);
event            = ft_read_event(cfg.dataset, 'detectflank', 'both', 'chanindx', find(ismember(hdr.label, 'DC2')));
idx              = [];
%%
for e = 1:numel(event)
  if isequal(event(e).type, 'annotation')% | ~isequal(event(e).type, 'DC3_down')
    idx = [idx e]; % events to be tossed
  end
end
%%
% Reverse engineer to find samples that aren't getting picked up
% Correlate timing with theoretical photodiode signal (could do first)
event(idx)       = [];
%%
% To corrolate with stim_table, should look at first image time
% DC Down @ row 14 is start of first break. 311.6685 seconds
event(1:13)    = [];
% Last event is row 371. 1512.4340 seconds. 
% Total time according to photodiode: 20.01 minutes
%%
% Stim table first time recorded: 
st_init = stim_table.exp_init(1) - stim_table.imageJitter(1) - stim_table.fixJitter(1); % 791.2779
% Final time
st_end = stim_table.val_clickTime(64); %19470 e3

st_runtime = (st_end - st_init)/60;
% Total runtime according to stim_table: 19.26 minutes

% Well.... shit.

% Plan of attack:
% Remove all events < 0.02 seconds? Maybe all the way up to 1 second...
%   Does anything relevant happen in less than 1 second of a photodiode?
% Rework labeling function to label viewing/rating periods and breaks
% Then add a break of ~ 0.0088 seconds at 4.117
%%

for i = 1:length([event.sample])
    event(i).timestamp = event(i).sample / data.fsample;
    if i < length([event.sample])
        event(i).duration = event(i+1).timestamp - event(i).timestamp;
    end
end
%%
t = 1;
trial = 1;
for i = 1:length([event.sample])
    event(i).trial = trial;
    if t == 1 || t == 5
        event(i).label = 'break';
        event(i).phase = t;
        t = t + 1;
    elseif t == 2
        event(i).label = 'exp';
        event(i).phase = t;
        t = t + 1;
    elseif t == 3 || t == 7
        event(i).label = 'flip';
        event(i).phase = t;
        t = t + 1;
    elseif t == 4
        event(i).label = 'exp_rate';
        event(i).phase = t;
        t = t + 1;
    elseif t == 6
        event(i).label = 'img';
        event(i).phase = t;
        t = t + 1;
    else 
        event(i).label = 'img_rate';
        event(i).phase = t;
        t = 1;
        trial = trial + 1;
    end
end
%%
idx = [];
for e = 1:numel(event)
  if ~isequal(event(e).label, 'img')
%   if event(e).trial == 0
    idx = [idx e]; % events to be tossed
  end
end

event(idx)       = [];
imgs            = [event.sample]';

% trial definition
pre              = round(1 * hdr.Fs);
post             = round(3 * hdr.Fs);
cfg.trl          = [imgs-pre imgs+post+1 ones(numel(imgs),1)*-pre]; 
% 1 seconds before and 3 seconds after trigger onset
% cfg.trl(any(cfg.trl>hdr.nSamples,2),:) = []; % ensure presence of samples

% Bring columns from stim table
%cfg.trl.trialnumber = stim_table.trial_number

%%
cfg.demean         = 'yes';
cfg.baselinewindow = 'all';
cfg.lpfilter       = 'yes';
cfg.lpfreq         = 200;
% cfg.padding        = .5;
% cfg.padtype        = 'data';
cfg.bsfilter       = 'yes';
cfg.bsfiltord      = 3;
cfg.bsfreq         = [59 61; 119 121; 179 181];

data           = []
data           = ft_preprocessing(cfg);

%%
depths         = {'RPXA*', 'RPPC*', 'RPRS*', 'RPAG*', 'RTA*', 'RTHA*', 'RTF*', 'RTS*', 'RIA*', 'LFC*', 'RFC*', 'LTA*', 'LTHA*'};
for d = 1:numel(depths)
    cfg            = [];
    cfg.channel    = ft_channelselection(depths{d}, data.label);
    cfg.reref      = 'yes';
    cfg.refchannel = 'all';
    cfg.refmethod  = 'bipolar';
    cfg.updatesens = 'no';
    reref_depths{d} = ft_preprocessing(cfg, data);
end

%%
cfg = [];
reref = ft_appenddata(cfg,reref_depths{:});
%%
% ft_databrowser(cfg, data);

cfg              = [];
cfg.method       = 'mtmconvol';
cfg.toi          = -.4:.1:2.4;
cfg.foi          = 1:5:161;
cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.2;
cfg.taper        = 'hanning';
cfg.output       = 'pow';
cfg.keeptrials   = 'no';
freq             = ft_freqanalysis(cfg, reref);

%%
cfg = [];
cfg.baseline = [-1 -0.1];
cfg.parameter = 'powspctrm';
cfg.baselinetype = 'relchange';
cfg.zlim = [-1 3];

for c = 1:numel(reref.label)
    cfg.channel = reref.label{c};
% cfg.channel = reref.label{story(c)}; % top figure
    % freq             - ft_freqbaseline(cfg,freq)
    figure; 
%     hold on
%     xlabel('Time (s)');
%     ylabel('Frequency (Hz)');
    ft_singleplotTFR(cfg, freq);
end
% ft_singleplotER(cfg, freq)
% Interesting: LTHA had decrease in low freq, increase in gamma around .6s
% LTA 1-2 has great 60Hz patch at .6 sec (122)
% Really consistent decrease in low frequency around .6-1.4s for LTA, RFC
% RTF has huge increases in beta power at 1.6 seconds, some in gamma
% Preceded by decrease in all sub-gamma activity
% Huge RTA gamma spike at 1.6 seconds. Early gamma activity in RTA1-2
% Possible seizure during image trial 62, timestamp ~1584
% story = [5 10 25 36 49 59 70 71 80 82 97 115 124 122];
%%
cfg.channel = reref.label{103}; % top figure
% freq             - ft_freqbaseline(cfg,freq)
figure; ft_singleplotTFR(cfg, freq);

%%  Frequency analysis from https://www.fieldtriptoolbox.org/workshop/madrid2019/tutorial_freq/

cfg1 = [];
cfg1.length = 1;
cfg1.overlap = 0;
base_rpt1 = ft_redefinetrial(cfg1, reref);

cfg1.length = 2;
base_rpt2 = ft_redefinetrial(cfg1, reref);

cfg1.length = 4;
base_rpt4 = ft_redefinetrial(cfg1, reref);
%%
cfg2 = [];
cfg2.output  = 'pow';
cfg2.channel = 'all';
cfg2.method  = 'mtmfft';
cfg2.taper   = 'boxcar';
cfg2.foi     = 0.5:1:45; % 1/cfg1.length  = 1;
base_freq1   = ft_freqanalysis(cfg2, base_rpt1);

cfg2.foi     = 0.5:0.5:45; % 1/cfg1.length  = 2;
base_freq2   = ft_freqanalysis(cfg2, base_rpt2);

cfg2.foi     = 0.5:0.25:45; % 1/cfg1.length  = 4;
base_freq4   = ft_freqanalysis(cfg2, base_rpt4);

%%

figure;
hold on;
plot(base_freq1.freq, base_freq1.powspctrm(4,:))
plot(base_freq2.freq, base_freq2.powspctrm(4,:))
plot(base_freq4.freq, base_freq4.powspctrm(4,:))
legend('1 sec window','2 sec window','4 sec window')
xlabel('Frequency (Hz)');
ylabel('absolute power (uV^2)');