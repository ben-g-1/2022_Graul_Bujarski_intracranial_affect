function run_EEE_task(subjectnumber, sessionnumber, projdirectorypath, debug)
% RunExpectationTask
%function 
% v1.3
% By Ben Graul
% Adapted from scripts by Zachary Leeds, Philip Kragel, Heejung Jung 

% function RunExpectationTask(subjectnum, sessionnum, projdirectorypath) 
% subjectnum and sessionnum needs to be only numbers

if ~debug
    DEBUG = false;
else
    DEBUG = debug;
end

%%% Input Path ID 
% projdir = 'C:\Users\bgrau\GitHub\ieeg_affect\EEE';
subjectnum = subjectnumber;
sessionnum = sessionnumber;
projdir = projdirectorypath;
filedir = fullfile(projdir, 'files');
scriptdir = fullfile(projdir, 'scripts', ' EEE_task');
subjdir = fullfile(projdir, 'subjects', ['sub-',  num2str(subjectnum)]);
sesdir = fullfile(subjdir, ['ses-', num2str(sessionnum)]);
funcdir = fullfile(scriptdir, 'functions');
imagedir = fullfile(filedir, 'oasis_pairs');
fname = 'stim_table.mat';
fpath = fullfile(sesdir, fname);
practice = fullfile(filedir, 'practice', 'practice_images.mat');
practicedir = fullfile(filedir, 'practice');
fpartialfill = fullfile(sesdir, 'stim_table_partial.mat');
f_all = fullfile(sesdir, 'stim_table_full.mat');

addpath(scriptdir);
addpath(funcdir)

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

%% Initialize PsychToolbox defaults %%
global p;
%%% Remove or comment when working on hospital laptop
if getenv('USERNAME') ~= 'ztlee'
  Screen('Preference', 'SkipSyncTests', 1);
end
% else 
%     disp('PsychToolbox probably won`t work correctly. Change the SyncTests setting.')
%     return
% end

% Screen('Preference', 'SkipSyncTests', 1);
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

% Wide Monitor
% Screen('TextSize', p.ptb.window, 96);

% Cart Laptop
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
stim_table.fixJitter = (1.4-0.9).*rand(nrow,1) + 0.9;
% stim_table.imageJitter = (4.2-3.5).*rand(nrow,1)+3.5;
stim_table.imageJitter = 4*ones(nrow,1)

fixJitter = stim_table.fixJitter(1);
imageJitter = stim_table.imageJitter(1);
HideCursor;

%% INSTRUCTIONS %% 
% Text strings and images per block
if DEBUG == false
instructtext1 = ['Thank you for helping us with this test. \n\n\n\n ' ...
    'You will see a series of pictures. \n\n\n\n' ...
    'We are interested in how pleasant or unpleasant you find each picture.'];
buttons = 0;
 while buttons == 0
    DrawFormattedText(p.ptb.window, instructtext1, 'center', 'center', 255);
    Screen('Flip', p.ptb.window)
    [x,y,buttons] = GetMouse;
 end

instructtext2 = ['We will ask you to rate each picture on a scale from \n\n '...
    'extremely unpleasant to extremely pleasant.\n\n\n\n'];
buttons = 0;
 while buttons == 0
    DrawFormattedText(p.ptb.window, instructtext2, 'center', p.ptb.screenYpixels*.15, 255);
    draw_scale(p)
    Screen('Flip', p.ptb.window);
    [x,y,buttons] = GetMouse;
 end
    
instructtext3 = ['Each image has been rated by 10 other people. \n\n\n\n ' ...
    'Before you see the picture, you will see the ratings that other people gave each picture.'];
buttons = 0;
 while buttons == 0
DrawFormattedText(p.ptb.window, instructtext3, 'center', 'center', 255);
Screen('Flip', p.ptb.window);
    [x,y,buttons] = GetMouse;
 end

instructtext4 = ['Each line represents one rating that someone gave to the picture you will see next.'];
buttons = 0;
 while buttons == 0
DrawFormattedText(p.ptb.window, instructtext4, 'center', p.ptb.screenYpixels*.15, 255);
  % Convert expectation cue lines based on screen size
    cuemat = cell2mat(practice_images.image_cue_values(1));
    cue_xPixel = zeros(1,10);
        for c = 1:10 
            pix_prcnt = ((cuemat(c)-1)/6);
            xpix_coord = (pix_prcnt*0.8*p.ptb.screenXpixels) + (.1*p.ptb.screenXpixels);
            cue_xPixel(1,c) = xpix_coord;
        end    
    % Show expectation cue
    draw_scale(p);
    draw_cue(p,cue_xPixel);
    % draw white rectangle in bottom right corner of screen for external timing validation
