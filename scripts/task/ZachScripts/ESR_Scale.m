% function for presenting Emotional Self-Rating Scale

function ESR_Scale(subj, stim, amp, channels, time)
    % INPUT - stim: 0=before stim, 1=during stim
    %       
    % OUTPUT - ResponseMat: 2x6 array
    %   row 1 = response times
    %   row 2 = response values
    
    %% set up rating scale and text display

    %%%% PTB screen presentation setup %%%%

    % clear any existing psychtoolbox screens
    clear Screen
    
    % default settings for setting up Psychtoolbox
    PsychDefaultSetup(2);
    
    % Get screen numbers
    % screens = Screen('Screens');
    
    % set to display to external monitor (2)
    % need to change to 1 for laptop screen display
    screenPresent = 2;
    
    % Define colors: black, white
    white = WhiteIndex(screenPresent);
    black = BlackIndex(screenPresent);
    
    % Open an on screen window
    [window, ~] = PsychImaging('OpenWindow', screenPresent, black);

    % get monitor refresh rate
    ifi = Screen('GetFlipInterval', window);

    % rating scale image filename
    ScaleFile = 'C:\Users\ztlee\Documents\MATLAB\EMO\Rating Scales\ESRScale.JPG';

    % read in image
    ScaleImg = imread(ScaleFile);

    % get size of image and aspect ratio
    [s1, s2, ~] = size(ScaleImg);
    AR = s2 / s1;   % aspect ratio

    % convert image to texture
    ScaleTexture = Screen('MakeTexture', window, ScaleImg);

    % Get the size of the on screen window
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);

    % calculate center of screen
    xCenter = screenXpixels /2;
    yCenter = screenYpixels /2;

    % resize image heights to 1/4 screen height
    imgHeight = screenYpixels ./ 8;
    % resize image width according to aspect ratio so as not to distort
    imgWidth = imgHeight .* AR;
    
    % make base resized rect for image
    baseRect = [0 0 imgWidth imgHeight];

    % make destination rect for scale image
    dstRect = CenterRectOnPoint(baseRect, ... %rect
        xCenter, ...    % centered horizontally
        yCenter + screenYpixels /4);    % centered on bottom half vertically

    % Setup the text font and size
    Screen('TextFont', window, 'Ariel');
    Screen('TextSize', window, 48);

    % emotions list
    scale_text = {'Anger','Disgust','Fear','Happiness','Sadness','Surprise'};

    %% set up scale response input

    % store response keys and response times in arrays
    rt = zeros(1,6);
    response_keys = zeros(1,6);

    % define key code labels
    escapeKey = KbName('ESCAPE');
    scaleKeys = [KbName('1') KbName('2') KbName('3') KbName('4') ...
        KbName('5')];

    % response output file
    % _0 = before stim ratings
    % _1 = during stim ratings

    subj_folder_path = strcat('C:\Users\ztlee\Documents\MATLAB\EMO\Data\',subj);
    DATA_FILE = strcat(subj_folder_path,'\ESR_',num2str(stim));
    
    % check if subject folder exists and if not create one
    if not(isfolder(subj_folder_path))
        mkdir(subj_folder_path)
    end

    %% start rating scale presentation

    % display start screen
    intro_txt = 'Press Any Key to Start';
    DrawFormattedText(window, intro_txt, 'center', 'center', white);
    Screen('Flip', window)
    [~,keys] = KbStrokeWait();

    % check for esc key and end task, otherwise continue
    if keys(escapeKey)
        return;
    end
    
    % check stim setting

    %% BEFORE stim %%
    if stim ==0
        % loop through each item in ESR scale
        for i=1:length(scale_text)
    
            word = scale_text{i};   % scale item
            % draw scales and word to screen
            Screen('DrawTexture', window, ScaleTexture, [], dstRect);
            DrawFormattedText(window, word, 'center', 'center', white);
            
            % flip to screen and sync with refresh rate
            ft = Screen('Flip', window);
            tStart = ft;
    
            % wait for user response
            response = 0;
            while response==0
    
               % draw scales and word to screen
                Screen('DrawTexture', window, ScaleTexture, [], dstRect);
                DrawFormattedText(window, word, 'center', 'center', white);
        
                % flip to screen
                ft = Screen('Flip', window, ft + 0.5 * ifi);
        
                % check for keypress
                [~, ~, keyCode] = KbCheck;
                
                % ESCAPE KEY - return
                if keyCode(escapeKey)
                    return;
        
                % SCALE RESPONE KEY
                elseif sum(keyCode(scaleKeys)) > 0
                    % store key response
                    response_keys(i) = find(scaleKeys == find(keyCode,1));
                    % store response time
                    rt(i) = ft - tStart;
                    % end loop
                    response=1;
                end
        
                % wait for release of all keys
                KbReleaseWait();
    
            end
            
            % flip to blank screen and wait 3 seconds before next rating
            Screen('Flip',window);
            WaitSecs(3);
    
        end
    %% DURING stim %%
    else
        % set up stimulator
        [cerestim, waveform] = SetupCerestim(amp);

        % loop through each item in ESR scale
        for i=1:length(scale_text)
    
            word = scale_text{i};   % scale item
            % draw scales and word to screen
            Screen('DrawTexture', window, ScaleTexture, [], dstRect);
            DrawFormattedText(window, word, 'center', 'center', white);

            % trigger stim
            TriggerStim(cerestim, waveform, channels);
            
            % flip to screen and sync with refresh rate
            ft = Screen('Flip', window);
            tStart = ft;
    
            % wait for user response
            response = 0;
            while response==0
    
               % draw scales and word to screen
                Screen('DrawTexture', window, ScaleTexture, [], dstRect);
                DrawFormattedText(window, word, 'center', 'center', white);
        
                % flip to screen
                ft = Screen('Flip', window, ft + 0.5 * ifi);
    
                % stop stim after set time even if no response
                if ((ft - tStart) > time) && (stim==1)
                    cerestim.stop()
                end
        
                % check for keypress
                [~, ~, keyCode] = KbCheck;
                
                % ESCAPE KEY - stop stim and return
                if keyCode(escapeKey)
                    cerestim.stop()
                    return;
        
                % SCALE RESPONE KEY
                elseif sum(keyCode(scaleKeys)) > 0
                    % stop stim
                    cerestim.stop()
                    % store key response
                    response_keys(i) = find(scaleKeys == find(keyCode,1));
                    % store response time
                    rt(i) = ft - tStart;
                    % end loop
                    response = 1;
                end
        
                % wait for release of all keys
                KbReleaseWait();
    
            end
            
            % flip to blank screen and wait 3 seconds before next rating
            Screen('Flip',window);
            WaitSecs(3);
    
        end
        % disconnect stimulator
        cerestim.disconnect;
        clear cerestim
    end
    
    % close screens
    Screen('CloseAll')
    % save respone matrix to file
    ResponseMat = [rt;response_keys];
    save(DATA_FILE,"ResponseMat");
    % end task
    disp("ESR Scale Completed")

    
