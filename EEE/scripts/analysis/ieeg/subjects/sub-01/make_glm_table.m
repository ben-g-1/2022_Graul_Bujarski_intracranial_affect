full = table();
for j = 1:size(imgview_freq.powspctrm, 2)
    for k = 1:size(imgview_freq.powspctrm, 3)
        for l = 1:size(imgview_freq.powspctrm, 4)

            X = design;
            Y = squeeze(imgview_freq.powspctrm(:,j,k,l));
            
            % comb = table('VariableNames', {'EEG', 'valence', 'trial', 'chan', 'freq', 'time'});
            comb = table();
            comb.eeg = Y; 
            comb.valence = X(:,2);
            comb.trial(:) = [1:63];
            comb.chan(:) = j;
            comb.freq(:) = k;
            comb.time(:) = l;

            full = [full; comb];
        end
    end
end

%%


num_j = size(imgview_freq.powspctrm, 2);
num_k = size(imgview_freq.powspctrm, 3);
num_l = size(imgview_freq.powspctrm, 4);

% Preallocate the table with an estimated size (adjust if needed)
estimatedSize = num_j * num_k * num_l*63;
full = table('Size',[estimatedSize, 6], 'VariableTypes',{'double','double','double','double','double','double'}, ...
    'VariableNames',{'eeg', 'valence', 'trial', 'chan', 'freq', 'time'});

rowIdx = 1;  % Track the row index

for j = 1:num_j
    for k = 1:num_k
        for l = 1:num_l
            X = design;
            Y = squeeze(imgview_freq.powspctrm(:,j,k,l));
            
            numSamples = numel(Y);
            
            % Preallocate a temporary table for this iteration
            comb = table('Size',[numSamples, 6], 'VariableTypes',{'double','double','double','double','double','double'}, ...
                'VariableNames',{'eeg', 'valence', 'trial', 'chan', 'freq', 'time'});
            
            % Assign values to the temporary table
            comb.eeg = Y; 
            comb.valence = X(:,2);
            comb.trial = (1:numSamples)';
            comb.chan(:) = j;
            comb.freq(:) = k;
            comb.time(:) = l;
            
            % Add the temporary table to the main table
            full(rowIdx:rowIdx+numSamples-1, :) = comb;
            rowIdx = rowIdx + numSamples;
        end
    end
end
