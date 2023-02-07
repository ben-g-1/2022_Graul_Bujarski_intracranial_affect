% DeliverStim %
% v. 2.16.2022 %

function Status = DeliverStim(stimulator, electrodes, waveforms)
    % INPUT - stimulator: cerestim object
    %       - electrodes: array of electrode IDs, 0=empty
    %       - waveforms: array of waveform IDs, 0=empty
    % OUTPUT - Status: sequence status
    %           0= stopped, 1=paused, 2=playing, 3=writing, 4=waiting for
    %           trigger

    % perform group stimulation
    stimulator.groupStimulus(1, ...% beginning of sequence. 0=false, 1=true
    1, ... % play immediatly. 0=no, 1=yes
    1, ... % number of times stimulation plays
    2, ... % number of simultaneous stimulations
    electrodes, ... % array of electrodes to stimulate
    waveforms); % array of waveforms IDs used on corresponding electrodes
    
    % return sequence status
    Status = stimulator.getSequenceStatus;
end
