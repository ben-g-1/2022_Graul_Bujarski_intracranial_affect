function p = plot_ERP_SE(dat, electrode, color)

% Example usage
% plot_ERP_SE([ERP_hi ERP_lo], 44, [cred; cgreen])

figure();

hold on;
for i = 1:numel(dat)
    mydat = squeeze(dat(i).powspctrm(:,electrode,:,:));
    mymean = mean(mydat);
    myste = std(mydat) / sqrt(numel(mydat(:,1)));
    
    lower = mymean - myste/2;
    upper = mymean + myste/2;

    plot(dat(i).time, mymean, '-', 'LineWidth', 1, 'Color', color(i,:) ./ 2, 'DisplayName', 'High Cue')
    fill([dat(i).time, fliplr(dat(i).time)], [lower, fliplr(upper)], ...
        color(i,:) ./ 2,'FaceAlpha', 0.3, 'EdgeColor', 'none')

    % mydat = squeeze(dat(2).powspctrm(:,electrode,:,:));
    % mymean2 = mean(mydat);
    % myste = std(mydat);
    % 
    % lower = mymean2 - myste/2;
    % upper = mymean2 + myste/2;
    % 
    % plot(dat(2).time, mymean2, '-', 'LineWidth', 1, 'Color', color(2,:) ./ 2, 'DisplayName', 'Low Cue')
    % fill([dat(2).time, fliplr(dat(2).time)], [lower, fliplr(upper)], ...
    %     color(2,:) ./ 2,'FaceAlpha', 0.3, 'EdgeColor', 'none')

end %for

ax = gca;
ax.FontSize = 18;
title('ERP Image Response', 'FontSize', 26)

xlabel('Time (s)', 'FontSize', 24, 'FontWeight','bold')
ylabel('Voltage (µV)', 'FontSize', 24, 'FontWeight','bold')
% plot([0 2], [0 0], 'k--') % add horizontal line
% ylim([-160 40])
% xlim([0 1.5])
% plot([0 0], [-160 40], 'k:') % vert. l
% legend('High Cue', '', 'Low Cue', '', '', 'FontSize', 18)

hold off;

end %function