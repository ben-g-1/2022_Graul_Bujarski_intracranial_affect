%%%%% Valence Response Analyzer %%%%%

% This script takes an EEG recording from a patient in the EEE study,
% segments it into the time of interest, decomposes it into time/frequency
% components, then uses a GLM to determine whether it tracks valence.

% Clean behavioral data and electrode channels should first be obtained
% using subXX_cleaning
% Electrode localization should be finished using recon_XX

% By Ben Graul
% v0.2 10/31/2023

%%% Load in Data %%%

subjectnum = '01';
sessionnum = '01';
projdir = 'C:\Users\bgrau\Dropbox (Dartmouth College)\2023_Graul_EEE';
subjdir = fullfile(projdir, 'Data', 'processed', ['sub-', subjectnum]);
datadir = fullfile(projdir, 'Data', 'raw', ['sub-', subjectnum], 'ses-01');
fsdir   = fullfile(subjdir, 'freesurfer');

event = fullfile(subjdir, ['sub-', subjectnum, '_event_clean.mat']);
chans = fullfile(subjdir, ['sub-', subjectnum, '_electrodes_clean.mat']);
depth_names = fullfile(subjdir, ['sub-', subjectnum, '_depth_names.mat']);
eegfile = fullfile(datadir, ['EEE_PT-', subjectnum, '_BG.EDF']);
elec = fullfile(subjdir, ['EEE_sub-', subjectnum, '_elec_acpc_f.mat']);

addpath(subjdir)
cd(subjdir)

load(event);
load(chans);
load(elec);
load(depth_names);
%% Preprocess %%
cfg                     = [];
cfg.dataset             = eegfile;
cfg.channel             = 'all';

cfg.demean              = 'yes'; 
cfg.baselinewindow      = 'all'; 

cfg.lpfilter    = 'yes';
cfg.lpfiltord   = 4;
cfg.lpfreq      = 150;

cfg.bsfilter    = 'yes';
cfg.bsfiltord   = 3;
cfg.bsfreq      = [58 62; 118 122];

%% Define Trials %%

% cfg                     = [];
% cfg.dataset             = eegfile;
cfg.trialfun            = 'trl_singlephase';
cfg.trialdef.pre        = 2.5; 
cfg.trialdef.post       = 5;
cfg.trialdef.offset     = -2.5; % Picture viewing is at T = 0
cfg.trialdef.event      = event;
cfg.trialdef.eventvalue = 6;
cfg.keeptrials          = 'yes';

cfg                     = ft_definetrial(cfg);

data                    = ft_preprocessing(cfg);
% data.elec               = elec_acpc_f;

%% Remove bad trial %%
cfg = [];
% cfg.trials = [1:61 63 64];

data_clean = ft_selectdata(cfg, data);
%% Reference to Bipolar Montage %%

for d = 1:numel(depths)
  cfg              = [];
  cfg.channel      = ft_channelselection(depths{d}, data.label); 
  cfg.reref        = 'yes';
  cfg.refchannel   = 'all';
  cfg.refmethod    = 'bipolar';
  cfg.updatesens   = 'yes';
  reref_depths{d} = ft_preprocessing(cfg, data_clean);
end

cfg              = [];
cfg.appendsens   = 'yes';
reref            = ft_appenddata(cfg, reref_depths{:});

%% Decompose into Frequencies

cfg                     = [];
cfg.method              = 'mtmconvol';
%quick and dirty
% cfg.toi     = -1.5:1:3.5;
% cfg.foi     = 30:5:80;
% This can be used to get a more granular view of the data if desired
cfg.toi                 = -1.5:.05:3.5;
cfg.foi                 = [5:5:55 65:5:115 125:5:151];
% cfg.foi        = [4:1:29 30:5:55 65:5:115 125:5:150];

cfg.t_ftimwin           = ones(length(cfg.foi),1).*0.2; % should figure out if this is reasonable
cfg.taper               = 'hanning';
cfg.output              = 'pow';
cfg.keeptrials          = 'yes';


imgview_freq            = ft_freqanalysis(cfg, data);

%% Visualize for Right Amygdala

cfg                    = [];
cfg.channel            = 'RTA1-RTA2';

cfg.avgoverrpt         = 'yes';

cfg.baseline           = 'yes'; 
cfg.baselinetype       = 'zscore';

cfg.latency            = [-1 3];

ft_singleplotTFR(cfg, imgview_freq)

%% Create layout from colocalized coordinates

% pial mesh combination
pial_lh          = ft_read_headshape(fullfile(fsdir, 'surf', 'lh.pial'));
pial_lh.coordsys = 'acpc';
pial_rh          = ft_read_headshape(fullfile(fsdir, 'surf', 'rh.pial'));
pial_rh.coordsys = 'acpc';
pial.pos         = cat(1,[pial_lh.pos; pial_rh.pos]); % concatenate
pial.tri         = cat(1,[pial_lh.tri; pial_rh.tri + size(pial_lh.pos,1)]);
pial.unit        = pial_lh.unit;
pial.coordsys    = 'acpc';

% layout preparation
cfg              = [];
cfg.headshape    = pial;
cfg.projection   = 'orthographic';
cfg.channel      = 'all';
cfg.viewpoint    = 'superior';
cfg.mask         = 'convex';
cfg.boxchannel   = {imgview_freq.label{1}, imgview_freq.label{2}}; % determines box size
flat_lay        = ft_prepare_layout(cfg, imgview_freq);

