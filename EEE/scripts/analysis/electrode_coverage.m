template = ft_read_mri('C:\Matlab\toolboxes\fieldtrip\template\anatomy\single_subj_T1_1mm.nii');
template.coordsys = 'mni';

elecs = ft_read_mri('C:\Users\bgrau\Dropbox (Dartmouth College)\PBS\2023_Graul_EEE\Data\DHMC\electrode-locations.nii');
%%
% a = fopen('C:\Users\bgrau\Dropbox (Dartmouth College)\PBS\2023_Graul_EEE\Data\DHMC\electrode_mni_coordinates.txt', 'r')
formatSpec = '%f';
% e = fscanf(a, formatSpec);
z = readtable('C:\Users\bgrau\Dropbox (Dartmouth College)\PBS\2023_Graul_EEE\Data\DHMC\electrode_mni_coordinates.txt');
elec_mni_f.unit = 'mm';
elec_mni_f.coordsys = 'mni';
elec_mni_f.label = [1:2905]';
elec_mni_f.elecpos = z;
elec_mni_f.chanpos = z;
%%

% cfg = [];
% cfg.channel = ''
% cfg.coordsys = 'mni';
DHMC_elec = ft_electrodeplacement(cfg, template, elecs);

% ft_plot_ortho(template.anatomy, 'transform', template.transform, 'style', 'intersect');
% ft_plot_sens(elec_mni_f)