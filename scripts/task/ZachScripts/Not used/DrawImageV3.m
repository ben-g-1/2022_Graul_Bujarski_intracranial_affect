% PresentImage %
% v3.7.2022

% function to load image file and present as texture

function timestamp = PresentImage(filename, window, time, ifi)
    % INPUT - filename: image file path
    %       - window: window where image will be displayed
    %       - time: image presentation time in secs
    % OUTPUT - 
  
    % read in image
    img = imread(filename);
    % convert image to a texture
    ImageTexture = Screen('MakeTexture', window, img);
    % get size of image
    [s1, s2, ~] = size(img);
    % resize image
    
    % convert time in secs to frames using ifi
    frames = round(time/ifi);

    % draw image, flip screen, and sync timing with refresh rate
    Screen('DrawTexture', window, ImageTexture);
    % store timestamp for image presentation
    timestamp = Screen('Flip', window);
    ft = timestamp;
    % present image for set # of frames (-1 since already presented
    % for 1 frame)
    for f = 1:frames -1
        Screen('DrawTexture', window, ImageTexture);
        ft = Screen('Flip', window, ft  + 0.5 * ifi);
    end
end