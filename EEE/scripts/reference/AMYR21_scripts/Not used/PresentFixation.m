% PresentFixation %
% v2.14.2022

function Fixation = PresentFixation(FixTxt, window, clr)
    % INPUT - Len: length of cross in pixels
    %       - Wid: width of cross in pixels
    %       - window: where cross will be presented
    
    % set screen coordinates
    fixCoord = [-len len 0 0; 0 0 -len len];
    
    % draw fixation cross with high quality smoothing
    Screen('DrawLines', window, fixCoord, wid, clr, [xCenter yCenter], 2);
    Screen('Flip', window);
    