%     Screen('FillRect',p.ptb.window,p.ptb.white, p.lightRect);
    Screen('Flip', p.ptb.window);
    [x,y,buttons] = GetMouse;
 end


instructtext5 = ['After seeing what others rated the picture, we will ask you how pleasant or unpleasant you expect \n\n' ...
    'the next picture to be. \n\n\n\n\n' ...
    'We will now practice making a rating. Press any key to begin.'];
buttons = 0;
 while buttons == 0
DrawFormattedText(p.ptb.window, instructtext5, 'center', 'center', 255);
Screen('Flip', p.ptb.window)
    [x,y,buttons] = GetMouse;
 end

practtext1 = ['Move the line using the mouse. Click when the line is where you would like to report your rating. \n\n\n\n\n' ...
    'Press any key to continue.'];
buttons = 0;
 while buttons == 0
DrawFormattedText(p.ptb.window, practtext1, 'center', 'center', 255);
Screen('Flip', p.ptb.window);
    [x,y,buttons] = GetMouse;
 end
record_rating(30,p,'Practice Rating')

instructtext6 = ['After you rate how pleasant or unpleasant you expect the picture to be, you will see the picture.' ...
    '\n\n\n\n\n\n\n We will now practice the whole process.'];
buttons = 0;
 while buttons == 0
DrawFormattedText(p.ptb.window, instructtext6, 'center', 'center', 255);
Screen('Flip', p.ptb.window);
    [x,y,buttons] = GetMouse;
 end

for practice = 1:2
    % Convert expectation cue lines based on screen size
    cuemat = cell2mat(practice_images.image_cue_values(practice));
    cue_xPixel = zeros(1,10);
        for c = 1:10 
            pix_prcnt = ((cuemat(c)-1)/6);
            xpix_coord = (pix_prcnt*0.8*p.ptb.screenXpixels) + (.1*p.ptb.screenXpixels);
            cue_xPixel(1,c) = xpix_coord;

        end    

