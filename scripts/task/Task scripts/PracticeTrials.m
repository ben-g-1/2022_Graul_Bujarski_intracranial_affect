% PracticeTrials %
% v3.7.2022 %

% function to run practice trial presentation

function Response = PracticeTrials(screenID, window, ifi)
    % INPUT - screenID: screen where window is open
    %       - window: where presentation occurs
    %       - ifi: inter flip interval for screen
    % OUTPUT - none
    
    %%% image set up %%%

    % practice image folder
    PracticeFolderPath = 'C:\Users\ztlee\Documents\MATLAB\EMO\Practice Images';
    % practice image file names
    PracticeImages = ["Horse racing 1.JPG" , "Motocross 1.JPG"];

    % presentation times in secs
    PImgTime = 3;
    FixTime = 1;

    %%%%%%%%%%%%%%%%%%%
    
    %%%  text set up %%%
    PracticeTxt = 'This is a PRACTICE trial';
    
    % text font
    Screen('TextFont', window, 'Ariel');
    % text color - set to white
    white = WhiteIndex(screenID);

    %%%%%%%%%%%%%%%%%%%%

    for p=1:length(PracticeImages)
        % display practice text alert
        Screen('TextSize', window, 72); % increase text size
        DrawFormattedText(window, PracticeTxt, 'center', 'center', white);
        Screen('Flip', window);
        WaitSecs(1);
        % fixation
        DrawFixation(screenID, window, FixTime, ifi);
        % image
        PImgfile = strcat(PracticeFolderPath,"\",PracticeImages(p));
        PresentImage(PImgfile, window, PImgTime, ifi);
        % response
        Response = RatingResponse(screenID, window, ifi);
        % check for escape key and end task
        if Response == 99
            return;
        end
    end
    
    % display message for end of practice
    Screen('TextSize', window, 72); % increase text size
    DrawFormattedText(window, 'Practice Finished. Press Any Key to Begin',...
        'center', 'center', white);
    Screen('Flip', window);
    KbStrokeWait();

end