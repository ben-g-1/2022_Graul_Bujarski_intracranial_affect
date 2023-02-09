%%% Image set up %%%

SUBJ_ID = 'TEST_SUB'
% path to master folder of stimulus images
ImageFolderPath = 'C:\Users\bgrau\GitHub\git_ieeg_affect\oasis\HIE_Amendment';

% subset of images within each condition - Encoding target set
SubfolderNames = {'Cues'};

% get cell array of image names, including full file path
[ImageFiles, ~] = ReadImageNames(ImageFolderPath, SubfolderNames);

% set image presentation time
ImgTime = 3;    % time in seconds

% set fixation cross presentation time
FixTime = 1;    % time in seconds

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Randomization of Image order %%%

% INPUT image stimuli
%   number of conditions and images per condition
GROUPS = 4;
GROUP_SIZE = 16;

% OUTPUT image stimuli
%   number of blocks and trials per block
BLOCKS = 8;
TRIALS = 8;

% generate mat with random order of images
%   columns = blocks
%   rows = position within block (1-4 not stimulated, 5-8 stimulated)
%   values = index to image within ImageFiles cell array

[RandImages, ImageKeys] = RandomizeImages(GROUPS, ... % # conditions
    GROUP_SIZE, ... % # of images per condition
    BLOCKS, ...  % # of blocks to be presented in task
    TRIALS);  % # of images per block   

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% DATA RECORDING %%%%%%

TimingData = zeros(2, BLOCKS.*TRIALS);
%   row 1 = marker/stim onset time
%   row 2 = image onset time

ResponseData = zeros(4, BLOCKS.*TRIALS);
%   row 1 = response time - valence rating
%   row 2 = response time - arousal rating
%   row 3 = response key - valence rating
%   row 4 = response key - arousal rating

% data output file
subj_folder_path = strcat('C:\Users\bgrau\Desktop\TEST',SUBJ_ID);
DATA_FILE = strcat(subj_folder_path,'\Response_E.mat');

% check if subject folder exists and if not create one
if not(isfolder(subj_folder_path))
    mkdir(subj_folder_path)
end

% save image randomization order and keys
save(DATA_FILE,"RandImages","ImageKeys")