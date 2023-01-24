function recon_sub05

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RECON_SUBXX performs a series of data preprocessing steps involving 
% the preparation and fusion of the anatomical scans (MR & CT) with the
% electrophysiological recordings. This allows the recordings to be 
% analyzed in an anatomically precise and consistent way. All methods are 
% fully integrated and freely available through the FieldTrip toolbox.
%
% The recommended procedure would be to evaluate the code blocks one by one
% in the Command Window. For more information on the underlying concepts 
% and implementation, see Stolk et al., Nature Protocols (2018) as well as 
% Sadhukha et al., PsyArXiv (2022). See also
% www.fieldtriptoolbox.org/tutorial/human_ecog for the online tutorial.
%
% Ensure FieldTrip is added to the MATLAB path, e.g.,
% addpath /Users/xxx/MATLAB/fieldtrip
% ft_defaults
%
% Arjen Stolk, 2022 (arjen.stolk@dartmouth.edu)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


%% 1) subject-specific details - these need to be set
subjID           = 'sub05'; % for generating subject-specific filenames
mrfile           = 'Pre-op MRI/R21AMY05/R21AMY05_MRI.nii'; % single file of a DICOM series or a nifti file
ctfile           = 'Post-op CT/R21AMY05/R21AMY05_CT.nii'; % single file of a DICOM series or a nifti file
eegfile          = 'EEG Files/EMO12R21#5.ENCODING.09.23.22.EDF'; % recording file (e.g., edf)

% create subject directory if non-existent
subjdir = [pwd filesep subjID];
if ~exist(subjdir, 'dir')
  mkdir(subjdir);
end

%%%% Preprocessing of the anatomical MRI %%%%
%% 2) read in the MR scan
mri              = ft_read_mri(mrfile); % read in the DICOM / Nifti file(s)

%% 3) determine the scan's coordinate system
ft_determine_coordsys(mri); % Q: Which axis describes the right hemisphere, +X?
% CRITICAL STEP To correctly fuse the MRI and CT scans at a later step, 
% accuracy in demarcating the right hemisphere landmark in the following step 
% is important for avoiding an otherwise hard to detect flip of the scan’s 
% left and right orientation.

%% 4) align to the ACPC coordinate system
cfg              = [];
cfg.method       = 'interactive'; % locate anterior and posterior commissure, and positive midline
cfg.coordsys     = 'acpc';
mri_acpc         = ft_volumerealign(cfg, mri);

%% 5) write to file
cfg              = [];
cfg.filename     = [subjdir filesep subjID '_MR_acpc'];
cfg.filetype     = 'nifti';
cfg.parameter    = 'anatomy';
ft_volumewrite(cfg, mri_acpc);
ft_sourceplot([], mri_acpc); print([subjdir filesep subjID '_MR_acpc.png'], '-dpng'); close

%%%% Cortical surface extraction with FreeSurfer (optional) %%%%
%% 6) run FreeSurfer (this may take several hours)
fshome           = '/Applications/freesurfer/7.3.2'
mrifile          = '/Users/benjidad/Desktop/sub05/R21AMY05_MRI.nii'
tmpfile          = '/Users/benjidad/Desktop/sub05/tmp.nii';
system(['export FREESURFER_HOME=' fshome '; ' ...
'source $FREESURFER_HOME/SetUpFreeSurfer.sh; ' ...
'mri_convert -c -oc 0 0 0 ' mrifile ' ' tmpfile '; ' ...
'recon-all -i ' tmpfile ' -s ' 'freesurfer' ' -sd ' subjdir ' -all'])

%% 7) inspect the cortical surfaces
pial_lh          = ft_read_headshape(fullfile(subjdir, 'freesurfer', 'surf', 'lh.pial'));
pial_lh.coordsys = 'acpc';
ft_plot_mesh(pial_lh);
hold on;
pial_rh          = ft_read_headshape(fullfile(subjdir, 'freesurfer', 'surf', 'rh.pial'));
pial_rh.coordsys = 'acpc';
ft_plot_mesh(pial_rh);
lighting gouraud;
camlight;
print([subjdir filesep subjID '_fsMR_acpc_pials.png'], '-dpng');

