%% Initialize PsychToolbox defaults
global p;
%%% Remove or comment when working on hospital laptop
if getenv('USERNAME') == 'bgrau'
    Screen('Preference', 'SkipSyncTests', 1);
else 
    disp('PsychToolbox probably won`t work correctly. Change the SyncTests setting.')
    return
end

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

KbStrokeWait;

%%

cuemat = cell2mat(stim_table.image_cue_values(4));
    for c = 1:10 
        pix_prcnt = ((cuemat(c)-1)/6);
        xpix_coord = (pix_prcnt*0.8*p.ptb.screenXpixels) + (.1*p.ptb.screenXpixels);
%%% Rewrite line to preallocate memory, not dynamically increase each loop
        cue_xPixel(1,c) = xpix_coord;
    end
%%

  Screen('DrawLines', p.ptb.window, p.rate.allCoords, p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
     % Side anchors
     Screen('DrawLine', p.ptb.window, p.ptb.white, p.rate.leftbound, p.ptb.yCenter-p.rate.anchorDisp, p.rate.leftbound, p.ptb.yCenter+p.rate.anchorDisp, p.penwidth)
     Screen('DrawLine', p.ptb.window, p.ptb.white, p.rate.rightbound, p.ptb.yCenter-p.rate.anchorDisp, p.rate.rightbound, p.ptb.yCenter+p.rate.anchorDisp, p.penwidth)
      
    DrawFormattedText(p.ptb.window,p.neutral,'center',p.ptb.screenYpixels*.70,255);
    DrawFormattedText(p.ptb.window,p.unpleasant,p.ptb.screenXpixels*0.05,p.ptb.screenYpixels*.70,255);
    DrawFormattedText(p.ptb.window,p.pleasant,p.ptb.screenXpixels*0.75,p.ptb.screenYpixels*.70,255);
draw_cue(p,cue_xPixel);
% draw white rectangle in bottom right corner of screen for external timing validation
Screen('FillRect',p.ptb.window,p.ptb.white, p.lightRect);
Screen('Flip', p.ptb.window);

KbStrokeWait;
sca;