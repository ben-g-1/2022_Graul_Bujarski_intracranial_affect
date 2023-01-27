% RunTask - Encoding %
% v.3.8.2022

% script to run EMO task - Encoding session

clear all;
close all;
clc;
%% 

%%%% FOR TESTING %%%
% use only during testing with multiple monitor dock set up to avoid errors
% Screen('Preference', 'SkipSyncTests', 1);
%%%%%%%%%%%%%%%%%%%%
%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
%%% VARIABLES TO BE CHANGED %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% subject ID 
SUBJ_ID = 'AMYR21PT04';  % format: 'AMYR21PTxx

% electrode ID Numbers for stimulation
StimChannels = [1 2];
    % select channels for stimulation
    % use channel numbers from cerestim splitter box
    % seperate multiple channels with a single space (ex. [1 2])
    %%% MAX of 4 channels with 4 modules enabled on cerestim
    %%% Min of 1 channel must be assigned

% stimulation intensity (in mA)
StimAmp = 0.4;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% VARIABLES BELOW SHOULD NOT BE CHANGED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SET UP TASK %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% PTB screen presentation setup %%%%

% default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenPresent = max(screens);

% Define colors: black, white
white = WhiteIndex(screenPresent);
black = BlackIndex(screenPresent);

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenPresent, black);

% % Get the size of the on screen window
% [screenXpixels, screenYpixels] = Screen('WindowSize', window);

% get monitor refresh rate
ifi = Screen('GetFlipInterval', window);

% % Get the centre coordinate of the window
% [xCenter, yCenter] = RectCenter(windowRect);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% set PTB as top priority level
Priority(MaxPriority(window));

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Image set up %%%

% path to master folder of stimulus images
ImageFolderPath = 'C:\Users\ztlee\Documents\MATLAB\EMO\Image Stimuli';

% subset of images within each condition - Encoding target set
SubfolderNames = {'Encoding'};

% get cell array of image names, including full file path
[ImageFiles, ImageSetOrder] = ReadImageNames(ImageFolderPath, SubfolderNames);

% set image presentation time
ImgTime = 3;    % time in seconds

% set fixation cross presentation time
FixTime = 1;    % time in seconds

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Randomization of Image order %%%

% INPUT image stimuli
%   number of conditions and images per condition
GROUPS = 4;
GROUP_SIZE = 16;

% OUTPUT image stimuli
%   number of blocks and trials per block
BLOCKS = 8;
TRIALS = 8;

% generate mat with random order of images
%   columns = blocks
%   rows = position within block (1-4 not stimulated, 5-8 stimulated)
%   values = index to image within ImageFiles cell array

[RandImages, ImageKeys] = RandomizeImages(GROUPS, ... % # conditions
    GROUP_SIZE, ... % # of images per condition
    BLOCKS, ...  % # of blocks to be presented in task
    TRIALS);  % # of images per block   

