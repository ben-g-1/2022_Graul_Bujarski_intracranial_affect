%function run_EEE_task_bglaptop(subjectnum, sessionnum, projdirectorypath)
% RunExpectationTask
%function 
% v1.1
% Adapted from scripts by Zachary Leeds, Philip Kragel, Heejung Jung 

% function RunExpectationTask(subjectnum, sessionnum, projdirectorypath) 
% subjectnum and sessionnum needs to be only numbers

subjectnum = 700;
sessionnum = 999;
%%% Input Path ID %%% CHANGE basedir MANUALLY, but create other scripts with this organization
projdir = 'C:\Users\ztlee\Documents\MATLAB\EEE';
% projdir = projdirectorypath
filedir = fullfile(projdir, 'files');
scriptdir = fullfile(projdir, 'scripts', 'EVRTask');
subjdir = fullfile(projdir, 'subjects', ['sub-',  num2str(subjectnum)]);
sesdir = fullfile(subjdir, ['ses-', num2str(sessionnum)]);
imagedir = fullfile(filedir, 'oasis_pairs');
fname = 'stim_table.mat';
fpath = fullfile(sesdir, fname);
practice = fullfile(filedir, 'practice', 'practice_images.mat');
fpartialfill = fullfile(sesdir, 'stim_table_partial.mat');
fall = fullfile(sesdir, 'stim_table_full.mat');

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
load(practice);
nrow = size(stim_table, 1);

%% Initialize PsychToolbox defaults
global p;
%%% Still isn't loading without skipping SyncTests. Check Zach's scripts to
%%% see if his do too.
    Screen('Preference', 'SkipSyncTests', 1);

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
%%% Needed to make font smaller for screen on cart
Screen('TextSize', p.ptb.window, 48);

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

%% Additional timing variables
%%% create jitter and save to stim_table
fixTime                        = 1.2; 
imageTime                      = 3.5;
HideCursor;
%% Text strings and images per block

instructtext1 = 'Thank you for helping us with this test. \n\n\n\n You will see a series of pictures that might cause an emotional response.';
DrawFormattedText(p.ptb.window, instructtext1, 'center', 'center', 255);
Screen('Flip', p.ptb.window)
KbStrokeWait;

instructtext3 = 'We are interested in how pleasant or unpleasant you find each picture.\n\n\n\n You might know this as a valence rating from prior tests.';
DrawFormattedText(p.ptb.window, instructtext3, 'center', 'center', 255);
Screen('Flip', p.ptb.window)
KbStrokeWait;
    
instructtext4 = 'Each image has been rated by 10 other participants. \n\n\n\n You will see these ratings before giving your own valence rating. \n\n\n\n The other ratings might be very similar or very different to your own feelings.';
DrawFormattedText(p.ptb.window, instructtext4, 'center', 'center', 255);
Screen('Flip', p.ptb.window)
KbStrokeWait;

instructtext5 = 'This is how you will see the ratings of other patients. \n\n\n\n\n\n\n\n\n\n\n\n\n\n Please ask questions if the ratings are unclear.' ;
DrawFormattedText(p.ptb.window, instructtext5, 'center', p.ptb.screenYpixels*.3, [255 0 255]);
%%% MAKE CELL FOR PRACTICE IMAGES, not drawn from table
 cuemat = cell2mat(stim_table.image_cue_values(2));
        for c = 1:10 
            pix_prcnt = ((cuemat(c)-1)/6);
            xpix_coord = (pix_prcnt*0.8*p.ptb.screenXpixels) + (.1);
            cue_xPixel(1,c) = xpix_coord;
        end
draw_cue(p,cue_xPixel)
draw_scale(p)
Screen('Flip', p.ptb.window)
KbStrokeWait;

instructtext6 = 'We will now practice making a rating.';
DrawFormattedText(p.ptb.window, instructtext6, 'center', 'center', 255);
Screen('Flip', p.ptb.window)
KbStrokeWait;

practtext1 = 'Move the red ball using the mouse. Click when the ball is where you would like to report your rating.';
DrawFormattedText(p.ptb.window, practtext1, 'center', p.ptb.screenYpixels*.3, 255);
record_rating(30,p,'Practice Rating')

