% RunExpectationTask
% v0.1
% Adapted from scripts by Zachary Leeds and Heejung Jung 

% function for allowing subject ID input
function RunExpectationTask(subj)

%% Input Proj ID %%% CHANGE MANUALLY
SUBJ_ID = 'EEE_PT-99'
PROJ_DIR = 'C:\Users\ztlee\Documents\MATLAB\EEE'

%%%SUBJ_ID = subj 
SUBJ_DIR = [PROJ_DIR filesep SUBJ_ID]
if not(isfolder(SUBJ_DIR))
    mkdir(SUBJ_DIR)
end
%% Initialize PsychToolbox defaults

% clear any existing psychtoolbox screens
clear Screen

% default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get screen numbers
 screens = Screen('Screens');

% set to display to external monitor (2)
% need to change to 1 for laptop screen display
    if screens = 
screenPresent = 2;

% Define colors: black, white
white = WhiteIndex(screenPresent);
black = BlackIndex(screenPresent);

% Open an on screen window
[window, ~] = PsychImaging('OpenWindow', screenPresent, black);

% % Get the size of the on screen window
% [screenXpixels, screenYpixels] = Screen('WindowSize', window);

% get monitor refresh rate
ifi = Screen('GetFlipInterval', window);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% set PTB as top priority level
Priority(MaxPriority(window));

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Input Image Settings
ImageFolderPath = [PROJ_DIR filesep 'stimuli']
CueFolderPath = [PROJ_DIR filesep 'cues']

%%% MODE A: FIGURE OUT HOW TO READ IN LIST OF MATCHED STIM/CUES
%ImgList = 
%CueList =

%ImgOrder = % if one variable for both stimuli and cues

%%% MODE B: RANDOMLY GENERATE ORDERS
%ImgList = RandomizeImages % Maybe don't want to use this script, but something

%%% INTRODUCE JITTER TIME 
ImgTime = 3; % time in seconds
FixTime = 1; % time in seconds
CueTime = 2.5; % time in seconds

BLOCKS = 8
TRIALS = 8

%% Set output path
DATA_DIR = [SUBJ_DIR filesep 'data']
if not(isfolder(DATA_DIR))
    mkdir(DATA_DIR)
end

DataFile = [DATA_DIR filesep 'responses.mat']
LogFile = [DATA_DIR filesep 'log.txt'] 

%% Get system time, sync with recordings

TimingData = zeroes(2, BLOCKS.*TRIALS)
% row 1 = cue onset time
% row 2 = image onset time

ResponseData = = zeros(4, BLOCKS.*TRIALS);

%% Show Instructions

%% Practice Task

%% Task in Blocks

%% Rest time

%% Debrief