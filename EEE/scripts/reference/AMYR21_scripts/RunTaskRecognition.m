
% RunTaskRecognition %
% v4.27.2022

% script to run EMO task - recognition session

clear all;
close all;
clc;

%% 

%%%% FOR TESTING %%%
% use only during testing with multiple monitor dock set up to avoid errors
% Screen('Preference', 'SkipSyncTests', 1);
%%%%%%%%%%%%%%%%%%%%
%% 
% subject ID 
SUBJ_ID = 'AMYR21PT04';  % format: 'AMYR21PTxx

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

% get monitor refresh rate
ifi = Screen('GetFlipInterval', window);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% set PTB as top priority level
Priority(MaxPriority(window));

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Image set up %%%

% path to master folder of stimulus images
ImageFolderPath = 'C:\Users\ztlee\Documents\MATLAB\EMO\Image Stimuli';

% subsets of images within each condition - Encoding target set and Foils
SubfolderNames = {'Encoding', 'Foils'};

% get cell array of image names, including full file path
[ImageFiles, ImageSetOrder] = ReadImageNames(ImageFolderPath, SubfolderNames);

% set image presentation time
ImgTime = 1;    % time in seconds

% set fixation cross presentation time
FixTime = 1;

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Randomization of Image order %%%

GROUPS = 4;     % # of stimulus conditions
TARGET_N = 16;  % # of target images, shown during encoding, per condition
FOIL_N = 32;    % # of foil images, not shown during encoding, per condition

% load randomization mat and key mat from encoding session
load(strcat("RAND\", SUBJ_ID, "keys.mat"));

% generate array with random order of images, use values to index image
% file names array
% also store an array of image keys, which code the images by condition,
% stimulation/no stimulation, and target/foil 

[RandImages2, ImageKeys2] = RandomizeImages2(GROUPS, FOIL_N, TARGET_N,...
    RandImages, ... % random image mat from encoding session
    ImageKeys);     % key mat for encoding session images

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% DATA RECORDING %%%%%%

TimingData = zeros(1, GROUPS .* (TARGET_N + FOIL_N));
%   row 1 = image onset time

ResponseData = zeros(2, GROUPS .* (TARGET_N + FOIL_N));
%   row 1 = response time
%   row 2 = response key (yes/no)

% data output filenames
DATA_FILE = strcat("C:\Users\ztlee\Documents\MATLAB\EMO\Data\Recognition_",SUBJ_ID);
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% RUN RECOGNITION TASK %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Instructions %%%

% instruction text string array - each row is presented on consecutive
% screens
InstructionTxt = {'This is the memory part of the task';...
    'Previously you were asked to rate and remember some images...';...0
    'Now you will be shown another series of images\n\n Some you were shown before, some are new...';...
    'For each image,\n\n PRESS Y if you have seen the image before\n\n PRESS N if you have not seen it'};

% loop through instruction text, exit if user presses esc key
for t=1:length(InstructionTxt)
    % display text
    endInstructions = ShowText(InstructionTxt{t}, screenPresent, window);
    % check if task terminated with user esc key
    if endInstructions == 0
        % clean up screens
        Screen('CloseAll')
        close all;
        % display message
        disp("User Terminated Task During Instructions")
        return;
    end
end

%% 
%%% Start Task %%%

% record start time
tStart = GetSecs;

% loop through randomized image index array
trialCount = 0;
for i=RandImages2
        
    % track total trial count
    trialCount = trialCount +1;

    % get image index and filename
    ImgFile = ImageFiles{i};
        
    % IMAGE/RESPONSE - present image and wait for response
    [Rt, Key, imageON] = RecallResponse(ImgFile, window, ifi);
    ResponseData(:,trialCount) = [Rt ; Key];
    TimingData(trialCount) = imageON;

    % check for escape key and end task
    if Key == 99
        % clean up screens
        Screen('CloseAll')
        close all;
        % save data
        save(DATA_FILE,"ImageSetOrder","ImageFiles","RandImages2","ImageKeys2","ResponseData","TimingData");
        % calculate task time
        total_time = (GetSecs - tStart);
        % reformat time
        total_time = seconds(total_time);
        total_time.Format = 'mm:ss';
        % display message
        disp("User Terminated Task at Image "+trialCount+" /192")
        disp("Task RunTime:")
        disp(total_time)
        return;
    end

end
% task ends
ShowText('Task Finished. Thank you.', screenPresent, window)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Clean up %
Screen('CloseAll');
close all;

% save data
save(DATA_FILE,"ImageSetOrder","ImageFiles","RandImages2","ImageKeys2","ResponseData","TimingData");
disp("Data Saved")

% calculate task time
total_time = (GetSecs - tStart);
% reformat time
total_time = seconds(total_time);
total_time.Format = 'mm:ss';
% display runtime
disp("Task RunTime:")
disp(total_time)

disp("Task Complete")