practtext2 = 'Do you have any questions?';
DrawFormattedText(p.ptb.window, practtext2, 'center', 'center', 255);
Screen('Flip', p.ptb.window)
KbStrokeWait;

practtext3 = 'Please click the mouse to begin.';
buttons = 0
 while buttons == 0
     DrawFormattedText(p.ptb.window, practtext3, 'center', 'center', 255);
    Screen('Flip', p.ptb.window);
        [x,y,buttons] = GetMouse;
 end

breaktext = 'You may take a break here. Please click when you are ready to continue.';
thanktext = 'Thank you for your help with this experiment. Press any key to end.';

%% Offer self-timed break every {perblock} images.
perblock = 2;
loopcount = 0;

%% Full Experiment
for trial = 1:4
      
    % Convert expectation cue lines based on screen size
    cuemat = cell2mat(stim_table.image_cue_values(trial));
        for c = 1:10 
            pix_prcnt = ((cuemat(c)-1)/6);
            xpix_coord = (pix_prcnt*0.8*p.ptb.screenXpixels) + (.1);
%%% Rewrite line to preallocate memory, not dynamically increase each loop
            cue_xPixel(1,c) = xpix_coord;

        end
%%
    % Show fixation cross
     
    Screen('DrawLines', p.ptb.window, p.fix.allCoords, p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
    Screen('Flip', p.ptb.window);
    KbCheck;
    
    WaitSecs(fixTime);
   

    % Show expectation cue
    draw_scale(p);
    draw_cue(p,cue_xPixel);
    % draw white rectangle in bottom right corner of screen for external timing validation
    Screen('FillRect',p.ptb.window,p.ptb.white, p.lightRect);
    Screen('Flip', p.ptb.window);
    
    WaitSecs(imageTime);
   

    % Show empty scale and record rating 
    [timing_initialized, x_coord, RT, buttonPressOnset] = record_rating(50,p,'Expectation');

    % Record expectation rating and timing  
    stim_table.exp_init(trial) = timing_initialized;
    stim_table.exp_rating_pixels(trial) = x_coord;
    stim_table.exp_RT(trial) = RT;
    stim_table.exp_clickTime(trial) = buttonPressOnset;

    % Show fixation cross
    Screen('DrawLines', p.ptb.window, p.fix.allCoords, p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
    Screen('Flip', p.ptb.window);
    
    WaitSecs(fixTime);
   
    % Show image
    imagename = append(stim_table.Theme(trial), ".jpg");
    imagepath = fullfile(imagedir, imagename);
    imagetex = Screen('MakeTexture', p.ptb.window, imread(imagepath));
    Screen('DrawTexture', p.ptb.window, imagetex, [], p.image.coords);

    % draw white rect in bottom right corner of screen
    Screen('FillRect',p.ptb.window,p.ptb.white, p.lightRect);
    Screen('Flip', p.ptb.window);
    
    WaitSecs(imageTime);
    

    % Show empty scale and record rating
    [timing_initialized, x_coord, RT, buttonPressOnset] = record_rating(50,p,'Valence');
    Screen('Flip', p.ptb.window);

    % Record expectation rating and timing 
    stim_table.val_init(trial) = timing_initialized;
    stim_table.val_rating_pixels(trial) = x_coord;
    stim_table.val_RT(trial) = RT;
    stim_table.val_clickTime(trial) = buttonPressOnset;

    %collapse converted pixel size for cue lines to single cell
    stim_table.cue_converted(trial) = num2cell(cue_xPixel, [1 2]);
    
    % Check if break is needed
    loopcount = loopcount + 1;
    buttons = 0;
    if loopcount == perblock && trial ~= 4
        while buttons == 0
        loopcount = 0;
        DrawFormattedText(p.ptb.window,breaktext,'center', 'center', 255);
        Screen('Flip', p.ptb.window);
        [x,y,buttons] = GetMouse;
        save(fpartialfill, "stim_table");
        end
    end %if    
end %trial


%% Debrief
%%% Don't save as full unless trial is the final trial number
% show slides or make in PTB?
save(fall, "stim_table");
DrawFormattedText(p.ptb.window,thanktext,'center','center',255);
Screen('Flip', p.ptb.window);
KbStrokeWait;
sca;