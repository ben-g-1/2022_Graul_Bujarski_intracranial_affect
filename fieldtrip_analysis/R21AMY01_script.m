%% PREPROCESSING %%

%% 1
% EDIT
subjID = 'R21AMY01';
%% 2 
mri = ft_read_mri([subjID, '_MRI.nii']);

%% 3
ft_determine_coordsys(mri)
% EDIT
%orientation = left_to_right

%% 4
% Keybinds for coord sys
% r for right hemisphere
% a for anterior commisure
% p for posterior commisure
% z for midline (dorsal interhemispheric fissure)

cfg = [];
cfg.method = 'interactive';
cfg.coordsys = 'acpc';
mri_acpc = ft_volumerealign(cfg,mri)

%% 5
% Write
cfg = [];
cfg.filename = [subjID '_MR_acpc'];
cfg.parameter = 'anatomy';
cfg.filetype = 'nifti';
ft_volumewrite(cfg, mri_acpc);

%% 6. Freesurfer generation
% Freesurfer- do later on Discovery
% EDIT
fs_files_dir = 'C:\Users\bgrau\Matlab\projects\ieeg_affect\fieldtrip_tutorial\freesurfer\'
%% 7. Import FreeSurfer generated files
% Will generate popup w/ 3D render to examine quality
pial_lh = ft_read_headshape( [fs_files_dir, 'surf\lh.pial'] )
pial.lh.coordsys = 'acpc';
ft_plot_mesh(pial_lh)
lighting gouraud;
camlight;
%% 7b. Second hemisphere
% rh

pial_rh = ft_read_headshape( [fs_files_dir, 'surf\rh.pial'] )
pial.rh.coordsys = 'acpc';
ft_plot_mesh(pial_rh)
lighting gouraud;
camlight;

%% 8. Import MRI from 6 for later CT fusion
% Then specify coordinates set in step 4
fsmri_acpc = ft_read_mri( [fs_files_dir, 'mri\T1.mgz'] );
fsmri_acpc.coordsys = 'acpc';

%% 9. Import CT
ct = ft_read_mri( [subjID, '_CT_acpc_f.nii' ]);

%% 10. Determine CT laterality
% Try to get this info earlier
ft_determine_coordsys(ct)
% EDIT
%left to right

%% 11. Specify CT landmarks
% nasion- junction of skull and ethmoid 
% n
% pre-auricular points- just rostral to ear canals
% l for left, r for right

cfg = [];
cfg.method = 'interactive';
cfg.coordsys = 'ctf';
ct_ctf = ft_volumerealign(cfg, ct);

%% 12. Approximate ACPC coordinates in CT
ct_acpc = ft_convert_coordsys(ct_ctf, 'acpc');

%% 13. Fusion of CT with MRI
cfg = []; 
cfg.method = 'spm';
csg.spmversoin = 'spm12';
cfg.coordsys = 'acpc';
cfg.viewresult = 'yes';
ct_acpc_f = ft_volumerealign(cfg, ct_acpc, fsmri_acpc);
% Uses patient as common denominator for rigid-body transformation
% 14. Examine output for significant abnormalities or misalignment

%% 15. Write MRI-fused anatomical CT
cfg = [];
cfg.filename = [subjID '_CT_acpc_f'];
cfg.filetype = 'nifti';
cfg.parameter = 'anatomy';
ft_volumewrite(cfg, ct_acpc_f);

%% ELECTRODE PLACEMENT %%%
%% 16. Import header information (if possible
% Facilitates to-do list for electrode placement later
% Locations directly assigned to labels
% EDIT
hdr = ft_read_header()
%% TUTORIAL ONLY

hdr = load([subjID '_hdr.mat']);
cfg = [];
cfg.channel = hdr.hdr.label;
elec_acpc_f = ft_electrodeplacement(cfg, ct_acpc_f, fsmri_acpc)
%% 17. Localize electrodes
cfg = [];
cfg.channel = hdr.label;
elec_acpc_f = ft_electrodeplacement(cfg, ct_acpc_f, fsmri_acpc)

%% 18. Verify electrode count
%elecpos is electrode position
%   usually absolute
%chanpos is channel position
%   can vary based on later processing
% tra is weight of each electrode in each channel
elec_acpc_f

%% 19. Visualize and inspect for aberrant electrodes
ft_plot_ortho(fsmri_acpc.anatomy, 'transform', fsmri_acpc.transform, 'style', 'intersect');
ft_plot_sens(elec_acpc_f, 'label', 'on', 'fontcolor', 'w');

%% 19.5 Correct incorrect electrodes
cfg = [];
cfg.channel = hdr.hdr.label;
cfg.elec = elec_acpc_f
elec_acpc_f = ft_electrodeplacement(cfg, ct_acpc_f, fsmri_acpc)
%% 20. Save electrode positioning to file
save([subjID '_elec_acpc_f.mat'], 'elec_acpc_f')



