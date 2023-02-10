% Present Texture %
% v.2.9.2022

function OnScreen = PresentTexture(ImgTxt,window)
    % INPUT - ImgTxt: an image texture object
    %       - window: where image will be presented
    % OUTPUT - ImageOn: time stamp for image onset
    
    % Draw the image to the screen
    Screen('DrawTexture', window, ImgTxt, [], [], 0);
    
    % Flip to the screen
    OnScreen = Screen('Flip', window);
    
end