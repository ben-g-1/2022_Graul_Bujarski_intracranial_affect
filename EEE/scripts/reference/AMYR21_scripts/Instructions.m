% Instructions %
% v3.7.2022 %

% function to present instructions at start of task

function Exit = Instructions(screenID, window)
    % INPUT - screenID: screen where window is open
    %       - window: where presentation occurs
    % OUTPUT - exit: boolean value, 1=end task, 0 =continue
    
    %%% Text %%%
    StartTxt = 'Press Any Key to Begin';
    AdvTxt = 'Press Any Key to Continue';
    
    % Setup the text font, size
    Screen('TextFont', window, 'Ariel');
    Screen('TextSize', window, 50);
    % set text color to white
    white = WhiteIndex(screenID);
    %%%%%%%%%%%%
    
    %%% Images %%%
    % instruction image folder
    InstructionsFolderPath = 'C:\Users\ztlee\Documents\MATLAB\EMO\Instructions';
    % instruction image filenames
    InstructionImages = ["slide1", "slide2", "slide3", "slide4", "slide5"];
    %%%%%%%%%%%%%%%

    %%% Screen %%%
    % Get the size of the on screen window
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);

    % get center of screen 
    xCenter = screenXpixels /2;
    yCenter = screenYpixels /2;
    %%%%%%%%%%%%

    %%% Input Keys %%%
    % define key code labels
    escapeKey = KbName('ESCAPE');
    %%%%%%%%%%%

    % start screen
    DrawFormattedText(window, StartTxt, 'center', 'center', white);
    Screen('Flip', window);
    [~,keys] = KbStrokeWait();
    % check for esc key and end task
    if keys(escapeKey)
        Exit = 1;
        return;
    end
    
    % present instruction slide images - wait for keypress to advance
    for i = 1:length(InstructionImages)
        Ifile = strcat(InstructionsFolderPath,'\',InstructionImages(i),".PNG");
        % read in image
        img = imread(Ifile);
        % get size of image
        [s1, s2, ~] = size(img);
        % convert image to a texture
        Instructions = Screen('MakeTexture', window, img);
        % resize image - set height to 50% screen height
        imgHeight = screenYpixels * 0.50;
        % calc aspect ratio
        ar = s2 / s1;
        % resize image width based on aspect ratio
        imgWidth = imgHeight .* ar;
        % make destination rect of resized img
        dstRect = CenterRectOnPoint([0 0 imgWidth imgHeight], xCenter, yCenter);
        % draw resized image texture to window
        Screen('DrawTexture', window, Instructions,[],dstRect);
        % draw text below image
        DrawFormattedText(window, AdvTxt, 'center', dstRect(4)+100, white);
        % flip to screen
        Screen('Flip', window);
        % wait for keypress to advance
        [~,keys] = KbStrokeWait();
        % check for esc key and end task
        if keys(escapeKey)
            Exit = 1;
            return;
        end
        % close texture
        Screen('Close', Instructions);
    end
    Exit = 0;
end