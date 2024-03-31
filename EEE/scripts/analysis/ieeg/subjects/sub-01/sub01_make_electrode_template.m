%% Make Sub 01 Electrode Template

subjectnum = '01';
sessionnum = '01';

%%%
gitdir = 'C:\Users\bgrau\GitHub\ieeg_affect\EEE';
projdir = 'C:\Users\bgrau\Dropbox (Dartmouth College)\2023_Graul_EEE';
scriptdir = fullfile(gitdir, 'scripts', 'analysis');
datadir = fullfile(projdir, 'Data', 'raw', ['sub-',  num2str(subjectnum)], ['ses-', num2str(sessionnum)]);
procdir = fullfile(projdir, 'Data', 'processed', ['sub-',  num2str(subjectnum)]);
analyzedir = fullfile(projdir, 'Analyses', 'ieeg', 'subjects', ['sub-',  num2str(subjectnum)]);

eegfile = fullfile(datadir, ['EEE_', subjectnum, '_deidentified.EDF']);

addpath(genpath(scriptdir));

load(fullfile(procdir, ['sub-', subjectnum, '_event_clean.mat']));
load(fullfile(procdir, ['sub-', subjectnum, '_cleanchans.mat']));
load(fullfile(procdir, ['sub-', subjectnum, '_cleantrials.mat']));
load(fullfile(procdir, ['EEE_sub-', subjectnum, '_elec_acpc_f.mat']));

%%
% get names of depth channels only
depths = {};
for i = 1:numel(cleanchans)
    depths{i} = cleanchans{i}(isstrprop(cleanchans{i},'alpha')); 
end

depths = unique(depths)';

% Depth names
% 'LFC*'
% 'LTA*'
% 'LTHA*'
% 'RFC*'
% 'RIA*'
% 'RPAG*'
% 'RPPC*'
% 'RPRS*'
% 'RPXA*'
% 'RTA*'
% 'RTF*'
% 'RTHA*'
% 'RTS*'

% cfg.channel = ; 
% layout = ft_prepare_layout(cfg, cond_full);

%% Left Hemisphere
cfg = [];
cfg.layout = 'vertical';
cfg.direction = 'BT';
cfg.width = 0.2;

cfg.channel = 'LFC*'; 
layoutLFC = ft_prepare_layout(cfg, cond_full);

cfg.channel = 'LTA*'; 
layoutLTA = ft_prepare_layout(cfg, cond_full);

cfg.channel = 'LTHA*'; 
layoutLTHA = ft_prepare_layout(cfg, cond_full);

% cfg = [];
% layoutL = ft_appendlayout(cfg, [left layouts]);

cfg = [];
layoutL = ft_appendlayout(cfg, layoutLFC, layoutLTA, layoutLTHA);


%% Right Hemisphere
cfg = [];
cfg.layout = 'vertical';
cfg.direction = 'BT';
cfg.width = 0.2;

cfg.channel = 'RFC*'; 
layoutRFC = ft_prepare_layout(cfg, cond_full);

cfg.channel = 'RIA*'; 
layoutRIA = ft_prepare_layout(cfg, cond_full);

cfg.channel = 'RPAG*'; 
layoutRPAG = ft_prepare_layout(cfg, cond_full);

cfg.channel = 'RPPC*'; 
layoutRPPC = ft_prepare_layout(cfg, cond_full);

cfg.channel = 'RPRS*'; 
layoutRPRS = ft_prepare_layout(cfg, cond_full);

cfg.channel = 'RPXA*'; 
layoutRPXA = ft_prepare_layout(cfg, cond_full);

cfg.channel = 'RTA*'; 
layoutRTA = ft_prepare_layout(cfg, cond_full);

cfg.channel = 'RTF*'; 
layoutRTF = ft_prepare_layout(cfg, cond_full);

cfg.channel = 'RTHA*'; 
layoutRTHA = ft_prepare_layout(cfg, cond_full);

cfg.channel = 'RTS*'; 
layoutRTS = ft_prepare_layout(cfg, cond_full);

% cfg = [];
% layoutR = ft_appendlayout(cfg, [right layouts]);

cfg = [];
layoutR1 = ft_appendlayout(cfg, layoutRFC, layoutRIA, layoutRPAG, layoutRPPC, layoutRPRS); 
layoutR2 = ft_appendlayout(cfg, layoutRPXA, layoutRTA, layoutRTF, layoutRTHA, layoutRTS);

%% Examine Layouts
cfg = [];
ft_plot_layout(layoutL)

ft_plot_layout(layoutR1)
ft_plot_layout(layoutR2)

%% Combine Layouts

cfg = [];
cfg.direction = 'vertical';
cfg.align = 'left';
cfg.distance = 0.1; % tweak the distance a bit
layoutShafts = ft_appendlayout(cfg, layoutL, layoutR1, layoutR2);

figure;
ft_plot_layout(layoutShafts);