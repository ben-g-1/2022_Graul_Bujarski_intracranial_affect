%% Initial Stim Table Analysis

subjectnum = '03';
sessionnum = '01';
projdir = 'C:\Users\bgrau\GitHub\ieeg_affect\EEE';
filedir = fullfile(projdir, 'files');
scriptdir = fullfile(projdir, 'scripts', 'EEE_task');
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

sesdir = 'C:\Users\bgrau\Dropbox (Dartmouth College)\2023_Graul_EEE\Data\raw\sub-03\ses-01';
eegfile = fullfile(sesdir, ['EEE_PT-', subjectnum, '_BG.EDF']);

cfg            = [];
cfg.dataset    = eegfile;
cfg.continuous = 'yes';
hdr              = ft_read_header(cfg.dataset);
cfg.channel    = 'all'; %% For first pass
%%
data           = ft_preprocessing(cfg);
beep
%%
% INPUT INITIAL BAD CHANNELS HERE
% Exclusion criteria:
%   Empty
% '-PR', '-Pleth', '-TRIG', '-OSAT'
% '-C*',

% triggerchan = 4; %% Change per subject %%
% DCs = {};
% c = 1;
% for d = 1:16
%     if d == triggerchan
%         continue
%     end
%     chan = strcat('-DC', string(d));
%     chan = convertStringsToChars(chan); 
%     DCs{c} = chan;
%     c = c + 1;
% end

rowcnt = 1;
emptychan = {};
for i = 182:256
    i_str = string(i);
    chan = strcat('-C', i_str);
    chan = convertStringsToChars(chan);
    emptychan{rowcnt} = chan;
    rowcnt = rowcnt + 1;
end
% Index = find(startsWith(data.label,'C'));

%   Scalp EEG
eegchan          = strcat('-', ft_channelselection({'eeg'}, hdr.label));


cfg.channel    = ft_channelselection({'all', '-PR', '-Pleth', '-TRIG', ...
    '-OSAT', '-*DC*' eegchan{:}, emptychan{:}}, hdr.label);
%%

cfg.reref = 'yes';
cfg.refmethod = 'bipolar';
cfg.groupchans = 'yes';

bp_data = ft_preprocessing(cfg, data);
%%
cfg.trialfun = 'trl_singlephase';
cfg.trialdef.pre = 2; % Picture viewing is at T = 0
cfg.trialdef.post = 3;
cfg.trialdef.offset = -2;
cfg.trialdef.event = event_full;
cfg.trialdef.eventvalue = 6;
cfg.keeptrial = 'yes';

