function plotERPWithShading(dat, shadingType, cond)
    color = hsv(numel(dat)); % Define colors for different conditions
    figure;
    % Initialize hold outside the loop
    hold on;

    for i = 1:numel(dat)
        mydat = squeeze(dat(i).powspctrm);
        dat(i).condition = cond{i};
        % Calculate mean and shading
        mymean = mean(mydat);
        if strcmp(shadingType, 'confidence')
            mystd = std(mydat);
            conf_interval = 1.96 * mystd / sqrt(size(mydat, 1)); % 1.96 for 95% confidence interval
            shadingstr = '95% CI';
            lower = mymean - conf_interval;
            upper = mymean + conf_interval;
        elseif strcmp(shadingType, 'SEM')
            myste = std(mydat) / sqrt(size(mydat, 1));
            shadingstr = 'SEM';
            lower = mymean - myste;
            upper = mymean + myste;
        else
            error('Invalid shading type. Use "confidence" or "SEM".');
        end

        % Plot mean line with dynamic legend entry
        plot(dat(i).time, mymean, '-', 'LineWidth', 1, 'Color', color(i,:), 'DisplayName', dat(i).condition)

        % Fill between the upper and lower bounds
        ci = fill([dat(i).time, fliplr(dat(i).time)], [lower, fliplr(upper)], ...
            color(i,:), 'FaceAlpha', 0.3, 'EdgeColor', 'none');

        % Exclude shading from the legend
        set(get(get(ci,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    end
    
    % Release hold after the loop
    hold off;
    
    legend('show'); % Display legend
    xlabel('Time');
    ylabel('Mean Power (uV)');

    % Include electrode and shading type in the title
    title({sprintf('%s response to %s', dat(1).cfg.roi, dat(1).cfg.cond); ['Shading: ' shadingstr]});
end
