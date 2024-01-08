%%% Creating Summary of Qualtrics Pilot Data

% By Ben Graul
% 11/9/23

% full = readtable('https://raw.githubusercontent.com/ben-g-1/Psyc178/main/pilot_clean.csv');
full = readtable('C:\Users\bgrau\GitHub\ieeg_affect\EEE\qualtrics\data\pilot_clean_NaNs.csv');
data = table();
data.subj = categorical(full.subj);
data.Pair = categorical(full.Pair);
data.Image = categorical(full.Image);
data.Theme = full.Theme;
% data.val_type = categorical(full.val_type);
% data.Half = categorical(full.Half);
data.img_rate = full.img_rate;
data.exp_rate = full.exp_rate;
data.Valence_mean = full.Valence_mean;
data.cue_mean = full.cue_observed_mean;
data.group = categorical(full.group);
data.highcue_indx = categorical(full.highcue_indx); 
data.norm_val = full.Valence_mean - mean(full.Valence_mean);
data.norm_cue = full.cue_observed_mean - mean(full.cue_observed_mean,  "omitmissing");

% querying highcue type difficult

% Normalize scale around normative image mean 
data.ic_img_rate = full.img_rate - full.Valence_mean;
    data.ic_img_rate = data.ic_img_rate - mean(data.ic_img_rate, "omitmissing");
data.ic_exp_rate = full.exp_rate - full.cue_observed_mean;
    data.ic_exp_rate;
data.zc_img_rate = full.img_rate - 50;
data.mc_img_rate = full.img_rate - mean(full.img_rate, "omitmissing");

%% Standardizing data
sdata = table();
sdata.img_rate = (data.img_rate - mean(data.img_rate, "omitmissing"))/std(data.img_rate, "omitmissing");
sdata.exp_rate = (data.img_rate - mean(data.exp_rate, "omitmissing"))/std(data.exp_rate, "omitmissing");
% sdata.img_rate = data.img_rate;
sdata.Valence_mean = (data.Valence_mean - mean(data.Valence_mean))/std(data.Valence_mean);
sdata.cue_observed_mean = (data.cue_mean -mean(data.cue_mean))/std(data.cue_mean);
sdata.Pair = data.Pair;
sdata.highcue_indx = data.highcue_indx;
sdata.subj = data.subj;
sdata.Image = data.Image;
sdata.group = data.group;
sdata.Theme = data.Theme;

%% Alternate way with existing functions
zdata = table();
zdata.subj = data.subj;
zdata.Pair = data.Pair;
zdata.Image = data.Image;
zdata.img_rate = zscore(data.img_rate);
zdata.Valence_mean = zscore(data.Valence_mean);

%% Deal with floor/ceiling effect by removing extreme scores...?
d = data(data.img_rate > 0,:);
d = d(d.img_rate < 100, :);
%% Create Pair Table
sorted = sortrows(data,"Pair","ascend");

cuehl = sorted.highcue_indx;
cuemean = sorted.cue_mean;
pair = sorted.Pair;
rating = sorted.mc_img_rate; %%%%%%%%%%%%%
stimmean = sorted.Valence_mean;

wh_high = cuehl == '1';
wh_low = cuehl == '-1';

hi_table = sorted(wh_high, :);
lo_table = sorted(wh_low, :);

pair_table = table();

pair_table.subj = hi_table.subj;
pair_table.group = hi_table.group;
pair_table.Pair = hi_table.Pair;

pair_table.hi_val = hi_table.img_rate;
pair_table.lo_val = lo_table.img_rate;
pair_table.hi_exp = hi_table.exp_rate;
pair_table.lo_exp = lo_table.exp_rate;
pair_table.val_mean = (hi_table.img_rate + lo_table.img_rate)/2;
pair_table.exp_mean = (hi_table.exp_rate + lo_table.exp_rate)/2;
pair_table.cue_mean = (hi_table.cue_mean + lo_table.cue_mean)/2;
% pair_table.cue_sd = (hi_table.cue_observed_std + lo_table.cue_observed_std)/2;
pair_table.stim_mean = (hi_table.Valence_mean + lo_table.Valence_mean)/2;
% pair_table.stim_sd = (hi_table.Valence_SD + lo_table.Valence_SD)/2;
pair_table.val_diff = hi_table.img_rate - lo_table.img_rate;
pair_table.stim_diff = (hi_table.Valence_mean - lo_table.Valence_mean);
pair_table.norm_hi = pair_table.hi_val - pair_table.val_mean;
pair_table.norm_lo = pair_table.lo_val - pair_table.val_mean;
pair_table.exp_hi = pair_table.hi_exp - pair_table.exp_mean;
pair_table.exp_lo = pair_table.lo_exp - pair_table.exp_mean;
pair_table.rating_diff = pair_table.val_mean - pair_table.exp_mean;


