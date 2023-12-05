%%% Permutation Testing on Discovery (Global Beta Variance)

% Steps: 
% Load time/frequency data
% Create design matrix
% Calculate beta weights for all time/frequency combinations
    % Per channel and per design feature
% Write .mat object for combining with others


% First make sure that variables are passing correctly

chans = getenv('chans');
outpath = getenv('outpath');

cd(outpath);

switch chans
    case  1
        first = 1;
        last = 25;
        chunk_size = numel(first:last);
    case 2
        first = 26;
        last = 50;
        chunk_size = numel(first:last);
    case 3
        first = 51;
        last = 75;
        chunk_size = numel(first:last);
    case 4
        first = 76;
        last = 100;
        chunk_size = numel(first:last);
    case 5
        first = 101;
        last = 121;
        chunk_size = numel(first:last);
end


disp(['First:', first]);
disp(['Last:', last]);
disp(['Channels:', chunk_size]);

% Save example 
save(sprintf('exampleFirst%d', chans), 'first');

quit
