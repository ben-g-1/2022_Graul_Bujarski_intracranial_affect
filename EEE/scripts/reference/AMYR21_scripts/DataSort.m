% Data sorting %
clear all
close all

% read image order from randomization output file

%%%%%%%%%%%%%%
% enter subject ID
SUBJ_ID = ['AMYR21PT05'];
%%%%%%%%%%%%%%%

%% Encoding Task
% read data to table
EncodingTable = ReadDataEncoding(SUBJ_ID);

%% Recogntion Task
% read data to table
RecognitionTable = ReadDataRecognition(SUBJ_ID);

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

