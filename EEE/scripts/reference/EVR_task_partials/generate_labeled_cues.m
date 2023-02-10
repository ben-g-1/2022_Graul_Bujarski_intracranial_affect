%% Normal distribution

clear all;

% mkdir('SocialCueLow_gray')
% cd SocialCueLow_gray
% m = 0.30    % provide mean
% s = 0.15    % provide stdev

%mkdir('SocialCue_mean5o5')
%cd SocialCue_mean5o5
m = 0.7857;     % provide mean [0.175, 0.25, 0.5, 0.6]
v = 0.15^2;  % provide stdev^2
n = 10;     % number of ratings to display
a = 11
z = []
z(1:a,:) = 1

set(0, 'defaultFigurePosition', [300 400 400 120], 'defaultFigureColor' , [.5 .5 .5], ...
    'defaultLineColor', [1 1 1])
set(0, 'DefaultFigureInvertHardcopy', 'off')

mu = log(m/(sqrt(1 + v/m^2)));
s = sqrt(log(1 + v/m^2));
lognormdist = makedist('lognormal','mu',mu, 'sigma',s);  % creates lognormal distribution with mean m and stdev sqrt(v)

fid = fopen('stimulilv1.txt','w');   % opens textfile to write stimulus parameters
fprintf(fid, '%s %d %s %d \n', 'mean = ', m, 'stdev = ', sqrt(v))
fprintf(fid, '%s \t %s \t %s \t %s \t %s \t %s \t \n', 'Stimulusfile', 'Mean', 'StDev','Min', 'Max',  'IndivRatings') 

f = 1
%for f = 1:1   % creates and saves figures as bmp

    close all
    
    stim(f).ratings = random(lognormdist, n,1);  % draws 10 values from normal distribution as defined above
    
    for i = 1:length(stim(f).ratings)
        while stim(f).ratings(i) < 0 | stim(f).ratings(i) > 1 | ~isreal(stim(f).ratings(i))   % if outside of bounds [0 1] repeat until sample found
            stim(f).ratings(i) = random(lognormdist, 1,1);
        end
    end
    
    stim(f).ratingsmean = mean(stim(f).ratings);
    stim(f).ratingsstdev = std(stim(f).ratings);
    stim(f).min = min(stim(f).ratings);
    stim(f).max = max(stim(f).ratings);

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
    errorbar(anchors.points, zeros(a,1), z, 'black', 'LineWidth', .5); hold on;
    plot(stim(f).ratings, 1, '.', 'MarkerSize', 1, 'Color',[.5 .5 .5]); hold on;
    errorbar(stim(f).ratings, zeros(n,1), (ones(n,1)), 'w', 'LineWidth', 2); hold on;

   

    strpos = {'Extremely', 'Positive'};
    strneg = {'Extremely', 'Negative'}
    l1 = text(.85, -.85,strpos,'FontSize',16, 'Color',[1 1 1]); hold on;
    l2 = text(0, -.85,strneg,'FontSize',16, 'Color',[1 1 1]); hold on;

    xlim([0 1])
    ylim([-0.5 0.5])
    box off
    
    % stuff for filename that includes m and s
    ms = num2str(stim(f).ratingsmean,'%.3f');
    ss = num2str(stim(f).ratingsstdev,'%.3f');
    stim(f).filename = ([num2str(f), '_M', ms(:,3:5), '_STD', ss(:, 3:5), '.jpg']);
      
    fprintf(fid, '%s \t %s \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t \n', stim(f).filename, stim(f).ratingsmean, stim(f).ratingsstdev, stim(f).min, stim(f).max, stim(f).ratings');
  
    set(gcf,'Units','pixels','Position',[200 200 600 150]);  %# Modify figure size

    frame = getframe(gcf);                   %# Capture the current window
    %imwrite(frame.cdata, stim(f).filename);  %# Save the frame data
    
    
%end  

%fclose(fid);

%save('stimulilv1', 'stim')  % saves the parameter structure as mat file