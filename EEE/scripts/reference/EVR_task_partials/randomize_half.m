% Define a row of 64 numbers
row = randperm(64);

% Find the indices of numbers greater than 32
indices2 = find(row > 32);
indices = find(row <= 32);

% Create a matrix with two rows
group_matrix = [row(indices); row(indices2)];
