% RunExpectationTask
%function 
% v0.1
% Adapted from scripts by Zachary Leeds and Heejung Jung 

% function for allowing subject ID input
%function RunExpectationTask(subjectnum, sessionnum) 
% subj needs to be only numbers

%%%TESTING
subjectnum = 99;
sessionnum = 99;
%%%

%% Input Path ID %%% CHANGE basedir MANUALLY, but create other scripts with this organization
basedir = 'C:\Users\bgrau\GitHub\ieeg_affect';
projdir = fullfile(basedir, 'EEE');
filedir = fullfile(projdir, 'files');
scriptdir = fullfile(projdir, 'scripts', 'EVRTask');
subjdir = fullfile(projdir, 'subjects', ['sub-',  num2str(subjectnum)]);
sesdir = fullfile(subjdir, ['ses-', num2str(sessionnum)]);


addpath(scriptdir);

% Make sure the subject and session have been created. 
if not(isfolder(subjdir))
    'This subject does not exist. Check your paths or run `generate_randomized_stim_table.m` for this session.'
    return
end
addpath(subjdir);
if not(isfolder(sesdir))
    'This session does not exist. Check your paths or run `generate_randomized_stim_table.m` for this session.'
    return
end
addpath(sesdir);
fname = fullfile(filedir, pair_matrix.xlsx);
fwritename = fullfile(sesdir, 'randomized_pair_matrix.xlsx');
if not(isfile(sesdir))
    'This reference file does not exist. Check your paths or run `generate_randomized_stim_table.m` for this session.'
    return
end
%PROJ_DIR = 'C:\Users\ztlee\Documents\MATLAB\EEE'


%%%SUBJ_ID = subj 

%% Initialize PsychToolbox defaults
global p
%%% Remove or comment when working on hospital laptop
if getenv('USERNAME') == 'bgrau'
    Screen('Preference', 'SkipSyncTests', 1);
else 
    'PsychToolbox Probably won`t work right now.'
    returnend
end

%%%

PsychDefaultSetup(2);
screens                        = Screen('Screens'); % Get the screen numbers
p.ptb.screenNumber             = max(screens); % Draw to the external screen if avaliable
p.ptb.white                    = WhiteIndex(p.ptb.screenNumber); % Define black and white
p.ptb.black                    = BlackIndex(p.ptb.screenNumber);
p.ptb.grey                     = p.ptb.white/2

PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'UseFastOffscreenWindows');

[p.ptb.window, p.ptb.rect]     = PsychImaging('OpenWindow',p.ptb.screenNumber,p.ptb.black);
[p.ptb.screenXpixels, p.ptb.screenYpixels] = Screen('WindowSize',p.ptb.window);
p.ptb.ifi                      = Screen('GetFlipInterval',p.ptb.window);
Screen('BlendFunction', p.ptb.window,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA'); % Set up alpha-blending for smooth (anti-aliased) lines
Screen('TextFont', p.ptb.window, 'Arial');

Screen('TextSize', p.ptb.window, 36);

[p.ptb.xCenter, p.ptb.yCenter] = RectCenter(p.ptb.rect);
p.fix.sizePix                  = 40; % size of the arms of our fixation cross
p.fix.lineWidthPix             = 4; % Set the line width for our fixation cross
p.fix.xCoords                  = [-p.fix.sizePix p.fix.sizePix 0 0];
p.fix.yCoords                  = [0 0 -p.fix.sizePix p.fix.sizePix];
p.fix.allCoords                = [p.fix.xCoords; p.fix.yCoords];

%%% DEBUG %%%
kbStrokeWait;
sca;

pairtable = readtable(fname)

%%% INTRODUCE JITTER TIME 
%%% See Phil's script for help
ImgTime = 3; % time in seconds
FixTime = 1; % time in seconds
CueTime = 2.5; % time in seconds

BLOCKS = 4
TRIALS = 16

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

ResponseData = zeros(4, BLOCKS.*TRIALS);

%% Show Instructions

%% Practice Task

%% Task in Blocks
endInstructions = Instructions(screenPresent, window);

% check if task terminated with user esc key
if endInstructions == 1
    % clean up screens
    Screen('CloseAll')
    close all;
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
            save(DATA_FILE, "TimingData","ResponseData",'-append')
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
            save(DATA_FILE, "TimingData","ResponseData",'-append')
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

%% Debrief