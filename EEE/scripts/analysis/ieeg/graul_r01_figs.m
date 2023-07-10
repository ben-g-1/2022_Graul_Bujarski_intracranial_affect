freqpath = 'C:\Users\bgrau\Dropbox (Dartmouth College)\PBS\2023_Graul_EEE\Data\EEE\processed\sub-01\imgview_freq_2b5a';
preproc = 'C:\Users\bgrau\Dropbox (Dartmouth College)\PBS\2023_Graul_EEE\Data\EEE\processed\sub-01\imgview_preproc_2b5a';
% erp = 'C:\Users\bgrau\Dropbox (Dartmouth College)\PBS\2023_Graul_EEE\Data\EEE\processed\sub-01\imgview_ERP_2b5a';
load(freqpath);
load(preproc);
% load(erp);
%%
% spectral decomposition
    timres          = .01; % 10 ms steps
    cfg             = [];
    % cfg.channel     =  'RTA1';

    cfg.output      = 'pow';
    cfg.method      = 'mtmconvol';
    cfg.taper       = 'dpss';
    % cfg.foi = [40 45 50 55 65 70 75 80 85 90 95 100 105 110 115 125 130 135 140 145 150 155 160 165 170 175 185 190]; % 80 - 190 Hz, leave out harmonics of 60 Hz
    cfg.foi = [5 8 11 14 17 20 23 26 29 32 35 40 45 50 55 65 70 75 80 85 90 95 100 105 110 115 125 130 135 140 145 150 155 160 165 170 175 180 185 190]
    % cfg.foi = [4:1:30 31:2:59 61:2:118 121:2:178 181:2:199];
    cfg.tapsmofrq   = 10;
    cfg.t_ftimwin   = .2*ones(length(cfg.foi),1); % 200 ms
    cfg.toi         = imgview.time{1}(1):timres:imgview.time{1}(end);  % begin to end of defined event
    % cfg.toi         = round(data.time{1}(hdr.Fs * 1.99)):timres:round(data.time{1}(hdr.Fs * 3.51));  
    cfg.keeptrials  = 'yes';
    cfg.pad         = 'nextpow2';

    % imgview_freq_hires = ft_freqanalysis(cfg,imgview);
imgview_freq = ft_freqanalysis(cfg,imgview);
% imgview_freq_RTA1 = ft_freqanalysis(cfg, imgview)
%%
% It's easiest to have a quick table to reference for the direct high-low cue comparisons within pair. It can be made from the trial info within the FieldTrip objects.
pairs = table();
hiorder = sortrows(imgview_freq.trialinfo, 'highcue_indx', 'descend');
hicue = hiorder(1:32,:);
hicue = sortrows(hicue, 'Pair', 'ascend');
locue = hiorder(33:64,:);
locue = sortrows(locue, 'Pair', 'ascend');
pairorder = sortrows(imgview_freq.trialinfo, 'Pair', 'ascend');
pairs.pairnum = hicue.Pair(1:32);
pairs.hitrial = hicue.trial(1:32);
pairs.lotrial = locue.trial(1:32);
pairs.hival = hicue.val_rating(1:32);
pairs.loval = locue.val_rating(1:32);
pairs.valdif = pairs.hival - pairs.loval;
pairs.hiexp = hicue.exp_rating(1:32);
pairs.loexp  = locue.exp_rating(1:32);
pairs.expdif = pairs.hiexp  - pairs.loexp;

% We want to start with looking in the amygdala. The electrode RTA1 is a good candidate for this. It's electrode #47 in our current dataset. If other electrodes are of interest, their number is the row number they appear on within the imgview_freq.label cell array.
%%
imgview_powspctrm_RTA1 = squeeze(imgview_freq.powspctrm(:,47,:,:));
xc = imgview_powspctrm_RTA1;

ii = 1;
difftable = [];

for r = 1:2:64
    if pairorder.highcue_indx(r) == 1
        j = pairorder.trial(r);
        k = pairorder.trial(r+1);
    else
        k = pairorder.trial(r);
        j = pairorder.trial(r+1);
    end
    
    difftable(ii,:,:) = xc(j,:,:) - xc(k,:,:);

    ii = ii + 1;

end

OUT = ttest3d(difftable);
% Here we're taking the power spectrum of a single electrode and comparing the high-low cue conditions. The OUT.sig array tells us our frequencies that survived multiple comparison testing. Let's see which pairs have the most frequencies that seem to be influenced by high vs. low cue type. 
for i = 1:32
    ideal = sum(abs(OUT.sig(i,:)));
    if ideal > 15
        disp(i)
    end
