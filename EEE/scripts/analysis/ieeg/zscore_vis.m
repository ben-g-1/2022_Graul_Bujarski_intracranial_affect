%%%
projdir = 'C:\Users\bgrau\Dropbox (Dartmouth College)\PBS\2023_Graul_EEE';
subnum = '01';
freq = 'broadband';
cond = 'imgview';
grouptype = 'agree'; %'highcue_indx', 'val_type', 'conform', 'agree'
condA = 1;
condB = 0;
threshtype = 'max';
thresh = 0.5;

%%%

datadir = fullfile(projdir, 'data', 'processed', ['sub-' subnum]);
freqdir = fullfile(datadir, cond, 'freq');
filename = strcat('sub-', subnum, '_', cond, "_freq_", freq);
%%%

%%
% load data
freqdat = fullfile(freqdir, filename);
load(freqdat);

%% Remove trials with outlier frequency power
alltrials = 1:64;
seizetrial = [13,20,21,38,39,53,55,62];
seizepair = [];
for c = 1:numel(seizetrial)
    for i = 1:numel(imgview_freq.trialinfo.pair_row)
        if imgview_freq.trialinfo.pair_row(i) == seizetrial(c)
            seizepair(c) = i;
        end
    end
end

trialsleft = setdiff(alltrials, [seizetrial seizepair]);

%%

cfg = [];
% cfg.frequency = [7 15];
cfg.latency = [-0.1 4];
freqgroup = 'broadband';
% cfg.avgoverfreq = 'yes';
cfg.trials = trialsleft;
imgview_freq = ft_selectdata(cfg, imgview_freq);
%%
imgview_freq_z = ft_zscore_pow(imgview_freq);
conddif = ft_zscore_difference(imgview_freq, grouptype, condA, condB);
%%
[sigelecs, sigelecs_labels] = zscore_thresholds(conddif, threshtype, thresh);


cfg = [];
cfg.channel = sigelecs_labels;
sigdif = ft_selectdata(cfg, conddif);

% visualize zscore differences
figure;

xlabel('Time (s)')
ylabel('zscore power ratio')
switch threshtype
    case 'max'
        switchtitle1 = sprintf('Z-score Difference of %s', grouptype);
        switchtitle2 = sprintf('Z-score above %.2f', thresh);
    case 'min'
        switchtitle1 = sprintf('Z-score Difference of %s', grouptype);
        switchtitle2 = sprintf('Z-score below %d', thresh);
end %switch
title({switchtitle1; switchtitle2; freqgroup});
set(gca, 'FontSize', 28)
xlim([-2.4 5.4])
hold on;
for c = 1:length(sigdif.label)
  avg = squeeze(nanmean(sigdif.powspctrm(c,1,:),1));
  plot(sigdif.time, avg)
end %for
legend(sigelecs_labels)

drawnow;
%%
[sigelecs, sigelecs_labels] = zscore_thresholds(imgview_freq_z,  threshtype, 0.7);

% visualize zscore
figure;

xlabel('Time (s)')
ylabel('zscore power ratio')
title({'Z-score Broadband Shift'; ...
    'zscore above 0.7'})
set(gca, 'FontSize', 28)
xlim([-2.4 5.4])
hold on;
for c = 1:length(imgview_freq_z.label)
  avg = squeeze(nanmean(imgview_freq_z.powspctrm(:,c,1,:),1));
    % avg = squeeze(nanmean(imgview_freq_z.powspctrm(c,1,:),1));

  plot(imgview_freq_z.time, avg)
end 
legend(sigelecs_labels)

% disp(sigelecs)
%%%% for groups of different sizes? 
% cfg = [];
% cfg.trials = avgfreq.trialinfo.conform == 1;
% cfg.avgoverrpt = 'yes';
% condA = ft_selectdata(cfg, avgfreq);
% 
% cfg.trials = avgfreq.trialinfo.agree == 0;
% cfg.avgoverrpt = 'yes';
% condB = ft_selectdata(cfg, avgfreq);
% %%
% cfg = [];
% cfg.parameter = 'powspctrm';
% cfg.operation = '(x1-x2)';
% avgfreq = ft_math(cfg, condA, condB);
%%