%% 8) import the FreeSurfer MR scan
fsmri_acpc       = ft_read_mri(fullfile(subjdir, 'freesurfer', 'mri', 'T1.mgz'));
fsmri_acpc.coordsys = 'acpc';

%%%% Preprocessing of the anatomical CT %%%%
%% 9) read in the CT scan
ct               = ft_read_mri(ctfile); % read in the DICOM / Nifti file(s)

%% 10) determine the scan's coordinate system
ft_determine_coordsys(ct); % Q: Which axis describes the right hemisphere, +X?
% CRITICAL STEP To correctly fuse the MRI and CT scans at a later step, 
% accuracy in demarcating the right hemisphere landmark in the following step 
% is important for avoiding an otherwise hard to detect flip of the scan’s 
% left and right orientation.

%% 11) align to the CTF head surface coordinate system
cfg              = []; % press "shift" and "equal" to increase the luminance
cfg.method       = 'interactive'; % locate nasion, left and right ear, and positive midline
cfg.coordsys     = 'ctf';
ct_ctf           = ft_volumerealign(cfg, ct);

%% 12) automatically convert to the ACPC coordinate system
ft_hastoolbox('spm12', 1);
ct_acpc = ft_convert_coordsys(ct_ctf, 'acpc');

%% ALTERNATIVE: in case of too little overlap, align to the ACPC system directly
cfg              = []; % press "shift" and "equal" to increase the luminance
cfg.method       = 'interactive'; % locate anterior and posterior commissure, and positive midline
cfg.coordsys     = 'acpc';
ct_acpc          = ft_volumerealign(cfg, ct);

%%%% Fusion of the CT with the MRI %%%%
%% 13) fuse the CT with the MR scan
cfg              = [];
cfg.method       = 'spm';
cfg.spmversion   = 'spm12';
cfg.coordsys     = 'acpc';
cfg.viewresult   = 'yes';
ct_acpc_f = ft_volumerealign(cfg, ct_acpc, fsmri_acpc);
print([subjdir filesep subjID '_CT_acpc_f.png'], '-dpng');

%% 14) inspect the interactive figure for tight interlocking of the scans
% CRITICAL STEP Accuracy of the fusion operation is important for correctly 
% placing the electrodes in anatomical context in a following step.

%% 15) write to file
cfg              = [];
cfg.filename     = [subjdir filesep subjID '_CT_acpc_f'];
cfg.filetype     = 'nifti';
cfg.parameter    = 'anatomy';
ft_volumewrite(cfg, ct_acpc_f);

%%%% Electrode placement %%%%
%% 16) import the header from the recording file
hdr              = ft_read_header(eegfile); % take electrode labels from the header

%% 17) localize the electrodes in the fused CT
cfg              = [];
cfg.channel      = hdr.label;
elec_acpc_f      = ft_electrodeplacement(cfg, ct_acpc_f, fsmri_acpc);

%% 18) examine the resulting electrode structure
elec_acpc_f

%% 18.5) reload electrodes for relocalization
elec_acpc_f = ([subjdir filesep subjID '_elec_acpc_f.mat'])
cfg_elec = elec_acpc_f

%% 19) visualize the MR scan along with the electrodes
ft_plot_ortho(fsmri_acpc.anatomy, 'transform', fsmri_acpc.transform, 'style', 'intersect');
alpha .2
ft_plot_sens(elec_acpc_f, 'label', 'on', 'fontcolor', 'w');
%print([subjdir filesep subjID '_elec_acpc_f.png'], '-dpng');

%% 20) write to file
save([subjdir filesep subjID '_elec_acpc_f.mat'], 'elec_acpc_f');
