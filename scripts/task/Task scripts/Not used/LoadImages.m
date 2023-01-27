% LoadImages %
% v.2.14.2022

% function to load image files and store as textures in cell array

function ImageTextures = LoadImages(filenames, window)
    % INPUT - filenames: cell array of image file paths
    %       - window: window where image will be displayed
    % OUTPUT - ImageTextures: array of image texture indices, which
    % are ready to be drawn to screen for presentation
    
    ImageTextures = 1:length(filenames);
    % iterate through each filepath
    for f = 1:length(filenames)
        % read in image
        img = imread(filenames{f});
        % convert image to a texture
        imgTexture = Screen('MakeTexture', window, img);
        % add texture to cell array
        ImageTextures(f) = imgTexture;
    end
end