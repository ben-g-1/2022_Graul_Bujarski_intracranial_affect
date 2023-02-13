f = 1;
a = 11
z = []
z(1:a,:) = 0.125/4
%for f = 1:1   % creates and saves figures as bmp

    close all
    
    %stim(f).ratings = random(lognormdist, n,1);  % draws 10 values from normal distribution as defined above
    
    % draws figure
    figure1 = figure('Color',[.5 .5 .5], 'Position', [800 400 600 250]);
    axes1 = axes('Parent', figure1, 'Position', [0.025 0.30 0.95 0.5], ...
                 'Color', [.5 .5 .5], 'YColor', [.5 .5 .5],...
                 'XColor', [.5 .5 .5]);
    hold(axes1, 'all');
    
    anchors = []
    anchors.points = [0 .1 .2 .3 .4 .5 .6 .7 .8 .9 1]';
    line([0,1], [0 0], 'Color', 'w', 'LineWidth', 2); hold on;
    plot(anchors.points, 1, '.', 'MarkerSize', 1, 'Color',[.5 .5 .5]); hold on;
    errorbar(anchors.points, zeros(a,1), z, 'w', 'LineWidth', .5); hold on;
    plot(stim(f).ratings, 1, '.', 'MarkerSize', 1, 'Color',[.5 .5 .5]); hold on;
    errorbar(stim(f).ratings, zeros(n,1), (ones(n,1)), 'w', 'LineWidth', 2); hold on;

   

    strpos = {'Extremely', 'Positive'};
    strneg = {'Extremely', 'Negative'};
    l1 = text(.85, -.85,strpos,'FontSize',16, 'Color',[1 1 1]); hold on;
    l2 = text(0, -.85,strneg,'FontSize',16, 'Color',[1 1 1]); hold on;

    xlim([0 1])
    ylim([-0.5 0.5])
    %[x,y] = ginput(2)
    box off