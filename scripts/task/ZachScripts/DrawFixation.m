% DrawFixation %
% v2.14.2022

function DrawFixation(screenID, window, time, ifi)
    % INPUT - screenID: index for screen where window is open
    %       - window: where fixation will be presented
    % OUTPUT -
    
    % parameters to adjust for fixation dimensions
    len = 50;    % length of cross lines
    wid = 10;     % thickness of cross lines

    % set line color to white
    clr = WhiteIndex(screenID);

    % Get the size of the on screen window
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);

    % set location of fixation cross to center of screen
    xCenter = screenXpixels /2;
    yCenter = screenYpixels /2;

    % set coordinates for fixation lines
    fixCoord = [-len len 0 0; 0 0 -len len];

    % calculate # of frames to present fixation based on time(secs) and ifi
    frames = round(time/ifi);
    
    % draw fixation cross
    Screen('DrawLines', window, fixCoord, wid, clr, [xCenter yCenter]);

    % draw fixation, flip screen, and sync timing with refresh rate
    ft = Screen('Flip', window);
    % present fixation for set # of frames (-1 since already presented
    % for 1 frame)
    for f = 1:frames -1
        Screen('DrawLines', window, fixCoord, wid, clr, [xCenter yCenter]);
        ft = Screen('Flip', window, ft  + 0.5 * ifi);
    end
end
    