% Task Setup Function %

%%%% placeholder for code %%%%%

    %%%
    % use only during testing with multiple monitor dock set up to avoid errors
    Screen('Preference', 'SkipSyncTests', 1); 
    %%%
    
    % call some default settings for setting up Psychtoolbox
    PsychDefaultSetup(2);
    
    % Get the screen numbers
    screens = Screen('Screens');
    
    % Draw to the external screen if avaliable
    screenNumber = max(screens);
    
    % Define black, white, grey
    white = WhiteIndex(screenNumber);
    black = BlackIndex(screenNumber);
    grey = white / 2;
    
    % Open an on screen window
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
    
    % Get the size of the on screen window
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);
    
    % Query the frame duration
    ifi = Screen('GetFlipInterval', window);
    
    % Get the centre coordinate of the window
    [xCenter, yCenter] = RectCenter(windowRect);
    
    % Set up alpha-blending for smooth (anti-aliased) lines
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
