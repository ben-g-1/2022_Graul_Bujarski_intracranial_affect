% Randomize Images Function %
% v.2.3.2022

function [RandImages, ImageKeys] = RandomizeImages(SetNum, Img_in_set, BlockNum, Img_in_block)
    % INPUT - SetNum = number of images sets (i.e stimuli conditions)
    %       - Img_in_set = number of images per set
    %       - BlockNum = number of blocks images randomized to
    %       - Img_in_block = number of images per block

    % OUTPUT - RandImages: columns = blocks, rows = images
    %       - ImageKeys: same dimensions as RandImageMat
    %              uses key number to indicate condition of each image in RandImageMat. 
    %              this will be used to decode segmented ECoG recording.
    %
    %                     ImageKey coding
    %                       no stim conditions = (Set #)
    %                       stim conditions = (Set #) + (total # sets)                    
    %                 
    %                       example: 4 sets.
    %                           condition 1 no stim = 1
    %                           condition 1 stim = 5
 

    % initialize zeros mat for rand images and image keys
    RandImages = zeros(Img_in_block, BlockNum);
    ImageKeys = RandImages;

    % iterate through sets
    for set=1:SetNum
        % randomize order of images within each set
        %   this randomizes assignment of images to blocks
        RandImgSet = randperm(Img_in_set) + ((set-1)*Img_in_set);
        % iterate through image set assigning two images to each block
        %   first image randomly assigned within rows 1-4, 2nd in rows 5-8
        first = true;   % track which half next image assigned to
        block = 1; % track current block #
        for i=1:Img_in_set
            % get image #
            Img = RandImgSet(i);
            % generate random position in first half of block
            if first
                rand_I = randi([1,Img_in_block/2]);
            % generate random position in second half of block
            else
                rand_I = randi([Img_in_block/2+1,Img_in_block]);
            end
            % check if position is empty in output matrix
            % if not regenerate random numbers
            while RandImages(rand_I, block) ~= 0
                % generate random position in first half of block
                if first
                    rand_I = randi([1,Img_in_block/2]);
                % generate random position in second half of block
                else
                    rand_I = randi([Img_in_block/2+1,Img_in_block]);
                end
            end
            % assign image # to available position
            RandImages(rand_I, block) = Img;

            % update ImageKey array, trackers for block # and block half
            % first half of block not stimulated
            if first
                ImageKeys(rand_I, block) = set;
                first = false;
            % second half of block stimulated
            else
                ImageKeys(rand_I, block) = set+SetNum;
                first = true;
                block = block +1;
            end
        end
    end

end
   