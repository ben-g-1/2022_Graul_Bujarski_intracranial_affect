% Present Texture %
% v.2.9.2022

% function for presenting image and fixation textures

function OnScreen = PresentTexture(Txt,window)
    % INPUT - Txt: texture index
    %       - window: where texture will be presented
    % OUTPUT - OnScreen: time stamp for image onset
    
    % Draw texture to the screen
    Screen('DrawTexture', window, Txt, [], [], 0);
    
    % Flip to the screen
    OnScreen = Screen('Flip', window);
    
end