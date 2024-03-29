
%function [cue_high, cue_low] = generateCue(ratingMean, ratingSD, pairnum)

%% Normal distribution
% Adapted from 
ratingMean = 1
ratingSD = 1
m = ratingMean/7;
sd = ratingSD/7;
v = sd^2;  % provide stdev^2
n = 10;     % number of ratings to display
pairnum = 1;

set(0, 'defaultFigurePosition', [300 400 400 120], 'defaultFigureColor' , [.5 .5 .5], ...
    'defaultLineColor', [1 1 1])
set(0, 'DefaultFigureInvertHardcopy', 'off')

for f = 1:2
    if f == 1
        cuemean = m + sd;
        cuetype = 'high';

%% This could be a function to call
mu = log(cuemean/(sqrt(1 + v/cuemean^2)));
s = sqrt(log(1 + v/m^2));
lognormdist = makedist('lognormal','mu',mu, 'sigma',s);  % creates lognormal distribution with mean m and stdev sqrt(v)

fid = fopen('stimulilv1.txt','w');   % opens textfile to write stimulus parameters
fprintf(fid, '%s %d %s %d \n', 'mean = ', m, 'stdev = ', sqrt(v))
fprintf(fid, '%s \t %s \t %s \t %s \t %s \t %s \t \n', 'Stimulusfile', 'Mean', 'StDev','Min', 'Max',  'IndivRatings') 


  

    
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
    figure1 = figure('Color',[.5 .5 .5], 'Position', [300 400 600 150]);
    axes1 = axes('Parent', figure1, 'Position', [0.025 0.025 0.95 0.95], ...
                 'Color', [.5 .5 .5], 'YColor', [.5 .5 .5],...
                 'XColor', [.5 .5 .5]);
    hold(axes1, 'all');

    line([0,1], [0 0], 'Color', 'w', 'LineWidth', 2); hold on;
    plot(stim(f).ratings, 1, '.', 'MarkerSize', 10, 'Color',[.5 .5 .5]); hold on;
    errorbar(stim(f).ratings, zeros(n,1), (ones(n,1)), 'w', 'LineWidth', 2); hold on;

    strpos = {'Extremely', 'Positive'};
    strneg = {'Extremely', 'Negative'};
    strneut = {'Neutral'}
    strl = 'l'
    lbl_right = text(1.04, 0 ,strpos,'FontSize',16, 'Color',[1 1 1]); hold on;
    lbl_left = text(-.2, 0 ,strneg,'FontSize',16, 'Color',[1 1 1]); hold on;
    lbl_low = text (0.45, -.65, strneut, 'FontSize',16, 'Color',[1 1 1]); hold on;

    %xlim([0 1])
    ylim([-0.5 0.5])
    box off
    
    % stuff for filename that includes m and s
    ms = num2str(stim(f).ratingsmean,'%.3f');
    ss = num2str(stim(f).ratingsstdev,'%.3f');
    stim(f).filename = (['Pair', num2str(pairnum), "_", cuetype, '_M', ms(:,3:5), '_STD', ss(:, 3:5), '.jpg']);
      
    %fprintf(fid, '%s \t %s \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t \n', stim(f).filename, stim(f).ratingsmean, stim(f).ratingsstdev, stim(f).min, stim(f).max, stim(f).ratings');
  
    set(gcf,'Units','pixels','Position',[200 200 600 150]);  %# Modify figure size

    saveas(gcf, 'mufile.png')
    frame = getframe(gcf);                   %# Capture the current window
    imwrite(frame.cdata, stim(f).filename);  %# Save the frame data
    
 
   
   

fclose(fid);

save('cuesall', 'cues')  % saves the parameter structure as mat file

close all

    else
        cuemean = m - sd;
        cuetype = 'low'
mu = log(cuemean/(sqrt(1 + v/cuemean^2)));
s = sqrt(log(1 + v/m^2));
lognormdist = makedist('lognormal','mu',mu, 'sigma',s);  % creates lognormal distribution with mean m and stdev sqrt(v)

fid = fopen('stimulilv1.txt','w');   % opens textfile to write stimulus parameters
fprintf(fid, '%s %d %s %d \n', 'mean = ', m, 'stdev = ', sqrt(v))
fprintf(fid, '%s \t %s \t %s \t %s \t %s \t %s \t \n', 'Stimulusfile', 'Mean', 'StDev','Min', 'Max',  'IndivRatings') 


  

    
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
    figure1 = figure('Color',[.5 .5 .5], 'Position', [300 400 600 150]);
    axes1 = axes('Parent', figure1, 'Position', [0.025 0.025 0.95 0.95], ...
                 'Color', [.5 .5 .5], 'YColor', [.5 .5 .5],...
                 'XColor', [.5 .5 .5]);
    hold(axes1, 'all');

    line([0,1], [0 0], 'Color', 'w', 'LineWidth', 2); hold on;
    plot(stim(f).ratings, 1, '.', 'MarkerSize', 10, 'Color',[.5 .5 .5]); hold on;
    errorbar(stim(f).ratings, zeros(n,1), (ones(n,1)), 'w', 'LineWidth', 2); hold on;

    strpos = {'Extremely', 'Positive'};
    strneg = {'Extremely', 'Negative'};
    strneut = {'Neutral'}
    strl = 'l'
    lbl_right = text(1.04, 0 ,strpos,'FontSize',16, 'Color',[1 1 1]); hold on;
    lbl_left = text(-.2, 0 ,strneg,'FontSize',16, 'Color',[1 1 1]); hold on;
    lbl_low = text (0.45, -.65, strneut, 'FontSize',16, 'Color',[1 1 1]); hold on;

    %xlim([0 1])
    ylim([-0.5 0.5])
    box off
    
    % stuff for filename that includes m and s
    ms = num2str(stim(f).ratingsmean,'%.3f');
    ss = num2str(stim(f).ratingsstdev,'%.3f');
    stim(f).filename = (['Pair', num2str(pairnum), "_", cuetype, '_M', ms(:,3:5), '_STD', ss(:, 3:5), '.jpg']);
      
    %fprintf(fid, '%s \t %s \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t \n', stim(f).filename, stim(f).ratingsmean, stim(f).ratingsstdev, stim(f).min, stim(f).max, stim(f).ratings');
  
    set(gcf,'Units','pixels','Position',[200 200 600 150]);  %# Modify figure size

    frame = getframe(gcf);                   %# Capture the current window
    imwrite(frame.cdata, stim(f).filename);  %# Save the frame data
    
 
   
   

fclose(fid);

save('cuesall', 'cues')  % saves the parameter structure as mat file
    end
end
