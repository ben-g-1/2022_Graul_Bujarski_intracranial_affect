%function run_EEE_task_bglaptop(subjectnum, sessionnum, projdirectorypath)
% RunExpectationTask
%function 
% v0.8
% Adapted from scripts by Zachary Leeds, Philip Kragel, Heejung Jung 

% function RunExpectationTask(subjectnum, sessionnum, projdirectorypath) 
% subjectnum and sessionnum needs to be only numbers

subjectnum = 700;
sessionnum = 999;
%%% Input Path ID %%% CHANGE basedir MANUALLY, but create other scripts with this organization
projdir = 'C:\Users\bgrau\GitHub\ieeg_affect\EEE';
% projdir = projdirectorypath
filedir = fullfile(projdir, 'files');
scriptdir = fullfile(projdir, 'scripts', 'EVRTask');
subjdir = fullfile(projdir, 'subjects', ['sub-',  num2str(subjectnum)]);
sesdir = fullfile(subjdir, ['ses-', num2str(sessionnum)]);
imagedir = fullfile(filedir, 'oasis_pairs');
fname = 'stim_table.mat';
fpath = fullfile(sesdir, fname);

addpath(scriptdir);

% Make sure the subject and session have been created. 
if not(isfolder(subjdir))
    disp('This subject does not exist. Check your paths or run `generate_randomized_stim_table.m` for this session.')
    return
end
addpath(subjdir);
if not(isfolder(sesdir))
    disp('This session does not exist. Check your paths or run `generate_randomized_stim_table.m` for this session.')
    return
end
addpath(sesdir);

if not(isfile(fpath))
    disp('This reference file does not exist. Check your paths or run `generate_randomized_stim_table.m` for this session.')
    return
end

% Load randomized matrix, then add empty columns for recordings
load(fpath);
nrow = size(stim_table, 1);

%% Initialize PsychToolbox defaults
global p;
%%% Remove or comment when working on hospital laptop
if getenv('USERNAME') == 'bgrau'
    Screen('Preference', 'SkipSyncTests', 1);
else 
    disp('PsychToolbox probably won`t work correctly. Change the SyncTests setting.')
    return
end
%%%

PsychDefaultSetup(2);
screens                        = Screen('Screens'); % Get the screen numbers
p.ptb.screenNumber             = max(screens); % Draw to the external screen if avaliable
p.ptb.white                    = WhiteIndex(p.ptb.screenNumber); % Define black and white
p.ptb.black                    = BlackIndex(p.ptb.screenNumber);
p.ptb.grey                     = p.ptb.white/2;


PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'UseFastOffscreenWindows');

