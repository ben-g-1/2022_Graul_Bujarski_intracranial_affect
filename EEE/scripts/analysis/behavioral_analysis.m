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

%%
 load(f_all)

% Comparison points to look at:

% Expectation and rating
% Cue mean and rating
% Normative rating and rating
% Cue mean and expectation
%% Difference between expectation and rating
stim_table.rateDiff = stim_table.exp_rating - stim_table.val_rating;
stim_table.rateDiffRel = stim_table.rateDiff .* stim_table.highcue_indx;

mean(stim_table.rateDiff)
mean(stim_table.rateDiffRel)
mean(abs(stim_table.rateDiff))
% Average difference is very low
% Absolute difference is higher than a standard deviation on average. 
% What does that mean? Does that tell us anything?

st = movevars(stim_table, 'val_rating', 'After', 'cue_observed_mean');
st = movevars(st, 'Valence_mean', 'Before', 'cue_observed_mean');
%% Difference between normative and reported
% No directionality
mean(abs(st.Valence_mean - st.val_rating))
mean(st.Valence_mean - st.val_rating)
st.valenceDiff = (st.val_rating - st.Valence_mean);
st.valenceDiffIdx = abs(st.valenceDiff).*st.highcue_indx;
st.IdxMismatch = st.valenceDiff+st.valenceDiffIdx;
%% Cue and reported
mean(abs(st.val_rating - st.cue_observed_mean))

%% Cue and expected
mean(abs(st.cue_observed_mean - st.exp_rating))

%% Finding difference between rating pairs

sth = st((st.highcue_indx > 0),:);
stl = st((st.highcue_indx < 0),:);
% Organize by pair number
sth = sortrows(sth, 'Pair', 'ascend');
stl = sortrows(stl,"Pair","ascend");

sth.pairdiff = sth.val_rating - stl.val_rating;
sth.expdiff = sth.exp_rating - stl.exp_rating;
sth.cuediff = sth.cue_observed_mean - stl.cue_observed_mean;

%% Vis?

% [h,p] = ttest2(stl.val_rating, sth.val_rating)
% [h,p] = ttest2(sth.cue_observed_mean, stl.cue_observed_mean)%, 'Vartype','unequal')
% [h,p] = ttest2(sth.Valence_mean, stl.Valence_mean, 'Vartype','unequal')
% [h,p] = ttest2(sth.cue_observed_mean, stl.cue_observed_mean)%, 'Vartype','unequal') %%% Significant

[h,p] = ttest2(sth.Valence_mean, sth.val_rating)
[h,p] = ttest2(stl.Valence_mean, stl.val_rating)
[h,p] = ttest2(sth.val_rating, sth.cue_observed_mean)
[h,p] = ttest2(sth.val_rating, sth.cue_observed_mean)
%%
[h,p] = ttest2(sth.exp_rating, stl.exp_rating) %% SIGNIFICANT
[h,p] = ttest2(sth.exp_rating, sth.val_rating)
[h,p] = ttest2(stl.exp_rating, stl.val_rating)

% 
% mean(sth.Valence_mean - stl.Valence_mean)
% mean(sth.val_rating - stl.val_rating) 
%%
[h,p] = ttest2(st.Valence_mean, st.val_rating, 'Vartype', 'unequal')

%% Figure comparing ratings with high and low cue
wh_low = stim_table.highcue_indx < 0;
wh_high = stim_table.highcue_indx > 0;

figure;
subplot(2,2,1); hold on;
plot(stim_table.cue_observed_mean, stim_table.cue_mean, 'ko'); refline; xlabel('subject observed mean'); ylabel('cue mean');
refline; 
plot(stim_table.cue_observed_mean(wh_high), stim_table.cue_mean(wh_high), 'ko', 'MarkerFaceColor', 'r'); 
plot(stim_table.cue_observed_mean(wh_low), stim_table.cue_mean(wh_low),  'ko', 'MarkerFaceColor', 'b'); 
xlabel('subject observed mean'); ylabel('cue mean');

