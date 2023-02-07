% ReadDataEncoding % 
% v.7.18.22 %

% function to read the saved data from the encoding task and parse with
% image names

function E_DATA = ReadDataEncoding(SUBJ_ID)
    % input: SUBJ = subject ID
    % output: E_DATA = table with images as rows, and descriptive and
    % response data as columns
    
    % create empty table
    E_DATA = table;

    row_n = 64; % total number of images in encoding task

    %% load saved data files

    % encoding task file
    Fname = strcat('C:\Users\ztlee\Documents\MATLAB\EMO\Data\',...
        SUBJ_ID,'\Response_E.mat');
    load(Fname,"ImageKeys","RandImages","ResponseData");

    % Standard OASIS ratings
    load("StandardRatings.mat","OASISratings");
    
     % reshape data matrix to array
    Order = reshape(RandImages,[row_n,1]);
    Keys = reshape(ImageKeys, [row_n,1]);

    %% Subject ID
    E_DATA.SUBJ(1:row_n) = {SUBJ_ID};

    %% Image Names
    % path to master folder of stimulus images
    ImageFolderPath = 'C:\Users\ztlee\Documents\MATLAB\EMO\Image Stimuli';
    
    % read only encoding image file names
    Subfolder ={'Encoding'};
    
    % get cell arrays of image names and category names
    [ImageFiles, ImageSetOrder] = ReadImageNames(ImageFolderPath, Subfolder);

    % strip file path and extension from image names
    f_path = wildcardPattern + "\";
    ImageFiles = erase(ImageFiles,f_path);
    f_ext = ".jpg";
    ImageFiles = erase(ImageFiles, f_ext);

    % reshape image names to column array
    ImageNames = reshape(ImageFiles,[row_n,1]);
    
    % put image names in order of presentation
    ImageNames = ImageNames(Order);

    % add image names to table
    E_DATA.Name = ImageNames;

    %% Encoded category
    % 1 = yes; 0 = no
    % all images get value of 1 for encoded category
    E_DATA.Encode(1:row_n) = 1;
   
    %% Stimulated category
    % 1 = yes; 0 = no
    % key codes for stimulated images = 5-8
    E_DATA.Stim = Keys>4;

    %% Valence category
    % 1 = positive; 0=negative

    % get key codes for positive valence
    pv_keys = find(contains(ImageSetOrder,'Positive'));
    pv_keys = [pv_keys, pv_keys+4];
    E_DATA.Vcat = ismember(Keys,pv_keys);

    %% Arousal category
    % 1 = high, 0 = low

    % get key codes for high arousal
    ha_keys = find(contains(ImageSetOrder,'High'));
    ha_keys = [ha_keys, ha_keys+4];
    E_DATA.Acat = ismember(Keys,ha_keys);

    %% Valence rating
    % row 3 in response data matrix
    E_DATA.Vrate = reshape(ResponseData(3,:),[row_n,1]);

    %% Arousal rating
    % row 4 in response data matrix
    E_DATA.Arate = reshape(ResponseData(4,:),[row_n,1]);

    %% Valence response/reaction time
    % row 1 in response data matrix
    E_DATA.Vrt = reshape(ResponseData(1,:),[row_n,1]);

    %% Arousal response/reaction time
    % row 2 in response data matrix
    E_DATA.Art = reshape(ResponseData(2,:),[row_n,1]);

    %% Recognition response
    % no data
    E_DATA.Recall(1:row_n) = 999;

    %% Recognition response/reaction time
    % no data
    E_DATA.Rrt(1:row_n) = 999;

    %% OASIS Standard Valence and Arousal Rating
    % search by image name through standard rating table
    E_DATA.VrateOASIS = zeros(length(ImageNames),1);
    E_DATA.ArateOASIS = zeros(length(ImageNames),1);
    for i = 1:length(ImageNames)
        % get image name
        img = ImageNames{i};
        % find image in OASIS ratings table
        O_idx = find(strcmp(img,OASISratings.ImageName));
        % get standard valence and arousal ratings
        E_DATA.VrateOASIS(i)= OASISratings.ValenceRating(O_idx);
        E_DATA.ArateOASIS(i) = OASISratings.ArousalRating(O_idx);
    end
end