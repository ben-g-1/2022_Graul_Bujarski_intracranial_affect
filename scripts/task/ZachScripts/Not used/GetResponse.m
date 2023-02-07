% GetResponse %
% v.2.15.2022 %

% function to get user keyboard input

function [rt, key] = GetResponse(ResponseScreen, window, ifi)
    % INPUT - ResponseScreen: texture presented  while getting response
    %       - window: where texture gets presented
    %       - Ifi: inter-flip-interval for screen sync
    % OUPUT - RT: response time
    %       - key: numerical value of key pressed
    %           scale response values = 1-7
    %           yes = 10 ; no = 0
    %           esc = 99
    
    % define key code labels
    escapeKey = KbName('ESCAPE');
    yesKey = KbName('0');
    noKey = KbName('.');
    scaleKeys = [KbName('1') KbName('2') KbName('3') KbName('4') ...
        KbName('5') KbName('6') KbName('7')];

    % draw response scales
    Screen('DrawTexture', window, ResponseScreen)
    % flip to screen and sync with refresh rate
    ft = Screen('Flip', window);
    tStart = ft;
    % check for key presses, loop until valid key is pressed
    check = true;

    while check == true
        % draw response scales
        Screen('DrawTexture', window, ResponseScreen);

        % check for keypress
        [~, ~, keyCode] = KbCheck;
        
        % return numeric value for key response
        % ESCAPE KEY - return 99
        if keyCode(escapeKey)
            key = 99;
            check = false;
        % YES KEY - return 10
        elseif keyCode(yesKey)
            key = 10;
            check = false;
        % NO KEY - return 0
        elseif keyCode(noKey)
            key = 0;
            check = false;
        % SCALE KEY - return value 1-7
        elseif sum(keyCode(scaleKeys)) > 0
            key = find(scaleKeys == find(keyCode,1));
            check = false;
        end

        % flip to screen
        ft = Screen('Flip', window, ft + 0.5 * ifi);
    end
    % calculate reaction time
    rt = ft - tStart;
end