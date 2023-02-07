% ReadDataRecognition % 
% v.7.18.22 %

% function to read the saved data from the recognition task and parse with
% image names

function R_DATA = ReadDataRecognition(SUBJ_ID)
    % input: SUBJ = subject ID
    % output: R_DATA = table with images as rows, and descriptive and
    % response data as columns
    
    % create empty table
    R_DATA = table;

    row_n = 192; % total number of images in recognition task

    %% load saved data file

    % Recognition task file
    Fname_R = strcat('C:\users\ztlee\Documents\MATLAB\EMO\Data\',SUBJ_ID,'\Response_R.mat');
    load(Fname_R);
    % reshape data matrix to array
    Order = reshape(RandImages2,[row_n,1]);
    Keys = reshape(ImageKeys2, [row_n,1]);
    
    %% Subject ID
    R_DATA.SUBJ(1:row_n) = {SUBJ_ID};

    %% Image Names

    % strip file path from image names
    f_path = wildcardPattern + "\";
    ImageFiles = erase(ImageFiles,f_path);

    % reshape image names to column array
    ImageNames = reshape(ImageFiles,[row_n,1]);

    %%% input OASIS standard ratings here %%%
    
    % put image names in order of presentation
    ImageNames = ImageNames(Order);

    % add image names to table
    R_DATA.Name = ImageNames;
    
    %%% parse image keys %%%

    %% Encoded category
    % 1 = yes; 0 = no
    % key codes = 1-8
    R_DATA.Encode = Keys<9;
   
    %% Stimulated category
    % 1 = yes; 0 = no
    % key codes for stimulated images = 5-8
    stim_keys = [5 6 7 8];
    R_DATA.Stim = ismember(Keys,stim_keys);

    %% Valence category
    % 1 = positive; 0=negative

    % get key codes for positive valence
    pv_keys = find(contains(ImageSetOrder,'Positive'));
    pv_keys = [pv_keys, pv_keys+4, pv_keys+8];
    R_DATA.Vcat = ismember(Keys,pv_keys);

    %% Arousal category
    % 1 = high, 0 = low

    % get key codes for high arousal
    ha_keys = find(contains(ImageSetOrder,'High'));
    ha_keys = [ha_keys, ha_keys+4, ha_keys+8];
    R_DATA.Acat = ismember(Keys,ha_keys);

    %% Valence rating
    % no rating, set blank value
    R_DATA.Vrate(1:row_n) = 999;

    %% Arousal rating
    % no rating, set blank value
    R_DATA.Arate(1:row_n) = 999;

    %% Valence response/reaction time
    % no data
    R_DATA.Vrt(1:row_n) = 999;

    %% Arousal response/reaction time
    % no data
    R_DATA.Art(1:row_n) = 999;

    %% Recognition response
    % row 2 response data
    R_DATA.Recall = reshape(ResponseData(2,:),[row_n,1]);

    %% Recognition response/reaction time
    % row 1 response data
    R_DATA.Rrt = reshape(ResponseData(1,:),[row_n,1]);

    %% OASIS Standard Valence and Arousal Rating
    % no data
    R_DATA.VrateOASIS(1:row_n) = 999;
    R_DATA.ArateOASIS(1:row_n) = 999;
end