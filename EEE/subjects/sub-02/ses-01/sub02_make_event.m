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
%% Adding new group label types
% Positive valence, negative valence, neutral valence
% First thought is neg < 40 neu < 60 < pos
% let's start with binary to keep things simple

for v = 1:height(stim_table)
    % First determine what kind of rating was given- hi, lo
    if stim_table.val_rating(v) >= 50
        stim_table.val_type(v) = 1;
    
    elseif stim_table.val_rating(v) < 50
        stim_table.val_type(v) = -1;

    else 
        stim_table.val_type(v) = 0;
    end
    
    % locate row that pair is on
    pairnum = stim_table.Pair(v);
    pairpair = stim_table.Pair == pairnum;
    for p = 1:numel(pairpair)
        if p == v
            continue
        elseif pairpair(p) == 1
            pairrow = p;
            break % break when match is found on row p
        end
    end % finding pair number
    stim_table.pair_row(v) = pairrow;

    % look for conformity to cue relative to pair rating
    if stim_table.val_rating(v) > stim_table.val_rating(pairrow) ...
            && stim_table.highcue_indx(v) == 1
        
        stim_table.conform(v) = 1;

    elseif stim_table.val_rating(v) < stim_table.val_rating(pairrow) ...
            && stim_table.highcue_indx(v) == -1
        
        stim_table.conform(v) = 1;

    else
        stim_table.conform(v) = 0;
    end %pair conformity 

    % look for surprise in rating, with expectation and valence rating greater than 25%
    if abs(stim_table.exp_rating(v) - stim_table.val_rating(v)) < 25
        stim_table.agree(v) = 1;
    else
        stim_table.agree(v) = 0;
    end % agreement
end
%% Load iEEG Data

%%% iEEG Channels %%%
% 


eegfile = fullfile(datadir, ['EEE_PT-', subjectnum, '_BG.EDF']);

% Find and label unneeded channels
cfg            = [];
cfg.dataset    = eegfile;
cfg.continuous = 'yes';

hdr              = ft_read_header(cfg.dataset);


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
        eventfix.sample(e + 1) = round(eventfix.sample(e) + hdr.Fs * eventfix.duration(e), 6, 'significant'); %match sigfigs
        eventfix.duration(e + 1) = 0.0088;
        eventfix.sample(e + 2) = round(eventfix.sample(e+1) + hdr.Fs * eventfix.duration(e+1), 6, 'significant');
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

%%
clearvars -except longstim event hdr depths chans eegfile stim_table