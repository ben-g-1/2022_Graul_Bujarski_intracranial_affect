% TestLightSensor
% v.9.22.22

function TestLightSensor()

    % INPUT - none
    % OUTPUT - none
    
    %%%% PTB screen presentation setup %%%%

    % clear any existing psychtoolbox screens
    clear Screen
    
    % default settings for setting up Psychtoolbox
    PsychDefaultSetup(2);
    
    % set to display to external monitor (2)
    % need to change to 1 for laptop screen display
    screenPresent = 2;
    
    % Define colors: black, white
    white = WhiteIndex(screenPresent);
    black = BlackIndex(screenPresent);
    
    % Open an on screen window
    [window, ~] = PsychImaging('OpenWindow', screenPresent, black);
    
    % get monitor refresh rate
    ifi = Screen('GetFlipInterval', window);
    
    % Set up alpha-blending for smooth (anti-aliased) lines
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    % set PTB as top priority level
    Priority(MaxPriority(window));

    %%% image set up %%%

    % practice image file path
    PracticeImage = 'C:\Users\ztlee\Documents\MATLAB\EMO\Practice Images\Horse racing 1.JPG';

    % presentation times in secs
    PImgTime = 3;
    FixTime = 1;

    %%%%%%%%%%%%%%%%%%%
    
    %%%  text set up %%%
    PracticeTxt = 'This is a TEST trial';
    
    % text font
    Screen('TextFont', window, 'Ariel');
    % text color - set to white
    Screen('TextColor', window, white)

    %%%%%%%%%%%%%%%%%%%%

    % loop to repeat image presentation
    num_tests = 6; % number of loops - 5 seconds per loop

    for i=1:num_tests
        % display practice text alert
        Screen('TextSize', window, 72); % increase text size
        DrawFormattedText(window, PracticeTxt, 'center', 'center', white);
        Screen('Flip', window);
        WaitSecs(1);
        % fixation
        DrawFixation(screenPresent, window, FixTime, ifi);
        % image
        PresentImage(PracticeImage, window, PImgTime, ifi);
    end
    
    % display message for end of practice
    Screen('TextSize', window, 72); % increase text size
    DrawFormattedText(window, 'Test Complete. Press Key to Exit',...
        'center', 'center', white);
    Screen('Flip', window);
    KbStrokeWait();
    Screen('Close',window)
end