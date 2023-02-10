%function [cue_high, cue_low] = generateCue(ratingMean, ratingSD, pairnum)

ratingMean = 1
ratingSD = 1
m = ratingMean/7;
sd = ratingSD/7;
v = sd^2;  % provide stdev^2
n = 10;     % number of ratings to display
pairnum = 1;
highmean = m + sd
lowmean = m - sd


%% High
highmu = log(highmean/(sqrt(1 + v/highmean^2)));
highs = sqrt(log(1 + v/highmean^2));
lognormdist = makedist('lognormal','mu',highmean, 'sigma',highs);% creates lognormal distribution with mean m and stdev sqrt(v)
highlines = random(lognormdist, n,1);
 for i = 1:length(highlines)
        while highlines(i) < 0 | highlines(i) > 1 | ~isreal(highlines(i))   % if outside of bounds [0 1] repeat until sample found
            highlines(i) = random(lognormdist, 1,1);
        end
    end

%% Low
lowmu = log(lowmean/(sqrt(1 + v/lowmean^2)));
lows = sqrt(log(1 + v/lowmean^2));
lognormdist = makedist('lognormal','mu',lowmean, 'sigma',lows);% creates lognormal distribution with mean m and stdev sqrt(v)
lowlines = random(lognormdist, n,1);