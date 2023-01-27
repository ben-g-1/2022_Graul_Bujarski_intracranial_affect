% DrawImage %
% v.3.3.2022

% function to load image file and store as texture

function [ImageTexture, sz] = DrawImage(filename, window)
    % INPUT - filename: image file path
    %       - window: window where image will be displayed
    % OUTPUT - ImageTexture: image texture index
    %       - sz: [x y] pixel size of image
  
    % read in image
    img = imread(filename);
    % convert image to a texture
    ImageTexture = Screen('MakeTexture', window, img);
    % get size of image
    [s1, s2, s3] = size(img);
    sz = [s2 s1];
end