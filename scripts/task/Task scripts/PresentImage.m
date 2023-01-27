% PresentImage %
% v3.7.2022

% function to load image file and present as texture for fixed time

function timestamp = PresentImage(filename, window, time, ifi)
    % INPUT - filename: image file path
    %       - window: window where image will be displayed
    %       - time: image presentation time in secs
    % OUTPUT - timestamp: time when image was presented
  
    % read in image
    img = imread(filename);
    % convert image to a texture
    ImageTexture = Screen('MakeTexture', window, img);
    % get size of image
    [s1, s2, ~] = size(img);

    % Get the size of the on screen window
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);

    % calculate center of screen
    xCenter = screenXpixels /2;
    yCenter = screenYpixels /2;
    
    % resize image - set height to 75% screen height
    imgHeight = screenYpixels * 0.75;
    % calc aspect ratio
    ar = s2 / s1;
    % resize image width based on aspect ratio
    imgWidth = imgHeight .* ar;

    % make destination rect of resized img
    dstRect = CenterRectOnPoint([0 0 imgWidth imgHeight], xCenter, yCenter);

    % make rect for light sensor
    lightRect = [(screenXpixels-50) (screenYpixels-50) screenXpixels screenYpixels];
    % draw white rect in bottom right corner of screen
    Screen('FillRect',window,[1 1 1], lightRect);
    
    % convert time in secs to frames using ifi
    frames = round(time/ifi);

    % draw image, flip screen, and sync timing with refresh rate
    Screen('DrawTexture', window, ImageTexture, [], dstRect);
    % store timestamp for image presentation
    timestamp = Screen('Flip', window);
    ft = timestamp;
    % present image for set # of frames (-1 since already presented
    % for 1 frame)
    for f = 1:frames -1
        Screen('DrawTexture', window, ImageTexture, [], dstRect);
        % draw light sensor rect along with image
        Screen('FillRect',window,[1 1 1], lightRect);
        ft = Screen('Flip', window, ft  + 0.5 * ifi);
    end
    % flip to blank screen
    Screen('Flip',window);
    % close image texture
    Screen('Close', ImageTexture);
end