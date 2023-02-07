% Encoding Task Ratings Results

% function to analyze ratings results for encoding task

function ResultsTable = EncodingTaskResults(subj)

% INPUT - subject ID
% OUTPUT - table with average valence and arousal ratings
% 
% table format:
%   columns: avaerage subject valence/arousal rating, average OASIS ratings
%   rows: valence/arousal/stimulation categories of images

    % empty matrix for results
    Results = zeros(8,4);

    % load database
    load('C:\Users\ztlee\Documents\MATLAB\EMO\Data\Database\BehavioralDatabase.mat','BehavioralData');

    % columns in database that will get averaged
    cols = ["Vrate","Arate","VrateOASIS","ArateOASIS"];

    % row names for table
    rows = ["No Stim/Neg V/Low A","Stim/Neg V/Low A",...
        "No Stim/Neg V/High A","Stim/Neg V/High A",...
        "No Stim/Pos V/Low A","Stim/Pos V/Low A",...
        "No Stim/Pos V/High A","Stim/Pos V/High A"];

    % filter database rows by subject ID

    sub_idx = strcmp(BehavioralData.SUBJ,subj);
    db = BehavioralData(sub_idx,:);

    % filter database rows for encoding task data
    task_idx = db.Recall == 999;
    db = db(task_idx,:);

    % filter database rows by image category (stim/valence/arousal)

    % stim condition
    % 1 = stimulated, 0 = not stimulated
    SC = db.Stim;
    
    % valence condition
    % 1 = positive, 0 = negative
    VC = db.Vcat;

    % arousal condition
    % 1 = high, 0 = low
    AC = db.Acat;

    % Row 1: No Stim/Neg V/Low A
    Results(1,:) = mean(db{SC==0 & VC==0 & AC==0, cols});
    % Row 2: Stim/Neg V/Low A
    Results(2,:) = mean(db{SC==1 & VC==0 & AC==0, cols});
    % Row 3: No Stim/Neg V/High A
    Results(3,:) = mean(db{SC==0 & VC==0 & AC==1, cols});
    % Row 4: Stim/Neg V/High A
    Results(4,:) = mean(db{SC==1 & VC==0 & AC==1, cols});
    % Row 5: No Stim/Pos V/Low A
    Results(5,:) = mean(db{SC==0 & VC==1 & AC==0, cols});
    % Row 6: Stim/Pos V/Low A
    Results(6,:) = mean(db{SC==1 & VC==1 & AC==0, cols});
    % Row 7: No Stim/Pos V/High A
    Results(7,:) = mean(db{SC==0 & VC==1 & AC==1, cols});
    % Row 8: Stim/Pos V/High A
    Results(8,:) = mean(db{SC==1 & VC==1 & AC==1, cols});

    % convert results mat to table
    ResultsTable = table(Results(:,1),Results(:,2),Results(:,3),Results(:,4),...
        'VariableNames',cols,'RowNames',rows);

end