trialinfo = imgview_freq.trialinfo;
condcol = trialinfo(:, grouptype);
sigdiff_elecs = {};
% 
cc = 1;
% for c = 1:20
for c = 1:numel(imgview_freq.label)
    chan = imgview_freq.label{c};
% find high and low valence trials 
condA = condcol(:,1) == valA;
condA = table2array(condA);
cfg = [];
cfg.avgoverrpt = 'yes';
cfg.channel = chan;
% cfg.avgoverfreq = 'yes';
cfg.trials = condA;
imgview_freq_agree = ft_selectdata(cfg, imgview_freq_z);

condB = condcol(:,1) == valB;
condB = table2array(condB);
cfg.trials = condB;
imgview_freq_disagree = ft_selectdata(cfg, imgview_freq_z);
%
agree = squeeze(imgview_freq_agree.powspctrm);
agree = mean(agree, 1);
disagree = squeeze(imgview_freq_disagree.powspctrm);
disagree = mean(disagree, 1);

mean_diff = mean(agree) - mean(disagree);
num_permutations = 10000;
permuted_mean_diffs = zeros(num_permutations, 1);
for i = 1:num_permutations
    combined_data = [agree, disagree];
    perm_data = combined_data(randperm(length(combined_data)));
    perm_agree = perm_data(1:length(agree));
    perm_disagree = perm_data(length(agree)+1:end);

    permuted_mean_diffs(i) = mean(perm_agree) - mean(perm_disagree);
end

pval = sum(abs(permuted_mean_diffs) >= abs(mean_diff)) / num_permutations;

if pval < 0.001
disp(chan);
disp(['Observed mean diff: ', num2str(mean_diff)]);
disp(['P-value: ', num2str(pval)]);
sigdiff_elecs{cc} = chan;
cc = cc + 1; 
end
end
%%

% Looking at STE of different conditions
dat = [imgview_freq_agree, imgview_freq_disagree];
cred = [1 0 0];
cblue = [0 0 1];
color = [cred; cblue];


figure();

hold on;
for i = 1:numel(dat)


    mydat = squeeze(dat(i).powspctrm);
    % mydat = squeeze(mean(mydat, 2));
    nanColumns = any(isnan(mydat), 1);

    mydat = mydat(:, ~nanColumns);
    mymean = mean(mydat);
    myste = ste(mydat);
    
    lower = mymean - myste;
    upper = mymean + myste;

    plot(1:numel(mydat(1,:)), mymean, '-', 'LineWidth', 1, 'Color', color(i,:) ./ 2, 'DisplayName', 'High Cue')
    fill([1:numel(mydat(1,:)), fliplr(1:numel(mydat(1,:)))], [lower, fliplr(upper)], ...
        color(i,:) ./ 2,'FaceAlpha', 0.3, 'EdgeColor', 'none')


end %for

ax = gca;
ax.FontSize = 18;
% title = sprintf( for %s', chan{1});
title(chan)

xlabel('Time (s)', 'FontSize', 24, 'FontWeight','bold')
ylabel('Percent Power', 'FontSize', 24, 'FontWeight','bold')
set(gca, 'FontSize', 32)

% plot([1500 5000], [1 1], 'k--') % add horizontal line
% ylim = [0 200];
% xlim([200 450])
% plot([2500 2500], [-0.5 3.5], 'r-', 'LineWidth', 2) % vert. l
% set(gca, 'XTick', [2000:500:4500], 'XTickLabel', {'-0.5' ' 0' '0.5' '1.0' '1.5' '2.0'});
% set(gca, 'YTick', [0.3 1 2 3], 'YTickLabel', [-100 0 100 200])

legend('Ratings Converge', '', 'Ratings Diverge', '', 'FontSize', 18)

hold off;


% end % if sig
% end % chan loop
