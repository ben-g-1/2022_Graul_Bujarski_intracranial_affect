

multichan = ft_channelselection({'RSMA*'}, hdr.label);
depths = {'RSMAB*', 'RSMAC*','RSMA*'};
chanlist = {};
%%
i = 1;
for d = 1:numel(depths)
    cfg = [];
    ii = 1;
    x = ft_channelselection(depths{d}, hdr.label);
    for c = 1:numel(x)
        name = x{c};
        isPresent = any(strcmp(chanlist, name));
        if ~isPresent
            chanlist = [chanlist, name];
            cfg.channel{ii} = x{c};
            ii = ii + 1;
        end % if present
    end% for c
end %for d
%%
% Define the column (cell array or string array) where you want to check for the string
column = {'LMA1', 'LMAA1', 'LMAB1'};

% Define the string you want to check
newString = 'LMAA1';

% Check if the string is present in the column using logical indexing
isPresent = any(strcmp(column, newString));

% Add the string if it is not already present
if ~isPresent
    column = [column, newString];
    disp('String added!');
else
    disp('String already present!');
end

%%
% Initialize an empty array to store the matching strings
elecs = {};

% Iterate over each cell element
for i = 1:numel(cfg.channel)
    % Check if the current cell element contains '6', but skip if 16
    if ~isempty(strfind(cfg.channel{i}, '16'))
        continue
    elseif ~isempty(strfind(cfg.channel{i}, '6'))
        % If it contains '6', add it to the matching array
        elecs{end+1} = cfg.channel{i};
    end
end

% Display the matching strings
elecs = strrep(elecs, '6', '*');
%%
    depths = {'LFMC*', 'LFC*', 'LPPC*', 'RSMAB*', 'RSMAC*', 'RSMA*', 'RFC*', ...
     'LSMA*'};
testchannellist = []
for d = 1:numel(depths)
    cfg            = [];
    cfg.dataset    = data;
    % chanlist = ft_channelselection(depths{d}, data.label;
    if ismember(ft_channelselection(depths{d}, data2.label), testchannellist)
    end
        cfg.channel    = ft_channelselection(depths{d}, data2.label);
    cfg.reref      = 'yes';
    cfg.refchannel = 'all';
    cfg.refmethod  = 'bipolar';
    cfg.updatesens = 'no';
    cfg.dataset    = eegfile;
    cfg.trl        = [imgs-pre imgs+post+1 ones(numel(imgs),1)*-pre stim_table.highcue_indx stim_table.trial_number]; 
    % reref_depths{d} = ft_preprocessing(cfg);
end
testchannellist = ft_channelselection() 