%% Extract Pair Names
pair_names = unique(sorted.Theme);
pair_names = regexprep(pair_names, '[0-9_]', '');
pair_names = pair_names(1:2:64);
pair_names{14} = 'HappyDog';
pair_names{15} = 'SadDog';

%% Simple Comparison of Cue Effect for each Pair
meanpair = table('Size', [32 5], 'VariableNames', {'mean_hi', 'mean_lo', 'hi_sd', 'lo_sd', 'pair'}, 'VariableTypes', {'double', 'double', 'double', 'double', 'double'});
for i = 1:32
    h = pair_table.hi_val(pair_table.Pair == string(i));
    l = pair_table.lo_val(pair_table.Pair == string(i));
    meanpair{i,1} = mean(h, 'omitmissing');
    meanpair{i,2} = mean(l, 'omitmissing');
    meanpair{i,3} = std(h, 'omitmissing')/sqrt(numel(h));
    meanpair{i,4} = std(l, 'omitmissing')/sqrt(numel(l));
    meanpair{i,5}  = i;
end

meanpair = sortrows(meanpair,"mean_lo","ascend");
means_hi = meanpair.mean_hi;
means_lo = meanpair.mean_lo;
stds_hi = meanpair.hi_sd;
stds_lo = meanpair.lo_sd;

% Creating a plot with error bars
figure;
errorbar(1:numel(means_hi), means_hi, stds_hi, 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'b'); % Error bars for 'hi' values
hold on;
errorbar(1:numel(means_lo), means_lo, stds_lo, 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'r'); % Error bars for 'lo' values

% Adding labels and title
xlabel('Pair');
ylabel('Value');
title('Mean Pair Values with Standard Error');
legend('Mean hi values', 'Mean lo values');
%%
% Simple Comparison of Cue Effect for each Pair
meanpair = table('Size', [32 5], 'VariableNames', {'mean_hi', 'mean_lo', 'hi_sd', 'lo_sd', 'pair'}, 'VariableTypes', {'double', 'double', 'double', 'double', 'double'});
for i = 1:32
    h = pair_table.hi_val(pair_table.Pair == string(i));
    l = pair_table.lo_val(pair_table.Pair == string(i));
    meanpair{i,1} = mean(h, 'omitmissing');
    meanpair{i,2} = mean(l, 'omitmissing');
    meanpair{i,3} = std(h, 'omitmissing') / sqrt(numel(h));
    meanpair{i,4} = std(l, 'omitmissing') / sqrt(numel(l));
    meanpair{i,5}  = i;
end

meanpair = sortrows(meanpair, 'mean_lo', 'ascend');
means_hi = meanpair.mean_hi;
means_lo = meanpair.mean_lo;
stds_hi = meanpair.hi_sd;
stds_lo = meanpair.lo_sd;

% Calculate t-distribution critical value for a one-sided 95% confidence interval
t_critical = tinv(0.95, numel(h) - 1); % Assuming a one-tailed distribution

% Creating a plot with error bars
figure;
errorbar(1:numel(means_hi), means_hi, t_critical * stds_hi, 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'b'); % Error bars for 'hi' values
hold on;
errorbar(1:numel(means_lo), means_lo, t_critical * stds_lo, 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'r'); % Error bars for 'lo' values

% Adding labels and title
xlabel('Pair');
ylabel('Value');
title('Mean Pair Values with 95% One-Sided Confidence Interval');
legend('Mean hi values', 'Mean lo values');

%% Histograms of Ratings
% 'Normalization', 'probability',
colors = seaborn_colors(16);

edges = -50:5:50;
f = figure;
histogram(data.mc_img_rate(data.highcue_indx == "1"), edges, 'FaceColor', colors{16}, 'FaceAlpha', 0.8, 'EdgeColor', 'auto');
hold on;
histogram(data.mc_img_rate(data.highcue_indx == "-1"), edges, 'FaceColor', colors{12}, 'FaceAlpha', 0.6, 'EdgeColor', 'auto');
legend({"High Cue", "Low Cue"})
xlabel("Valence Rating")
title("Distribution of Subject Valence Ratings")
hold off;


