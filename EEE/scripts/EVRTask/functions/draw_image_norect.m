
%%
% cues = stim_table.image_cue_values;
% for k = 1:64
%     %Show fixation cross 
%     %Show ratings w/ white box in corner
%     for m = 1:10
%         column = cues{k};
%         rating = column(m);
%     end
%     %Show rating line
%     %Record expectation rating w/ white box in corner
%         % Record time initialized, X displacement, button onset, reaction time 
%     %Show fixation cross
%     %Show image at line k
%     %Record valence rating w/ white box in corner
% end
%% Set directories
subjectnum = 99
sessionnum = 99

basedir = 'C:\Users\bgrau\GitHub\ieeg_affect';
projdir = fullfile(basedir, 'EEE');
filedir = fullfile(projdir, 'files');
scriptdir = fullfile(projdir, 'scripts', 'EVRTask');
subjdir = fullfile(projdir, 'subjects', ['sub-',  num2str(subjectnum)]);
sesdir = fullfile(subjdir, ['ses-', num2str(sessionnum)]);
imagedir = fullfile(filedir, 'oasis_pairs');
load(fullfile(sesdir, 'stim_table.mat'))
%%
nrow = size(stim_table, 1);
stim_table.exp_react_time = NaN(nrow, 1)

%% PTB Setup
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

Screen('TextSize', p.ptb.window, 36);

[p.ptb.xCenter, p.ptb.yCenter] = RectCenter(p.ptb.rect);
p.fix.sizePix                  = 40; % size of the arms of our fixation cross
p.fix.lineWidthPix             = 4; % Set the line width for our fixation cross
p.fix.xCoords                  = [-p.fix.sizePix p.fix.sizePix 0 0];
p.fix.yCoords                  = [0 0 -p.fix.sizePix p.fix.sizePix];
p.fix.allCoords                = [p.fix.xCoords; p.fix.yCoords];


% p.rate.lineWidthPix             = 8; % Set the line width for our rating lines cross
% p.rate.bounds                   = 0.4*p.ptb.screenXpixels;
% p.rate.leftbound                = 0.1*p.ptb.screenXpixels;
% p.rate.rightbound               = 0.9*p.ptb.screenXpixels;   
% p.rate.anchorDisp               = 0.02*p.ptb.screenYpixels;
% p.rate.rateDisp                 = 0.1*p.ptb.screenYpixels;
% p.rate.xCoords                  = [-p.rate.bounds p.rate.bounds 0 0];
% p.rate.yCoords                  = [0 0 -p.rate.anchorDisp p.rate.anchorDisp];
% p.rate.ratingyCoords            = [0 0 -100 100]
% p.rate.anchoryCoords            = [0 0 -p.rate.anchorDisp p.rate.anchorDisp];
% p.rate.allCoords                = [p.rate.xCoords; p.rate.yCoords];
% p.rate.leftanchor               = [[-50 -50 -p.rate.anchorsizePix p.rate.anchorsizePix]; [-50 -50 -p.rate.anchorsizePix p.rate.anchorsizePix]];
% p.penwidth                      = 3

%%
p.image.coords                    = [0.1*p.ptb.screenXpixels 0.1*p.ptb.screenYpixels 0.9*p.ptb.screenXpixels 0.9*p.ptb.screenYpixels]
lightRect                         = [(p.ptb.screenXpixels-70) (p.ptb.screenYpixels-70) p.ptb.screenXpixels p.ptb.screenYpixels];
%%
KbName('UnifyKeyNames');
p.keys.confirm                 = KbName('return');
p.keys.right                   = KbName('2');
p.keys.left                    = KbName('1');
p.keys.space                   = KbName('space');
p.keys.esc                     = KbName('ESCAPE');
p.keys.trigger                 = KbName('5%');
p.keys.start                   = KbName('s');
p.keys.end                     = KbName('e');

%% Show image
imagename = append(stim_table.Theme(1), ".jpg")
imagepath = fullfile(imagedir, imagename)
imagetex = Screen('MakeTexture', p.ptb.window, imread(imagepath))
Screen('DrawTexture', p.ptb.window, imagetex, [], p.image.coords)

%     % draw white rect in bottom right corner of screen
% Screen('FillRect',p.ptb.window,p.ptb.white, lightRect);
Screen('Flip', p.ptb.window)
KbStrokeWait;
sca;
