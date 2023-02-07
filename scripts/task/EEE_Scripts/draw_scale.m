ScaleFolderPath = 'C:\Users\bgrau\GitHub\canlab-Paradigms_Public\inprep_Lanlan_Social_influence\Stimuli';
    VscaleFile = strcat(ScaleFolderPath,'\','grayratingscale.bmp');
    AscaleFile = strcat(ScaleFolderPath,'\','socialhigh.bmp');

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