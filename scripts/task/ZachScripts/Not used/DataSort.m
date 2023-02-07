% Data sorting %

% read image order from randomization output file

%%%%%%%%%%%%%%
% enter subject ID
SUBJ_ID = 'AMYR21PT04';
%%%%%%%%%%%%%%%

%% load saved data files

% Encoding task file
Fname_E = strcat('RAND\',SUBJ_ID,'keys.mat');
load(Fname_E);
% reshape data matrix to array
Order_E = reshape(RandImages,[1,64]);
Keys_E = reshape(ImageKeys, [1,64]);

% Recognition task file
Fname_R = strcat('C:\users\ztlee\Documents\MATLAB\EMO\Data\Recognition_',SUBJ_ID,'.mat');
load(Fname_R);
Order_R = RandImages2;
Keys_R = ImageKeys2;

%% Image Names
% path to master folder of stimulus images
ImageFolderPath = 'C:\Users\ztlee\Documents\MATLAB\EMO\Image Stimuli';

% subset of images within each condition - Encoding target set
SubfolderNames = {'Encoding','Recognition'};

% get cell array of image names, including full file path
[ImageFiles, ImageSetOrder] = ReadImageNames(ImageFolderPath, SubfolderNames);

% get image names
ImageNames_E = ImageFiles(Order_E);
ImageNames_R = ImageFiles(Order_R);

% strip file path
f_path = wildcardPattern + "\";
ImageNames_E = erase(ImageNames_E,f_path);
ImageNames_R = erase(ImageNames_R, f_path);

% save file with image names in order
save(strcat('C:\Users\ztlee\Documents\MATLAB\EMO\Data\SORT\',SUBJ_ID,'_ImageOrders.mat'),"ImageNames_E","ImageNames_R");

