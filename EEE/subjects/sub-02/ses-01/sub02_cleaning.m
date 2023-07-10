%% Initial Stim Table Analysis

clear all
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

f_all = fullfile(sesdir, 'stim_table_full.mat');

addpath(scriptdir);
addpath(funcdir);
addpath(genpath(subjdir));

load(f_all)

 %% Convert ratings to 100 point scale


cs = find(contains(stim_table.Properties.VariableNames, 'mean'));
stim_table{:,cs} = (stim_table{:,cs} - 1)/6*100;

cs = find(contains(stim_table.Properties.VariableNames, 'SD'));
stim_table{:,cs} = (stim_table{:,cs})/6*100;

cs = find(contains(stim_table.Properties.VariableNames, 'std'));
stim_table{:,cs} = (stim_table{:,cs})/6*100;

cs = find(contains(stim_table.Properties.VariableNames, 'difference'));
stim_table{:,cs} = (stim_table{:,cs})/6*100;

cs = find(contains(stim_table.Properties.VariableNames, 'deviation'));
stim_table{:,cs} = (stim_table{:,cs})/6*100;

cs = find(contains(stim_table.Properties.VariableNames, 'rating'));
stim_table{:,cs} = (stim_table{:,cs} - 1)/6*100;

%% Load iEEG Data

%%% iEEG Channels %%%
% 


eegfile = fullfile(datadir, ['EEE_PT-', subjectnum, '_BG.EDF']);

% Find and label unneeded channels
cfg            = [];
cfg.dataset    = eegfile;
cfg.continuous = 'yes';

hdr              = ft_read_header(cfg.dataset);




% rowcnt = 1;
% emptychan = {};
% for i = 167:256
%     i_str = string(i);
%     chan = strcat('-C', i_str);
%     chan = convertStringsToChars(chan);
%     emptychan{rowcnt} = chan;
%     rowcnt = rowcnt + 1;
% end

%   Scalp EEG
eegchan          = strcat('-', ft_channelselection({'eeg'}, hdr.label));


cfg.channel    = ft_channelselection({'all', '-PR', '-Pleth', '-TRIG', ...
    '-OSAT', '-*DC*', '-C*' eegchan{:}}, hdr.label);
%%


%%% Examining Data %%%
% cfg = [];
% cfg.dataset = eegfile;
% cfg.channel    = ft_channelselection({'all', '-PR', '-Pleth', '-TRIG', ...
%     '-OSAT', '-C*' eegchan{:}}, hdr.label);
% data = ft_preprocessing(cfg);
%%% Possible Trigger Channels
% DC2
% DC3

% DC
%

%%
% cfg = [];
% ft_databrowser(cfg, data)



%% Detect events from photodiode


% Marker is DC8
% Upward deflections mean that light is on


cfg.dataset      = eegfile;

% trigger detection 
hdr              = ft_read_header(cfg.dataset);
event            = ft_read_event(cfg.dataset, 'detectflank', 'both', 'chanindx', find(ismember(hdr.label, 'DC8')));
idx              = [];
for e = 1:numel(event)
  if isequal(event(e).type, 'annotation')
    idx = [idx e]; % events to be tossed
  end
end

% Remove all annotations
event(idx)       = [];


% Fill Duration Column
for i = 1:length([event.sample])
    event(i).timestamp = event(i).sample / hdr.Fs;
end
for i = 1:length([event.sample])
    if i < length([event.sample])
        event(i).duration = event(i+1).timestamp - event(i).timestamp;
    end
end

%%
% First on at 355
% End around 1515

% Starts at sample 23

eventfix = table();
e = 1;
% try to fix event
for i = 22:numel(event)-1
    if event(i).value == 1 && event(i).duration > 4.02 && event(i-1).duration > 0.02
        eventfix.sample(e) = event(i).sample;
        eventfix.duration(e) = 4.0117;
        eventfix.sample(e + 1) = eventfix.sample(e) + hdr.Fs * eventfix.duration(e);
        eventfix.duration(e + 1) = 0.0088;
        eventfix.sample(e + 2) = eventfix.sample(e+1) + hdr.Fs * eventfix.duration(e+1);
        eventfix.duration(e + 2) = event(i).duration - (eventfix.duration(e) + eventfix.duration(e + 1));
        e = e + 3;
    else 
        eventfix.sample(e) = event(i).sample;
        eventfix.duration(e) = event(i).duration;
        e = e + 1;
    end
end
%%
eventfix(513:end,:) = [];
event = eventfix;

%%

t = 1;
trial = 1;
for i = 1:numel(event.sample)
    event.trial(i) = trial;
    if t == 1 || t == 5
        event.label{i} = 'break';
        event.phase(i) = t;
        t = t + 1;
    elseif t == 2
        event.label{i} = 'exp';
        event.phase(i) = t;
        t = t + 1;
    elseif t == 3 || t == 7
        event.label{i} = 'flip';
        event.phase(i) = t;
        t = t + 1;
    elseif t == 4
        event.label{i} = 'exp_rate';
        event.phase(i) = t;
        t = t + 1;
    elseif t == 6
        event.label{i} = 'img';
        event.phase(i) = t;
        t = t + 1;
    else 
        event.label{i} = 'img_rate';
        event.phase(i) = t;
        t = 1;
        trial = trial + 1;
    end
end


%% Label sanity checks

if length([event.label]) > 512
    warning('Too many events were labeled. Number of events:')
    length([event.label])
end

%% Extend stim_table to length of event timing
longstim = table();
for i = 1:numel(stim_table.trial_number)
    tbl = table();
    for r = 1:8
        tbl(r,:) = stim_table(i,:);
    end
    longstim = [longstim; tbl];
end

%% Combine

% etab = struct2table(event);
etab = event;
full = [etab, longstim];
event = table2struct(full);


%% Compare length of rating periods

%%% Expectation %%%
comp = event;
idx = [];
for e = 1:numel(event)
  if ~isequal(event(e).phase, 4)
    idx = [idx e]; % events to be tossed
  end
end

comp(idx) = [];
a = [comp.duration].';
b = [comp.exp_RT].';
c = a - b;
if sum(abs(c)) > 0.5
    warning('Differences in MATLAB and EEG recording periods are large.')
    disp('Phase: Expectation Ratings')
    disp(sum(abs(c)))
end

%%% Valence %%%
comp = event;
idx = [];
for e = 1:numel(event)
  if ~isequal(event(e).phase, 8)
    idx = [idx e]; % events to be tossed
  end
end

comp(idx) = [];
a = [comp.duration].';
b = [comp.val_RT].';
c = a - b;
if sum(abs(c)) > 0.5
    warning('Differences in MATLAB and EEG recording periods are large.')
    disp('Phase: Valence Ratings')
    disp(sum(abs(c)))
end
