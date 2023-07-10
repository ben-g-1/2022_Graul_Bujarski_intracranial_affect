%function stim_table = generate_randomized_stim_table(subnum, sesnum, basedir)
% This function generates a subject-specific table with stimuli and cue
% positions (and other meta-data) in pseudorandom order).
%
% Special for EEE
%
% USAGE:
% SET UP PATHS AND LOCATION OF FILE NAME
% ------------------------------------------------------
%%%
subnum = '03';
sesnum = '01';

%% Input Path ID %%% CHANGE basedir MANUALLY, but create other scripts with this organization
basedir = 'C:\Users\bgrau\GitHub\ieeg_affect';
projdir = fullfile(basedir, 'EEE');
filedir = fullfile(projdir, 'files');
scriptdir = fullfile(projdir, 'scripts', 'EVRTask');
subjectnum = subnum;
sessionnum = sesnum;
subjdir = fullfile(projdir, 'subjects', ['sub-',  num2str(subjectnum)]);
sesdir = fullfile(subjdir, ['ses-', num2str(sessionnum)]);

addpath(scriptdir);

% Make sure the subject and session have been created. 
if not(isfolder(subjdir))
   disp('Creating subject directory')
    mkdir(subjdir);
end

addpath(subjdir);
if not(isfolder(sesdir))
    disp('Creating session directory')
    mkdir(sesdir);
end

addpath(sesdir);

fname = fullfile(filedir, 'pair_matrix.xlsx');

if not(isfile(fname))
    disp('The paired file list is missing. Exiting now.')
    return
end
fwritename = fullfile(sesdir,'stim_table.mat');

%PROJ
% 
% GENERATE A RANDOMIZED TABLE
% ------------------------------------------------------
% stim_table = generate_randomized_stim_table(fname)
% 
% SAVE THE TABLE IN A SUBJECT-SPECIFIC FOLDER NAMED WITH THE SUBJECT CODE
% ------------------------------------------------------
% subj_code = 'EEE_001';
% mkdir(subj_code)
% cd(subj_code)
% save stim_table stim_table
% 
% LATER, when you run the experiment, you'll load stim_table for that
% subject
% ------------------------------------------------------
%
% You can check the randomization and properties in various ways.
% Some plots are created in the function - you can copy/paste code to
% re-run here:
% figure; subplot(2, 2, 1); hold on;
% plot(stim_table.cue_mean, stim_table.cue_observed_mean, 'ko'); refline; xlabel('cue mean'); ylabel('subject observed mean');
% refline; 
% wh_high = stim_table.highcue_indx > 0;
% plot(stim_table.cue_mean(wh_high), stim_table.cue_observed_mean(wh_high), 'ko', 'MarkerFaceColor', 'r'); 
% wh_low = stim_table.highcue_indx < 0;
% plot(stim_table.cue_mean(wh_low), stim_table.cue_observed_mean(wh_low), 'ko', 'MarkerFaceColor', 'b'); 
% xlabel('cue mean'); ylabel('subject observed mean');
% 
% subplot(2, 2, 2); hold on;
% plot(stim_table.cue_deviation_from_norm, 'ko'); refline; 
% xlabel('Trial'); ylabel('Cue mean - Picture Norm');
% refline; 
% plot(find(wh_high), stim_table.cue_deviation_from_norm(wh_high), 'ko', 'MarkerFaceColor', 'r'); 
% plot(find(wh_low), stim_table.cue_deviation_from_norm(wh_low), 'ko', 'MarkerFaceColor', 'b'); 
% 
% subplot(2, 2, 3); hold on;
% plot(stim_table.Valence_mean, stim_table.cue_deviation_from_norm, 'ko'); refline; 
% xlabel('Normative valence'); ylabel('Cue mean - Picture Norm');
% refline; 
% plot(stim_table.Valence_mean(wh_high), stim_table.cue_deviation_from_norm(wh_high), 'ko', 'MarkerFaceColor', 'r'); 
% plot(stim_table.Valence_mean(wh_low), stim_table.cue_deviation_from_norm(wh_low), 'ko', 'MarkerFaceColor', 'b'); 
% 
% subplot(2, 2, 4); hold on;
% plot(stim_table.Valence_mean, stim_table.cue_observed_std, 'ko'); refline; 
% xlabel('Normative valence'); ylabel('Cue observed std');
% refline; 
% plot(stim_table.Valence_mean(wh_high), stim_table.cue_observed_std(wh_high), 'ko', 'MarkerFaceColor', 'r'); 
% plot(stim_table.Valence_mean(wh_low), stim_table.cue_observed_std(wh_low), 'ko', 'MarkerFaceColor', 'b'); 


pairtable = readtable(fname);


%% Preliminary identification of pairs

first_indx = pairtable.Half == 1;
second_indx = pairtable.Half == 2;

n1 = sum(first_indx); 
n2 = sum(second_indx); 

if n1 ~= n2, error('WRONG INPUT: unpaired stimuli'), end
npairs = n1;
clear n1 n2

