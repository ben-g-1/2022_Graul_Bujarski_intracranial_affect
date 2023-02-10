% RandomizeImages2 %
% v3.14.2022 

% randomization function for recognition session of task
% takes randomization from encoding session and adds in foil images

function [RandImages, ImageKeys] = RandomizeImages2(SetNum, Fnum, Enum, Eimages, Ekeys)
    % INPUT - SetNum = number of images sets (i.e stimuli conditions)
    %       - Fnum = # foil images per set
    %       - Enum = # encoding images per set
    %       - Eimages = mat of image indices from first randomization
    %       - Ekeys = mat of key values from first randomization

    % OUTPUT - RandImages: columns = blocks, rows = images
    %       - ImageKeys: same dimensions as RandImageMat
    %              uses key number to indicate condition of each image in RandImageMat. 
    %              this will be used to decode segmented ECoG recording.
    %
    %                     ImageKey coding
    %                       no stim conditions = (Set #)
    %                       stim conditions = (Set #) + (total # sets) 
    %                       foil = (Set #) + 2*(total # sets)
    %                 
    %                       example: 4 sets.
    %                           condition 1 no stim = 1
    %                           condition 1 stim = 5
    %                           condition 1 foil = 9
    
    % calculate image totals
    Etot = Enum .* SetNum;  % total # encoding images
    Ftot = Fnum .* SetNum;  % total # foil images
    Itot = Etot + Ftot;     % total # image

    % reshape mats for randomized encoding images and keys into row arrays 
    images = reshape(Eimages,[1,Etot]);
    keys = reshape(Ekeys, [1,Etot]);
    % now images and keys are row arrays with the encoding images in the
    % randomized order that they were presented

    % next build onto the end of those two arrays to add image indices and
    % keys for the foil images. foil image indices start after the last
    % encoding image and follow sequentially

    % Image Array %

    % start at index after last encoding image
    i_start = Etot +1;
    % end at last index in entire image set
    i_end = Itot;

    % append to array
    images = [images i_start:i_end];

    % Key Array %

    % append zeros to key array as placeholders for foil image keys
    keys = [keys zeros(1,Ftot)];
    
    % update key values for foil images. each set has a unique key so
    % iterate through sets. key is calculated based on set number
    for set = 1:SetNum
        % get index for end of current set
        i_end = i_start + Fnum -1;
        % update keys for entire set
        keys(i_start:i_end) = set + SetNum.*2;
        % update start index for next set
        i_start = i_end +1;
    end
    
    % generate random order for all images
    rand_order = randperm(Itot);

    % use rand array to index and order images and keys
    RandImages = images(rand_order);
    ImageKeys = keys(rand_order);

end