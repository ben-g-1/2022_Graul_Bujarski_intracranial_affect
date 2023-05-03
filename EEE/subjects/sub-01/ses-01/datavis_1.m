% Step 1: Import the data
% data = readtable('data.csv'); % Replace 'data.csv' with the appropriate filename or path

% Step 2: Extract the ratings for high and low cues
high_cue_ratings = sth.val_rating; % Replace 'high_cue_ratings' with the column name in your dataset
low_cue_ratings = stl.val_rating; % Replace 'low_cue_ratings' with the column name in your dataset

% Step 3: Calculate descriptive statistics
mean_high = mean(high_cue_ratings);
mean_low = mean(low_cue_ratings);

median_high = median(high_cue_ratings);
median_low = median(low_cue_ratings);

std_high = std(high_cue_ratings);
std_low = std(low_cue_ratings);

min_high = min(high_cue_ratings);
min_low = min(low_cue_ratings);

max_high = max(high_cue_ratings);
max_low = max(low_cue_ratings);

% Step 4: Perform a sign-ranked test
[p, ~, stats] = signrank(high_cue_ratings, low_cue_ratings); % Perform the sign-ranked test

% Print the results
fprintf('p-value: %.4f\n', p);
if p < 0.05
    fprintf('There is a significant difference between the ratings for high and low cues.\n');
else
    fprintf('There is no significant difference between the ratings for high and low cues.\n');
end

% Step 5: Sample visualizations
% Box plot
figure;
boxplot([high_cue_ratings, low_cue_ratings], 'Labels', {'High Cue', 'Low Cue'});
ylabel('Ratings');
title('Comparison of Ratings for High and Low Cues');

% Histograms
figure;
histogram(high_cue_ratings, 'Normalization', 'probability', 'FaceAlpha', 0.5, 'DisplayName', 'High Cue', 'NumBins', 6);
hold on;
histogram(low_cue_ratings, 'Normalization', 'probability', 'FaceAlpha', 0.5, 'DisplayName', 'Low Cue', 'NumBins', 6);
xlabel('Ratings');
ylabel('Probability');
title('Distribution of Ratings for High and Low Cues');
legend;

% Bar plot
figure;
bar([mean_high, mean_low], 'FaceColor', 'b');
hold on;
errorbar([mean_high, mean_low], [std_high, std_low], 'k', 'LineStyle', 'none');
ylabel('Mean Ratings');
xticks([1, 2]);
xticklabels({'High Cue', 'Low Cue'});
title('Mean Ratings for High and Low Cues');
