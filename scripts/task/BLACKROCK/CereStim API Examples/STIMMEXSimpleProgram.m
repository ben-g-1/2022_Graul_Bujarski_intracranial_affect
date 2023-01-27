clear all; 
close all;
clc;

%%
%Create stimulator object
stimulator = cerestim96();

%%
%Check for stimulators
DeviceList = stimulator.scanForDevices();

%%
%Select a stimulator
stimulator.selectDevice(DeviceList(1));

%%
%Connect to the stimulator
stimulator.connect; 

%%
%Program our waveform (stim pattern)
    stimulator.setStimPattern('waveform',1,...%We can define multiple waveforms and distinguish them by ID
        'polarity',0,...%0=CF, 1=AF
        'pulses',50,...%Number of pulses in stim pattern
        'amp1',215,...%Amplitude in uA
        'amp2',215,...%Amplitude in uA
        'width1',100,...%Width for first phase in us
        'width2',100,...%Width for second phase in us
        'interphase',100,...%Time between phases in us
        'frequency',100);%Frequency determines time between biphasic pulses

%%
%Create a program sequence using any previously defined waveforms (we only
%have one)
stimulator.beginSequence;%Begin program definition
    stimulator.autoStim(1, 1);%autoStim(Channel,waveformID)
    stimulator.autoStim(2, 1);
stimulator.endSequence;%End program definition


%%
stimulator.play(1);%Play our program; number of repeats


%%
%Close it all
cbmex('close')
stimulator.disconnect;
clear stimulator
