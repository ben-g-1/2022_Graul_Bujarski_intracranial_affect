% Use if loading script from GitHub
fname = matlab.desktop.editor.getActiveFilename();
fdir = fileparts(fname);
cd(fdir);
cd ..\data
load('pilot_master_long.mat')

%load('C:\Users\bgrau\GitHub\ieeg_affect\EEE\qualtrics\data\pilot_master_long.mat');
%%
subs_cell = {};
design = {};
group_cohort = [];
rownum = 1;
for i = 1:123
    for k = 1:64
        subs_cell{i}(k,:) = [master.img_rate(rownum), master.highcue_indx(rownum), master.img_rate(rownum) .* master.highcue_indx(rownum)];
                % subs_cell{i}(k,:) = [master.Valence_mean(rownum), master.Pair(rownum), master.Valence_mean(rownum) .* master.Pair(rownum)];

        design{i}(k,1) = master.trial(rownum);
        group_cohort(i) = master.Pair(rownum);
                % group_cohort(i) = master.highcue_indx(rownum);

        rownum = rownum + 1;
    end
end
group_cohort = group_cohort';


EffectNames = {'Intercept' 'ValRate' 'CueType' 'ValRate x CueType'};

stats = glmfit_multilevel(design, subs_cell, group_cohort, 'names', EffectNames, 'beta_names', {'Pair Number'}, 'verbose', 'weighted')

% subs_cell = subs_cell(~cellfun('isempty', subs_cell));