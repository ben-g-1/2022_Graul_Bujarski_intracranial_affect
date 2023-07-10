function [timing_initialized, x_coord, RT, buttonPressOnset] = record_rating_norect(duration, p, rating_type)
% global screenNumber window windowRect xCenter yCenter screenXpixels screenYpixels
% shows a linear rating scale and records mouse position
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
% edited Ben Graul for EEE task 2/7/2023
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

% %%PTB SETTINGS
% global p
% %%% Remove or comment when working on hospital laptop
% if getenv('USERNAME') == 'bgrau'
%     Screen('Preference', 'SkipSyncTests', 1);
% else 
%     'PsychToolbox Probably won`t work correctly. Change the SyncTests setting.'
%     return
% end
% 
% PsychDefaultSetup(2);
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
% KbName('UnifyKeyNames');
% p.keys.confirm                 = KbName('return');
% p.keys.right                   = KbName('2');
% p.keys.left                    = KbName('1');
% p.keys.space                   = KbName('space');
% p.keys.esc                     = KbName('ESCAPE');
% p.keys.trigger                 = KbName('5%');
% p.keys.start                   = KbName('s');
% p.keys.end                     = KbName('e');
% 
% p.image.coords                 = [0.1*p.ptb.screenXpixels 0.1*p.ptb.screenYpixels 0.9*p.ptb.screenXpixels 0.9*p.ptb.screenYpixels];
% p.lightRect                      = [(p.ptb.screenXpixels-70) (p.ptb.screenYpixels-70) p.ptb.screenXpixels p.ptb.screenYpixels];
% 
% p.pleasant = 'Extremely Pleasant';
% p.unpleasant = 'Extremely Unpleasant';
% p.neutral = 'Neutral';
%%% 
% 
%     duration = 5;
% 
%     rating_type = 'Expectation';

%%

SAMPLERATE = .01; % used in continuous ratings
TRACKBALL_MULTIPLIER=1;

%%%

%HideCursor;


%%


dspl.cscale.width = p.ptb.screenXpixels*0.8; % scale width
dspl.cscale.height = p.rate.rateDisp; %  scale height
dspl.cscale.xcenter = p.ptb.screenXpixels/2; % scale center
dspl.cscale.ycenter = p.ptb.screenYpixels/2;

% placement
dspl.cscale.rect = [...
    [p.ptb.xCenter p.ptb.yCenter]-[0.5*dspl.cscale.width 0.5*dspl.cscale.height] ...
    [p.ptb.xCenter p.ptb.yCenter]+[0.5*dspl.cscale.width 0.5*dspl.cscale.height]];

% determine cursor parameters for all scales
cursor.xmin = p.rate.leftbound;
cursor.xmax = p.rate.rightbound;


cursor.size = 32;
cursor.xcenter = ceil(dspl.cscale.rect(1) + (dspl.cscale.rect(3) - dspl.cscale.rect(1))*0.5);
cursor.ycenter = ceil(dspl.cscale.rect(2) + (dspl.cscale.rect(4)-dspl.cscale.rect(2))*0.5);
cursor.ymin = cursor.ycenter;
cursor.ymax = cursor.ycenter;


% Screen('TextSize',p.ptb.window,72);
% DrawFormattedText(p.ptb.window,rating_type,'center',p.ptb.screenYpixels/2+150,255);
timing_initialized = Screen('Flip',p.ptb.window);
cursor.x = cursor.xcenter;
cursor.y = cursor.ycenter;
sample = 1;
SetMouse(cursor.xcenter,cursor.ycenter);
nextsample = GetSecs;



%%%
buttonpressed  = false;
% GetClicks = 0
rlim = 500;
xlim = cursor.xcenter;
ylim = cursor.ycenter;
% while GetClicks == 0
while GetSecs < timing_initialized + duration

    loopstart = GetSecs;

    % sample at SAMPLERATE
    if loopstart >= nextsample
        ctime(sample) = loopstart; %#ok
        trajectory(sample,1) = cursor.x; %#ok
        trajectory(sample,2) = cursor.y;
        nextsample = nextsample+SAMPLERATE;
        sample = sample+1;
    end


    if ~buttonpressed
    [x, y, buttonpressed] = GetMouse; % measure mouse movement
    SetMouse(cursor.xcenter,cursor.ycenter); % reset mouse position

    % calculate displacement
    cursor.x = (cursor.x + x-cursor.xcenter) * TRACKBALL_MULTIPLIER;
    cursor.y = (cursor.y + y-cursor.ycenter) * TRACKBALL_MULTIPLIER;
    %[cursor.x, cursor.y, xlim, ylim] = limit(cursor.x, cursor.y, cursor.xcenter, cursor.ycenter, rlim, xlim, ylim);
    xlim = cursor.xcenter;
    ylim = cursor.ycenter;
    % check bounds
    if cursor.x > cursor.xmax
        cursor.x = cursor.xmax;
    elseif cursor.x < cursor.xmin
        cursor.x = cursor.xmin;
    end

    if cursor.y > cursor.ymax
        cursor.y = cursor.ymax;
    elseif cursor.y < cursor.ymin
        cursor.y = cursor.ymin;
    end

    % produce screen
    draw_scale(p)
    % Screen('FillRect',p.ptb.window,p.ptb.white, p.lightRect);
    DrawFormattedText(p.ptb.window,rating_type,'center',p.ptb.screenYpixels/4,255);
    % add rating indicator line
    Screen('DrawLine', p.ptb.window, p.ptb.white, cursor.x, p.ptb.yCenter-p.rate.rateDisp, cursor.x, p.ptb.yCenter+p.rate.rateDisp, p.penwidth);
    Screen('Flip',p.ptb.window);

    elseif any(buttonpressed)
       RT = GetSecs - timing_initialized;
       buttonPressOnset = GetSecs;
       buttonpressed = [0 0 0];
       x_coord = trajectory(length(trajectory), 1);
       draw_scale(p)
       DrawFormattedText(p.ptb.window,rating_type,'center',p.ptb.screenYpixels/4,255);
       % cursor changes
       Screen('DrawLine', p.ptb.window, [255 0 0], cursor.x, p.ptb.yCenter-p.rate.rateDisp, cursor.x, p.ptb.yCenter+p.rate.rateDisp, p.penwidth);
       Screen('Flip',p.ptb.window);
    %    remainder_time = duration-0.5-RT;
    %    sca;
       duration = 0;
       WaitSecs(.5);
       
    end 
    
end %while

end %function


