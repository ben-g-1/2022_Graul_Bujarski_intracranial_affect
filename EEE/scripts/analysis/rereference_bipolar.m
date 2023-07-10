% run qualtrics_cleaning.m to get necessary variables %

%%
% chans = ft_channelselection({'all', '-PR', '-Pleth', '-TRIG', ...
    % '-OSAT', '-*DC*', eegchan{:},badchan{:}, emptychan{:}, extrachan{:}}, hdr.label);
% chans = ft_channelselection({'all', '-PR', '-Pleth', '-TRIG', ...
%     '-OSAT', '-*DC*', eegchan{:}, emptychan{:}}, hdr.label);





%%
cfg = [];
cfg.dataset      = eegfile;

if ~exist('hdr', 'var')
    hdr              = ft_read_header(cfg.dataset);
end
cfg.channel      = chans;
cfg.demean         = 'no';
% cfg.detrend        = 'yes';
cfg.baselinewindow = 'all';
cfg.lpfilter       = 'yes';
cfg.lpfreq         = 200;
cfg.hpfilter       = 'yes';
cfg.hpfreq         = 3;
% cfg.padding        = .5;
% cfg.padtype        = 'data';
cfg.bsfilter       = 'yes';
cfg.bsfiltord      = 3;
cfg.bsfreq         = [59 61; 119 121; 179 181];

data = ft_preprocessing(cfg, data);


%%
%SUB 01
% depths         = {'RPXA*', 'RPPC*', 'RPRS*', 'RPAG*', 'RTA*', 'RTHA*', 'RTF*', 'RTS*', 'RIA*', 'LFC*', 'RFC*', 'LTA*', 'LTHA*'};

%SUB 03
% depths         = {}



% depths         = {'RTA*', 'RTHA*'};       



%% Trial Definition
e2 = event;
idx = [];
for e = 1:numel(event)
  if ~isequal(event(e).phase, 6)
%   if event(e).trial == 0
    idx = [idx e]; % events to be tossed
  end
end

e2(idx)         = [];
imgs            = [e2.sample]';

% trial definition
pre              = round(1 * hdr.Fs);
post             = round(4 * hdr.Fs);
% 1 second before and 10 seconds after stimulus (image) onset

%% Referencing
chanlist = {};

for d = 1:numel(depths)
    cfg            = [];
    cfg.dataset    = data;    

    % cfg.channel    = ft_channelselection(depths{d}, data.label);
    cfg.reref      = 'yes';
    cfg.refchannel = 'all';
    cfg.refmethod  = 'bipolar';
    cfg.updatesens = 'no';
    cfg.dataset    = eegfile;
    % cfg.trl        = [imgs-pre imgs+post+1 ones(numel(imgs),1)*-pre stim_table.highcue_indx stim_table.trial_number]; 
    
    
    % Loop to fix stupid overlapping electrode names
    ii = 1;
    x = ft_channelselection(depths{d}, data.label);
    for c = 1:numel(x)
        name = x{c};
        isPresent = any(strcmp(chanlist, name));
        if ~isPresent
            chanlist = [chanlist, name];
            cfg.channel{ii} = x{c}; % This is where the channels are saved
            ii = ii + 1;
        end % if present
    end% for c
    reref_depths{d} = ft_preprocessing(cfg);
end

%%% NOTE ABOUT SUB 3: reref_depths{17} was the full list of channels...?
%%% recursive issues?
%%
cfg = [];
reref = ft_appenddata(cfg,reref_depths{:});