end
%%
% Let's start with Pair 15 for visualization. These are both negatively valenced ratings, so the literature suggests that the differentiation of signals should be easier. 


pairnum = 27;
cfg = [];


cfg.xlim = [-2.4 5.4]; % trim the empty space
% cfg.ylim = [70 150]; %focus on mid/high gamma
% cfg.zlim = [0 8]; % set scale to be the same across figures
cfg.parameter = 'powspctrm';
cfg.baselinetype = 'relchange';
cfg.baseline = [-0.5 -0.01];


cfg.channel = 'LPC3';

cfg.trials      = imgview_freq.trialinfo.highcue_indx == 1;
cfg.title = sprintf('%s Average Image Response, High Cue', cfg.channel);
ylabel({'Frequency (Hz)'; '5 Hz Step'})
xlabel({'Time (s)'; 'Stimulus T = 0'})
ft_singleplotTFR(cfg, imgview_freq)

cfg.trials      = imgview_freq.trialinfo.highcue_indx == -1;
cfg.title = sprintf('%s Average Image Response, Low Cue', cfg.channel);
ylabel({'Frequency (Hz)'; '5 Hz Step'})
xlabel({'Time (s)'; 'Stimulus T = 0'})
ft_singleplotTFR(cfg, imgview_freq)

cfg.trials = pairs.hitrial(pairnum);
cfg.title = sprintf('%s, Pair %d, Hi Cue', cfg.channel, pairnum);
ylabel({'Frequency (Hz)'; '5 Hz Step'})
xlabel({'Time (s)'; 'Stimulus T = 0'})
ft_singleplotTFR(cfg, imgview_freq)

cfg.trials = pairs.lotrial(pairnum);
cfg.title = sprintf('%s, Pair %d, Lo Cue', cfg.channel, pairnum);
ylabel({'Frequency (Hz)'; '5 Hz Step'})
xlabel({'Time (s)'; 'Stimulus T = 0'})
ft_singleplotTFR(cfg, imgview_freq)
% We can compare ERPs for the same time period in each condition. The canonical ERP we anticipate with highly emotional image viewing is the P400, which occurs 400 ms after image onset. This should be strongest in the amygdala, but we see that it also seems to appear in most ROIs to a lesser extent as well. 

%% Creating ERPs

cfg          = [];

imgview_ERP = ft_timelockanalysis(cfg, imgview);
cfg.keeptrials = 'yes';

cfg.trials = imgview_freq.trialinfo.highcue_indx == 1;
imgview_ERP_hicue   = ft_timelockanalysis(cfg,imgview);

cfg.trials = imgview_freq.trialinfo.highcue_indx == -1;
imgview_ERP_locue   = ft_timelockanalysis(cfg,imgview);

% @Tor, since you mentioned that having a trial-specific baseline subtraction might be problematic, I've created two sets of variables to compare against one another in addition to the cue pair variables. In general, it seems that the baseline correction pulls the starting point closer to 0 and increase magnitude of signal. At the peak negative point of the P400 in the amygdala (channel RTA1), it seems to differentiate the two conditions more than the uncorrected version. We can discuss which way we'll proceed in the rest of the analysis. 
% baseline correction
cfg.baseline = [-0.5 -0.01];

imgview_ERP_hicue_bl = ft_timelockbaseline(cfg,imgview_ERP_hicue);
imgview_ERP_locue_bl = ft_timelockbaseline(cfg,imgview_ERP_locue);
%%
% z score for equal contributions
for c = 1:length(imgview_freq.label)
  for f = 1:length(imgview_freq.freq)
    tmp = imgview_freq.powspctrm(:,c,f,:);
    avg = nanmean(tmp(:));
    sd = nanstd(tmp(:));
    imgview_freq.powspctrm(:,c,f,:) = (tmp-avg)/sd;
  end
end
% high gamma signals
cfg             = [];
cfg.avgoverfreq = 'yes';
cfg.nanmean     = 'yes';
hg = ft_selectdata(cfg, imgview_freq);
%%
% visualize
figure;
sigelecs = {};
xlabel('Time (s)')
ylabel('zscore power ratio')
title('Broadband Power Shifts During Image Anticipation and Viewing')
set(gca, 'FontSize', 28)
xlim([-2.4 5.4])

for c = 1:length(imgview_freq.label)
% for c = 39:46
  avg = squeeze(nanmean(hg.powspctrm(:,c,1,:),1));
  hold on; 
  if max(avg)>.75
      sigelecs = [sigelecs imgview_freq.label{c} c];
      plot(imgview_freq.time, avg)
  end
