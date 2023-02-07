% Trigger Marker %
% v.3.7.2022 %

% function to trigger sync marker with Cerestim with stim on empty channel

function timestamp = TriggerMarker(Cerestim, waveform)
    % INPUT - Cerestim: cerestim object
    %       - waveform: ID for waveform to be triggered
    % OUTPUT - timestamp: time of marker onset
    
    %%% Marker Channel %%
    % needs to be set to an empty channel on cerestim splitter box
    MarkerChannel = 32;
    
    % get time stamp
    timestamp = GetSecs;

    % trigger marker stim
    Cerestim.beginSequence();
    Cerestim.autoStim(MarkerChannel, waveform);
    Cerestim.endSequence();
    Cerestim.play(0);

end