dataPath = 'C:\Users\bgrau\GitHub\ieeg_affect\EEE\subjects\sub-02\ses-01';
load(fullfile(dataPath, 'stim_table_full.mat'));

cueHighLow = stim_table.highcue_indx;
cueMean = stim_table.cue_observed_mean;
pair = stim_table.Pair;
rating = stim_table.val_rating;

figure('Name', 'Ratings by cue and pair');

cueColors = {[1 0 0] [0 0 1]};
isHighCue = cueHighLow > 0;
isLowCue = cueHighLow < 0;

[~, highOrder] = sort(pair(isHighCue));
highData = [rating(isHighCue) pair(isHighCue)];
highData = highData(highOrder, :);

[~, lowOrder] = sort(pair(isLowCue));
lowData = [rating(isLowCue) pair(isLowCue)];
lowData = lowData(lowOrder, :);

y = [highData(:, 1) lowData(:, 1)];  % ratings, [high low]
x = [highData(:, 2) lowData(:, 2)];  % pairs, [high low]

difference = -(diff(y')'); % high - low difference scores for matched pairs

plot(x(:, 1), y(:, 1), 'o', 'MarkerFaceColor', cueColors{1}); hold on;
plot(x(:, 2), y(:, 2), 'o', 'MarkerFaceColor', cueColors{2});

xlabel('Pair');
ylabel('Valence Rating (unpleasant to pleasant)');
hold off;

[hyp, pval, ci, stat] = ttest(difference);
fprintf('High vs. low cue effect: M = %3.2f, SE = %3.2f, t(%3.0f) = %3.2f, p = %3.6f\n', mean(difference), ste(difference), stat.df(1), stat.tstat(1), pval(1));

pairTable = table;
pairTable.ratingsHigh = y(:, 1);
pairTable.ratingsLow = y(:, 2);
pairTable.ratingsDiff = difference;
pairTable.pair = x(:, 1);

meanRatings = mean(y, 2);
[~, sortedIndices] = sort(meanRatings);

ysort = y(sortedIndices, :);
dsort = difference(sortedIndices);

figure('Name', 'Ratings by cue and pair sorted'); hold on;
plot(x(:, 1), ysort(:, 1), 'o', 'Color', cueColors{1}./2, 'MarkerFaceColor', cueColors{1});
plot(x(:, 2), ysort(:, 2), 'o', 'Color', cueColors{2}./2, 'MarkerFaceColor', cueColors{2});

whPositiveDiff = dsort > 0;
plot(x(whPositiveDiff, :)', ysort(whPositiveDiff, :)', 'k-');
plot(x(~whPositiveDiff, :)', ysort(~whPositiveDiff, :)', '-', 'Color', [.7 .4 .4]);
hold off;

% Sort the table based on the difference between ratings in descending order
[~, sortedIndices] = sort(abs(dsort(:, 1)), 'descend');
dsortSorted = dsort(sortedIndices, :);
ysortSorted = ysort(sortedIndices, :);

plot(x(:, 1), ysortSorted(:, 1), 'o', 'Color', cueColors{1}./2, 'MarkerFaceColor', cueColors{1});
plot(x(:, 2), ysortSorted(:, 2), 'o', 'Color', cueColors{2}./2, 'MarkerFaceColor', cueColors{2});

whPositiveDiff = dsortSorted > 0;
plot(x(whPositiveDiff, :)', ysortSorted(whPositiveDiff, :)', 'k-');
plot(x(~whPositiveDiff, :)', ysortSorted(~whPositiveDiff, :)', '-', 'Color', [.7 .4 .4]);

xlabel('Pair');
ylabel('Valence Rating (unpleasant to pleasant)');