end 
disp(sigelecs)
%%
cfg = [];
% cfg.channel = 'RTA1';
cfg.xlim = [-.2 1.2];

% cfg.title = (sprintf('%s Average ERP at Stimulus Onset', cfg.channel))
% legend('High Cue', 'Low Cue')
% xlabel('Time (s)');
% ylabel('Relative Potential Shift (uV)');
% ft_singleplotER(cfg, imgview_ERP_hicue, imgview_ERP_locue);

% cfg.title = sprintf('%s Baseline Shifted ERP at Stimulus Onset', cfg.channel);

legend('High Cue', 'Low Cue')
xlabel('Time (s)');
ylabel('Relative Potential Shift (uV)');
ft_singleplotER(cfg, imgview_ERP_hicue_bl, imgview_ERP_locue_bl);

%%

%%
cfg.trials = imgview_freq.trialinfo.highcue_indx == 1;
% cfg.trials = imgview_freq.trialinfo.val_type == 1;
% cfg.trials = imgview_freq_RTA1.trialinfo.conform == 1;
% cfg.trials = imgview_freq_RTA1.trialinfo.agree == 1;


imgview_freq_hicue = ft_selectdata(cfg, imgview_freq);
cfg.trials = imgview_freq.trialinfo.highcue_indx == -1;
% cfg.trials = imgview_freq.trialinfo.val_type == -1;
% cfg.trials = imgview_freq_RTA1.trialinfo.conform == 0;
% cfg.trials = imgview_freq_RTA1.trialinfo.agree == 0;

imgview_freq_locue = ft_selectdata(cfg, imgview_freq);

%% Looking at STE of different conditions
dat = [imgview_freq_hicue, imgview_freq_locue];
cred = [1 0 0];
cblue = [0 0 1];
color = [cred; cblue];


figure();

hold on;
for i = 1:numel(dat)


    mydat = squeeze(dat(i).powspctrm);
    mydat = squeeze(mean(mydat, 2));
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
title('Average Gamma Power from Expected and Unexpected Valence Trials', 'FontSize', 26)

xlabel('Time (s)', 'FontSize', 24, 'FontWeight','bold')
ylabel('Percent Power', 'FontSize', 24, 'FontWeight','bold')
set(gca, 'FontSize', 32)

plot([1500 5000], [1 1], 'k--') % add horizontal line
ylim([0.7 3.5])
xlim([2000 4500])
plot([2500 2500], [-0.5 3.5], 'r-', 'LineWidth', 2) % vert. l
set(gca, 'XTick', [2000:500:4500], 'XTickLabel', {'-0.5' ' 0' '0.5' '1.0' '1.5' '2.0'});
set(gca, 'YTick', [0.3 1 2 3], 'YTickLabel', [-100 0 100 200])

legend('Ratings Converge', '', 'Ratings Diverge', '', 'FontSize', 18)

hold off;
%% 
pairnum = 15;
cfg = [];
cfg.channel = 'RTA1';
% cfg.title = sprintf('%s B at Stimulus Onset', cfg.channel)
cfg.trials = pairs.hitrial(pairnum);
freq_pair_hi = ft_selectdata(cfg, imgview_freq_lores);
cfg.trials = pairs.lotrial(pairnum);
freq_pair_lo = ft_selectdata(cfg, imgview_freq_lores);


figure(); hold on;
ax = gca;
ax.FontSize = 20;
title('Single Trial  Gamma Activity', 'FontSize', 26)
ylabel('Gamma Activity (Fold Increase)', 'FontSize', 24, 'FontWeight','bold')
xlabel('Time After Image Onset(s)', 'FontSize', 24, 'FontWeight','bold')

cfg = [];
cfg.figure = gcf;
cfg.title = 'Individual Trial High Gamma Activity for Matched Images';
cfg.fontsize = 22;
cfg.xlim = [0 1.5];
cfg.linewidth = 1.5;
cfg.baseline = [-0.5 -0.01];
% cfg.showlegend = 'yes'
% legend('High Cue', 'Low Cue', 'FontSize', 18)

% ft_singleplotER(cfg, imgview_freq_locue, imgview_freq_hicue)
ft_singleplotER(cfg, freq_pair_lo,freq_pair_hi)
% ft_singleplotTFR(cfg, imgview_freq_locue, imgview_freq_hicue)
%%
cred = [1 0 0];
cblue = [0 0 1];