subplot(2,2,2); hold on;
plot(stim_table.val_rating, stim_table.cue_mean, 'ko'); refline; xlabel('subject rated valence'); ylabel('cue normative mean');
refline;
plot(stim_table.val_rating(wh_high), stim_table.cue_mean(wh_high), 'ko', 'MarkerFaceColor', 'r');
plot(stim_table.val_rating(wh_low), stim_table.cue_mean(wh_low), 'ko', 'MarkerFaceColor', 'b'); 

subplot(2,2,3); hold on;
plot(stim_table.val_rating, stim_table.cue_observed_mean,  'ko'); refline; xlabel('subject rated valence'); ylabel('cue observed mean');
refline;
plot(stim_table.val_rating(wh_high), stim_table.cue_observed_mean(wh_high),  'ko', 'MarkerFaceColor', 'r');
plot(stim_table.val_rating(wh_low), stim_table.cue_observed_mean(wh_low), 'ko', 'MarkerFaceColor', 'b'); 
% boxplot([stim_table.val_rating(wh_high), stim_table.val_rating(wh_low)], 'Notch', 'on', 'Labels', {'High Cue', 'Low Cue'}, 'Whisker', 1);
% NOT WORKING % violinplot([stim_table.val_rating(wh_high), stim_table.val_rating(wh_low)], {'High Cue', 'Low Cue'}, 'ShowData', true);
% ylabel('subject rated valence')

subplot(2,2,4); hold on;
% Ideally want this one to quickly show difference in rating per pair.
%   Should it be normalized? 
%   Should the middle point be the mean normative valence OASIS pics?

% plot(stim_table.Pair, stim_table.val_rating, 'ko'); refline; ;
% refline;
xlabel('Subject Rated Valence'); ylabel('Pair Number')
% plot(stim_table.Pair(wh_high), (stim_table.val_rating(wh_high) - stim_table.cue_observed_mean(wh_high)), 'ko', 'MarkerFaceColor', 'r');
% plot(stim_table.Pair(wh_low), (stim_table.val_rating(wh_low) - stim_table.cue_observed_mean(wh_low)), 'ko', 'MarkerFaceColor', 'b');
% plot(stim_table.Pair(wh_high), stim_table.Valence_mean(wh_high), 'ko', 'MarkerFaceColor', 'g')

% figure;
plot((stim_table.val_rating(wh_high)), stim_table.Pair(wh_high), 'ko', 'MarkerFaceColor', 'r'); hold on;

plot((stim_table.val_rating(wh_low)), stim_table.Pair(wh_low), 'ko', 'MarkerFaceColor', 'b');
% plot(((stim_table.Arousal_mean(wh_high) + stim_table.Arousal_mean(wh_low)) / 2), stim_table.Pair(wh_low), 'c*')
%plot(stim_table.Pair(wh_high), (stim_table.Valence_mean_women(wh_high) - stim_table.cue_observed_mean(wh_high)), 'c*', 'MarkerFaceColor', 'g')

%%
figure; hold on;
plot(stim_table.val_rating(wh_high), stim_table.Pair(wh_high), 'ko', 'MarkerFaceColor', 'r');
% plot(stim_table.exp_rating(wh_high), stim_table.Pair(wh_high), 'ko', 'MarkerFaceColor', 'g');
plot(stim_table.cue_observed_mean(wh_high), stim_table.Pair(wh_high), 'ko', 'MarkerFaceColor', 'g');
plot(stim_table.Valence_mean(wh_high), stim_table.Pair(wh_high), 'c*')
%%
figure; hold on;
plot(stim_table.val_rating(wh_low), stim_table.Pair(wh_low), 'ko', 'MarkerFaceColor', 'b');
plot(stim_table.exp_rating(wh_low), stim_table.Pair(wh_low), 'ko', 'MarkerFaceColor', 'g');