%% Sample baseline
cfg              = [];
cfg.baseline     = 'yes';
cfg.baselinetype = 'db'; 
freq_blc         = ft_freqbaseline(cfg, imgview_freq);

%% visualize on 2D layout
cfg              = [];
cfg.layout       = flat_lay;
cfg.showoutline  = 'yes';
ft_multiplotTFR(cfg, freq_blc);

%% Test Significance With GLM
% Very incomplete

%Reduce T/F 4D Size to Channel x Freq x Time

cfg = [];
cfg.avgoverrpt = 'yes';
cfg.avgoverfreq = 'yes';

imgview_freq_avg = ft_selectdata(cfg, imgview_freq);

% start with a sample electrode
% reduce to a single measure of frequency magnitude at each point in time 

cfg                    = [];
cfg.avgoverrpt = 'yes';
cfg.avgoverfreq = 'yes';

cfg.channel            = 'RTA1-RTA2';
cfg.baseline = 'yes';
cfg.baselinetype = 'zscore';

imgview_zscore = ft_freqbaseline(cfg, imgview_freq);
imgview_amy    = ft_selectdata(cfg, imgview_zscore);

Y = imgview_amy;
% X1 = 

TF_amy = squeeze(imgview_amy.powspctrm);

%% Monte Carlo for Positive vs Negative Valence 
% (https://www.fieldtriptoolbox.org/tutorial/cluster_permutation_freq/)

% Split into high and low valence trials

cfg     = [];
cfg.trials = imgview_freq.trialinfo.val_type == 1;

pos_img = ft_selectdata(cfg, imgview_freq);

cfg.trials = imgview_freq.trialinfo.val_type == -1;

neg_img = ft_selectdata(cfg, imgview_freq);

cfg = [];
cfg.latency          = 'all';
cfg.frequency        = 'all';
cfg.method           = 'montecarlo';
cfg.statistic        = 'ft_statfun_indepsamplesT';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan        = 2;
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.025;
cfg.numrandomization = 100;

% prepare_neighbours determines what sensors may form clusters
cfg_neighb.elec = imgview_freq.elec;
cfg_neighb.method    = 'distance';
cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, imgview_freq);

design = zeros(1,size(pos_img.powspctrm,1) + size(neg_img.powspctrm,1));
design(1,1:size(pos_img.powspctrm,1)) = 1;
design(1,(size(pos_img.powspctrm,1)+1):(size(pos_img.powspctrm,1)+...
size(neg_img.powspctrm,1))) = 2; 

cfg.design           = design;
cfg.ivar             = 1;

[stat] = ft_freqstatistics(cfg, pos_img, neg_img);

%% Stat mask for result visualization



%% Visualize Results 

% These next pieces are adapted directly from analyze_subXX script by Arjen
% Stolk
 %% Extract high-gamma band activity
cfg              = [];
cfg.frequency    = [70 150]; 
cfg.avgoverfreq  = 'yes';
cfg.latency      = [0 1];
cfg.avgovertime = 'yes';

statmask         = ft_selectdata(cfg, stat);
%also need to collapse trials for freq data
cfg.avgoverrpt  = 'yes';

freq_sel         = ft_selectdata(cfg, freq_blc);


%% Create volumetric mask of right hippocampus and amygdala
atlas            = ft_read_atlas(fullfile(fsdir, 'mri', 'aparc+aseg.mgz'));
atlas.coordsys   = 'acpc';
cfg              = [];
cfg.inputcoord   = 'acpc';
cfg.atlas        = atlas;
% cfg.roi          = 'Right-Amygdala'; 
mask_rha         = ft_volumelookup(cfg, atlas);
% cfg.roi          = 'Left-Amygdala'; 
% mask_lha         = ft_volumelookup(cfg, atlas);

%% Create triangulated surface mesh
seg = keepfields(atlas, {'dim', 'unit','coordsys','transform'}); 
seg.brain        = mask_rha;
cfg              = [];
cfg.method       = 'iso2mesh';
cfg.radbound     = 2;
cfg.maxsurf      = 0;
cfg.tissue       = 'brain';
cfg.numvertices  = 1000;
cfg.smooth       = 3;
mesh_rha         = ft_prepare_mesh(cfg, seg);
seg.brain        = mask_lha;
mesh_lha         = ft_prepare_mesh(cfg, seg);

%% Select depth probes of interest
cfg              = [];
cfg.channel      = {'RTA*', 'LTA*'};
freq_sel2        = ft_selectdata(cfg, freq_sel);
elec_statmask    = ft_selectdata(cfg, statmask);

%% Visualize high-gamma band activity
cfg              = [];
cfg.funparameter = 'powspctrm';
% cfg.funcolorlim  = [-1000 1000];
cfg.funcolormap  = 'parula';
cfg.method       = 'cloud';
cfg.facealpha    = .25;
cfg.maskparameter = elec_statmask;

% cfg.atlas        = atlas;
% cfg.roi          = {'Right-Amygdala', 'Left-Amygdala'}; 

ft_sourceplot(cfg, freq_sel2, {mesh_rha, mesh_lha});
view([120 40]);
lighting gouraud;
camlight;