% save image keys to be used for recognition task
save(strcat('RAND\',SUBJ_ID,'keys.mat'),"RandImages","ImageKeys");

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CereStim set up %%%

% initialize cerestim object and waveform pattern
[Cerestim, WaveformID] = SetupCerestim(StimAmp);

% check if cerestim connected
if Cerestim == 0
    disp("Stimulator Not Connected. Check USB connection")
    % clean up screens
    Screen('CloseAll')
    close all;
    return
end

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% DATA RECORDING %%%%%%

TimingData = zeros(2, BLOCKS.*TRIALS);
%   row 1 = marker/stim onset time
%   row 2 = image onset time

ResponseData = zeros(4, BLOCKS.*TRIALS);
%   row 1 = response time - valence rating
%   row 2 = response time - arousal rating
%   row 3 = response key - valence rating
%   row 4 = response key - arousal rating

% data output filenames
TD_FILE = strcat('C:\Users\ztlee\Documents\MATLAB\EMO\Data\Timing_E_',SUBJ_ID);
RD_FILE = strcat('C:\Users\ztlee\Documents\MATLAB\EMO\Data\Response_E_',SUBJ_ID);
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% RUN ENCODING TASK %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Instructions %%%

endInstructions = Instructions(screenPresent, window);

% check if task terminated with user esc key
if endInstructions == 1
    % clean up screens
    Screen('CloseAll')
    close all;
    % disconnect stimulator
    Cerestim.disconnect;
    clear Cerestim
    % display message
    disp("User Terminated Task During Instructions")
    return;
end

%% 
%%% Practice %%%

endPractice = PracticeTrials(screenPresent, window, ifi);

% check if task terminated with user esc key
if endPractice == 99
    % clean up screens
    Screen('CloseAll')
    close all;
    % disconnect stimulator
    Cerestim.disconnect;
    clear Cerestim
    % display message
    disp("User Terminated Task During Practice Trials")
    return;
end

%% 
%%% Start Task %%%

% get task start time
tStart = GetSecs;

% loop through matrix of random images by columns (block) then rows (trial)
trialCount = 0;
for block = 1:BLOCKS

    for trial = 1:TRIALS
        
        % track total trial count
        trialCount = trialCount +1;

        % get image index and filename
        ImgIdx = RandImages(trial, block);
        ImgFile = ImageFiles{ImgIdx};

        % FIXATION - present fixation
        DrawFixation(screenPresent, window, FixTime, ifi);
        
        % MARKER - first half of block (NO STIM trials)
        if trial < TRIALS/2
            % trigger marker and store time of onset
            TimingData(1,trialCount) = TriggerMarker(Cerestim, WaveformID);
           
        % STIMULATION - second half of block
        else
            % trigger stim and store time of onset
            TimingData(1, trialCount) = TriggerStim(Cerestim, WaveformID, StimChannels);
        end
            
        % IMAGE - present image and store time of onset
        TimingData(2, trialCount) = PresentImage(ImgFile, window, ImgTime, ifi);

        % stop stim 500ms after picture presentation stops
        WaitSecs(0.1);
        Cerestim.stop();

        % RESPONSE %
        
        % draw response scales and get user responses and reaction times
        response = RatingResponse(screenPresent, window, ifi);
        % store reaction time and key response data
        ResponseData(:,trialCount) = response;

        % check for escape key and end task
        if response == 99
            % clean up screens
            Screen('CloseAll')
            close all;
            % save data
            save(TD_FILE, "TimingData");
            save(RD_FILE, "ResponseData");
            % disconnect stimulator
            Cerestim.disconnect;
            clear Cerestim
            % display message
            disp("User Terminated Task at Block "+block+" / Trial "+trial)
            % calculate task time
            total_time = (GetSecs - tStart);
            % reformat time
            total_time = seconds(total_time);
            total_time.Format = 'mm:ss';
            disp("Task RunTime:")
            disp(total_time)
            return;
        end
  
    end
    
    % check if more blocks left
    if block < BLOCKS

        % break after each block
        disp("Block " +block+ " completed.")
        
        % disp block break screen and wait for keypress to continue
        blockTxt = strcat('Take a Break\n\n You have completed...\n',num2str(block),'/8 Blocks');
        nextBlock = ShowText(blockTxt, screenPresent, window);
    
        % check for escape key and end task
        if nextBlock == 0
            % clean up screens
            Screen('CloseAll')
            close all;
            % save data
            save(TD_FILE, "TimingData");
            save(RD_FILE, "ResponseData");
            % disconnect stimulator
            Cerestim.disconnect;
            clear Cerestim
            % display message
            disp("User Terminated Task at Block "+block+" / Trial "+trial)
            % calculate task time
            total_time = (GetSecs - tStart);
            % reformat time
            total_time = seconds(total_time);
            total_time.Format = 'mm:ss';
            disp("Task RunTime:")
            disp(total_time)
            return;
        end
        % otherwise advance to next block
    end

end

% task ends - display message
ShowText('Task Finished. Thank you', screenPresent, window);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save data
save(TD_FILE, "TimingData");
save(RD_FILE, "ResponseData");
disp("Data Saved")

% disconnect and close stimulator
Cerestim.disconnect;
clear Cerestim

% Clean up %
Screen('CloseAll');
close all;

% calculate task time
total_time = (GetSecs - tStart);
% reformat time
total_time = seconds(total_time);
total_time.Format = 'mm:ss';
% display runtime
disp("Task RunTime:")
disp(total_time)

disp("Task Complete")
