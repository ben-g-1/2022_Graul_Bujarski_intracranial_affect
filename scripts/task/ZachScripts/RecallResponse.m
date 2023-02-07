% RecallResponse %
% v.3.15.2022 %

% function to get user keyboard response input for recognition task - Y/N

function [rt, key, tStart] = RecallResponse(ImageFile, window, ifi)
    % INPUT - ImageFile: image file path
    %       - window: where texture gets presented
    %       - Ifi: inter-flip-interval for screen sync
    % OUPUT - RT: response time
    %       - key: numerical value of key pressed
    %           yes = 1 ; no = 0
    %           esc = 99
    %       - tStart: image onset time, store for timing validation

    % define key code labels
    escapeKey = KbName('ESCAPE');
    yesKey = KbName('0');
    noKey = KbName('.');

    %%%% Image Set up %%%
  
    % read in image
    img = imread(ImageFile);
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

    %%%%%%%%%%%%%%%%

    %%% Get Response %%%

    % draw image, flip screen, and sync timing with refresh rate
    Screen('DrawTexture', window, ImageTexture, [], dstRect);
    % store timestamp for image presentation
    ft = Screen('Flip', window);
    tStart = ft;
    
    % check for key presses, loop until valid key is pressed
    check = true;

    while check == true
        
        % draw image
        Screen('DrawTexture', window, ImageTexture, [], dstRect);
        % flip to screen
        ft = Screen('Flip', window, ft + 0.5 .* ifi);

        % check for keypress
        [keyTime, keyCode, ~] = KbStrokeWait();
        
        % if a valid key is pressed - return the key value, otherwise
        % continue loop

        % ESCAPE KEY - return 99
        if keyCode(escapeKey)
            key = 99;
            check = false;
        % YES KEY - return 1
        elseif keyCode(yesKey)
            key = 1;
            check = false;
        % NO KEY - return 0
        elseif keyCode(noKey)
            key = 0;
            check = false;
        end
       
    end

    % calculate reaction time
    rt = keyTime - tStart;

    % close image texture
    Screen('Close', ImageTexture)
end