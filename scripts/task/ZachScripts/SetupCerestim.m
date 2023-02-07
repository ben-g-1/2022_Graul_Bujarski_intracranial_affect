% SetupCerestim %
% v.8.1.2022 %

function [stimulator, waveID] = SetupCerestim(Amp)
    % INPUT - Amp: amplitude of stim in mA
    % OUTPUT - stimulator: CereStim object
    %        - waveID: ID # for programmed waveform

    %%%%% set stim parameters %%%%%
    polarity = 1;       % 0=anodic, 1=cathodic
    pulses = 1;         % number of biphasic pulses in stim pattern
    amp1 = Amp.*1000;         % Amplitude in uA first phase
    amp2 = Amp.*1000;         % Amplitude in uA second phase
    width1 = 200;       % Width for first phase in us
    width2 = 200;       % Width for second phase in us
    interphase = 53;   % Time between phases in us
    frequency = 200;    % Frequency in Hz; time between biphasic pulses
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % calculate # of pulses based on stim duration
%     pulse_duration = (width1 + width2 + interphase) ./ 1000000; % in secs
%     pulses = ceil(time./pulse_duration);

    % calculate actual stim duration
%     stim_duration = pulses .* pulse_duration; % in secs
    
    % Create stimulator object
    stimulator = cerestim96();

    % Scan for devices
    DeviceList = stimulator.scanForDevices();

    % check if stimulator USB connected, if not return 0
    if size(DeviceList,1) <1
        stimulator = 0;
        waveID = 0;
        return
    end
    
    % Select a device to connect to
    stimulator.selectDevice(DeviceList(1));
    
    % Connect stimulator with default method
    stimulator.disconnect();
    stimulator.connect(); 

    % read and print number of enabled modules
    devInfo = stimulator.deviceInfo();
    modules = sum(devInfo.moduleStatus);

    if modules == 4
        disp("CereStim enabled with "+modules+" modules for stimulation.")
    elseif modules > 0
        disp("Error Modules Disabled. Only "+modules+" /4 modules enabled.")
    else
        disp("No modules enabled for stimulation. Check Cerestim setup.")
    end

    % read and print current stimulation parameter max limits
    maxOutput = stimulator.stimulusMaxValue();
    disp(newline)
    disp("Maximum stimulation parameters ...")
    disp("Voltage: " + maxOutput.voltage)
    disp("Amplitude: " + maxOutput.amplitude)
    disp("Phase Charge: " + maxOutput.phaseCharge)
    disp("Frequency: " + maxOutput.frequency)

    % program single waveform
    waveID = 1; % waveform ID #
    stimulator.setStimPattern('waveform',waveID,...% waveform ID #
        'polarity',polarity,...% 0=anodic, 1=cathodic
        'pulses',pulses,...% Number of pulses in stim pattern
        'amp1',amp1,...% Amplitude in uA first phase
        'amp2',amp2,...% Amplitude in uA second phase
        'width1',width1,...% Width for first phase in us
        'width2',width2,...% Width for second phase in us
        'interphase',interphase,...% Time between phases in us
        'frequency',frequency);% Frequency in Hz

    % print waveform parameters
    waveform = stimulator.getStimPattern(waveID);
    disp(newline)
    disp("Waveform " + waveID + " set with parameters...")
    disp("Amplitude: " + waveform.amp1)
    disp("Frequency: " + waveform.frequency)
    disp("Pulses: " + waveform.pulses)
    disp("Pulse Width: " + waveform.width1)
%     disp(newline)
%     disp("Pulse Duration: " + pulse_duration .*1000000 + " us")

end