m = 0.7857;     % provide mean [0.175, 0.25, 0.5, 0.6]
v = 0.15^2;  % provide stdev^2
n = 10;     % number of ratings to display
a = 11
z = zeros(n,2)


set(0, 'defaultFigurePosition', [300 400 400 120], 'defaultFigureColor' , [.5 .5 .5], ...
    'defaultLineColor', [1 1 1])
set(0, 'DefaultFigureInvertHardcopy', 'off')

mu = log(m/(sqrt(1 + v/m^2)));
s = sqrt(log(1 + v/m^2));
lognormdist = makedist('lognormal','mu',mu, 'sigma',s);  % creates lognormal distribution with mean m and stdev sqrt(v)

%fid = fopen('stimulilv1.txt','w');   % opens textfile to write stimulus parameters
%fprintf(fid, '%s %d %s %d \n', 'mean = ', m, 'stdev = ', sqrt(v))
%fprintf(fid, '%s \t %s \t %s \t %s \t %s \t %s \t \n', 'Stimulusfile', 'Mean', 'StDev','Min', 'Max',  'IndivRatings') 

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
   figure1 = figure('Color',[.5 .5 .5], 'Position', [800 400 800 250]);
    axes1 = axes('Parent', figure1, 'Position', [0.15 0.30 0.7 0.5], ...
                 'Color', [.5 .5 .5], 'YColor', [.5 .5 .5],...
                 'XColor', [.5 .5 .5]);
    hold(axes1, 'all');

    anchors = []
    anchors.points = [0 .1 .2 .3 .4 .5 .6 .7 .8 .9 1]';
    line([0,1], [0 0], 'Color', 'w', 'LineWidth', 2); hold on;
    %plot(anchors.points, 1, '.', 'MarkerSize', 1, 'Color',[.5 .5 .5]); hold on;
    %errorbar(anchors.points, zeros(a,1), z, 'black', 'LineWidth', .5); hold on;
    %plot(stim(f).ratings, 1, '.', 'MarkerSize', 1, 'Color',[.5 .5 .5]); hold on;
    %errorbar(stim(f).ratings, zeros(n,1), (ones(n,1)), 'w', 'LineWidth', 1); hold on;

   

    strpos = {'Extremely', 'Positive'};
    strneg = {'Extremely', 'Negative'};
    strneut = {'Neutral'}
    strl = 'l'
    l1 = text(1.04, 0 ,strpos,'FontSize',16, 'Color',[1 1 1]); hold on;
    l2 = text(-.2, 0 ,strneg,'FontSize',16, 'Color',[1 1 1]); hold on;
    l3 = text (0.45, -.65, strneut, 'FontSize',16, 'Color',[1 1 1]); hold on;
     
    %Gotta be a better way to iterate over the list [0:.1:1], but
    %can't figure it out now
    a0 =  text(0, 0, 'l','FontSize',16, 'Color',[1 1 1]); hold on;
    a1 =  text(0.1, 0, 'l','FontSize',16, 'Color',[1 1 1]); hold on;
    a2 =  text(0.1, 0, 'l','FontSize',16, 'Color',[1 1 1]); hold on;
    a3 =  text(0.2, 0, 'l','FontSize',16, 'Color',[1 1 1]); hold on;
    a4 =  text(0.3, 0, 'l','FontSize',16, 'Color',[1 1 1]); hold on;
    a5 =  text(0.4, 0, 'l','FontSize',16, 'Color',[1 1 1]); hold on;
    a6 =  text(0.5, 0, 'l','FontSize',16, 'Color',[1 1 1]); hold on;
    a7 =  text(0.6, 0, 'l','FontSize',16, 'Color',[1 1 1]); hold on;
    a8 =  text(0.7, 0, 'l','FontSize',16, 'Color',[1 1 1]); hold on;
    a9 =  text(0.8, 0, 'l','FontSize',16, 'Color',[1 1 1]); hold on;
    a10 =  text(0.9, 0, 'l','FontSize',16, 'Color',[1 1 1]); hold on;
    a11 =  text(1, 0, 'l','FontSize',16, 'Color',[1 1 1]); hold on;

    %xlim([0 1])
    ylim([-0.5 0.5])
    box off