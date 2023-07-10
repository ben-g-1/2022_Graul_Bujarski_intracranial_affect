%% Import Stim Table and convert to long format

clear all
subjectnum = '02';
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
% Extend stim_table to length of event timing
longstim = table();
for i = 1:numel(stim_table.trial_number)
    tbl = table();
    for r = 1:8
        tbl(r,:) = stim_table(i,:);
    end
    longstim = [longstim; tbl];
end



%% Dummy Timing from stim_table


% dummy = longstim;
% dummy.duration = zeros(512, 1);
% for i = 1:64
%     if i == 1
%         dummy.duration(1) = 1.042480468750000;
%     elseif mod(i, 64) == 0 % IS DIVISIBLE BY 65
%         dummy.duration(1 + (i-1)*8) = (dummy.exp_init(1 + (i-1)*8) - dummy.fixJitter(1 + (i-1)*8) - dummy.imageJitter(1 + (i-1)*8))  - dummy.val_clickTime((i-1)*8);
%     else 
%        dummy.duration(1 + (i-1)*8) = dummy.fixJitter(1 + (i-1)*8) + .5;
%     end
% dummy.duration(2 + (i-1)*8) = dummy.imageJitter(2 + (i-1)*8)+.028;
% dummy.duration(3 + (i-1)*8) = 0.0085;
% dummy.duration(4 + (i-1)*8) = dummy.exp_RT(4 + (i-1)*8) + .008;
% dummy.duration(5 + (i-1)*8) = dummy.fixJitter(5 + (i-1)*8) + .5;
% dummy.duration(6 + (i-1)*8) = dummy.imageJitter(6 + (i-1)*8)+.028;
% dummy.duration(7 + (i-1)*8) = 0.0085;
% dummy.duration(8 + (i-1)*8) = dummy.val_RT(8 + (i-1)*8) + .008;
% end
% for i = 1:64
%     if i == 1
%         dummy.duration(1 + (i-1)*8) = 9.3340;
%     else
%         dummy.duration(1 + (i-1)*8) = dummy.fixJitter(1 + (i-1)*8)+ .5;
%     end
% dummy.duration(2 + (i-1)*8) = dummy.imageJitter(2 + (i-1)*8)+.028;
% dummy.duration(3 + (i-1)*8) = 0.0085;
% dummy.duration(4 + (i-1)*8) = dummy.exp_RT(4 + (i-1)*8) + .008;
% dummy.duration(5 + (i-1)*8) = dummy.fixJitter(5 + (i-1)*8)+ .5;
% dummy.duration(6 + (i-1)*8) = dummy.imageJitter(6 + (i-1)*8)+.028;
% dummy.duration(7 + (i-1)*8) = 0.0085;
% dummy.duration(8 + (i-1)*8) = dummy.val_RT(8 + (i-1)*8) + .008;
% end

%%
%%
dummy = longstim;
dummy.timestamp = zeros(512, 1);
t = 1;
trial = 0;
for i = 1:numel(dummy.trial_number)
    % dummy(i).trial = trial;
    if t == 1 
        if mod(i,65) == 0
            dummy.timestamp(i) = dummy.exp_init(i) - dummy.val_clickTime(i-1);
        else
            dummy.duration(i) = dummy.fixJitter(i);
        end
        t = t + 1;
    elseif t == 2 || t == 6
        dummy.duration(i) = dummy.imageJitter(i);
        t = t + 1;
    elseif t == 3 || t == 7
        dummy.duration(i) = 0.0085;
        t = t + 1;
    elseif t == 4
        dummy.duration(i) = dummy.exp_RT(i);
        t = t + 1;
    elseif t == 5
        dummy.duration(i) = dummy.fixJitter(i);
        t = t + 1;
    elseif t == 8 
        dummy.duration(i) = dummy.val_RT(i);
        t = 1;
    end
end
%%
dummy = longstim;
dummy.duration = zeros(512, 1);
t = 1;
trial = 0;
for i = 1:numel(dummy.trial_number)
    % dummy(i).trial = trial;
    if t == 1 
        if mod(i,65) == 0
            dummy.duration(i) = dummy.exp_init(i) - dummy.val_clickTime(i-1);
        else
            dummy.duration(i) = dummy.fixJitter(i);
        end
        t = t + 1;
    elseif t == 2 || t == 6
        dummy.duration(i) = dummy.imageJitter(i);
        t = t + 1;
    elseif t == 3 || t == 7
        dummy.duration(i) = 0.0085;
        t = t + 1;
    elseif t == 4
        dummy.duration(i) = dummy.exp_RT(i);
        t = t + 1;
    elseif t == 5
        dummy.duration(i) = dummy.fixJitter(i);
        t = t + 1;
    elseif t == 8 
        dummy.duration(i) = dummy.val_RT(i);
        t = 1;
    end
end
%%


for ts = 1:512
    if ts == 1
        % dummy.timestamp(1) = 204.7988;
        dummy.timestamp(ts) = dummy.exp_init(ts) - dummy.imageJitter(ts) - dummy.fixJitter(ts);
    else
        dummy.timestamp(ts) = (dummy.timestamp(ts-1) + dummy.duration(ts - 1));
    end
end
%%
eventtiming = zeros(10,2);
eventtiming(1,1) = event(1).timestamp;
for ts = 2:8
    eventtiming(ts,1) = (event(ts-1).timestamp + event(ts - 1).duration);
end

eventtiming(1:8,2) = dummy.timestamp(1:8);
%%
durations = [event.duration]';
durations(1:13) = [];
idx = durations > 0.001;
% durations = durations(idx);