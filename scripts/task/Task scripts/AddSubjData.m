% AddSubjData

% function to add single subject data to database for AMY task

function AddSubjData(subj)

% INPUT - subj ID
% OUTPUT - none

    %% Encoding Task
    % read data to table
    EncodingTable = ReadDataEncoding(subj);
    
    %% Recogntion Task
    % read data to table
    RecognitionTable = ReadDataRecognition(subj);
    
    %% Join tables
    
    % join task data tables for single subject
    SubjectTable = [EncodingTable; RecognitionTable];
    
    % join subject data table to study database table
    
    % load study database
    database_fname = 'C:\Users\ztlee\Documents\MATLAB\EMO\Data\Database\BehavioralDatabase.mat';
    load(database_fname,"BehavioralData");
    % append subject data table to database
    BehavioralData = [BehavioralData; SubjectTable];
    
    % save database
    save(database_fname,"BehavioralData");

end

