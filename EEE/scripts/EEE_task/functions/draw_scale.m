function draw_scale(p)    
% Screen('Preference', 'SkipSyncTests', 1);
% % 
% % PsychDefaultSetup(2);
% screens                        = Screen('Screens'); % Get the screen numbers
% p.ptb.screenNumber             = max(screens); % Draw to the external screen if avaliable
% p.ptb.white                    = WhiteIndex(p.ptb.screenNumber); % Define black and white
% p.ptb.black                    = BlackIndex(p.ptb.screenNumber);
% p.ptb.grey                     = p.ptb.white/2;
% 
% 
% PsychImaging('PrepareConfiguration');
% PsychImaging('AddTask', 'General', 'UseFastOffscreenWindows');
% 
% [p.ptb.window, p.ptb.rect]     = PsychImaging('OpenWindow',p.ptb.screenNumber,p.ptb.black);
% [p.ptb.screenXpixels, p.ptb.screenYpixels] = Screen('WindowSize',p.ptb.window);
% p.ptb.ifi                      = Screen('GetFlipInterval',p.ptb.window);
% Screen('BlendFunction', p.ptb.window,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA'); % Set up alpha-blending for smooth (anti-aliased) lines
% Screen('TextFont', p.ptb.window, 'Arial');
% 
% Screen('TextSize', p.ptb.window, 108);
% 
% [p.ptb.xCenter, p.ptb.yCenter] = RectCenter(p.ptb.rect);
% p.fix.sizePix                  = 40; % size of the arms of our fixation cross
% p.fix.lineWidthPix             = 4; % Set the line width for our fixation cross
% p.fix.xCoords                  = [-p.fix.sizePix p.fix.sizePix 0 0];
% p.fix.yCoords                  = [0 0 -p.fix.sizePix p.fix.sizePix];
% p.fix.allCoords                = [p.fix.xCoords; p.fix.yCoords];
% 
% 
% p.rate.lineWidthPix             = 8; % Set the line width for our rating lines cross
% p.rate.bounds                   = 0.4*p.ptb.screenXpixels;
% p.rate.leftbound                = 0.1*p.ptb.screenXpixels;
% p.rate.rightbound               = 0.9*p.ptb.screenXpixels;   
% p.rate.anchorDisp               = 0.02*p.ptb.screenYpixels;
% p.rate.rateDisp                 = 0.1*p.ptb.screenYpixels;
% p.rate.xCoords                  = [-p.rate.bounds p.rate.bounds 0 0];
% p.rate.yCoords                  = [0 0 -p.rate.anchorDisp p.rate.anchorDisp];
% p.rate.allCoords                = [p.rate.xCoords; p.rate.yCoords];
% p.penwidth                      = 3
% 
% pleasant = 'Extremely Pleasant';
% unpleasant = 'Extremely Unpleasant';
% neutral = 'Neutral';

%Empty Scale
  Screen('DrawLines', p.ptb.window, p.rate.allCoords, p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
     % Side anchors
    Screen('DrawLine', p.ptb.window, p.ptb.white, p.rate.leftbound, p.ptb.yCenter-p.rate.anchorDisp, p.rate.leftbound, p.ptb.yCenter+p.rate.anchorDisp, p.penwidth)
    Screen('DrawLine', p.ptb.window, p.ptb.white, p.rate.rightbound, p.ptb.yCenter-p.rate.anchorDisp, p.rate.rightbound, p.ptb.yCenter+p.rate.anchorDisp, p.penwidth)
    
    % Add text labels
    DrawFormattedText(p.ptb.window,p.neutral,'center',p.ptb.screenYpixels*.70,255);
    DrawFormattedText(p.ptb.window,p.unpleasant,p.ptb.screenXpixels*0.05,p.ptb.screenYpixels*.70,255);
    DrawFormattedText(p.ptb.window,p.pleasant,p.ptb.screenXpixels*0.8,p.ptb.screenYpixels*.70,255);
end %function



