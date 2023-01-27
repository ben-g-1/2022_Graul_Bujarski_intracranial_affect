% TestCereStim %
% v.2.16.2022 %

% script to test stimulation with CereStim
clear all;
close all;
clc;

% setup cerestim
[cerestim, modules] = SetupCerestim();

% define electrodes to be stimulated; array is equal in length to # modules
% 0 = no stim on that module
electrodes = zeros(1,modules);
% set two electrodes to be stimulated
electrodes(1) = 1;
electrodes(2) = 2;

% define waveforms for stimulation; array is equal in length to # modules
waveforms = zeros(1,modules);
% both electrodes will deliver waveform 1
waveforms(1) = 1;
waveforms(2) = 1;

% perform group stimulation
cerestim.groupStimulus(1, ...% beginning of sequence. 0=false, 1=true
    1, ... % play immediatly. 0=no, 1=yes
    1, ... % number of times stimulation plays
    2, ... % number of simultaneous stimulations
    electrodes, ... % array of electrodes to stimulate
    waveforms); % array of waveforms IDs used on corresponding electrodes

cerestim.disconnect()