%% no floor/ceiling
% 
% figure;
% histogram(d.img_rate(d.highcue_indx == "1"), edges, 'FaceColor', colors{16}, 'FaceAlpha', 0.8, 'EdgeColor', 'auto');
% hold on;
% histogram(d.img_rate(d.highcue_indx == "-1"), edges, 'FaceColor', colors{12}, 'FaceAlpha', 0.6, 'EdgeColor', 'auto');
% hold off;
%%
edges = -2:.1:2;
figure;
histogram(sdata.img_rate(data.highcue_indx == "1"), edges, 'Normalization', 'probability','FaceColor', colors{16}, 'FaceAlpha', 0.8, 'EdgeColor', 'auto');
hold on;
histogram(sdata.img_rate(data.highcue_indx == "-1"), edges, 'Normalization', 'probability','FaceColor', colors{12}, 'FaceAlpha', 0.6, 'EdgeColor', 'auto');
hold off;

legend({"High Cue", "Low Cue"})
title("Distribution of Subject Valence Ratings")
%%
% figure;
% histogram(data.img_rate, edges, 'FaceColor', 'blue', 'FaceAlpha', 0.2, 'EdgeColor', 'none'); %'Normalization', 'probability'
edges = -83:5:85;

figure;
histogram(data.ic_img_rate(data.highcue_indx == "-1"), edges, 'FaceColor', 'blue', 'EdgeColor', 'auto');
hold on;
histogram(data.ic_img_rate(data.highcue_indx == "1"), edges,'FaceColor', 'red', 'EdgeColor', 'auto');
hold off;

title('Subject Ratings Relative to Normative Image Rating')
ylabel('Count')
xlabel('Valence Rating')

set(gca, 'FontSize', 30)
%%
% Normative val normalized hist
figure;
edges = -83:5:85;
subplot(1,2,1);
histogram(data.ic_img_rate(data.highcue_indx == "-1"), edges, 'FaceColor', 'blue', 'EdgeColor', 'auto');
title('Distribution of Cue Effect')
hold on;
histogram(data.ic_img_rate(data.highcue_indx == "1"), edges,'FaceColor', 'red', 'EdgeColor', 'auto');
hold off;
ylabel('Count')
xlabel('Valence Rating')
ax2 = subplot(1,2,2);
% histogram(data.ic_img_rate, edges, 'Normalization', 'probability','FaceColor', 'green', 'FaceAlpha', 0.8, 'EdgeColor', 'none');
histfit(ax2, data.ic_img_rate, 34)
title('Distribution Comparison to Normal Dist')
ylabel('Count')
xlabel('Valence Rating')
%%
% Center scale around 0 by subtracting 50
% This is not easy to interpret
% data.zc_img_rate = data.img_rate - 50;
% data.zc_exp_rate = data.exp_rate - 50;
% data.zc_norm_mean = data.Valence_mean - 50;

%%
% hicue_val = (data.ic_img_rate(data.highcue_indx == '1'));
% locue_val = (data.ic_img_rate(data.highcue_indx == '-1'));
% hicue_val = (data.img_rate(data.highcue_indx == '1'));
% locue_val = (data.img_rate(data.highcue_indx == '-1'));
hicue_val = (data.zc_img_rate(data.highcue_indx == '1'));
locue_val = (data.zc_img_rate(data.highcue_indx == '-1'));

%% Overall Cue Effect
data_to_plot = {locue_val, hicue_val};
colors = seaborn_colors(2);

figure;
subplot(1,2,1);
barplot_columns(data_to_plot, 'title', 'Cue Effect on Valence Rating', 'colors', {colors{2}, colors{1}}, 'MarkerSize', 0.3, ...
    'names', {'Low Cue', 'High Cue'}, 'nofigure', 'nostars');
hold on;
ylabel('Valence Rating')
xlabel('Cue Type');
title('Rating Comparison by Cue Type')
hold off;

data_to_plot = {hicue_val - locue_val};
colors = seaborn_colors(4);

subplot(1,2,2);
title('Difference Between Ratings Due to Cue Type')
barplot_columns(data_to_plot, 'title', 'Cue Effect on Valence Rating', 'colors', colors{4}, 'MarkerSize', 0.3, ...
    'names', {'Diff'}, 'nofigure');