cfg = ft_definetrial(cfg);
bp_data = ft_preprocessing(cfg, bp_data);
%%
cfg = [];
ft_databrowser(cfg,bp_data)
% 
% %% Find bad channels
% 
% % Major Drift ['-LTHA6', '-RPAG7', '-RPAG11', '-RFC5', ]
% % LTHA6 is really consistent in strong deviation. Maybe look to see if
% % sinal pattern emerges correlated to any task moment?
% 
% % LTHA11/12, RFC4-6,
% 
% % Minor Drift ['-LTA5', '-RPAG8', '-RPRS13', '-LTA8', '-RPAG3', '-RTF2']
% % Major Spike ['-LTHA1', '-LTHA2', '-RTF4', '-RPRS15', '-LTA2',   
% % Scalp EEG 163:181
% % NOTE THAT FIELDTRIP HAS FUNCTIONALITY TO REMOVE THIS WITH 'eeg' FLAG BELOW
% % scalpchan = {'FP1','F7','T3','T5','O1','F3','C3','P3','FP2','F8','T4','T6','O2','F4','C4','P4','Fz','Cz','Pz'};
% % rm_scalpchan = {'-FP1','-F7','-T3','-T5','-O1','-F3','-C3','-P3','-FP2','F8','-T4','-T6','-O2','-F4','-C4','-P4','-Fz','-Cz','-Pz'};
% % C182:C256 seem empty?
% % C123:128 not empty, but signal is small. Lacking label?
% % All are 'unknown' signal type except scalp EEG, TRIG incorrect as trigger
% eegchan          = strcat('-', ft_channelselection({'eeg'}, data.label));
% 
% badchan = {};


%% Find trials

% Marker is DC4
% Downward deflections mean that light is on


cfg.dataset      = eegfile;

% trigger detection 
hdr              = ft_read_header(cfg.dataset);
event            = ft_read_event(cfg.dataset, 'detectflank', 'both', 'chanindx', find(ismember(hdr.label, 'DC4')));
idx              = [];
for e = 1:numel(event)
  if isequal(event(e).type, 'annotation')
    idx = [idx e]; % events to be tossed
  end
end


%%
event(idx)       = [];


%%
% First on at 786
% End around 1835

% find starting sample 
% 558454/data.fsample
% 786*data.fsample % starts at row 54
% (64*8) + 54 % ends at row 566

event(1:54)      = [];






%%

t = 1;
trial = 0;
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

% Fill Duration Column
for i = 1:length([event.sample])
    event(i).timestamp = event(i).sample / data.fsample;
end
for i = 1:length([event.sample])
    if i < length([event.sample])
        event(i).duration = event(i+1).timestamp - event(i).timestamp;
    end
end

% Now that duration is filled, remove extra rows
event(513:end)   = [];

%% Label sanity checks

if length([event.label]) > 512
    warning('Too many events were labeled. Number of events:')
    height(event)
end

% for i = 1:512
%     if event(i).duration > .05 && event(i).phase == 3 
%         warning('Timing seems to be mismatched.')
%     end
% end
%% Add necessary columns for analysis from stim_table
% Current thought is to add all columns for each trial to each row 
% Maybe too much, but easier to analyze what's needed when pulling 
% rows without overhead. 

% Note that for working with the event table, the row index comes BEFORE
% the dot index

% Columns
% col_names = fieldnames(stim_table);
%% Look at image rating period 
% 
% Compare valence rating reaction times between stim_table and photodiode
% idx = [];
% for e = 1:numel(event)
%   if ~isequal(event(e).label, 'img_rate')
% %   if event(e).trial == 0
%     idx = [idx e]; % events to be tossed
%   end
% end
% 
% event(idx)       = [];
% imgs            = [event.sample]';
% 
% 
% pre              = round(1 * hdr.Fs);
% post             = round(1 * hdr.Fs);
% cfg.trl          = [imgs-pre imgs+post+1 ones(numel(imgs),1)*-pre];
% 
% ft_definetrial(cfg)
%% Move from stim_table

% 
% for e = 1:numel(event)
%     event(e).duration_from_table = stim_table.val_RT(e);
% end
% 
% for e = 1:numel(event)
%     event(e).dur_diff = event(e).duration - event(e).duration_from_table;
% end
%% Only take the image portion of each trial
idx = [];
for e = 1:numel(event)
  if ~isequal(event(e).phase, 6)
%   if event(e).trial == 0
    idx = [idx e]; % events to be tossed
  end
end
pics = event;
pics(idx)       = [];
imgs            = [pics.sample]';

% trial definition
pre              = round(1 * hdr.Fs);
post             = round(3 * hdr.Fs);
cfg.trl          = [imgs-pre imgs+post+1 ones(numel(imgs),1)*-pre]; 
% 1 seconds before and 3 seconds after trigger onset


% Bring columns from stim table
%cfg.trl.trialnumber = stim_table.trial_number

%%
cfg                = [];
cfg.dataset        = eegfile;
cfg.demean         = 'yes';
cfg.baselinewindow = 'all';
cfg.lpfilter       = 'yes';
cfg.lpfreq         = 80;
% cfg.padding        = .5;
% cfg.padtype        = 'data';
cfg.bsfilter       = 'yes';
cfg.bsfiltord      = 3;
cfg.bsfreq         = [59 61; 119 121; 179 181];

data           = [];
data           = ft_preprocessing(cfg);

%%
% Initialize an empty array to store the matching strings
elecs = {};

% Iterate over each cell element
for i = 1:numel(cfg.channel)
    % Check if the current cell element contains '6', but skip if 16
    if ~isempty(strfind(cfg.channel{i}, '16'))
        continue
    elseif ~isempty(strfind(cfg.channel{i}, '6'))
        % If it contains '6', add it to the matching array
        elecs{end+1} = cfg.channel{i};
    end
end

% Display the matching strings
elecs = strrep(elecs, '6', '*');
%%

depths         = elecs;
for d = 1:numel(depths)
    cfg2            = [];
    cfg2.channel    = ft_channelselection(depths{d}, data.label);
    cfg2.reref      = 'yes';
    cfg2.refchannel = 'all';
    cfg2.refmethod  = 'bipolar';
    cfg2.updatesens = 'no';
    reref_depths{d} = ft_preprocessing(cfg2, data);
end

%%
cfge = [];

reref = ft_appenddata(cfg2,reref_depths{:});

%%
ft_databrowser(cfge, data);

%%

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