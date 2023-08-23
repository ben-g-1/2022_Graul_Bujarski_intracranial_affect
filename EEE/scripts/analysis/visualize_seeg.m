% Visualizing Amygdala for EEE Sub 01

datadir = ('C:\Users\bgrau\Dropbox (Dartmouth College)\PBS\2023_Graul_EEE\Data\processed\sub-01\imgview\freq');
fsdir = '//dartfs-hpc/rc/lab/C/CANlab/labdata/data/EEE/ieeg/raw/sub-01/freesurfer';

cd(datadir);

load('sub-01_imgview_freq_fullspec.mat');
imgview_freq.elec = elec_acpc_fr;

%% Interactive Plotting
cfg = [];
cfg.headshape = pial_rh;
cfg.projection = 'orthographic';
cfg.channel = {'R*'};
cfg.viewpoint = 'topright';
cfg.mask = 'mri';
cfg.direction = 'LR';
% cfg.boxchannel = {'RTA1', 'RTA12'};
lay = ft_prepare_layout(cfg, imgview_freq);

%%
cfg  = [];
cfg.baseline = [-.3 -.1];
cfg.baselinetype = 'db';
cfg.channel = {'R*'};
imgview_freq_blc = ft_freqbaseline(cfg, imgview_freq);

%%
cfg = [];
cfg.layout = lay;
cfg.showoutline = 'yes';
ft_multiplotTFR(cfg, imgview_freq_blc)

%%
atlas = ft_read_atlas(fullfile(fsdir, 'mri', 'aparc+aseg.mgz'));
atlas.coordsys = 'acpc';
cfg = [];
cfg.inputcoord = 'acpc';
cfg.atlas = atlas;
cfg.roi = 'Right-Amygdala';
mask_rha = ft_volumelookup(cfg, atlas);

%%
seg = keepfields(atlas, {'dim', 'unit','coordsys','transform'});
seg.brain = mask_rha;
cfg = [];
cfg.method = 'iso2mesh';
cfg.radbound = 2;
cfg.maxsurf = 0;
cfg.tissue = 'brain';
cfg.numvertices = 1000;
cfg.smooth = 3;
mesh_rha = ft_prepare_mesh(cfg, seg);

%%
cfg = [];
cfg.channel = {'RTA*'};
cfg.frequency = [40 100];
cfg.latency = [0 4];
cfg.avgovertime = 'yes';
freq_sel = ft_selectdata(cfg, imgview_freq);

%%
cfg = [];
cfg.funparameter = 'powspctrm';
cfg.funcolorlim = [-.5 .5];
cfg.method = 'cloud';
cfg.slice = '2d';
cfg.nslices = 2;
cfg.facealpha = .25;
ft_sourceplot(cfg, freq_sel, mesh_rha);
view([120 40]);
lighting gouraud;
camlight;