% These are indices for paired images, and will match in order (e.g., 1 in
% each for pair 1, 2 in each for pair 2, etc., as long as the pairs are next to one another in the original list

wh_first = find(first_indx);
wh_second = find(second_indx);

unsorted_pairs_wh = [wh_first wh_second];

%% Assign one member of each pair to be high and low cue at random

unsorted_highlow = [ones(npairs ./ 2, 1); 2*ones(npairs ./ 2, 1)];

wh_rand = randperm(npairs);

sorted_highlow = unsorted_highlow(wh_rand);

% Turn this into a list of -1 for low and 1 for high, in the order of the original images 
% -----------------------------------------------------------------------
% Find the indices of images that are high cues.  
% Take the first image for sorted_highlow==1, and the second image for sorted_highlow==2
wh_highcue = [unsorted_pairs_wh(sorted_highlow == 1, 1) unsorted_pairs_wh(sorted_highlow == 2, 2)];
wh_highcue = wh_highcue(:); % vectorize; order doesn't matter

% Turn them into a vector f ones for high cues
highcue_indx = zeros(2*npairs, 1);
highcue_indx(wh_highcue) = 1;

highcue_indx(highcue_indx == 0) = -1; % all the rest are -1, low cues.
% Could check this code by creating wh_lowcue just as above, and should be
% mutually exclusive with high cues. and check match as you re-randomize

% add this to the table
pairtable.highcue_indx = highcue_indx;

%% Calculate cue means and add to table

mean_shift = .8;  % value by which to shift up or down, in units of original 7-point scale used in Valence_mean

pairtable.cue_mean = pairtable.Valence_mean + mean_shift .* pairtable.highcue_indx;

%% Generate vector of n points for cue lines
% given mean and standard deviations

nlines = 10; % how many lines to generate

cuesd = 0.7; % standard deviation of lines around the cue mean
            % 1.3 may be large and cause more clipping? 

% Store values in cell so we can add them to the table as a vector for each
% image (row) in a single table variable

image_cue_values = cell(2*npairs, 1);
[cue_observed_mean, cue_observed_std] = deal(zeros(2*npairs, 1));

for i = 1:(2*npairs)

     image_cue_vals = pairtable.cue_mean(i, 1) + cuesd * randn(nlines, 1); %  Normal distribution, with std = cuesd

     % Make sure none are outside the range of the scale
     % avoid exact overlaps by jittering a bit
     image_cue_vals(image_cue_vals < 1) = 1 + 0.2 * unifrnd(0, 1, sum(image_cue_vals < 1), 1);
     image_cue_vals(image_cue_vals > 7) = 7 - 0.2 * unifrnd(0, 1, sum(image_cue_vals > 7), 1);

     image_cue_values{i} = image_cue_vals;

     % Save the empirical mean and std of each cue -- which will vary randomly 
     % This is what the subject sees, so is useful in analysis
     cue_observed_mean(i, 1) = mean(image_cue_vals);
     cue_observed_std(i, 1) = std(image_cue_vals);

end

pairtable.image_cue_values = image_cue_values;

pairtable.cue_observed_mean = cue_observed_mean;

pairtable.cue_observed_std = cue_observed_std;


%% Now sort the table rows randomly
% stratifying one member of each pair into first and 2nd half, so the
% paired images don't occur next to one another


wh_rand1 = randperm(npairs);
wh_rand2 = npairs + randperm(npairs);  % 2nd half

trial_order = zeros(size(first_indx)); % initalize

trial_order(first_indx) = wh_rand1;  % random order within first half

trial_order(second_indx) = wh_rand2;  % random order within first half

% Note: if there are any zeros, this is a coding error

pairtable.trial_number = trial_order;

% now sort rows
stim_table = sortrows(pairtable, 'trial_number');

% Calculate potentially useful derivative measures (for convenience)
stim_table.cue_deviation_from_norm = stim_table.cue_observed_mean - stim_table.Valence_mean;

% reorder some columns for convenience

stim_table = movevars(stim_table, 'trial_number', 'Before', 1);
stim_table = movevars(stim_table, 'highcue_indx', 'After', 1);
% stim_table = movevars(stim_table, 'cue_mean', 'After', 'highcue_indx'); % this is the normative mean; the subject sees a random draw around this
stim_table = movevars(stim_table, 'cue_observed_mean', 'After', 'highcue_indx');
stim_table = movevars(stim_table, 'cue_observed_std', 'After', 'cue_mean');
stim_table = movevars(stim_table, 'image_cue_values', 'After', 'cue_observed_std');

%%
figure; subplot(2, 2, 1); hold on;
plot(stim_table.cue_mean, stim_table.cue_observed_mean, 'ko'); refline; xlabel('cue mean'); ylabel('subject observed mean');
refline; 
wh_high = stim_table.highcue_indx > 0;
plot(stim_table.cue_mean(wh_high), stim_table.cue_observed_mean(wh_high), 'ko', 'MarkerFaceColor', 'r'); 
wh_low = stim_table.highcue_indx < 0;
plot(stim_table.cue_mean(wh_low), stim_table.cue_observed_mean(wh_low), 'ko', 'MarkerFaceColor', 'b'); 
xlabel('cue mean'); ylabel('subject observed mean');

subplot(2, 2, 2); hold on;
plot(stim_table.cue_deviation_from_norm, 'ko'); refline; 
xlabel('Trial'); ylabel('Cue mean - Picture Norm');
refline; 
plot(find(wh_high), stim_table.cue_deviation_from_norm(wh_high), 'ko', 'MarkerFaceColor', 'r'); 
plot(find(wh_low), stim_table.cue_deviation_from_norm(wh_low), 'ko', 'MarkerFaceColor', 'b'); 

subplot(2, 2, 3); hold on;
plot(stim_table.Valence_mean, stim_table.cue_deviation_from_norm, 'ko'); refline; 
xlabel('Normative valence'); ylabel('Cue mean - Picture Norm');
refline; 
plot(stim_table.Valence_mean(wh_high), stim_table.cue_deviation_from_norm(wh_high), 'ko', 'MarkerFaceColor', 'r'); 
plot(stim_table.Valence_mean(wh_low), stim_table.cue_deviation_from_norm(wh_low), 'ko', 'MarkerFaceColor', 'b'); 

subplot(2, 2, 4); hold on;
plot(stim_table.Valence_mean, stim_table.cue_observed_std, 'ko'); refline; 
xlabel('Normative valence'); ylabel('Cue observed std');
refline; 
plot(stim_table.Valence_mean(wh_high), stim_table.cue_observed_std(wh_high), 'ko', 'MarkerFaceColor', 'r'); 
plot(stim_table.Valence_mean(wh_low), stim_table.cue_observed_std(wh_low), 'ko', 'MarkerFaceColor', 'b'); 
%% Check some things

errorcount = 0;

bad_table_flag = any(stim_table.Valence_mean > 7 | stim_table.Valence_mean < 1);
if bad_table_flag, error('Some Valence_mean values out of range'); 
    errorcount = errorcount + 1
 end

bad_table_flag = any(stim_table.cue_observed_mean > 7 | stim_table.cue_observed_mean < 1);
if bad_table_flag, error('Some cue_observed_mean values out of range');
    errorcount = errorcount + 1
 end

bad_table_flag = any(stim_table.cue_observed_std  < 0.25);
if bad_table_flag, warning('Some cues have very low std, < 0.25');
    errorcount = errorcount + 1;
 end

bad_table_flag = any(abs(stim_table.cue_deviation_from_norm) > 1.6);
if bad_table_flag, warning('Some cues are very different from the normalized rating')
    errorcount = errorcount + 1;
end

 if errorcount == 1
    warning('Consider rerunning the script')
    errorcount
    return
 elseif errorcount > 1
    warning('Poor randomization. Rerun the script. Exiting now.')
    errorcount
    return
 end
 
%% 
set(gcf,'Units','pixels','Position', [200 200 800 250]);  %# Modify figure size

    frame = getframe(gcf);                   %# Capture the current window
    
    filename = fullfile(sesdir, "stats_vis.jpg");
%     saveas(gcf, append([rand_dir, num2str(k), rand_settings, "_stats_vis.jpg" ]))
    saveas(gcf, filename);
% figure; hold on; plot(stim_table.cue_observed_mean, 'LineWidth', 2)
% refline
% title('Cue observed mean over time');
% ylabel('Observed mean')

%%
% Visual check: Draw lines for each trials
% (Drawing would be done at run-time most likely)
% k = 3; % pick a trial/image number; or loop through all
figure; hold on;

% k=1;
for k = 1:2*npairs
    clf
    hold on;
    set(gcf, 'Color', [0.5 0.5 0.5])
    % Plot background scale elements and text
%     figure('Color', [.5 .5 .5], 'Position', [200 200 800 250]);
    plot([1 7], [0.5 0.5], 'color', 'k','LineWidth', 3);

    strpos = {'Extremely', 'Pleasant'};
    strneg = {'Extremely', 'Unpleasant'};
    text(0.5, -.4, strneg,'color', 'w', 'FontSize', 18)
    text(6.5, -.4, strpos, 'color', 'w','FontSize', 18)
    text(3.6, -.4, 'Neutral', 'color', 'w', 'FontSize', 18)
    plot([1 1], 0.2 * [1 3.7], 'k', 'LineWidth', 3);
    plot([7 7], 0.2 * [1 3.7], 'k', 'LineWidth', 3);
    plot([4 4], 0.2 * [1 3.7], 'k', 'LineWidth', 3);

    % Plot cues (on top)   
    %plot(pairtable.cue_mean(k), 0, 'ko', 'MarkerFaceColor', 'b');  % Note: we would not plot this in the actual experiment
    plot([pairtable.image_cue_values{k} pairtable.image_cue_values{k}]', [zeros(nlines, 1) ones(nlines, 1)]', 'w', 'LineWidth', 1.5);

    set(gca, 'XLim', [0 8], 'YLim', [-1 1])
    axis off
    
    set(gcf,'Units','pixels','Position', [200 200 800 250]);  %# Modify figure size

    frame = getframe(gcf);                   %# Capture the current window
    drawnow
    
    pause(0.1)
end

%%

save(fwritename, 'stim_table')
%end % function

