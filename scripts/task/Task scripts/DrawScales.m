% DrawScales %
% v3.7.2022

function DrawScales(screenID, window, highlight)
    % INPUT - screenID: screen where window is open
    %       - window: where presentation occurs
    %       - highlight: indicates which scale should be highlighted for
    %       response; 1=Valence, 2=Arousal
    % OUTPUT - none
    
    %%%%%%%%%%%%%%
    %%% IMAGES %%%

    % rating scale image filenames
    ScaleFolderPath = 'C:\Users\ztlee\Documents\MATLAB\EMO\Rating Scales';
    VscaleFile = strcat(ScaleFolderPath,'\','ValenceScale.PNG');
    AscaleFile = strcat(ScaleFolderPath,'\','ArousalScale.PNG');

    % read in images
    VscaleImg = imread(VscaleFile);
    AscaleImg = imread(AscaleFile);

    % get size of images
    [Vs1, Vs2, ~] = size(VscaleImg);
    [As1, As2, ~] = size(AscaleImg);

    % calc aspect ratios
    Var = Vs2 / Vs1;
    Aar = As2 / As1;

    % convert images to textures
    VscaleTexture = Screen('MakeTexture', window, VscaleImg);
    AscaleTexture = Screen('MakeTexture', window, AscaleImg);

    % Get the size of the on screen window
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);

    % calculate center of screen
    xCenter = screenXpixels /2;
    yCenter = screenYpixels /2;

    % resize image heights to 1/4 screen height
    imgHeight = screenYpixels ./ 4;
    % resize image widths according to aspect ratio so as not to distort
    imgWidthV = imgHeight .* Var;
    imgWidthA = imgHeight .* Aar;
    
    % make base resized rect for images
    baseRectV = [0 0 imgWidthV imgHeight];
    baseRectA = [0 0 imgWidthA imgHeight];

    % make destination rects for each scale image
    dstRectV = CenterRectOnPoint(baseRectV, ... %rect
        xCenter, ...    % centered horizontally
        yCenter - screenYpixels /4);    % centered on top half vertically
    dstRectA = CenterRectOnPoint(baseRectA, ... %rect
        xCenter, ...    % centered horizontally
        yCenter + screenYpixels /4);    % centered on bottom half vertically

    % draw scales to window at location designated above
    Screen('DrawTexture', window, VscaleTexture, [], dstRectV);
    Screen('DrawTexture', window, AscaleTexture, [], dstRectA);

    % highlight selected scale for response with green box around scale
    
    % width of highlighter frame
    HLwid = 10;
    % color of highlighter frame - set to blue
    HLcolor = [0 0 1];

    % Valence scale selected - highlight and set text prompt
    if highlight == 1
       Screen('FrameRect', window, HLcolor, dstRectV, HLwid);
       txt_prompt = 'Enter a Valence Rating';
    % Arousal scale selected - highlight and set text prompt
    else
       Screen('FrameRect', window, HLcolor, dstRectA, HLwid);
       txt_prompt = 'Enter an Arousal Rating';
    end

    %%%%%%%%%%%%%
    %%% TEXT %%%

    % Setup the text font and size
    Screen('TextFont', window, 'Ariel');
    Screen('TextSize', window, 30);

    % set text color to white
    white = WhiteIndex(screenID);
    
    % add headers to the left of Valence and Arousal Scales, centered
    % vertically along each scale
    DrawFormattedText(window, 'VALENCE', dstRectV(1)-200, dstRectV(2)+imgHeight/2, white);
    DrawFormattedText(window, 'AROUSAL', dstRectA(1)-200, dstRectA(2)+imgHeight/2, white);

    % display rating prompt in center of screen
    DrawFormattedText(window, txt_prompt, 'center', 'center', white);

    % close textures
    Screen('Close', [VscaleTexture, AscaleTexture]);
end
    