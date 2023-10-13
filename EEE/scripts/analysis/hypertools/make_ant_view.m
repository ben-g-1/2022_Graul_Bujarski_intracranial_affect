load("C:\Users\bgrau\Dropbox (Dartmouth College)\2023_Graul_EEE\Data\processed\sub-01\imgview\sub-01_imgview_freq_fullspec.mat")


% for i = 1:64
%     if imgview_freq.trialinfo.val_rating(i) > 60
%         imgview_freq.trialinfo.val_type(i) = 1;
%     elseif imgview_freq.trialinfo.val_rating(i) < 40
%         imgview_freq.trialinfo.val_type(i) = -1;
%     else
%         imgview_freq.trialinfo.val_type(i) = 0;
%     end
% 
% end
%%

cfg = [];
cfg.channel = 'RTA1';
cfg.trials = imgview_freq.trialinfo.val_type == 1;
cfg.latency = [-2 0];
% cfg.keeptrials = 'no';
% cfg.avgoverrpt = 'yes';
tempall = ft_selectdata(cfg, imgview_freq);
temppow = squeeze(tempall.powspctrm);
r = reshape(temppow, [], 201)';

RTA_pos_ant = rmmissing(r)';
writematrix(RTA_pos_ant, 'RTA_pos_ant.csv')
%%
cfg = [];
cfg.channel = 'RTA1';
cfg.trials = imgview_freq.trialinfo.val_type == -1;
cfg.latency = [-2 0];
% cfg.keeptrials = 'no';
% cfg.avgoverrpt = 'yes';
tempall = ft_selectdata(cfg, imgview_freq);
temppow = squeeze(tempall.powspctrm);
r = reshape(temppow, [], 201)';


RTA_neg_ant = rmmissing(r)';
writematrix(RTA_neg_ant, 'RTA_neg_ant.csv')

%%
cfg = [];
cfg.channel = 'RTA1';
cfg.trials = imgview_freq.trialinfo.val_type == 1;
cfg.latency = [0 2];
% cfg.keeptrials = 'no';
% cfg.avgoverrpt = 'yes';
tempall = ft_selectdata(cfg, imgview_freq);
temppow = squeeze(tempall.powspctrm);
r = reshape(temppow, [], 201)';

RTA_pos_view = rmmissing(r)';
writematrix(RTA_pos_view, 'RTA_pos_view.csv')

%%
cfg.trials = imgview_freq.trialinfo.val_type == -1;

tempall = ft_selectdata(cfg, imgview_freq);
temppow = squeeze(tempall.powspctrm);
r = reshape(temppow, [], 201)';

RTA_neg_view = rmmissing(r)';
writematrix(RTA_neg_view, 'RTA_neg_view.csv')
