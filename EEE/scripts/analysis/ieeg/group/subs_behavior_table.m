%%% Making single table for iEEG patients behavioral data

subjs = {'01', '02', '03', '04'};
for sub = 1:4
subj = subjs{sub};

subjdir = 'C:\Users\bgrau\GitHub\ieeg_affect\EEE\subjects';
% C:\Users\bgrau\GitHub\ieeg_affect\EEE\subjects\sub-01\ses-01
datadir = fullfile(subjdir, ['sub-', num2str(subj)], 'ses-01');
cd(datadir)

clear stim_table;
try 
    load('stim_table_full.mat');
catch
    load('stim_table_partial.mat');
end

hi = stim_table.highcue_indx == 1;
lo = ~hi;

% disp(subj);
% h = ttest(stim_table.val_rating(hi), stim_table.val_rating(lo))

if exist('allsubs', 'var') == 0
    allsubs = stim_table;
else 
    allsubs = [allsubs; stim_table];
end

end

disp('all');
hi = allsubs.highcue_indx == 1;
lo = ~hi;
[h,p,ci,stats] = ttest(allsubs.val_rating(hi), allsubs.val_rating(lo))

mean(allsubs.val_rating(hi))
mean(allsubs.val_rating(lo))


%% Violin of Cue Effect by Subject
subj_avg = struct;

for i = 1:numel(unique(pair_table.subj))
    temp_pair = pair_table(pair_table.subj == num2str(i), :);
    subj_avg.hi{i} = mean(temp_pair.hi_val-temp_pair.stim_mean); % center around normative rating within pair
    subj_avg.lo{i} = mean(temp_pair.lo_val-temp_pair.stim_mean);
    % subj_avg.hi{i} = mean(temp_pair.hi_val - 50);
    % subj_avg.lo{i} = mean(temp_pair.lo_val - 50);
end

data_to_plot = {};
data_to_plot{1,1} = cell2mat(subj_avg.lo');
data_to_plot{1,2} = cell2mat(subj_avg.hi');

colors = seaborn_colors(2);

figure; hold on;
barplot_columns(data_to_plot, 'title', 'Cue Effect on Valence Rating With Mean Subject Ratings', 'color', {colors{2}, colors{1}}, 'MarkerSize', 0.5, ...
    'names', {'Lo Cue', 'Hi Cue'}, 'dolines', 'nofigure', 'plotout'); %'dolines', , 'dostars',
ylabel('Valence Rating')
xlabel('Cue Type');
% legend({});

% axis([-1.3 1.3 -1 1])
hold off;