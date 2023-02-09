% Define the number of ones
num_ones = 16;

% Define the number of twos
num_twos = 16;

% Create a row with 16 ones and 16 twos
row = [ones(1, num_ones), 2 * ones(1, num_twos)];

% Randomly permute the order of the ones and twos
row = row(randperm(length(row)));
row2 = 3 - row

A = [row; row2]