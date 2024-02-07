function resume_EEE_task(subjectnumber, sessionnumber, projdirectorypath, startingimage, debugging)
%%
% Resume EEE Task after ending prematurely during testing
% v1.1
% By Ben Graul

if ~debugging
    DEBUG = false;
else
    DEBUG = debugging;
end

%%% Input Path ID 
subjectnum = subjectnumber;
sessionnum = sessionnumber;
projdir = projdirectorypath;
filedir = fullfile(projdir, 'assets');
scriptdir = fullfile(projdir, 'scripts', 'EEE_task');
subjdir = fullfile(projdir, 'subjects', ['sub-',  num2str(subjectnum)]);
sesdir = fullfile(subjdir, ['ses-', num2str(sessionnum)]);
funcdir = fullfile(scriptdir, 'functions');
imagedir = fullfile(filedir, 'pair_1');
fname = 'stim_table.mat';
fpath = fullfile(sesdir, fname);
fpartialfill = fullfile(sesdir, ['stim_table_partial_from_', num2str(startingimage), '.mat']);
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

if not(isfile(fullfile(sesdir, 'stim_table_partial.mat')))
    disp('Previous partial matrix not found. Execute `run_EEE_task` instead.')
    return
end

% Load randomized matrix, then add empty columns for recordings
load(fpath);
nrow = size(stim_table, 1);

%% Initialize PsychToolbox defaults %%
global p;
%%% Remove or comment when working on hospital laptop
if DEBUG == true
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
p.pleasant                     = 'Extremely Pleasant';
p.unpleasant                   = 'Extremely Unpleasant';
p.neutral                      = 'Neutral';

%% Additional timing variables
%%% create jitter and save to stim_table
stim_table.fixJitter = (1.4-0.9).*rand(nrow,1) + 0.9;
% stim_table.imageJitter = (4.2-3.5).*rand(nrow,1)+3.5; % used for first
% three patients
stim_table.imageJitter = 4*ones(nrow,1);

fixJitter = stim_table.fixJitter(1);
imageJitter = stim_table.imageJitter(1);

breaktext = ['You may take a break here.' ... 
            '\n\n\n Please rest and use this time to adjust if you are uncomfortable.' ...
            '\n\n\n Click when you are ready to continue.'];thanktext = 'Thank you for your help with this experiment. Press any key to end.';
resumetext = 'Please click when you are ready to continue.';

%% Resume showing images after last saved image
% Number should be one higher than the last image saved
%% Offer self-timed break every {perblock} images.


perblock = 8;
numblocks = 8;
loopcount = mod(startingimage, perblock);
blockcount = ceil(startingimage/perblock);
HideCursor;

if DEBUG == true
    numblocks = 8; 
    perblock = 8;
    ShowCursor;
end % test settings 

totaltrials = numblocks*perblock;
disp("Trials: ", num2str(totaltrials))

%% Resume Experiment
click_resume = 0;
while click_resume == 0
    DrawFormattedText(p.ptb.window,resumetext,'center', 'center', 255);
    Screen('Flip', p.ptb.window);
    % WaitSecs(3.0);
    [~,~,click_resume] = GetMouse;
end

for trial = startingimage:totaltrials
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
    [timing_initialized, x_coord, RT, buttonPressOnset] = record_rating(500,p,'Expectation');

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
    [timing_initialized, x_coord, RT, buttonPressOnset] = record_rating(500,p,'Valence');
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
    disp(['Trial ', num2str(trial), ' saved.'])
    disp(['Expected: ', num2str(stim_table.exp_rating(trial))])
    disp(['Rated: ', num2str(stim_table.val_rating(trial))])
    
    % Check if break is needed
    % Don't show break text after last block

    loopcount = loopcount + 1;
    if blockcount < numblocks
        if loopcount == perblock
            click_break = 0;
            loopcount = 0;
            while click_break == 0
                DrawFormattedText(p.ptb.window,breaktext,'center', 'center', 255);
                Screen('Flip', p.ptb.window);
                % WaitSecs(3.0);
                [~,~,click_break] = GetMouse;
            end %while no buttons

            if mod(blockcount, 2) == 0 % Show block number on even trials 
                disp(["Modulo condition met", mod(blockcount, 2)])
                trialmsg = [num2str(blockcount), ' of ', num2str(numblocks), ' sections completed.'];
                WaitSecs(0.3);
                click_blocknum = 0;
                while click_blocknum == 0
                    DrawFormattedText(p.ptb.window,trialmsg,'center', 'center', 255);
                    Screen('Flip', p.ptb.window);
                    [~,~,click_blocknum] = GetMouse;
                end %while no click
            end %if even

            blockcount = blockcount + 1;

        end %if loopcount
    Screen('Close')
    end % if blockcount to skip on last block

    % Display current settings to terminal
    disp(["Current loop", loopcount])
    disp(["Per block", perblock])
    disp(["Total blocks", numblocks])
    disp(["Current block", blockcount])
end %trials


%% Debrief

save(f_all, "stim_table");
DrawFormattedText(p.ptb.window,thanktext,'center','center',255);
Screen('Flip', p.ptb.window);
KbStrokeWait;
sca;


end %function