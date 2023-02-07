% Recognition Task Results

% function to analyze recognition response data and get results table

function Results = RecognitionTaskResults(subj)
    % INPUT - subject ID
    % OUTPUT - table with results for single subject

    % Correct responses:
    % Encoded images (stim or no stim) 1 = correct
    % Foil images 0 = correct

    % table format:
    %   columns: stim correct, no stim correct, false positves
    %   rows: valence/arousal conditions

    % load database
    load('C:\Users\ztlee\Documents\MATLAB\EMO\Data\Database\BehavioralDatabase.mat','BehavioralData');

    % filter database by subject ID

    sub_idx = strcmp(BehavioralData.SUBJ,subj);
    db = BehavioralData(sub_idx,:);

    % filter database for recognition task data
    task_idx = db.Recall ~= 999;
    db = db(task_idx,:);

    % sort images into conditions

    % encoding condition
    % 1 = encoded, 0 = foil
    EC = db.Encode;

    % stim condition
    % 1 = stimulated, 0 = not stimulated
    SC = db.Stim;
    
    % valence condition
    % 1 = positive, 0 = negative
    VC = db.Vcat;

    % arousal condition
    % 1 = high, 0 = low
    AC = db.Acat;

    % initialize arrays for stim, no stim, and false positive columns
    Stim = zeros(4,1);
    NoStim = zeros(4,1);
    FalsePositive = zeros(4,1);

    % Row 1 - negative valence / low arousal
    Stim(1,1) = sum(table2array(db(VC == 0 & AC == 0 & EC == 1 & SC == 1, 'Recall')));
    NoStim(1,1) = sum(table2array(db(VC == 0 & AC == 0 & EC == 1 & SC == 0, 'Recall')));
    FalsePositive(1,1) = sum(table2array(db(VC == 0 & AC == 0 & EC == 0, 'Recall')));

    % Row 2 - negative valence / high arousal
    Stim(2,1) = sum(table2array(db(VC == 0 & AC == 1 & EC == 1 & SC == 1, 'Recall')));
    NoStim(2,1) = sum(table2array(db(VC == 0 & AC == 1 & EC == 1 & SC == 0, 'Recall')));
    FalsePositive(2,1) = sum(table2array(db(VC == 0 & AC == 1 & EC == 0, 'Recall')));

    % Row 3 - positive valence / low arousal
    Stim(3,1) = sum(table2array(db(VC == 1 & AC == 0 & EC == 1 & SC == 1, 'Recall')));
    NoStim(3,1) = sum(table2array(db(VC == 1 & AC == 0 & EC == 1 & SC == 0, 'Recall')));
    FalsePositive(3,1) = sum(table2array(db(VC == 1 & AC == 0 & EC == 0, 'Recall')));

    % Row 4 - positive valence / high arousal
    Stim(4,1) = sum(table2array(db(VC == 1 & AC == 1 & EC == 1 & SC == 1, 'Recall')));
    NoStim(4,1) = sum(table2array(db(VC == 1 & AC == 1 & EC == 1 & SC == 0, 'Recall')));
    FalsePositive(4,1) = sum(table2array(db(VC == 1 & AC == 1 & EC == 0, 'Recall')));

    % results table
    Results = table(Stim, NoStim, FalsePositive,...
        'RowNames',["-V/-A","-V/+A","+V/-A","+V/+A"]);

end