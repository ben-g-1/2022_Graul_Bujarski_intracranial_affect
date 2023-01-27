% DrawFixation %
% v2.14.2022

function FixationTexture = DrawFixation(xy, clr, backgrd, window)
    % INPUT - Len: length of cross in pixels
    %       - Wid: width of cross in pixels
    %       - [xy]: coordinates for center of fixation
    %       - clr: color of lines
    %       - backgrd: color of background window
    %       - window: where fixation will be presented
    % OUTPUT - FixationTexture: a texture with fixation cross
    
    % parameters to adjust for fixation dimensions
    len = 50;    % length of cross lines
    wid = 10;     % thickness of cross lines

    % set screen coordinates
    fixCoord = [-len len 0 0; 0 0 -len len];
    % make texture
    FixationTexture = Screen('makeTexture', window, ones(len)*backgrd);
    
    % draw fixation cross
    Screen('DrawLines', FixationTexture, fixCoord, wid, clr, xy);
end
    