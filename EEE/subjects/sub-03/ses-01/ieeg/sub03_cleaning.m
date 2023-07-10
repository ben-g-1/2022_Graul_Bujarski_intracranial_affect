%% Initial Stim Table Analysis

clear all
subjectnum = '03';
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

    % look for surprise in rating, with expectation-valence rating greater than 25%
    if abs(stim_table.exp_rating(v) - stim_table.val_rating(v)) < 25
        stim_table.agree(v) = 1;
    else
        stim_table.agree(v) = 0;
    end % agreement
end

%% Load iEEG Data

%%% iEEG Channels %%%
% LFMC*, LFC*, LPPC*, RSMA*, RFC*, RSMAB*, RSMAC*, LSMA* 


eegfile = fullfile(datadir, ['EEE_PT-', subjectnum, '_BG.EDF']);

% Find and label unneeded channels
cfg            = [];
cfg.dataset    = eegfile;
cfg.continuous = 'yes';

hdr              = ft_read_header(cfg.dataset);




rowcnt = 1;
emptychan = {};
for i = 182:256
    i_str = string(i);
    chan = strcat('-C', i_str);
    chan = convertStringsToChars(chan);
    emptychan{rowcnt} = chan;
    rowcnt = rowcnt + 1;
end

%   Scalp EEG
eegchan          = strcat('-', ft_channelselection({'eeg'}, hdr.label));



%%% Example from Patient 1 %%%
% cfg.channel    = ft_channelselection({'all', '-PR', '-Pleth', '-TRIG', ...
%     '-OSAT', '-*DC*', eegchan{:},badchan{:}, emptychan{:}, extrachan{:}}, hdr.label);

% CHANNELS
% 
chans             = ft_channelselection({'all', '-PR', '-Pleth', '-TRIG', ...
    '-OSAT', '-*DC*' eegchan{:}, emptychan{:}}, hdr.label);

depths = {'LSMAB*', 'LFMC*', 'LFCA*', 'LPPC*', 'RSMAB*', 'RSMAC*', 'RSMA*',  ...
      'LSMA*', 'RFMC*', 'RPC*', 'RPPC*', 'RFCA*', 'RFOA*', 'RFOB*', ...
     'RFA*', 'RFC*', 'LFC*', 'LPC*'};

cfg.channel    =  chans;

%% Detect events from photodiode


% Marker is DC4
% Downward deflections mean that light is on


cfg.dataset      = eegfile;

% trigger detection 
% hdr              = ft_read_header(cfg.dataset);
event            = ft_read_event(cfg.dataset, 'detectflank', 'both', 'chanindx', find(ismember(hdr.label, 'DC4')));
idx              = [];
for e = 1:numel(event)
  if isequal(event(e).type, 'annotation')
    idx = [idx e]; % events to be tossed
  end
end

event(idx)       = [];


%%
% First on at 786
% End around 1835

% find starting sample 
% 558454/hdr.fsample
% 786*hdr.fsample % starts at row 54
% (64*8) + 54 % ends at row 566

event(1:54)      = [];






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
% Fill Duration Column
for i = 1:length([event.sample])
    event(i).timestamp = event(i).sample / hdr.Fs;
end
for i = 1:length([event.sample])
    if i < length([event.sample])
        event(i).duration = event(i+1).timestamp - event(i).timestamp;
    end
end

% Now that duration is filled, remove extra rows
event(513:end)   = [];

%%
% Drop empty rows
% idx = [];
% for e = 1:numel(event_full)
%     if isempty(event_full(e).label)
%         idx = [idx e];
%     end
% end
% event_full(idx)     = [];
%%
% Drop redundant columns
event_full = rmfield(event, {'offset', 'type', 'value'});

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

% %% Extend stim_table to length of event timing
% longstim = table();
% for i = 1:numel(stim_table.trial_number)
%     tbl = table();
%     for r = 1:8
%         tbl(r,:) = stim_table(i,:);
%     end
%     longstim = [longstim; tbl];
% end



%% Label sanity checks

if length([event_full]) > 512
    warning('Too many events were labeled. Number of events:')
    length([event_full])
end
%% Compare length of rating periods

%%% Expectation %%%
comp = event_full;
idx = [];
for e = 1:numel(event_full)
  if ~isequal(event_full(e).phase, 4)
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
comp = event_full;
idx = [];
for e = 1:numel(event_full)
  if ~isequal(event_full(e).phase, 8)
    idx = [idx e]; % events to be tossed
  end
end

comp(idx) = [];
a = [comp.duration].';
b = [comp.val_RT].';
c = a - b;
if sum(abs(c)) > 0.5
    warning('Differences in MATLAB and EEG recording periods are large.')
    disp('Phase: Expectation Ratings')
    disp(sum(abs(c)))
end

clearvars -except longstim event_full hdr depths chans eegfile stim_table