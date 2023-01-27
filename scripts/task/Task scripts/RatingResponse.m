% RatingResponse %
% v3.7.2022 %

% function to get user response for valence and arousal ratings scales

function ResponseMat = RatingResponse(screenID, window, ifi)
    % INPUT - screenID: screen where window is open
    %       - window: where presentation occurs
    %       - Ifi: inter-flip-interval for screen sync
    % first two inputs get passed to DrawScales function
    % OUPUT - ResponseMat: 4x1 mat of response data
            %   row 1 = response time - valence rating
            %   row 2 = response time - arousal rating
            %   row 3 = response key - valence rating
            %   row 4 = response key - arousal rating
            % 99 = esc value
    
    % store response keys and response times in 2x1 arrays
    % [Valence ; Arousal]
    rt = [0; 0];
    keys = [0; 0];

    % define key code labels
    escapeKey = KbName('ESCAPE');
    scaleKeys = [KbName('1') KbName('2') KbName('3') KbName('4') ...
        KbName('5') KbName('6') KbName('7')];
    
    % track which scale response is for
    %   1 = valence
    %   2 = arousal
    % start with valence scale
    scaleID = 1;    

    % draw response scales
    DrawScales(screenID, window, scaleID);

    % flip to screen and sync with refresh rate
    ft = Screen('Flip', window);
    tStart = ft;

    % loop until 2 responses have been given (i.e scaleID =3)
    while scaleID < 3
        % draw response scales
        DrawScales(screenID, window, scaleID);

        % flip to screen
        ft = Screen('Flip', window, ft + 0.5 * ifi);

        % check for keypress
        [~, ~, keyCode] = KbCheck;
        
        % return numeric value for key response
        % ESCAPE KEY - return
        if keyCode(escapeKey)
            ResponseMat = 99;
            return;

        % SCALE RESPONE KEY - return value 1-7
        elseif sum(keyCode(scaleKeys)) > 0
            % store key response
            keys(scaleID) = find(scaleKeys == find(keyCode,1));
            % store response time
            rt(scaleID) = ft - tStart;
            % move to next scale
            scaleID = scaleID +1;
        end

        % wait for release of all keys
        KbReleaseWait();

    end
    ResponseMat = [rt;keys];
end