cfg = [];
cfg.method = 'glassbrain';
cfg.anaprameter = imgview_freq.elec.chanpos;
cfg.funparater = [];

ft_sourceplot(cfg, imgview_freq)
%%
cfg = [];
labels = ft_volumelookup(cfg, imgview_freq.elec.chanpos);

%%
atlas = ft_read_atlas('C:\Matlab\toolboxes\fieldtrip\template\atlas\spm_anatomy\AllAreas_v18_MPM.mat');
%%
atlas            = ft_read_atlas(fullfile(fsdir, 'mri', 'aparc+aseg.mgz'));
atlas.coordsys   = 'acpc';
cfg              = [];
cfg.inputcoord   = 'acpc';
cfg.atlas        = atlas;
cfg.roi          = imgview_freq.elec.chanpos(1,:);
cfg.output       = 'single';
cfg.round2nearestvoxel = 'yes';
% cfg.roi          = 'Right-Amygdala'; 
labels         = ft_volumelookup(cfg, atlas);

%%
cfg            = [];
cfg.elec       = imgview_freq.elec;
cfg.method     = 'mni';
cfg.mri        = mri;
cfg.spmversion = 'spm12';
cfg.spmmethod  = 'new';
cfg.nonlinear  = 'yes';
elec_mni_frv = ft_electroderealign(cfg);