hold on;
ylabel('Valence Rating')
xlabel('Diff');
hold off;

%% Violin of Cue Effect by Subject
subj_avg = struct;

for i = 1:numel(unique(pair_table.subj))
    temp_pair = pair_table(pair_table.subj == num2str(i), :);
    % subj_avg.hi{i} = mean(temp_pair.hi_val-temp_pair.stim_mean); % center around normative rating within pair
    % subj_avg.lo{i} = mean(temp_pair.lo_val-temp_pair.stim_mean);
    subj_avg.hi{i} = mean(temp_pair.hi_val, "omitmissing");
    subj_avg.lo{i} = mean(temp_pair.lo_val, "omitmissing");
end

data_to_plot = {};
data_to_plot{1,1} = cell2mat(subj_avg.lo');
data_to_plot{1,2} = cell2mat(subj_avg.hi');

colors = seaborn_colors(2);

figure; hold on;
barplot_columns(data_to_plot, 'title', 'Cue Effect on Valence Rating With Mean Subject Ratings', 'color', {colors{2}, colors{1}}, 'MarkerSize', 0.5, ...
    'names', {'Lo Cue', 'Hi Cue'}, 'dolines', 'nofigure', 'plotout', 'dorob', 'nostars', 'nobars'); %'dolines', , 'dostars',
ylabel('Valence Rating')
xlabel('Cue Type');
% legend({});

% axis([-1.3 1.3 -1 1])
hold off;

%% Violin of Cue Effect by Group

figure;

% High - Low by group

data_to_plot = {};
for i = 1:4
    data_to_plot{1,i} = (data.ic_img_rate(data.highcue_indx == '1' & data.group == string(i))) - (data.ic_img_rate(data.highcue_indx == '-1' & data.group == string(i))); %diff between groups

end

colors = seaborn_colors(4);

subplot(2,1,1); hold on;
barplot_columns(data_to_plot, 'title', 'Cue Effect on Valence Rating By Group', 'color', {colors{1} colors{2} colors{3} colors{4}}, 'MarkerSize', 0.3, ...
    'names', {'1', '2', '3', '4'}, 'dostars', 'nofigure', 'plotout');
ylabel('Valence Rating')
xlabel('Group Name');
hold off;

% By Subgroup

data_to_plot = {};
g = 1;
for i = 1:4
    data_to_plot{1,i} = data.ic_img_rate(data.highcue_indx == '-1' & data.group == string(g)); %low groups
    data_to_plot{1,i+4} = (data.ic_img_rate(data.highcue_indx == '1' & data.group == string(g))); %high groups
    g = g + 1;
end

colors = seaborn_colors(4);

subplot(2,1,2); hold on;
barplot_columns(data_to_plot, 'title', 'Cue Effect on Valence Rating By Group and Cue type', 'color', {colors{1} colors{1}/2 colors{2} colors{2}/2 colors{3} colors{3}/2 colors{4} colors{4}/2}, 'MarkerSize', 0.3, ...
    'names', {'1L', '1H', '2L', '2H', '3L', '3H', '4L', '4H'}, 'nostars', 'nofigure', 'plotout');
ylabel('Valence Rating')
xlabel('Group Name');
hold off;




%% Standardized
% 
% data_to_plot = {};
% g = 1;
% for i = 1:2:8
%     data_to_plot{1,i} = sdata.img_rate(data.highcue_indx == '1' & data.group == string(g));
%     data_to_plot{1,i+1} = (sdata.img_rate(data.highcue_indx == '-1' & data.group == string(g)));
%     g = g + 1;
% end
% 
% 
% 
% colors = seaborn_colors(4);
% 
% subplot(2,1,1); 
% gcf; hold on;
% barplot_columns(data_to_plot, 'title', 'Cue Effect on Valence Rating Does Not Depend on Cue-Image Pairing', 'color', {colors{1} colors{1} colors{2} colors{2} colors{3} colors{3} colors{4} colors{4}}, 'MarkerSize', 0.3, ...
%     'names', {'1H', '1L', '2H', '2L', '3H', '3L', '4H', '4L'}, 'dostars',  'nofigure');
% ylabel('Valence Rating')
% xlabel('Group Name');
% hold off;
%% Not groupwise

% data_to_plot = {};
% 
% data_to_plot{1,2} = data.zc_img_rate(data.highcue_indx == '1');
% data_to_plot{1,1} = data.zc_img_rate(data.highcue_indx == '-1');
% 
% colors = seaborn_colors(2);
% 
% figure; gcf;
% barplot_columns(data_to_plot, 'title', 'Cue Effect on Valence Rating', 'color', colors, 'MarkerSize', 0.5, ...
%     'names', {'Low Cue', 'High Cue'}, 'dostars', 'nofigure'); % 'dolines',
% ylabel('Valence Rating')
% xlabel('Group Name');
% set(gca, "FontSize", 30)
% hold off;

%%
% 
% data_to_plot = {};
% 
% data_to_plot{1,2} = sdata.img_rate(data.highcue_indx == '1');
% data_to_plot{1,1} = sdata.img_rate(data.highcue_indx == '-1');
% 
% colors = seaborn_colors(2);
% 
% figure; gcf;
% barplot_columns(data_to_plot, 'title', 'Cue Effect on Valence Rating', 'color', colors, 'MarkerSize', 0.5, ...
%     'names', {'Low Cue', 'High Cue'}, 'dostars', 'dolines', 'nofigure');
% ylabel('Valence Rating')
% xlabel('Group Name');
% hold off;
%% Fig for all subjects


%% DOWNLOAD COCOAN LAB TOOLBOX
% plot_specificity_box()

%Gramm 
% g1.facet for individual subjects

%% Find average difference across pairs
data_to_plot = {};
for p = 1:16
    data_to_plot1{1,p} = pair_table.val_diff(pair_table.Pair == string(p));
end
for p = 17:32
    data_to_plot2{1,p-16} = pair_table.val_diff(pair_table.Pair == string(p));
end

colors = seaborn_colors(16);

figure; subplot(2,1,1);
barplot_columns(data_to_plot1, 'title', 'Cue Effect By Image Pair', 'color', colors, 'MarkerSize', 0.5, 'names', {pair_names{1:16}}, 'stars', 'dostars', 'plotout', 'nofigure')

ylabel('Difference from Cue Effect')
xlabel('Pair Name');
hold on;

subplot(2,1,2)
barplot_columns(data_to_plot2, 'title', "-", 'color', colors, 'MarkerSize', 0.5, 'names', {pair_names{17:32}}, 'stars', 'dostars', 'plotout', 'nofigure')

ylabel('Difference from Cue Effect')
xlabel('Pair Theme');
hold off;
%, ...    % 'names', {'1A', '1B', '2A', '2B', '3A', '3B', '4A', '4B'}, 'nostars');





%%

%% Linear Mixed Models

% These focus in on the cue effect. The ic_img_rate is the rating for each
% image RELATIVE TO ITS NORMATIVE RATING. This is mean centered at 0.

% qfx.minlm = fitlm(data,'ic_img_rate ~  highcue_indx*norm_val');
qfx.sublmm = fitlme(data, 'zc_img_rate ~ highcue_indx + (highcue_indx|subj)', 'FitMethod', 'REML');
% qfx.pairlmm = fitlme(data, 'ic_img_rate ~ highcue_indx*norm_val + (1|Pair)', 'FitMethod', 'REML');
% qfx.pairimglmm = fitlme(data, 'ic_img_rate ~ highcue_indx*norm_val + (1|Pair:Image)', 'FitMethod', 'REML');
% qfx.subpairimglmm = fitlme(data, 'ic_img_rate ~ highcue_indx*norm_val + (highcue_indx*norm_val | subj) + (1|Pair:Image)', 'FitMethod', 'REML');
% qfx.plus_lmm = fitlme(data, 'ic_img_rate ~ highcue_indx + norm_val + (highcue_indx + norm_val | subj) + (1|Pair) + (1|Pair:Image)', 'FitMethod', 'REML');
% qfx.full_lmm = fitlme(data, 'ic_img_rate ~ highcue_indx*norm_val + (highcue_indx*norm_val | subj) + (1|Pair) + (1|Pair:Image)', 'FitMethod', 'REML');

% qfx.quad_lmm = fitlme(data, 'ic_img_rate ~ highcue_indx*norm_val^2 + (highcue_indx*norm_val^2 | subj) + (1|Pair) + (1|Pair:Image)', 'FitMethod', 'REML'); % Never converges and crashes MATLAB
% exfx.min = fitlme(data, 'img_rate ~ 1 + Valence_mean + exp_rate + (highcue_indx |subj)')

% These might have some redundant terms. 
% z = fitlme(data, 'img_rate ~ 1 + exp_rate + highcue_indx + (1|highcue_indx) + (1 | subj) + (1 | Pair) + (1|Pair:Image)')
%% LMM Diagnostics

%%%
lm = qfx.full_lmm;
numboot = 1000;
%%%

figure();
plotResiduals(lm, 'fitted')
figure();
plotResiduals(lm, 'probability')
figure();
plotResiduals(lm, 'lagged')

% numel(find(residuals(centlmm)>0.25))

% Color code by subj?

% figure();
% gscatter(F,R,data.group)


r1 = residuals(lm, 'Conditional', false); % only fixed effects
subplot(1,2,1); histfit(r1)
title('Fixed Effects Only')

r2 = residuals(lm, 'Conditional', true); % fixed and random effect
subplot(1,2,2); histfit(r2)
title('Fixed and Random Effects')



figure;
pr = residuals(lm,'ResidualType','Pearson');
st = residuals(lm,'ResidualType','Standardized');
X = [r1 r2 pr st];
boxplot(X,'labels',{'Fixed', 'Full', 'Pearson','Standardized'})

r = residuals(lm);

numel(find(r > mean(r,'omitnan') + 2.5*std(r,'omitnan')))
numel(find(r < mean(r,'omitnan') - 2.5*std(r,'omitnan')))

% Check the QQ plot with the Shapiro-Wilk test
% Takes a maximum of 5000 values, so will bootstrap 

% lownum = 1;
% lmqq = table();
% for i = 1:numboot
%     rsamp = datasample(r, 4999, 'replace', false);
%     [H, pValue, SWstatistic] = swtest(rsamp, 0.05);
%         if SWstatistic < 0.98
%             lmqq(lownum, 1) = {SWstatistic};
%             lownum = lownum + 1;
%         end % if stat low
% end % boot test
% mean(lmqq)

anova(lm, 'dfmethod', 'satterthwaite')
% beep on; beep


%%
test.sub = fitlme(data, 'ic_img_rate ~ highcue_indx*norm_val + (1|subj)', 'FitMethod', 'REML');

[betasub, betanamesub] = fixedEffects(test.sub)
y = [data.ic_img_rate(data.highcue_indx == "-1"), data.ic_img_rate(data.highcue_indx == "1")];

% Create x-values for the plot
xvals = [-1 1];
x_values = linspace(min(xvals), max(xvals), 100);

% Create a different slope for 30 subjects
subs = datasample(unique(data.subj), 30, 'replace', false);
figure; hold on;
for i = 1:numel(subs)
    subdat = data(data.subj == subs(i), :);
    test.lmsub{i} = fitlm(subdat, 'ic_img_rate ~  highcue_indx*norm_val');
    test.beta{i} = test.lmsub{i}.Coefficients.Estimate;
    ypred = test.beta{i}(1) + test.beta{i}(2)*x_values;
    plot(x_values, ypred, '--')
end

ymixed = betasub(1) + betasub(2)*x_values;
plot(x_values, ymixed, '-', 'LineWidth', 3, 'Color', 'r' )
hold off;
title('Mixed Effect Estimate for Subject')
%%
% Extract fixed effects coefficients
[betapart, betanamespart] = fixedEffects(minlmm)
[betafull, betanamesfull] = fixedEffects(fulllmm)
x = [-1 1];
y = [data.img_rate(data.highcue_indx == "-1"), data.img_rate(data.highcue_indx == "1")];



% Create x-values for the plot
x_values = linspace(min(x), max(x), 100); % adjust based on your data range

% Compute predicted y-values using fixed effects coefficients of mix models
y_pred_part = betapart(1) + betapart(2)*x_values;
y_pred_full = betafull(1) + betafull(2)*x_values;

% compute predicted y-values using minimal model
betamin =  minlm.Coefficients.Estimate;
y_pred_min = betamin(1) + betamin(2)*x_values;

% Plot the actual line
figure;
% scatter(x, y, 'o');
hold on;
plot(x_values, y_pred_min, ':', 'LineWidth', 2);
plot(x_values, y_pred_part, '--', 'LineWidth', 2);
plot(x_values, y_pred_full, '-', 'LineWidth', 2);

% axis([-1.1 1.1 -1.3 1.3])

% Extract fixed effects coefficients
[betapart, betanamespart] = fixedEffects(minlmm)
[betafull, betanamesfull] = fixedEffects(fulllmm)
x = [-1 1];
y = [data.img_rate(data.highcue_indx == "-1"), data.img_rate(data.highcue_indx == "1")];



% Create x-values for the plot
x_values = linspace(min(x), max(x), 100); % adjust based on your data range

% Compute predicted y-values using fixed effects coefficients of mix models
y_pred_part = betapart(1) + betapart(2)*x_values;
y_pred_full = betafull(1) + betafull(2)*x_values;

% compute predicted y-values using minimal model
betamin =  minlm.Coefficients.Estimate;
y_pred_min = betamin(1) + betamin(2)*x_values;

% Plot the actual line
figure;
% scatter(x, y, 'o');
hold on;
plot(x_values, y_pred_min, ':', 'LineWidth', 2);
plot(x_values, y_pred_part, '--', 'LineWidth', 2);
plot(x_values, y_pred_full, '-', 'LineWidth', 2);
%%
% xlabel('X');
% ylabel('Y');
% title('Actual Line Estimated by minlmm');
% hold off;

subj_avg = struct;

for i = 1:numel(unique(pair_table.subj))
    temp_pair = pair_table(pair_table.subj == num2str(i), :);
    subj_avg.hi{i} = mean(temp_pair.hi_val-temp_pair.val_mean); % center around normative rating within pair
    subj_avg.lo{i} = mean(temp_pair.lo_val-temp_pair.val_mean);
    % subj_avg.hi{i} = mean(temp_pair.hi_val - 50);
    % subj_avg.lo{i} = mean(temp_pair.lo_val - 50);
end

data_to_plot = {};
data_to_plot{1,1} = cell2mat(subj_avg.lo');
data_to_plot{1,2} = cell2mat(subj_avg.hi');

colors = seaborn_colors(2);

figure; gcf;
barplot_columns(data_to_plot, 'title', 'Cue Effect on Valence Rating With Mean Subject Ratings', 'color', colors, 'MarkerSize', 0.5, ...
    'names', {'Lo Cue', 'Hi Cue'}, 'nofigure', 'plotout', 'dolines') %, , 'dostars',
ylabel('Valence Rating')
xlabel('Cue Type');
% legend({});

% axis([-1.3 1.3 -1 1])
hold off;
%%
% zclmm = fitlme(data, 'zc_img_rate ~ highcue_indx + norm_val^2 + (highcue_indx + norm_val^2|subj)', 'FitMethod', 'REML')
%%
group = {data.highcue_indx, data.Valence_mean, data.subj};
interactionplot(data.img_rate, group, 'varnames', {'Highcue', 'Valence_mean', 'subj'})
%%
anova(fulllmm, 'dfmethod', 'satterthwaite')
%%

%% Residuals are really messed up. Maybe because initial data isn't normally distributed?

centlmmfull = fitlme(data, 'ic_img_rate ~ highcue_indx*norm_val + (highcue_indx*norm_val | subj) + (1|Pair) + (1|Pair:Image)', 'FitMethod', 'REML');

figure();
plotResiduals(centlmmfull, 'fitted')
figure();
plotResiduals(centlmmfull, 'probability')
figure();
plotResiduals(centlmmfull, 'lagged')

numel(find(residuals(centlmm)>0.25))

% Color code by subj?

% figure();
% gscatter(F,R,data.group)


r = residuals(centlmmfull);

subplot(1,2,1); histfit(r)

r = residuals(centlmmfull, 'Conditional', true);
subplot(1,2,2); histfit(r)


figure;
pr = residuals(centlmmfull,'ResidualType','Pearson');
st = residuals(centlmmfull,'ResidualType','Standardized');
X = [r pr st];
boxplot(X,'labels',{'Raw','Pearson','Standardized'})

numel(find(r > mean(r,'omitnan') + 2.5*std(r,'omitnan')))
numel(find(r < mean(r,'omitnan') - 2.5*std(r,'omitnan')))

anova(centlmmfull, 'dfmethod', 'satterthwaite')
beep on; beep


%% Playing with LMM
% playlmm = fitlme(data, 'img_rate ~ Valence_mean^2 + highcue_indx*Pair + (highcue_indx + Valence_mean^2 |subj) + (1|Arousal_mean)', 'FitMethod', 'REML') 
% playlmm = fitlme(data, 'img_rate ~ highcue_indx + Valence_mean^2 + (highcue_indx + Valence_mean^2|Pair) + (1|subj)', 'FitMethod', 'REML') % Pair Satterhwaite is TINY
% playlmm = fitlme(data, 'img_rate ~ cue_observed_mean + Pair + Valence_mean^2 + (1|subj) + (1|Arousal_mean)', 'FitMethod', 'REML') % Really good: 68097 68361
% TOR's: playlmm = fitlme(data, 'img_rate ~ highcue_indx + Valence_mean + Valence_mean * highcue_indx + Valence_mean^2 + Valence_mean^2 * highcue_indx + (highcue_indx + Valence_mean + Valence_mean * highcue_indx + Valence_mean^2 + Valence_mean^2 * highcue_indx|subj) + (1 | Pair) + (1 | Pair:highcue_indx)')
% playlmm = fitlme(data, 'img_rate ~ Valence_mean^2 + highcue_indx + (Valence_mean^2 + highcue_indx |subj:highcue_indx:Image)', 'FitMethod', 'REML')
% playlmm = fitlme(data, 'img_rate ~  cue_observed_mean + Valence_mean + (Valence_mean + cue_observed_mean |subj) + (1|Pair)', 'FitMethod', 'REML')
% playlmm = fitlme(data, 'norm_img_rate ~ highcue_indx * norm_val^2 + (highcue_indx * norm_val^2 |subj) + (1|Pair:highcue_indx)', 'FitMethod', 'REML') 
playlmm2 = fitlme(data, 'norm_img_rate ~ highcue_indx * norm_val  - norm_val + (highcue_indx * norm_val - norm_val|subj) + (1|Pair:highcue_indx)', 'FitMethod', 'REML')

anova(playlmm2, 'dfmethod', 'satterthwaite')
beep on; beep

%%
%%%%% CURRENT BEST: 'img_rate ~ Valence_mean^2 + highcue_indx + Pair + (highcue_indx + Valence_mean^2 |subj)'  % 67127 67446 16.401
% bestlmm =
%% Compare R and MATLAB output

% comp = fitlme(data, 'img_rate ~ 1 + Valence_mean + (1 | subj)',
% 'FitMethod', 'REML') SAME
% comp = fitlme(data, 'img_rate ~ 1 + highcue_indx *Valence_mean + (1 |
% subj)', 'FitMethod', 'REML') SAME

% First differences when you add in random slopes
% comp = fitlme(data, 'img_rate ~ 1 + highcue_indx * Valence_mean + (1 +
%   highcue_indx*Valence_mean | subj)', 'FitMethod', 'REML') 
% Also got the issue of the boundary being singular in R

comp = fitlme(data, 'img_rate ~ 1 + highcue_indx + Valence_mean + (1 | subj)', 'FitMethod', 'REML') 
anova(comp, 'dfmethod', 'satterthwaite') 


%% Pair Rating Comparison LME

pairlmm = fitlme(pair_table, 'val_diff ~ stim_mean + (1|subj:Pair)')
 anova(pairlmm, 'dfmethod', 'satterthwaite')
%%
F = fitted(pairlmm);
R = response(pairlmm);
figure(); hold on;
plot(R,F,'rx')
xlabel('Response')
ylabel('Fitted')
hold off; 


figure();
plotResiduals(pairlmm, 'fitted')
%%
testlmm = fitlme(sdata, 'img_rate ~ highcue_indx*Valence_mean^2 + (highcue_indx * Valence_mean^2 | subj) + (highcue_indx|Pair)', 'FitMethod', 'REML')

anova(testlmm, 'dfmethod', 'satterthwaite')
%%
anova(testlmm, 'dfmethod', 'satterthwaite')
anova(fulllmm,  'dfmethod', 'satterthwaite')
compare(testlmm, fulllmm)
%%
testlmm2 = fitlme(sdata, 'img_rate ~ highcue_indx*Valence_mean^2 + (highcue_indx * Valence_mean^2 | subj) + (highcue_indx|group)', 'FitMethod', 'REML')
anova(testlmm2, 'dfmethod', 'satterthwaite')
compare(testlmm, testlmm2)