Screen('DrawLines', p.ptb.window, p.fix.allCoords, p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
    Screen('Flip', p.ptb.window);
    KbCheck;
    
    WaitSecs(fixJitter);
   
    % Show expectation cue
    draw_scale(p);
    draw_cue(p,cue_xPixel);
    % draw white rectangle in bottom right corner of screen for external timing validation
%     Screen('FillRect',p.ptb.window,p.ptb.white, p.lightRect);
    Screen('Flip', p.ptb.window);
    
    WaitSecs(imageJitter);
   
    % Show empty scale and record rating 
    [timing_initialized, x_coord, RT, buttonPressOnset] = record_rating(50,p,'Expectation');

    % Show fixation cross
    Screen('DrawLines', p.ptb.window, p.fix.allCoords, p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
    Screen('Flip', p.ptb.window);
    
    WaitSecs(fixJitter);
   
    % Show image
    imagename = append(practice_images.Theme(practice), ".jpg");
    imagepath = fullfile(practicedir, imagename);
    imagetex = Screen('MakeTexture', p.ptb.window, imread(imagepath));
    Screen('DrawTexture', p.ptb.window, imagetex, [], p.image.coords);

    % draw white rect in bottom right corner of screen
%     Screen('FillRect',p.ptb.window,p.ptb.white, p.lightRect);
    Screen('Flip', p.ptb.window);
    
    WaitSecs(imageJitter);
    
    % Show empty scale and record rating
    [timing_initialized, x_coord, RT, buttonPressOnset] = record_rating_norect(50,p,'Valence');
    Screen('Flip', p.ptb.window);

end

practtext2 = 'Do you have any questions?';
buttons = 0;
 while buttons == 0
DrawFormattedText(p.ptb.window, practtext2, 'center', 'center', 255);
Screen('Flip', p.ptb.window)
    [x,y,buttons] = GetMouse;
 end
end % tutorial skip for DEBUG == true 

practtext3 = 'Please click the mouse to begin.';
buttons = 0;
 while buttons == 0
    DrawFormattedText(p.ptb.window, practtext3, 'center', 'center', 255);
    Screen('Flip', p.ptb.window);
    [x,y,buttons] = GetMouse;
 end

breaktext = 'You may take a break here. Please click when you are ready to continue.';
thanktext = 'Thank you for your help with this experiment. Press any key to end.';

%% Offer self-timed break every {perblock} images.
perblock = 8;
loopcount = 0;
HideCursor;

%% Full Experiment
for trial = 1:nrow
%     escCheck(p, trial)
    fixJitter = stim_table.fixJitter(trial);
    imageJitter = stim_table.imageJitter(trial);
    % Convert expectation cue lines based on screen size
    cuemat = cell2mat(stim_table.image_cue_values(trial));
    cue_xPixel = zeros(1,10);
        for c = 1:10 
            pix_prcnt = ((cuemat(c)-1)/6);
            xpix_coord = (pix_prcnt*0.8*p.ptb.screenXpixels) + (.1*p.ptb.screenXpixels);
            cue_xPixel(1,c) = xpix_coord;
        end

    % Show fixation cross
     
    Screen('DrawLines', p.ptb.window, p.fix.allCoords, p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
    Screen('Flip', p.ptb.window);
    
    WaitSecs(fixJitter);
   

    % Show expectation cue
    draw_scale(p);
    draw_cue(p,cue_xPixel);
    % draw white rectangle in bottom right corner of screen for external timing validation
    Screen('FillRect',p.ptb.window,p.ptb.white, p.lightRect);
    Screen('Flip', p.ptb.window);
    
    WaitSecs(imageJitter);
   
    % ADDED 5/10/23 AFTER PTs 1,2,3
    % Shows black screen, but PTB was angry about just doing an empty flip
    % Required to ensure photodiode had enough time to reset with black
    % screen.
    Screen('DrawLines', p.ptb.window, p.fix.allCoords, p.fix.lineWidthPix, p.ptb.black, [p.ptb.xCenter p.ptb.yCenter], 2);
    
    Screen('Flip', p.ptb.window);
    WaitSecs(.08);
    % END /ADDED

    % Show empty scale and record rating 
    [timing_initialized, x_coord, RT, buttonPressOnset] = record_rating(50,p,'Expectation');

    % Record expectation rating and timing  
    stim_table.exp_init(trial) = timing_initialized;
    stim_table.exp_rating_pixels(trial) = x_coord;
    stim_table.exp_RT(trial) = RT;
    stim_table.exp_clickTime(trial) = buttonPressOnset;

    stim_table.exp_rating(trial) = convert_from_pixel(p, x_coord);

    % Show fixation cross
    Screen('DrawLines', p.ptb.window, p.fix.allCoords, p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
    Screen('Flip', p.ptb.window);
    
    WaitSecs(fixJitter);
   
    % Show image
    imagename = append(stim_table.Theme(trial), ".jpg");
    imagepath = fullfile(imagedir, imagename);
    imagetex = Screen('MakeTexture', p.ptb.window, imread(imagepath));
    Screen('DrawTexture', p.ptb.window, imagetex, [], p.image.coords);

    % draw white rect in bottom right corner of screen
    Screen('FillRect',p.ptb.window,p.ptb.white, p.lightRect);
    Screen('Flip', p.ptb.window);
    
    WaitSecs(imageJitter);
    
    % ADDED 5/10/23, AFTER PTs 1,2,3
    Screen('DrawLines', p.ptb.window, p.fix.allCoords, p.fix.lineWidthPix, p.ptb.black, [p.ptb.xCenter p.ptb.yCenter], 2);
    Screen('Flip', p.ptb.window);
    WaitSecs(.08);
    % END /ADDED

    % Show empty scale and record rating
    [timing_initialized, x_coord, RT, buttonPressOnset] = record_rating(50,p,'Valence');
    Screen('Flip', p.ptb.window);

    % Record expectation rating and timing 
    stim_table.val_init(trial) = timing_initialized;
    stim_table.val_rating_pixels(trial) = x_coord;
    stim_table.val_RT(trial) = RT;
    stim_table.val_clickTime(trial) = buttonPressOnset;

    stim_table.val_rating(trial) = convert_from_pixel(p, x_coord);

    %collapse converted pixel size for cue lines to single cell
    stim_table.cue_converted(trial) = num2cell(cue_xPixel, [1 2]);
    save(fpartialfill, "stim_table");
    
    % Check if break is needed
    loopcount = loopcount + 1;
    buttons = 0;
    if loopcount == perblock
        while buttons == 0
        loopcount = 0;
        DrawFormattedText(p.ptb.window,breaktext,'center', 'center', 255);
        Screen('Flip', p.ptb.window);
        [x,y,buttons] = GetMouse;
        end
    end %if
    Screen('Close')
end %trial


%% Debrief

save(f_all, "stim_table");
DrawFormattedText(p.ptb.window,thanktext,'center','center',255);
Screen('Flip', p.ptb.window);
KbStrokeWait;
sca;


end %function