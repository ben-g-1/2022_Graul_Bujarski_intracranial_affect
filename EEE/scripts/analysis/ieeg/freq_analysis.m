%%% Frequency Analysis %%%

%%%
projdir = 'C:\Users\bgrau\Dropbox (Dartmouth College)\PBS\2023_Graul_EEE';
subnum = '01';
freq = 'broadband';
cond = 'imgview';
%%%

datadir = fullfile(projdir, 'Data', 'processed', ['sub-' subnum]);
freqdir = fullfile(datadir, cond);
filename = strcat('sub-', subnum, '_', cond, "_freq_", freq);
%%%


% load data
freqdat = fullfile(freqdir, filename);
freqdat = "C:\Users\bgrau\Dropbox (Dartmouth College)\2023_Graul_EEE\Data\processed\sub-01\imgview\sub-01_imgview_freq_fullspec.mat";
% load(freqdat);

%%
cfg = []; 

%%

imgview_freq_z = imgview_freq;
% z score for equal contributions
for c = 1:length(imgview_freq.label)
  for f = 1:length(imgview_freq.freq)
    tmp = imgview_freq_z.powspctrm(:,c,f,:);
    avg = nanmean(tmp(:));
    sd = nanstd(tmp(:));
    imgview_freq_z.powspctrm(:,c,f,:) = (tmp-avg)/sd;
  end
end

%%
% average frequency contribution
cfg             = [];
% cfg.avgoverfreq = 'yes';
cfg.channel = 'RTA1';
% cfg.avgoverchan = 'yes';
cfg.nanmean     = 'yes';
avgfreq = ft_selectdata(cfg, imgview_freq_z);
%%
% visualize
figure;
sigelecs = {};
sigelecs_labels = {};
xlabel('Time (s)')
ylabel('zscore power ratio')
title({'Broadband Power Shifts During Image Anticipation and Viewing'; ...
    'zscore above 0.7'})
set(gca, 'FontSize', 28)
xlim([-2.4 5.4])
% xlim([-2.4 0])
% xlim([0 5.4])


% avgfreq_early = avgfreq 

hold on;
for c = 1:length(avgfreq.label)
% for c = 39:46
  avg = squeeze(nanmean(avgfreq.powspctrm(:,c,1,:),1));
 
  % if min(avg)<-.3
    if max(avg)>.3
      sigelecs = [sigelecs avgfreq.label{c} c];
      sigelecs_labels = [sigelecs_labels, avgfreq.label{c}];
      plot(avgfreq.time, avg)
  end
end 
legend(sigelecs_labels)
disp(sigelecs)


%%
chans = {'RTA1', 'LFC2', 'LFC10', 'RPAG9', 'RPPC1', 'RFC3', 'LTA1', 'RFC7'};
% chans = {'LTA1', 'LTA3', 'LTHA4', 'LTHA3'};
% chans = {'RTA1', 'LFC2', 'LFC10', 'RFC7'};

for chan = 1:numel(chans)
figure; hold on;
set(gca, 'FontSize', 22)
scn_export_papersetup(400);
% cfg.title = sprintf('%s Average Image Response', cfg.channel);
% title('High Gamma Activity Following Image Onset', 'FontSize', 26)
% ylabel({'Frequency (Hz)'; '2 Hz Step'}, 'FontSize', 32, 'FontWeight','bold')
ylabel('Frequency (Hz)', 'FontSize', 32, 'FontWeight','bold')

xlabel({'Time After Image Onset (s)'}, 'FontSize', 32, 'FontWeight','bold')
zlabel('z-score');
% set(gca, 'ZTick', -2:9, 'ZTickLabel', ['-200%' '0']);

cfg = [];
cfg.fontsize = 22;
cfg.figure = gcf;
cfg.xlim = [-2 3]; % trim the empty space
% cfg.ylim = [4 15]; %focus on mid/high gamma
cfg.ylim = [0 110];
% cfg.zlim = [-1 2]; % set scale to be the same across figures
cfg.parameter = 'powspctrm';
% cfg.baseline = [-2.4 -2.3];
% cfg.baselinetype = 'absolute';

cfg.channel = chans{chan};
% cfg.trials = 10;
cfg.title = {'Broadband Activity Following Image Onset'; cfg.channel};



ft_singleplotTFR(cfg, imgview_freq_z)
end
% ft_singleplotTFR(cfg, avgfreq)


