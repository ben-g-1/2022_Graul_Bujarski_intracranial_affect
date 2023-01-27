% ReadImageNames %
% v.2.14.2022

% function to read image file names from desktop folder

function [ImageNames, Order] = ReadImageNames(FolderPath, subfolders)
    % INPUT - FolderPath: string, file path to image folder
    %       - subfolder: cell array with subfolder names
    %   NOTE: subfolder names must be the same within each folder
    % OUPUT - ImageNames: cell array of filename for each image, including
    % folder path, listed sequentially by sets.
    % provides file path to each image
    %       - Order: lists folder names in order they were read,
    %       corresponds to order of image sets within ImageNames
    
    % cell arrays to store file paths for each subset of images
    EncodingNames = {};
    FoilNames = {};

    % store order in which 4 image sets are listed
    Order ={};
    
    % get list of folders corresponding to image sets
    FolderDir = dir(FolderPath);    % read folders within Image folder
    FolderNames = {FolderDir.name}; % store folder names as cell array
    
    % remove empty folder names
    FolderNames = FolderNames(~ismember(FolderNames, {'.','..'}));
    
    % iterate through folders
    for f = 1:length(FolderNames)
        % add folder to order array
        Order = [Order FolderNames{f}];
        % then iterate through subfolders
        for s = 1:length(subfolders)
            % get name of folder to be read
            folderRead = strjoin({FolderPath '\' FolderNames{f} '\' subfolders{s}},'');
            % get image file names within folder
            fileNames = dir(folderRead);
            fileNames = {fileNames.name};
            % remove empty file names
            fileNames = fileNames(~ismember(fileNames,{'.','..'}));
            % add folder path to file names
            fileNames = strcat(folderRead,'\',fileNames);
            % check if current subfolder is for Encoding or Foil images and
            % append file names to corresponding array
            if s==1     % ENCODING
                EncodingNames = [EncodingNames fileNames];
            else        % FOILS 
                FoilNames = [FoilNames fileNames];
            end
        end
    end

    % join encoding and foil names into single array
    ImageNames = [EncodingNames FoilNames];
end