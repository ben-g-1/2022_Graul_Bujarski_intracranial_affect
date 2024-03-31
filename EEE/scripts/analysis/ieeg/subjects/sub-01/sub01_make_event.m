%% Initial Stim Table Analysis

clear all
subjectnum = '01';
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
triggerdir = 'up'; % Upward deflections mean that light is on
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
%%
event(idx) = [];

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
% First on at event 28
% First trial starts around XX seconds 
% Last trial ends around XX seconds
 
starttrial = 28;

if strcmp(starttrial, 0)
    disp("No start trial indicated.")
    return
end

%%%%%%%%

%  IF PHOTODIODE BROKEN OR MISSING RESPONSES
% eventfix = table();
% e = 1;
% % try to fix event
% for i = 2:numel(event)
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

%%
event(:,1:(starttrial-1)) = [];
event = struct2table(event);

%% Fix missing flips %! should loop until all fixed
try
    [event, beforemiss, aftermiss, badrow, trial, rownum] = labelphase(event);
catch
    event = labelphase(event);
    disp("No phase discrepancies flagged.")
end
%%
% Missing flip and rate in trial 9

% Flip duration should be around 0.0830 based on average flip times
% Need to adjust the subsequent break time


% missingflip = 0.0830;
% missingrate = stim_table.val_RT(trial);
% breaktime = event.duration{rownum} - missingflip - missingrate;
% newheight = 3;
% badrow(newheight+1, :) = badrow(1,:);
% badrow(end,:) = [];
% 
% badrow.duration{1} = missingflip;
% badrow.duration{2} = missingrate;
% badrow.duration{3} = breaktime;
% 
% badrow.sample(3) = badrow.sample(1);
% badrow.sample(1) = int64(beforemiss.sample(height(beforemiss)) + (missingflip*hdr.Fs)); %integer instead of scientific notation for later checks
% badrow.sample(2) = int64(badrow.sample(1) + (missingrate*hdr.Fs));
% 
% badrow.type{3} = badrow.type{1};
% badrow.type{2} = [marker, '_', triggerdir];
% badrow.value(2) = 1;
% 
% badrow.timestamp(1:3) = badrow.sample(1:3) / hdr.Fs;
% 
% badrow.trial{1} = [];
% badrow.label{1} = [];
% badrow.phase(1) = 0;
% 
% fixedevent = [beforemiss; badrow; aftermiss];
% 
% event = labelphase(fixedevent);

%% Label sanity checks

if length([event.label]) > 512
    warning('Too many events were labeled. Number of events:')
    disp(length([event.label]))
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

% clearvars -except  event hdr info

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cleanevent, beforemiss, aftermiss, badrow, trial, rownum] = labelphase(event)

t = 1;
trial = 1;
for rownum = 1:512 % only label events inside time 
    event.trial{rownum} = trial;
    if t == 1 || t == 5
        event.label{rownum} = 'break';
        event.phase(rownum) = t;
        t = t + 1;
    elseif t == 2
        event.label{rownum} = 'exp';
        event.phase(rownum) = t;
        t = t + 1;
    elseif t == 3 || t == 7
        event.label{rownum} = 'flip';
        event.phase(rownum) = t;
        t = t + 1;
    elseif t == 4
        event.label{rownum} = 'exp_rate';
        event.phase(rownum) = t;
        t = t + 1;
    elseif t == 6
        event.label{rownum} = 'img';
        event.phase(rownum) = t;
        t = t + 1;
    else 
        event.label{rownum} = 'img_rate';
        event.phase(rownum) = t;
        t = 1;
        trial = trial + 1;
    end

    if strcmp(event.label{rownum}, 'flip') && ...
            event.duration{rownum} > 0.2   && ...
            event.trial{rownum} < 64

        disp(['Timing is off on trial ', num2str(trial)]);
        disp(['Row ' num2str(rownum)]);
        beforemiss = event(1:rownum-1, :);
        aftermiss = event(rownum+1:end, :);
        badrow = event(rownum,:);
        break
    end

    cleanevent = event;
end

end % function:labelphase