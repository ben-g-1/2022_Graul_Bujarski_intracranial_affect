% TriggerStim %
% v3.7.2022 %

% function to trigger cerestim to deliver stimulation
% can stimulate up to 4 channels, all with the same waveform

function timestamp = TriggerStim(Cerestim, waveform, channels)
    % INPUT - Cerestim: stimulator object
    %       - waveform: ID for waveforms to be delivered
    %       - channels: array of channels to be stimulated (max length =4)
    % OUTPUT - timestamp: time of stim onset
    
    % check # of channels selected for stimulation and set up stim sequence

    %%%% 1 CHANNEL %%%%
    if length(channels) == 1
        Cerestim.beginSequence();
        Cerestim.autoStim(channels(1), waveform);
        Cerestim.endSequence();
    %%% 2 CHANNELS %%%
    elseif length(channels) == 2
        Cerestim.beginSequence();
        Cerestim.beginGroup();
        Cerestim.autoStim(channels(1), waveform);
        Cerestim.autoStim(channels(2), waveform);
        Cerestim.endGroup();
        Cerestim.endSequence();
    %%% 3 CHANNELS %%%
    elseif length(channels) == 3
        Cerestim.beginSequence();
        Cerestim.beginGroup();
        Cerestim.autoStim(channels(1), waveform);
        Cerestim.autoStim(channels(2), waveform);
        Cerestim.autoStim(channels(3), waveform);
        Cerestim.endGroup();
        Cerestim.endSequence();
    %%% 4 CHANNELS %%%
    elseif length(channels) == 4
        Cerestim.beginSequence();
        Cerestim.beginGroup();
        Cerestim.autoStim(channels(1), waveform);
        Cerestim.autoStim(channels(2), waveform);
        Cerestim.autoStim(channels(3), waveform);
        Cerestim.autoStim(channels(4), waveform);
        Cerestim.endGroup();
        Cerestim.endSequence();
    %%% other # of channels (Error)
    else
        % disconnect stimulator
        Cerestim.disconnect;
        clear Cerestim
        % clean up screens
        Screen('CloseAll')
        close all;
        % display error message
        disp("ERROR. Invalid number of stimulation channels.\nMin 1, Max 4 channels must be selected.")
        return
    end
    
    % get time stamp
    timestamp = GetSecs;
    % play stim sequence
    Cerestim.play(0);

end