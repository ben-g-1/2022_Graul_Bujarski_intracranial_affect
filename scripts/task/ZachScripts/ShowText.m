% ShowText %
% v3.15.22

% function to display text and wait for user keypress

function Advance = ShowText(txt, screenID, window)
    % INPUT - txt: text to be shown
    %       - screenID: where window is open
    %       - window: where text gets displayed
    % OUTPUT - Advance: 0=exit task. 1 = continue
    
    % Setup the text font, size
    Screen('TextFont', window, 'Ariel');
    Screen('TextSize', window, 40);
    % set text color to white
    white = WhiteIndex(screenID);

    % Get the size of the on screen window
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);

    % get center of screen 
    xCenter = screenXpixels /2;
    yCenter = screenYpixels /2;

    % define key code for escape key
    escapeKey = KbName('ESCAPE');

    % sub-text instructing user to advance screen
    AdvTxt = 'Press Any Key to Continue';
    
    % draw main text centered
    DrawFormattedText(window, txt, 'center', 'center', white);
    % draw sub-text below
    DrawFormattedText(window, AdvTxt, 'center', yCenter + 300, white);
    % flip
    Screen('Flip', window);
    % wait for key press
    [~,keys] = KbStrokeWait();
    % check for esc key and end task
    if keys(escapeKey)
        Advance = 0;
    else
        Advance = 1;
    end

end