plot_ERP_SE([imgview_freq_hicue imgview_freq_locue], 1, [cred; cblue])
%, imgview_freq_locue);
% ft_singleplotER(cfg, imgview_freq)

%%

cred = [1 0 0];
cblue = [0 0 1];
plot_ERP_SE([imgview_ERP_hicue_bl imgview_ERP_locue_bl], 1, [cred; cblue])

%%
cuecolors = {[1 0 0] [0 0 1]};

pair_table = sortrows(pair_table, "pair_number", "ascend");
pairs = [1:32]';

y = [pair_table.hi_val pair_table.lo_val];
x = [pairs pairs];  % pairs, [high low]

figure;

highdots = plot(x(:, 1), y(:, 1), 'o', 'MarkerFaceColor', cuecolors{1}, 'MarkerSize', 10); hold on;

lowdots = plot(x(:, 2), y(:, 2), 'o', 'MarkerFaceColor', cuecolors{2}, 'MarkerSize', 10); 

d = -(diff(y')'); % h - l difference scores for matched pairs

wh_hvsl = d > 0;
line = plot(x(wh_hvsl, :)', y(wh_hvsl, :)', 'k-');
line = plot(x(~wh_hvsl, :)', y(~wh_hvsl, :)', '-', 'Color', [.7 .4 .4]);

title('Cue Type Positively Correlates with Valence Rating', 'FontSize', 26)
xlabel('Image Pair Number', 'FontSize', 24, 'FontWeight','bold');
ylabel('Valence Rating Within Picture Pairs', 'FontSize', 24, 'FontWeight','bold')
hold off;

axis([0 33 -2 119])

ax = gca;
ax.FontSize = 20;
legend([highdots lowdots], {'High Cue', 'Low Cue'})
%%

% pair_table = sortrows(pair_table, "rating_diff", "ascend");
pairs = [1:32]';

y = [pair_table.hi_val-pair_table.rating_mean pair_table.lo_val-pair_table.rating_mean];  % ratings, [high low]
x = [pairs pairs];  % pairs, [high low]

figure;

highdots = plot(x(:, 1), y(:, 1), 'o', 'MarkerFaceColor', cuecolors{1}, 'MarkerSize', 10); hold on;

lowdots = plot(x(:, 2), y(:, 2), 'o', 'MarkerFaceColor', cuecolors{2}, 'MarkerSize', 10); 

d = -(diff(y')'); % h - l difference scores for matched pairs

wh_hvsl = d > 0;
line = plot(x(wh_hvsl, :)', y(wh_hvsl, :)', 'k-');
line = plot(x(~wh_hvsl, :)', y(~wh_hvsl, :)', '-', 'Color', [.7 .4 .4]);

title('Cue Type Positively Correlates with Valence Rating', 'FontSize', 26)
xlabel('Smallest to Largest Difference in Ratings with Pairs', 'FontSize', 24, 'FontWeight','bold');
ylabel('Valence Rating Within Picture Pairs', 'FontSize', 24, 'FontWeight','bold')
hold off;

axis([0 33 -30 35])

ax = gca;
ax.FontSize = 20;
legend([highdots lowdots], {'High Cue', 'Low Cue'})
%%
figure; hold on;
set(gca, 'FontSize', 32)
scn_export_papersetup(400);
% cfg.title = sprintf('%s Average Image Response', cfg.channel);
% title('High Gamma Activity Following Image Onset', 'FontSize', 26)
ylabel({'Frequency (Hz)'; '2 Hz Step'}, 'FontSize', 32, 'FontWeight','bold')
xlabel({'Time After Image Onset (s)'}, 'FontSize', 32, 'FontWeight','bold')
% zlabel({'*100'});
% set(gca, 'ZTick', -2:9, 'ZTickLabel', ['-200%' '0']);

cfg = [];
cfg.title = 'Gamma Activity Following Image Onset';
cfg.fontsize = 32;
cfg.figure = gcf;
cfg.xlim = [0 1.5]; % trim the empty space
cfg.ylim = [35 101]; %focus on mid/high gamma
% cfg.zlim = [-2 5]; % set scale to be the same across figures
cfg.parameter = 'powspctrm';
cfg.baseline = [-0.5 -0.001];
cfg.baselinetype = 'db';

cfg.channel = 'RTA1';
cfg.trials      = 'all';
ft_singleplotTFR(cfg, imgview_freq)



%%
cfg = [];
cfg.baseline = [-0.5 -0.01];
cfg.keeptrials = 'yes';

ERP_bl = ft_timelockanalysis(cfg, imgview_ERP)