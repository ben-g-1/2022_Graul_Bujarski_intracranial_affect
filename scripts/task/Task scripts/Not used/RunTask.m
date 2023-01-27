% RunTask - Encoding %
% v.2.16.2022

% script to run EMO task - Encoding session

clear all;
close all;
clc;
%% 

%%%% FOR TESTING %%%
% use only during testing with multiple monitor dock set up to avoid errors
Screen('Preference', 'SkipSyncTests', 1);
%%%%%%%%%%%%%%%%%%%%
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

% Define colors: black, white, grey
white = WhiteIndex(screenPresent);
black = BlackIndex(screenPresent);
grey = white / 2;

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenPresent, black);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% get monitor refresh rate
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% set PTB as top priority level
Priority(MaxPriority(window));

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Image set up %%%

% path to master folder of images
ImageFolderPath = 'C:\Users\ztlee\Documents\MATLAB\EMO\Image Stimuli';

% subset of images within each condition - Encoding target set or Foils for
% recogntion task
SubfolderNames = {'Encoding'};

% get cell array of image names, including full file path
[ImageFiles, ImageSetOrder] = ReadImageNames(ImageFolderPath, SubfolderNames);

% set image presentation time
ImgTime = 3;    % time in seconds
ImgFrames = round(ImgTime/ifi);     % time in screen frames

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Fixation cross set up %%%

% create texture for fixation cross
Fixation = DrawFixation([xCenter yCenter], ...  % location on screen
    white, ...              % fixation line color
    black, ...              % background screen color
    window);                % window to be drawn to

% set fixation cross presentation time
FixTime = 1;    % time in seconds
FixFrames = round(FixTime/ifi);     % time in screen frames

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Rating scale set up %%%

% create texture for scales 
Scales = DrawScales([xCenter yCenter], ...  % location on screen
    white, ...              % fixation line color
    black, ...              % background screen color
    window);                % window to be drawn to

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
    TRIALS);      % # of images per block

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CereStim set up %%%

% initialize cerestim object and waveform pattern
[Cerestim, WaveformID, WaveformTime] = SetupCerestim();

% check if cerestim connected
if Cerestim == 0
    disp("Stimulator Not Connected. Check USB connection")
    % clean up screens
    Screen('CloseAll')
    close all;
    return
end

%%%% 4 MODULE STIMULATION - if < 4 modules enabled, code will not run %%%%

% set electrodes for stimulation
%   arrays of 4 channels for 4 modules, each position has electrode # 
%   that will be stimulated with that module, 0=no stim on that module
StimChannels = [1 2 3 4];    % IDs for target electrodes during stimulated trials
MarkerChannels = [32 0 0 0]; % IDs for non-stimulated trials - allows sync markers to be placed

% set waveforms for stimulation
%   array of waveform IDs to be delivered to each electrode
%   for this set up the same waveform will be used for all stimulation on
%   all electrodes
Waveforms = zeros(1,4) + WaveformID;

% set # of times to repeat stimulation so that stim duration is equal to
% image presentation duration
% round up to nearest int to ensure stim time >= image duration
StimTimes = ceil((ImgFrames .* ifi) / WaveformTime);
% print stimulation duration
disp("Stimulation duration = " +(StimTimes.*WaveformTime) + " secs")

% check if stimulation duration >= actual image duration
check_times = (StimTimes .* WaveformTime) >= (ImgFrames .* ifi);
% good - proceed
if check_times == 1
    disp("Stimulation duration is good.")
% bad - exit
else
    disp("Stimulation duration does not match image presentation time.")
    % clean up screens
    Screen('CloseAll')
    close all;
     % disconnect stimulator
    Cerestim.disconnect;
    clear Cerestim
    return
end

%% 

%%%%% DATA RECORDING %%%%%%

TimingData = zeros(2, BLOCKS.*TRIALS);
%   row 1 = marker/stim onset time
%   row 2 = image onset time

ResponseData = zeros(2, BLOCKS.*TRIALS);
%   row 1 = response time
%   row 2 = response key

% data output filenames
TD_FILE = "TimingData_TEST";
RD_FILE = "ResponseData_TEST";
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% RUN ENCODING TASK %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Instructions %%% - fill in later
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 

% task starts

% loop through matrix of random images by columns (block) then rows (trial)

for block = 1:BLOCKS

    for trial = 1:TRIALS
        
        % get image index
        ImgIdx = RandImages(trial, block);
        % load image file
        Image = DrawImage(ImageFiles{ImgIdx},window);

        % FIXATION %

        % draw fixation, flip screen, and sync timing with refresh rate
        Screen('DrawTexture', window, Fixation)
        ft = Screen('Flip', window);
        % present fixation for set # of frames (-1 since already presented
        % for 1 frame)
        for f = 1:FixFrames -1
            Screen('DrawTexture', window, Fixation)
            ft = Screen('Flip', window, ft  + 0.5 * ifi);
        end
        
        %%% NO STIM trials - first half of block
        if trial < TRIALS/2
            % MARKER %

            % get marker timestamp
            TimingData(1,end) = GetSecs;
            % trigger marker stim
            Cerestim.groupStimulus(1,... % not beginning of sequence
                1,... % play stim immediately
                StimTimes,... % # times stim plays
                1,... % # of stim to occur simultaneously
                MarkerChannels,... % electrodes
                Waveforms); % waveforms
        %%% STIM trials - second half of block
        else
            % STIMULATION %

            % get stim timestamp
            TimingData(1,end) = GetSecs;
            % trigger stim
            Cerestim.groupStimulus(1,... % not beginning of sequence
                1,... % play stim immediately
                StimTimes,... % # times stim plays
                4,... % # of stim to occur simultaneously
                StimChannels,... % electrodes
                Waveforms); % waveforms
        end
            
        % IMAGE %

        % draw image, flip screen, and sync timing with refresh rate
        Screen('DrawTexture', window, Image)
        ft = Screen('Flip', window);
        % store timestamp for image presentation
        TimingData(2, end) = ft;
        % present image for set # of frames (-1 since already presented
        % for 1 frame)
        for f = 1:ImgFrames -1
            Screen('DrawTexture', window, Image)
            ft = Screen('Flip', window, ft  + 0.5 * ifi);
        end
        
        % RESPONSE %
        
        % draw response scales and get user response and reaction time
        [Rt, key] = GetResponse(Scales, window, ifi);
        % store reaction time and key response data
        ResponseData(1,end) = Rt;
        ResponseData(2,end) = key;

        % check for escape key and end task
        if key == 99
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
            return;
        end
  
    end
    
    % break after each block
    disp("Block " +block+ " completed.")
    %%%% insert some code for block break %%%%

end

% task ends
disp("Task complete. Saving data...")
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

disp("Task Finished. Thank you.")
