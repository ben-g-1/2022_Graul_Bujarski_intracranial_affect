%function valence_rating(foo, fii, fee)

% Script adapted from Heejung Jung, Philip Kragel, and Zachary Leeds
% [Point to specfic scripts for reference later?]
% this is redundant but need to check differences



%% -----------------------------------------------------------------------------
%                           Parameters
% ------------------------------------------------------------------------------

%% A. Psychtoolbox parameters _________________________________________________
global p
%%% Remove or comment when working
Screen('Preference', 'SkipSyncTests', 1);

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


%% B. Directories ______________________________________________________________

%%% Improve these when on local machine
task_dir                       = pwd; %'C:\\{USER}\\MATLAB\\task\\EEE';
image_dir                       = [task_dir filesep 'images']; %'C:\\{USER}\\MATLAB\\task\\EEE\\images';

taskname                       = 'EEE';



%% E. Keyboard information _____________________________________________________
KbName('UnifyKeyNames');
p.keys.confirm                 = KbName('return');
p.keys.right                   = KbName('2');
p.keys.left                    = KbName('1');
p.keys.space                   = KbName('space');
p.keys.esc                     = KbName('ESCAPE');
p.keys.trigger                 = KbName('5%');
p.keys.start                   = KbName('s');
p.keys.end                     = KbName('e');


%% G. Instructions _____________________________________________________________
%expect = 'expect the next image to be ';
%T.param_taskname(:) = lower(judgment);

% For exp
instruct_start                 = ['We will now start the practice ratings.\nPlease indicate how pleasant or unpleasant you expect the next image to be ';'.\n\n\n\nexperimenters, press "s" to start'];
instruct_trigger              = ['Please indicate how pleasant or unpleasant you found the previous image'];

instruct_end                   = 'This is the end of the experiment. Please wait for the experimenter\n\n\n\nexperimenters, press "e" to end';



%% C. Linear rating scale _____________________________________________________
%image_filepath                 = fullfile(main_dir,'stimuli','ratingscale');
%image_scale_filename           = lower(['task-',judgment,'_scale.jpg']);
image_scale                    = fullfile(task_dir,'ratingscale.jpg');

%%% Uncomment after ratings are consistently occuring without breaking
%HideCursor;
%%
% % H. Make Images Into Textures ________________________________________________
% DrawFormattedText(p.ptb.window,sprintf('LOADING\n\n0%% complete'),'center','center',p.ptb.white );
%Screen('Flip',p.ptb.window);
%
%%% FIGURE OUT LOOP THROUGH 
%for trl = 1:length(EEE_pairs)
% 
%     %cue_tex{trl} = Screen('MakeTexture', p.ptb.window, imread(cue_image));
%     image_filename  = [countBalMat.image_filename{trl}];
%     image_file      = fullfile(dir_video, video_filename);
%     [movie{trl}, ~, ~, imgw{trl}, imgh{trl}] = Screen('OpenMovie', p.ptb.window, video_file);
     rating_tex      = Screen('MakeTexture', p.ptb.window, imread(image_scale)); % pure rating scale
%     %start_tex       = Screen('MakeTexture',p.ptb.window, imread(instruct_start));
%     %end_tex         = Screen('MakeTexture',p.ptb.window, imread(instruct_end));
%     DrawFormattedText(p.ptb.window,sprintf('LOADING\n\n%d%% complete', ceil(100*trl/length(countBalMat.ISI))),'center','center',p.ptb.white);
%     Screen('Flip',p.ptb.window);
% end

%% -----------------------------------------------------------------------------
%                              Start Experiment
% ------------------------------------------------------------------------------

%% ______________________________ Instructions _________________________________
Screen('TextSize',p.ptb.window,40);
DrawFormattedText(p.ptb.window,instruct_start,'center',p.ptb.screenYpixels/2,255);
Screen('Flip',p.ptb.window);

%% _______________________ Wait for Trigger to Begin ___________________________
DisableKeysForKbCheck([]);

WaitKeyPress(KbName('s'));
% flips to fixation after immediately pressing s
Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
    p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
Screen('Flip',p.ptb.window);
WaitKeyPress(p.keys.trigger);
T.param_trigger_onset(:) = GetSecs;
%T.param_start_biopac(:)                   = biopac_linux_matlab(biopac, channel, channel.trigger, 1);
Screen('TextSize',p.ptb.window,72);
DrawFormattedText(p.ptb.window,instruct_trigger,'center',p.ptb.screenYpixels/2,255);
Screen('Flip',p.ptb.window);

WaitSecs(TR*6);

Screen('TextSize',p.ptb.window,36);
%% 0. Experimental loop _________________________________________________________
%for trl = 1:size(countBalMat,1)

    %% 1. Fixtion Jitter  ____________________________________________________
    %jitter1 = countBalMat.ISI(trl)-1;
    Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
        p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);


    T.event01_fixation_onset(trl)         = Screen('Flip', p.ptb.window);
    %T.event01_fixation_biopac(trl)        = biopac_linux_matlab(biopac, channel, channel.fixation, 1);
    WaitSecs(2);
    %jitter1_end                           = biopac_linux_matlab(biopac, channel, channel.fixation, 0);
    %T.event01_fixation_duration(trl) = jitter1_end - T.event01_fixation_onset(trl) ;

    %% 2. face ________________________________________________________________
    %video_filename = [countBalMat.image_filename{trl}];
    %video_file = fullfile(dir_video, video_filename);
    %T.event02_face_biopac(trl)      = biopac_linux_matlab(biopac, channel, channel.faces, 1);
    %movie_time = video_play(video_file , p ,movie{trl}, imgw{trl}, imgh{trl});
    %T.event02_face_onset(trl) = movie_time;
    %biopac_linux_matlab(biopac, channel, channel.faces, 0);


    %% 3. post evaluation rating ___________________________________________________
    %T.event03_rating_biopac(trl)          = biopac_linux_matlab(biopac, channel, channel.rating, 1);
    [onsettime, trajectory, RT, buttonPressOnset] = linear_rating_adapted(1.875,p, rating_tex, 'expectation')%, biopac, channel);
    rating_Trajectory{trl,2}            = trajectory;
    T.event03_rating_displayonset(trl) = onsettime;
    T.event03_rating_responseonset(trl) = buttonPressOnset;
    T.event03_rating_RT(trl) = RT;
    %biopac_linux_matlab(biopac, channel, channel.rating, 0);

        %% ________________________ 7. temporarily save file _______________________
   % tmp_file_name = fullfile(sub_save_dir,strcat(bids_string,'_TEMPbeh.csv' ));
   % writetable(T,tmp_file_name);
%end

%% ______________________________ Instructions _________________________________
Screen('TextSize',p.ptb.window,40);
DrawFormattedText(p.ptb.window,instruct_end,'center',p.ptb.screenYpixels/2,255);

T.param_end_instruct_onset(:) = Screen('Flip',p.ptb.window);
%T.param_end_biopac(:)                     = biopac_linux_matlab(biopac, channel, channel.trigger, 0);
WaitKeyPress(KbName('e'));
%T.param_experiment_duration(:) = T.param_end_instruct_onset(1) - T.param_trigger_onset(1);


%clear all; clear p; Screen('Close'); close all; sca; clearvars;



