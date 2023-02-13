%%%% PTB screen presentation setup %%%%

% clear any existing psychtoolbox screens
clear Screen

% default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
% Screen('Preference', 'SkipSyncTests', 1)

% Get screen numbers
screens = Screen('Screens');

% set to display to external monitor (2)
% need to change to 1 for laptop screen display
screenPresent = max(screens);

% Define colors: black, white
white = WhiteIndex(screenPresent);
black = BlackIndex(screenPresent);

% Open an on screen window
[window, ~] = PsychImaging('OpenWindow', screenPresent, black);

% % Get the size of the on screen window
 [screenXpixels, screenYpixels] = Screen('WindowSize', window);

% get monitor refresh rate
ifi = Screen('GetFlipInterval', window);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% set PTB as top priority level
Priority(MaxPriority(window));

% exit on any key
KbStrokeWait;
sca;