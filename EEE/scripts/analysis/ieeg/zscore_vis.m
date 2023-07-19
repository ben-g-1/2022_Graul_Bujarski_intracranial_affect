%%%
projdir = 'C:\Users\bgrau\Dropbox (Dartmouth College)\PBS\2023_Graul_EEE';
subnum = '01';
freq = 'fullspec';
cond = 'imgview';
grouptype = 'highcue_indx';
condA = 1;
condB = -1;
threshtype = 'max';
thresh = 0.8;

%%%

datadir = fullfile(projdir, 'data', 'processed', ['sub-' subnum]);
freqdir = fullfile(datadir, cond, 'freq');
filename = strcat('sub-', subnum, '_', cond, "_freq_", freq);
%%%


% load data
freqdat = fullfile(freqdir, filename);
load(freqdat);
%%

% cfg = [];
% cfg.frequency = [7 13];
% imgview_freq = ft_selectdata(cfg, imgview_freq);

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
title({switchtitle1; switchtitle2});
set(gca, 'FontSize', 28)
xlim([-2.4 5.4])
hold on;
for c = 1:length(sigdif.label)
  avg = squeeze(nanmean(sigdif.powspctrm(:,c,1,:),1));
  plot(sigdif.time, avg)
end %for
legend(sigelecs_labels)

drawnow;
%%
[sigelecs, sigelecs_labels] = zscore_thresholds(imgview_freq_z,  threshtype, thresh);

% visualize zscore
figure;

xlabel('Time (s)')
ylabel('zscore power ratio')
title({'Z-score Difference of High and Low Ratings'; ...
    'zscore above 0.6'})
set(gca, 'FontSize', 28)
xlim([-2.4 5.4])
hold on;
for c = 1:length(imgview_freq_z.label)
  avg = squeeze(nanmean(imgview_freq_z.powspctrm(:,c,1,:),1));
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