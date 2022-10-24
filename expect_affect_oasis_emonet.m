%% Import
filepath = 'C:\Users\bgrau\Dropbox (Dartmouth College)\PBS\2022_Graul_Bujarski_intracranial_affect\Documents\oasis_picture_set\oasis_file_names.csv'
 oasis_path = 'C:\Users\bgrau\Matlab\data\oasis\Images'

oasis_set_names = readtable(filepath)
strcat(oasis_set_names)
%oasis_set_names_cat = strcat(oasis_set_names)
% if wrapper script used, look at vargin()
%%
% Figure out best way for looping in Matlab
%for image in oasis_set_names; do 
    % use strcat()

%% Load EmoNet
load(model_filepath);
% display the network layers
netTransfer.Layers

%% Set filepath based on iteration of index generated
%I=%Oasis_dir_filepath/image;
figure;imshow(I);

%% Preprocess image for classification
I = readAndPreprocessImage(I);

%% Classify image using EmoNet
probs = netTransfer.predict(I);
output_table=table(netTransfer.Layers(23).Classes, probs','VariableNames',{'EmotionCategory','Probability'})

%% Get activation in different layers of the network
conv5_activation = netTransfer.activations(I,'conv5');
fc8_activation = netTransfer.activations(I,'fc');

%% Write out result
% Figure out Matlab syntax
write_csv(output_table)

done

% Add line to knit all tables into one document? 
