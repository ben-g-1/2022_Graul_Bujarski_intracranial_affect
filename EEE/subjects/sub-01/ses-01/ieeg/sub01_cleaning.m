%% Initial Stim Table Analysis

clear all
subjectnum = '01';
sessionnum = '01';
projdir = 'C:\Users\bgrau\GitHub\ieeg_affect\EEE';
filedir = fullfile(projdir, 'assets');
scriptdir = fullfile(projdir, 'scripts', 'EEE_task');
subjdir = fullfile(projdir, 'subjects', ['sub-',  num2str(subjectnum)]);
sesdir = fullfile(subjdir, ['ses-', num2str(sessionnum)]);
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

% iEEG Channels
% RPXA*, RPPC*, RPRS*, RPAG*, RTA*, RTHA*, RTF*, RTS*, RIA*, LFC*, RFC*, LTA*, LTHA*

subjdir = 'C:\Users\bgrau\GitHub\ieeg_affect\EEE\subjects\sub-01';
sesdir = fullfile(subjdir, 'ses-01', 'ieeg');

eegfile = fullfile(sesdir, ['EEE_PT-', subjectnum, '_BG.EDF']);

% Find and label unneeded channels
cfg            = [];
cfg.dataset    = eegfile;
cfg.continuous = 'yes';

hdr              = ft_read_header(cfg.dataset);


%%
extrachan = {}; % at DHMC, channels starting with C are empty.
rowcnt = 1;
for i = 123:128
    i_str = string(i);
    chan = strcat('-C', i_str);
    chan = convertStringsToChars(chan);
    extrachan{rowcnt} = chan;
    rowcnt = rowcnt + 1;
end
 
% Find bad channels
badchan = {'-LTHA6', '-RPAG7', '-RPAG11', '-RFC5','-LTA2', '-LTA5', '-RPAG8', '-RPRS13', '-LTA8', '-RPAG3', '-RTF2','-LTHA1', '-LTHA2', '-RTF4', '-RPRS15'};


rowcnt = 1;
emptychan = {};
for i = 182:256
    i_str = string(i);
    chan = strcat('-C', i_str);
    chan = convertStringsToChars(chan);
    emptychan{rowcnt} = chan;
    rowcnt = rowcnt + 1;
end
eegchan          = strcat('-', ft_channelselection({'eeg'}, hdr.label));

chans    = ft_channelselection({'all', '-PR', '-Pleth', '-TRIG', ...
    '-OSAT', '-*DC*', eegchan{:}, badchan{:}, emptychan{:}, extrachan{:}}, hdr.label);

cfg.channel = chans;

depths         = {'RPXA*', 'RPPC*', 'RPRS*', 'RPAG*', 'RTA*', 'RTHA*', 'RTF*', 'RTS*', 'RIA*', 'LFC*', 'RFC*', 'LTA*', 'LTHA*'};

% ft_databrowser(cfg,data)
% LTHA11/12, RFC4-6,



%% Detect event_fulls from photodiode

event_full            = ft_read_event(cfg.dataset, 'detectflank', 'both', 'chanindx', find(ismember(hdr.label, 'DC3')));
idx              = [];
for e = 1:numel(event_full)
  if isequal(event_full(e).type, 'annotation')% | ~isequal(event_full(e).type, 'DC3_down')
    idx = [idx e]; % event_fulls to be tossed
  end
end

event_full(idx)       = [];

% Calculate timestamps and durations
for i = 1:length([event_full.sample])
    event_full(i).timestamp = event_full(i).sample / hdr.Fs;
end
for i = 1:length([event_full.sample])
    if i < length([event_full.sample])
        event_full(i).duration = event_full(i+1).timestamp - event_full(i).timestamp;
    end
end
%%

t = 1;
trial = 0;
for i = 1:length([event_full.sample])
    event_full(i).trial = trial;
    if t == 1 || t == 5
        event_full(i).label = 'break';
        event_full(i).phase = t;
        t = t + 1;
    elseif t == 2
        event_full(i).label = 'exp';
        event_full(i).phase = t;
        t = t + 1;
    elseif t == 3 || t == 7
        event_full(i).label = 'flip';
        event_full(i).phase = t;
        t = t + 1;
    elseif t == 4
        event_full(i).label = 'exp_rate';
        event_full(i).phase = t;
        t = t + 1;
    elseif t == 6
        event_full(i).label = 'img';
        event_full(i).phase = t;
        t = t + 1;
    else 
        event_full(i).label = 'img_rate';
        event_full(i).phase = t;
        t = 1;
        trial = trial + 1;
    end
    if i < 28 || i > length([event_full.sample])-3
        event_full(i).label = [];
        event_full(i).trial = 0;
        event_full(i).phase = [];
        trial = 1;
        t = 1;
    end
end
%%
% Drop empty rows
idx = [];
for e = 1:numel(event_full)
    if isempty(event_full(e).label)
        idx = [idx e];
    end
end
event_full(idx)     = [];
%%
% Drop redundant columns
event_full = rmfield(event_full, {'offset', 'type', 'value'});

%% Extend stim_table to length of event_full timing
longstim = table();
for i = 1:numel(stim_table.trial_number)
    tbl = table();
    for r = 1:8
        tbl(r,:) = stim_table(i,:);
    end
    longstim = [longstim; tbl];
end

%% Combine

etab = struct2table(event_full);
full = [etab, longstim];
event_full = table2struct(full);

if isequal([event_full.trial], [event_full.trial_number])
    event_full = rmfield(event_full, 'trial_number');
else
    warning('Number of trials between event table and initial table do not match.')
end


%% Create event_full table per trial
% fulltrial = struct;
% for t = 1:64
% fulltrial(t) = event_full(1 + ((t-1)*8));
% fulldur = 0;
% for i = (1 +((t-1)*8)):(8 + ((t-1)*8))
%     dur = event_full(i).duration;
%     fulldur = fulldur + dur;
% end
% fulltrial(t).duration = fulldur;
% end

% fulltrial = rmfield(fulltrial, ['phase'; 'label'; 'trial']);
% f = struct2table(fulltrial);
% f = sortrows(f, 'Pair', 'ascend');
% fulltrial = table2struct(f);
%% Compare length of rating periods


%%% Expectation %%%
comp = event_full;
idx = [];
for e = 1:numel(event_full)
  if ~isequal(event_full(e).phase, 4)
    idx = [idx e]; % event_fulls to be tossed
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
comp = event_full;
idx = [];
for e = 1:numel(event_full)
  if ~isequal(event_full(e).phase, 8)
    idx = [idx e]; % event_fulls to be tossed
  end
end

comp(idx) = [];
a = [comp.duration].';
b = [comp.val_RT].';
c = a - b;
if sum(abs(c)) > 0.5
    warning('Differences in MATLAB and EEG recording periods are large.')
    disp('Phase: Image Ratings')
    disp(sum(abs(c)))
end

%%
clearvars -except longstim event_full hdr depths chans eegfile stim_table