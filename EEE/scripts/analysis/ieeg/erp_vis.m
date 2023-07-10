% hival = event((event.highcue_indx == 1, :));
% loval =  event(event.highcue_indx == -1);

%%
cfg = [];
cfg.pad = 'nextpow2';

cfg.keeptrials = 'yes';
% cfg.toi         = data.time{1}(hdr.Fs * 3):timres:data.time{1}(hdr.Fs * 5);  % begin to end of experiment

% cfg.covariance = 'yes';
cfg.trials = event.highcue_indx == 1;

ERP_hi = ft_timelockanalysis(cfg, imgview);

cfg.trials = event.highcue_indx == -1;

% imgview_ERP = ft_timelockanalysis(cfg, imgview);


% 
% 
ERP_lo = ft_timelockanalysis(cfg, imgview);

%%
cfg         = [];
cfg.layout  = 'natmeg_customized_eeg1005.lay';
cfg.channel   = c;
% cfg.ylim    = [-50 50]; % Millivolts
% cfg.trials = 16;

ft_singleplotER(cfg, ERP_hi);

% cfg.channel   = ft_channelselection('RTA1-RTA2', imgview_ERP.label);
% cfg.figure = 'no';
% cfg.trials = 56;
ft_singleplotER(cfg, ERP_lo);


%%
c_hi = [1 0 0];
c_lo = [0 0 0.8];
% color = [c_hi; c_lo];
% figure;
% for k =  [96 98 113 114]
k = 113;
plot_ERP_SE([ERP_hi ERP_lo], k, [c_hi; c_lo])
% end
%%
mydat_hi = squeeze(ERP_hi.trial(:,45,:));
% mydat_hi = dropColumnsWithNaN(mydat_hi);

mydat_lo = squeeze(ERP_lo.trial(:,45,:));
% mydat_lo = dropColumnsWithNaN(mydat_lo);

[h,p,ci,stats] = ttest(mydat_hi, mydat_lo);
% Find columns with the specified value
columnIndices = any(p < 0.05, 1);

% Get the column numbers
columnNumbers = find(columnIndices);

% Display the column numbers
col = (columnNumbers / hdr.Fs)-3.5;

%%
dat  = [ERP_hi ERP_lo];
electrode = 100;
color = [c_hi; c_lo];
figure;
hold on;
for i = 1:numel(dat)
    mydat = squeeze(dat(i).trial(:,electrode,:));
    mymean = mean(mydat);
    myste = ste(mydat);
    
    lower = mymean - (myste);
    upper = mymean + (myste);

    plot(dat(i).time, mymean, '-', 'LineWidth', 1, 'Color', color(i,:) ./ 2)
    fill([dat(i).time, fliplr(dat(i).time)], [lower, fliplr(upper)], ...
        color(i,:) ./ 2,'FaceAlpha', 0.3, 'EdgeColor', 'none' )

end %for

xlabel('Time (s)')
ylabel('Voltage (mV)')
plot([dat(1).time(1), dat(1).time(end)], [0 0], 'k--') % add horizontal line
% plot([0 0], cfg.ylim, 'k--') % vert. l
hold off;

%%
% Pair 6 trials: [1,46]

% % for i = 1:numel(ERP_hi.label)
% 
% cfg         = [];
% cfg.layout  = 'natmeg_customized_eeg1005.lay';
% % cfg.channel = ERP_hi.label{i};
% cfg.channel   = ERP_hi.label{44};
% cfg.ylim    = [-50 50]; % Millivolts
% % cfg.trials =  [1; 46]
% 
% 
% figure
% ft_singleplotER(cfg, ERP_hi, ERP_lo);
% % ft_plotER(cfg, ERP_hi, ERP_lo)
% 
% hold on
% xlabel('Time (s)')
% ylabel('Electric Potential (mV)')
% plot([ERP_hi.time(1), ERP_hi.time(end)], [0 0], 'k--') % add horizontal line
% plot([0 0], cfg.ylim, 'k--') % vert. l
% legend({'hi', 'lo'})
% 
% print -dpng singleplot.png
% end

%%%%% Interesting plots for sub 1
% 34 41 
% 
% 137 ? 136 132 131
% 
% **128 LTA7/8
% 106 LFC3/4
% 93 RIA5/6
% 89
% 
% RTA3 51
% 
% RPAG 45 **44**
%%%%%

%% Multiplotting all electrodes
% need to get label names from
% reref_depths{i}.label({1:numel(reref_depths{i}.label})
% first create multiplot for reref_depths{i}
% for loop for each label 
% check if numel(reref{
cfg         = [];
cfg.layout  = 'natmeg_customized_eeg1005.lay';
l = 1;

erpdir = fullfile(subjdir, 'derivatives', 'ERP');


for i = 1:numel(reref_depths)
    ename = regexp(ERP_hi.label{l}, '^\D*', 'match', 'once');
    if numel(reref_depths{i}.label) < 7        
        figure('units','normalized','outerposition',[0 0 1 1]); 
        for j = 1:numel(reref_depths{i}.label)
            subplot(6,1, j); hold on;
            cfg.channel = ERP_hi.label{l};
            plot_ERP_SE([ERP_hi ERP_lo], l, [c_hi; c_lo])
            title([string(ERP_hi.label{l}), string(l)])
            l = l + 1;
        end
        sgtitle('Img Hi Val vs Img Lo Val')
        % hL = subplot(6,1,7);
        % poshL = get(hL,'position');     % Getting its position
        % lgd = legend(hL,[h1;h2;h3;h4],'RandomPlot1','RandomPlot2','RandomPlot3','RandomPlot4');
        % set(lgd,'position',poshL);      % Adjusting legend's position
        % axis(hL,'off');
        print(fullfile(erpdir, ename), '-dpng')
        hold off

    elseif numel(reref_depths{i}.label) < 13
        figure('units','normalized','outerposition',[0 0 1 1]); 
        for j = 1:numel(reref_depths{i}.label)
            subplot(6,2, j); hold on;
            cfg.channel = ERP_hi.label{l};
            plot_ERP_SE([ERP_hi ERP_lo], l, [c_hi; c_lo])
            title([string(ERP_hi.label{l}); string(l)])

            l = l + 1;
        end
        
        sgtitle('Img Hi Val vs Img Lo Val')
        % hL = subplot(6,2,2.5);
        % poshL = get(hL,'position');     % Getting its position
        % lgd = legend(hL,['high';'low'],'RandomPlot1','RandomPlot2','RandomPlot3','RandomPlot4');
        % set(lgd,'position',poshL);      % Adjusting legend's position
        % axis(hL,'off');
        print(fullfile(erpdir, ename), '-dpng')
        hold off

    elseif numel(reref_depths{i}.label) < 19
                figure('units','normalized','outerposition',[0 0 1 1]); 
        for j = 1:numel(reref_depths{i}.label)
            subplot(6,3, j); hold on;
            plot_ERP_SE([ERP_hi ERP_lo], l, [c_hi; c_lo])
            title([string(ERP_hi.label{l}), string(l)])
            l = l + 1;
        end
        sgtitle('Img Hi Val vs Img Lo Val')

        print(fullfile(erpdir, ename), '-dpng')
        hold off;

    end
end
    
%%
%%
% cfg           = [];
% cfg.operation = 'x1-x2'% / x2';
% cfg.parameter = 'avg';
% 
% difference_wave = ft_math(cfg, ERP_hi, ERP_lo);
function newData = dropColumnsWithNaN(data)
    % Find columns with NaN values
    nanColumns = any(isnan(data), 1);
    
    % Select columns without NaN values
    newData = data(:, ~nanColumns);
end
