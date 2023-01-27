% DrawScales %
% v2.16.2022

function ScaleTexture = DrawScales(backgrd, window)
    % INPUT - clr: color of lines
    %       - backgrd: color of background window
    %       - window: where fixation will be presented
    % OUTPUT - ScaleTexture: a texture with scales for image ratings
    
    % make texture the size of the window
    [sX, sY] = Screen('WindowSize', window);
    ScaleTexture = Screen('makeTexture', window, ones(sX,sY)*backgrd);
    
    % rating scale filenames
    ScaleFolderPath = 'C:\Users\ztlee\Documents\MATLAB\EMO\Rating Scales';
    VscaleFile = strcat(ScaleFolderPath,'\','ValenceScale.PNG');
    AscaleFile = strcat(ScaleFolderPath,'\','ArousalScale.PNG');
%    
%     % create texture for scales
%     [Vscale, Vsize] = DrawImage(VscaleFile, window);
%     [Ascale, Asize] = DrawImage(AscaleFile, window);

%     % get size of scale images
%     [Vs1, Vs2] = size(Vscale)
%     [As1, As2] = size(Ascale)

    % read in images
    VscaleImg = imread(VscaleFile);
    AscaleImg = imread(AscaleFile);

    % get size of images
    [Vs1, Vs2, Vs3] = size(VscaleImg);
    [As1, As2, As3] = size(AscaleImg);

    % calc aspect ratios
    Var = Vs2 / Vs1;
    Aar = As2 / As1;

    % convert images to textures
    VscaleTexture = Screen('MakeTexture', window, VscaleImg);
    AscaleTexture = Screen('MakeTexture', window, AscaleImg);

    % Get the size of the on screen window
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);

    % resize image heights to 1/3 screen height
    imgHeight = screenYpixels ./ 3;
    % resize image widths according to aspect ratio so as not to distort
    imgWidthV = imgHeight .* Var;
    imgWidthA = imgHeight .* Aar;
    
    % make base resized rect for images
    baseRectV = [0 0 imgWidthV imgHeight]
    baseRectA = [0 0 imgWidthA imgHeight]

    % make destination rects for each scale image
    dstRectV = CenterRectOnPoint(baseRectV, ... %rect
        screenXpixels /2, ...    % centered horizontally
        screenYpixels /3);    % centered on top 3rd vertically
    dstRectA = CenterRectOnPoint(baseRectA, ... %rect
        screenXpixels /2, ...    % centered horizontally
        - screenYpixels /3);    % centered on bottom 3rd vertically

    [x1, y1] = RectCenter(dstRectV)
    [x2, y2] = RectCenter(dstRectA)
    R1 = dstRectV
    R2 = dstRectA
%     S1 = Vsize
%     S2 = Asize

    % draw scale images into single window
    Screen('DrawTexture', ScaleTexture, VscaleTexture, [], dstRectV);
    Screen('DrawTexture', ScaleTexture, AscaleTexture, [], dstRectA);
    
end
    