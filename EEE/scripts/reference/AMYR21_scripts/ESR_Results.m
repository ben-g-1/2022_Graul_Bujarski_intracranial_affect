% ESR_Results

% function to get results of ESR rating scale before and during stim;
% combines results into single table which can be displayed in GUI

function ResultTable = ESR_Results(subj)
    % INPUT - subj: subject ID

    % OUTPUT - table with rows for each item in scale and columns for
    % before and during stim; 3rd column is categorical variable for effect
    % of stim ("yes" or "no") based on comparison of ratings

    % read in response matrices for ESR scale ratings before and during
    % stim
    
    % response files for input
        % _0 = before stim ratings
        % _1 = during stim ratings
    ResponseBeforeFile = strcat('C:\Users\ztlee\Documents\MATLAB\EMO\Data\',subj,'\ESR_0.mat');
    ResponseDuringFile = strcat('C:\Users\ztlee\Documents\MATLAB\EMO\Data\',subj,'\ESR_1.mat');

    % load mat variables from files and get ratings values (row 2)
    ResponseBefore = load(ResponseBeforeFile,"ResponseMat");
    ResponseBefore = ResponseBefore.ResponseMat(2,:);
    ResponseDuring = load(ResponseDuringFile,"ResponseMat");
    ResponseDuring = ResponseDuring.ResponseMat(2,:);
    
    % compare ratings before and during
    stim_effect = cell(6,1);

    for i=1:length(ResponseBefore)
        if ResponseBefore(i) == ResponseDuring(i)
            stim_effect{i,1} = 'no';
        else
            stim_effect{i,1} = 'yes';
        end
    end
    % reshape response arrays from row array to column array
    ResponseBefore = reshape(ResponseBefore,[6,1]);
    ResponseDuring = reshape(ResponseDuring,[6,1]);

    % row names
    scale_text = {'Anger';'Disgust';'Fear';'Happiness';'Sadness';'Surprise'};

    % create table with 3 columns of data and row and column names
    ResultTable = table(ResponseBefore, ResponseDuring, categorical(stim_effect), ...
        'VariableNames',["Before","During","Effect"], ...
        'RowNames',scale_text);

    % save result table to mat file
    ResultFName = strcat('C:\Users\ztlee\Documents\MATLAB\EMO\Data\',subj,'\ESR_ResultsTable.mat');
    save(ResultFName,"ResultTable");
    
end