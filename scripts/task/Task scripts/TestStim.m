% function for testing cerestim stimulation before task

function TestStim(amp, channels, time)
    % OUTPUT - none
    % INPUT - Amp: amplitude of stim in mA

    % initialize stimulator
    [cerestim, waveform] = SetupCerestim(amp);

    % stimulate for designated length of time
    TriggerStim(cerestim, waveform, channels);
    WaitSecs(time);
    cerestim.stop();

    % disconnect stimulator
    cerestim.disconnect;
    clear cerestim;
end