%% Import
filenames = 'C:\Users\bgrau\Matlab\projects\ieeg_affect\oasis\oasisFilterFileNames.csv';
 oasis_pics = 'C:\Users\bgrau\Matlab\data\oasis\oasis_filter_11.1.22';

oasis_set_names = readtable(filenames);
oasis_set_names = table2array(oasis_set_names);
oasis_set_names = append(oasis_set_names,'.jpg');

%%
test_set = head(oasis_set_names)
%strcat(oasis_set_names)
%oasis_set_names_cat = strcat(oasis_set_names)
% if wrapper script used, look at vargin()
%%
% Figure out best way for looping in Matlab
%for image in oasis_set_names; do 
    % use strcat()

%% Get the EmoNet model
model_filepath=which('netTransfer_20cat.mat');
if isempty(model_filepath)
    fprintf('Please download EmoNet from https://sites.google.com/colorado.edu/emonet \n');
end

%% Load EmoNet
load(model_filepath)

%% Iterate through 
% Set filepath based on iteration of index generated
for i = 1:length(test_set)

    I = imread(test_set{:,i})

    I = readAndPreprocessImage(I);

    probs = netTransfer.predict(I);
    output_table = table(netTransfer.Layers(23).Classes, probs','VariableNames',{'EmotionCategory','Probability'}); %#ok
    
    probs_all(i, :) = double(probs);
    
    [~, wh] = max(probs);
    Category{i} = output_table.EmotionCategory(wh);
    CategoryNum(i) = wh;
    MaxProb(i) = probs(wh);
    
    fc8_activation = netTransfer.activations(I,'fc');
    fc8_activation = squeeze(double(fc8_activation));
    
    fc8_all(i, :) = fc8_activation';
    write_csv([ I, output_table])
end 
%%
I = 'C:\Users\bgrau\Matlab\projects\ieeg_affect\oasis\oasis_filter_11.1.22\Acorns1.jpg';
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