[p.ptb.window, p.ptb.rect]     = PsychImaging('OpenWindow',p.ptb.screenNumber,p.ptb.black);
[p.ptb.screenXpixels, p.ptb.screenYpixels] = Screen('WindowSize',p.ptb.window);
p.ptb.ifi                      = Screen('GetFlipInterval',p.ptb.window);
Screen('BlendFunction', p.ptb.window,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA'); % Set up alpha-blending for smooth (anti-aliased) lines
Screen('TextFont', p.ptb.window, 'Arial');

Screen('TextSize', p.ptb.window, 108);

[p.ptb.xCenter, p.ptb.yCenter] = RectCenter(p.ptb.rect);
p.fix.sizePix                  = 40; % size of the arms of our fixation cross
p.fix.lineWidthPix             = 4; % Set the line width for our fixation cross
p.fix.xCoords                  = [-p.fix.sizePix p.fix.sizePix 0 0];
p.fix.yCoords                  = [0 0 -p.fix.sizePix p.fix.sizePix];
p.fix.allCoords                = [p.fix.xCoords; p.fix.yCoords];


p.rate.lineWidthPix             = 8; % Set the line width for our rating lines cross
p.rate.bounds                   = 0.4*p.ptb.screenXpixels;
p.rate.leftbound                = 0.1*p.ptb.screenXpixels;
p.rate.rightbound               = 0.9*p.ptb.screenXpixels;   
p.rate.anchorDisp               = 0.02*p.ptb.screenYpixels;
p.rate.rateDisp                 = 0.1*p.ptb.screenYpixels;
p.rate.xCoords                  = [-p.rate.bounds p.rate.bounds 0 0];
p.rate.yCoords                  = [0 0 -p.rate.anchorDisp p.rate.anchorDisp];
p.rate.allCoords                = [p.rate.xCoords; p.rate.yCoords];
p.penwidth                      = 3;

KbName('UnifyKeyNames');
p.keys.confirm                 = KbName('return');
p.keys.right                   = KbName('2');
p.keys.left                    = KbName('1');
p.keys.space                   = KbName('space');
p.keys.esc                     = KbName('ESCAPE');
p.keys.trigger                 = KbName('5%');
p.keys.start                   = KbName('s');
p.keys.end                     = KbName('e');


p.image.coords                 = [0.1*p.ptb.screenXpixels 0.1*p.ptb.screenYpixels 0.9*p.ptb.screenXpixels 0.9*p.ptb.screenYpixels];
p.lightRect                    = [(p.ptb.screenXpixels-70) (p.ptb.screenYpixels-70) p.ptb.screenXpixels p.ptb.screenYpixels];
p.pleasant = 'Extremely Pleasant';
p.unpleasant = 'Extremely Unpleasant';
p.neutral = 'Neutral';

%%% DEBUG
% sca;
%% Additional timing variables
%%% create jitter and save to stim_table
fixTime                        = 1.5; 
imageTime                      = 4;


%% Instructions and Practice Sessions

%% Full Experiment
% while p.keys.esc == 0

for trial = 1:nrow
    

    % Convert expectation cue lines based on screen size
    cuemat = cell2mat(stim_table.image_cue_values(trial));
        for c = 1:10 
            pix_prcnt = ((cuemat(c)-1)/6)
            xpix_coord = (pix_prcnt*0.8*p.ptb.screenXpixels) + (.1);
%%% Rewrite line to preallocate memory, not dynamically increase each loop
            cue_xPixel(1,c) = xpix_coord;

        end
%%
    % Show fixation cross
     
    Screen('DrawLines', p.ptb.window, p.fix.allCoords, p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
    Screen('Flip', p.ptb.window)
   
 
    WaitSecs(fixTime)
   

    % Show expectation cue
    draw_scale(p)
    draw_cue(p,cue_xPixel)
    % draw white rectangle in bottom right corner of screen for external timing validation
    Screen('FillRect',p.ptb.window,p.ptb.white, p.lightRect);
    Screen('Flip', p.ptb.window)
    
    WaitSecs(imageTime)
   

    % Show empty scale and record rating 
    [timing_initialized, x_coord, RT, buttonPressOnset] = record_rating(10,p,'Expectation');

    % Record expectation rating and timing  
    stim_table.exp_init(trial) = timing_initialized;
    stim_table.exp_rating_pixels(trial) = x_coord;
    stim_table.exp_RT(trial) = RT;
    stim_table.exp_clickTime(trial) = buttonPressOnset;

    % Show fixation cross
    Screen('DrawLines', p.ptb.window, p.fix.allCoords, p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
    Screen('Flip', p.ptb.window)
    
    WaitSecs(fixTime)
   
    % Show image
    imagename = append(stim_table.Theme(trial), ".jpg");
    imagepath = fullfile(imagedir, imagename);
    imagetex = Screen('MakeTexture', p.ptb.window, imread(imagepath));
    Screen('DrawTexture', p.ptb.window, imagetex, [], p.image.coords);

    % draw white rect in bottom right corner of screen
    Screen('FillRect',p.ptb.window,p.ptb.white, p.lightRect);
    Screen('Flip', p.ptb.window);
    
    WaitSecs(imageTime)
    
    

    % Show empty scale and record rating
    [timing_initialized, x_coord, RT, buttonPressOnset] = record_rating(10,p,'Valence');
    Screen('Flip', p.ptb.window);

    % Record expectation rating and timing 
    stim_table.val_init(trial) = timing_initialized;
    stim_table.val_rating_pixels(trial) = x_coord;
    stim_table.val_RT(trial) = RT;
    stim_table.val_clickTime(trial) = buttonPressOnset;

    %collapse converted pixel size for cue lines to single cell
stim_table.cue_converted(trial) = num2cell(cue_xPixel, [1 2]);

end %trial
 % escCheck
%% Debrief
% show slides or make in PTB?
KbStrokeWait;
sca;

%%
% %%% INTRODUCE JITTER TIME 
% %%% See Phil's script for help
% ImgTime = 3; % time in seconds
% FixTime = 1; % time in seconds
% CueTime = 2.5; % time in seconds

% BLOCKS = 4
% TRIALS = 16

% %% Set output path
% DATA_DIR = [SUBJ_DIR filesep 'data']
% if not(isfolder(DATA_DIR))
%     mkdir(DATA_DIR)
% end

% DataFile = [DATA_DIR filesep 'responses.mat']
% LogFile = [DATA_DIR filesep 'log.txt'] 

% %% Get system time, sync with recordings

% TimingData = zeroes(2, BLOCKS.*TRIALS)
% % row 1 = cue onset time
% % row 2 = image onset time

% ResponseData = zeros(4, BLOCKS.*TRIALS);

% %% Show Instructions

% %% Practice Task

% %% Task in Blocks
% endInstructions = Instructions(screenPresent, window);

% % check if task terminated with user esc key
% if endInstructions == 1
%     % clean up screens
%     Screen('CloseAll')
%     close all;
%     % display message
%     disp("User Terminated Task During Instructions")
%     return;
% end

% %% 
% %%% Practice %%%

% endPractice = PracticeTrials(screenPresent, window, ifi);

% % check if task terminated with user esc key
% if endPractice == 99
%     % clean up screens
%     Screen('CloseAll')
%     close all;
%     % display message
%     disp("User Terminated Task During Practice Trials")
%     return;
% end

%% 
%%% Start Task %%%

% get task start time
%tStart = GetSecs;


% % loop through matrix of random images by columns (block) then rows (trial)
% trialCount = 0;
% for block = 1:BLOCKS

%     for trial = 1:TRIALS
        
%         % track total trial count
%         trialCount = trialCount +1;

%         % get image index and filename
%         ImgIdx = RandImages(trial, block);
%         ImgFile = ImageFiles{ImgIdx};

%         % FIXATION - present fixation
%         DrawFixation(screenPresent, window, FixTime, ifi);
        
%         % MARKER - first half of block (NO STIM trials)
%         if trial < TRIALS/2
%             % trigger marker and store time of onset
%             TimingData(1,trialCount) = TriggerMarker(Cerestim, WaveformID);
           
%         % STIMULATION - second half of block
%         else
%             % trigger stim and store time of onset
%             TimingData(1, trialCount) = TriggerStim(Cerestim, WaveformID, StimChannels);
%         end
            
%         % IMAGE - present image and store time of onset
%         TimingData(2, trialCount) = PresentImage(ImgFile, window, ImgTime, ifi);

%         % RESPONSE %
        
%         % draw response scales and get user responses and reaction times
%         response = RatingResponse(screenPresent, window, ifi);
%         % store reaction time and key response data
%         ResponseData(:,trialCount) = response;

%         % check for escape key and end task
%         if response == 99
%             % clean up screens
%             Screen('CloseAll')
%             close all;
%             % save data
%             save(DATA_FILE, "TimingData","ResponseData",'-append')
%             % display message
%             disp("User Terminated Task at Block "+block+" / Trial "+trial)
%             % calculate task time
%             total_time = (GetSecs - tStart);
%             % reformat time
%             total_time = seconds(total_time);
%             total_time.Format = 'mm:ss';
%             disp("Task RunTime:")
%             disp(total_time)
%             return;
%         end
  
%     end
    
%     % check if more blocks left
%     if block < BLOCKS

%         % break after each block
%         disp("Block " +block+ " completed.")
        
%         % disp block break screen and wait for keypress to continue
%         blockTxt = strcat('Take a Break\n\n You have completed...\n',num2str(block),'/8 Blocks');
%         nextBlock = ShowText(blockTxt, screenPresent, window);
    
%         % check for escape key and end task
%         if nextBlock == 0
%             % clean up screens
%             Screen('CloseAll')
%             close all;
%             % save data
%             save(DATA_FILE, "TimingData","ResponseData",'-append')
%             % display message
%             disp("User Terminated Task at Block "+block+" / Trial "+trial)
%             % calculate task time
%             total_time = (GetSecs - tStart);
%             % reformat time
%             total_time = seconds(total_time);
%             total_time.Format = 'mm:ss';
%             disp("Task RunTime:")
%             disp(total_time)
%             return;
%         end
%         % otherwise advance to next block
%     end

% end

% % task ends - display message
% ShowText('Task Finished. Thank you', screenPresent, window);

%% Debrief