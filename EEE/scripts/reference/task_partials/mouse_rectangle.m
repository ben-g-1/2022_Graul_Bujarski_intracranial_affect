%function [timing_initialized, trajectory, RT, buttonPressOnset] = linear_rating(duration, p, image_tex, rating_type, biopac, channel)
% global screenNumber window windowRect xCenter yCenter screenXpixels screenYpixels
% shows a circular rating scale and records mouse position
%
% Input: duration - length of response period in seconds)
% Output: trajectory - n samples x 2 matrix (x coord, y coord)
%
% Note - this function call a new instance of PTB
% you likely wont want to use it this way in a paradigm
% just copy paste the relevant sections or use this as a subfunction
% initializing screen
%
% You will need PTB installed for this to work.
%
% [trajectory, dspl,cursor] = circular_rating(3);
% figure; comet(trajectory(:,1),trajectory(:,2))
%
% Phil Kragel 6/20/2019
% edited Heejung Jung 7/26/2019
% edited Phil Kragel for faces task 11/15/2019
%
% Additions ________________
% 1. duration:    length of rating scale, NOTE that the duration is filled with a fixation
%                 once the participant incidates a response.
%                 e.g. * experimenter fixes rating duration to 4 sec.
%                      * participant RT to respond to rating scale was 1.6 sec.
%                      * response will stay on screen for 0.5 sec
%                      * fixation cross will fill the the remainder of the duration
%                              i.e., 4-1.6-0.5 = 1.9 sec of fixation
% 2. p: psychtoolbox window parameters
% 3. image_scale: social influence task requires different rating scales
%                 (pain rating vs cognitive effort rating)
%                 The code takes different rating scale images
% 4. rating_type: social influence task has two ratings "expectation" & "actual experience"
%                 rating_type takes the keyword and displays it onto the rating scale

%%PTB SETTINGS
global p
%%% Remove or comment when working on hospital laptop
if getenv('USERNAME') == 'bgrau'
    Screen('Preference', 'SkipSyncTests', 1);
else 
    'PsychToolbox Probably won`t work correctly. Change the SyncTests setting.'
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

Screen('TextSize', p.ptb.window, 36);

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
p.penwidth                      = 3

KbName('UnifyKeyNames');
p.keys.confirm                 = KbName('return');
p.keys.right                   = KbName('2');
p.keys.left                    = KbName('1');
p.keys.space                   = KbName('space');
p.keys.esc                     = KbName('ESCAPE');
p.keys.trigger                 = KbName('5%');
p.keys.start                   = KbName('s');
p.keys.end                     = KbName('e');

%%%DEBUG

p.image.coords                 = [0.1*p.ptb.screenXpixels 0.1*p.ptb.screenYpixels 0.9*p.ptb.screenXpixels 0.9*p.ptb.screenYpixels]
lightRect                      = [(p.ptb.screenXpixels-70) (p.ptb.screenYpixels-70) p.ptb.screenXpixels p.ptb.screenYpixels];
%%

SAMPLERATE = .01; % used in continuous ratings
TRACKBALL_MULTIPLIER=1;
RT = NaN;
buttonPressOnset = NaN;
%%%
rating_type = 'expect'; 

HideCursor; 
SetMouse(p.ptb.xCenter, p.ptb.yCenter, p.ptb.window);
waitframes = 1;
vbl = Screen('Flip', p.ptb.window)
while ~KbCheck
    [x, y, buttons] = GetMouse(p.ptb.window)
%     xMin = min(x, p.rate.leftbound)
%     xMax = max(x, p.rate.rightbound)
%     yMin = min(y, p.ptb.yCenter)
%     yMax = max(y, p.ptb.yCenter)
    x = min(x, p.ptb.xCenter)
    y = min(y, p.ptb.yCenter)
  

    Screen('FillRect', p.ptb.window, [x y], 10, p.ptb.white, [], 2);

    vbl = Screen('Flip', p.ptb.window, vbl + (waitframes - 0.5) * p.ptb.ifi)
end
sca;
