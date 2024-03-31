%% Initial Stim Table Analysis

clear all
subjectnum = '08'; 
sessionnum = '01';

%%%%


%%%%
gitdir = 'C:\Users\bgrau\GitHub\ieeg_affect\EEE';
projdir = 'C:\Users\bgrau\Dropbox (Dartmouth College)\2023_Graul_EEE';
scriptdir = fullfile(gitdir, 'scripts', 'analysis');
datadir = fullfile(projdir, 'Data', 'raw', ['sub-',  num2str(subjectnum)], ['ses-', num2str(sessionnum)]);
procdir = fullfile(projdir, 'Data', 'processed', ['sub-',  num2str(subjectnum)]);

eegfile = fullfile(datadir, ['EEE_', subjectnum, '_deidentified.EDF']);
f_all = fullfile(datadir, 'stim_table_full.mat');

addpath(scriptdir);
addpath(datadir);

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

cs = find(contains(stim_table.Properties.VariableNames, 'image_cue_values'));
stim_table(:,cs) = cellfun(@(x) (x-1)/6*100, stim_table{:,cs}, 'UniformOutput', false);

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
%% Identify Event Marker

cfg            = [];
cfg.dataset    = eegfile;
cfg.continuous = 'yes';

hdr              = ft_read_header(cfg.dataset);

cfg.channel = ft_channelselection('DC*', hdr.label);

marker_data = ft_preprocessing(cfg);
%%
%%%%%%%%
marker = 'DC3'; 
% Upward deflections mean that light is XX (on/off)
%%%%%%%%

if strcmp('DCXX', marker)
    cfg = [];
    cfg.ylim = 'maxmin';
    cfg.blocksize = 60;
    ft_databrowser(cfg, marker_data)
end
%% Detect events from photodiode

cfg = [];
cfg.dataset      = eegfile;

% trigger detection 
event            = ft_read_event(cfg.dataset, 'detectflank', 'both', 'chanindx', find(ismember(hdr.label, marker)));
idx              = [];
for e = 1:numel(event)
  if isequal(event(e).type, 'annotation')
    idx = [idx e]; % events to be tossed
  end
end

eventcopy = event;
%%
event = eventcopy;
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
%%%%%%%
% First on at XX
% First trial starts around 715 seconds 
% Last trial ends around 1514 seconds
 
starttrial = 14; %;
trigger_dir = 'up'; % 'down' 'up';
%%%%%%%%

%  IF PHOTODIODE BROKEN OR MISSING RESPONSES
eventfix = table();
e = 1;
% try to fix event
% for i = starttrial:numel(event)-1
%     if event(i).value == 1 && event(i).duration > 4.02 && event(i-1).duration > 0.02
%         eventfix.sample(e) = event(i).sample;
%         eventfix.duration(e) = 4.0117;
%         eventfix.sample(e + 1) = round(eventfix.sample(e) + hdr.Fs * eventfix.duration(e), 6, 'significant'); %match sigfigs
%         eventfix.duration(e + 1) = 0.0088;
%         eventfix.sample(e + 2) = round(eventfix.sample(e+1) + hdr.Fs * eventfix.duration(e+1), 6, 'significant');
%         eventfix.duration(e + 2) = event(i).duration - (eventfix.duration(e) + eventfix.duration(e + 1));
%         e = e + 3;
%     else 
%         eventfix.sample(e) = event(i).sample;
%         eventfix.duration(e) = event(i).duration;
%         e = e + 1;
%     end
% end

% Need to remove artifacts where event is less than 0.01 seconds
% Remove that line, the next line, and make the previous duration the total
% of the duration before, artifact duration, and subsequent duration
% (should be one continuous 'up' or 'down' signal

% FIXME

fix_ii = 1;
for i = starttrial:numel(event) - 1
    if event(i).duration > 0.01
        eventfix(fix_ii) = event(i);
        fix_ii = fix_ii + 1;
    else
        eventfix(fix_ii - 1).duration = eventfix(fix_ii-1).duration + ...
                                        event(i).duration + ...
                                        event(i + 1).duration;
        i = i + 1;
    end
                
end

% eventfix = table2struct(eventfix);
% for i = 1:length([eventfix.sample])
%     eventfix(i).timestamp = eventfix(i).sample / hdr.Fs;
% end
% for i = 1:length([eventfix.sample])
%     if i < length([eventfix.sample])
%         eventfix(i).duration = eventfix(i+1).timestamp - eventfix(i).timestamp;
%     end
% end

%%
% event = eventfix;
event(:,1:(starttrial-1)) = [];
event = struct2table(event);
%%

% event.trial = {}; %FIX
t = 1;
trial = 1;
for i = 1:height(event) % only label events inside time FIX
    event.trial{i} = trial;
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
    event(513:end, :) = [];
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
exp_dur = [comp.duration].';
exp_RT = [comp.exp_RT].';
exp_time = exp_dur - exp_RT;
if sum(abs(exp_time)) > 0.5
    warning('Differences in MATLAB and EEG recording periods are large.')
    disp('Phase: Expectation Ratings')
    disp(sum(abs(exp_time)))
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
val_dur = [comp.duration].';
val_RT = [comp.val_RT].';
val_time = val_dur - val_RT;
if sum(abs(val_time)) > 0.5
    warning('Differences in MATLAB and EEG recording periods are large.')
    disp('Phase: Valence Ratings')
    disp(sum(abs(val_time)))
end

%% Save metadata
cd(procdir)
info = table();
info.subject = subjectnum;
info.trigger_chan = marker;
info.trigger_dir = triggerdir;
% info.missed_trigs = {};  %!
info.task_start = starttrial;
info.val_timing_diff = sum(abs(val_time));
info.exp_timing_diff = sum(abs(exp_time));

save(['sub-' num2str(subjectnum) '_event_info.mat'], "info")
save(['sub-', subjectnum, '_event_clean'], "event")
%%
% clearvars -except longstim event hdr depths chans eegfile stim_table