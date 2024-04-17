%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HIE_subXX_makeinfo is creates a metadata file for the subject, designed to 
% create consistent paths and info that can be quickly loaded in for 
% subsequent preprocessing or analyses. 
% The two objects it writes out are 'sub-XX_info.mat' and 'sub-XX_paths.mat'
% The subject number is according to the global HIE Consortium 
% numbering schema, and should contain a reference to each project which 
% has data from the same subject. 
% This section contains the following information about the subject:
%   - subj_num: the subject number
%   - handedness: the handedness of the subject
%   - gender: the gender of the subject
%   - age: the age of the subject
%   - SOZ_laterality: information about the seizure onset zone and laterality
%   - epilepsy_duration: the duration of epilepsy for the subject
%   - medications: information about the medications the subject was taking at the time of enrollment
%   - neuropsych_testing: information about the neuropsychological testing results, such as IQ
%   - electrode_locations: information about the locations of the electrodes
%   - electrode_characteristics: information about the characteristics of the electrodes
%   - electrodes_in_excised_areas: information about the electrodes that are contained in excised areas
%   - channel_names: names of the channels
%   - notes: any additional notes or comments
%
% A second object used to save paths to any anatomical data will be created. 
% This object is loaded into subsequent scripts and altered with project-specific 
%  paths as needed.
%
% For use with Dartmouth College Human Intracranial Consortium data
%
% Note that 'filesep' is used because fullfile() breaks if trying to access 
%  the Discovery HPC or other Linux systems on a Windows machine
%
% Ben Graul, 2024 (benjamin.e.graul.gr@dartmouth.edu)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE 4/16: Current paths go to 'CANLab' and 'EEE', which are placeholders for the
%  actual directory. This will need to be updated to the correct path once 
%  we secure the server space.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 



%% Subject-specific details useful for all projects
%__________________________________________________________________________
%%% ALL VALUES IN THIS SECTION MUST BE SET MANUALLY %%%

sub_info        = struct();
sub_paths       = struct();

subjectnum      = 'XX'; % as a string
sessionnum      = '01'; % Likely will be unnecessary for this generic script

sub_info.subj_num = subjectnum;
% sub_info.handedness = 'R'; % R | L
% sub_info.gender = 'M'; % M | F | O | U
% sub_info.age = '34'; % age as string
% sub_info.SOZ_laterality =  'R'; % R | L | B | U 
% sub_info.epilepsy_duration =  ; % Years since diagnosis of epilepsy
% sub_info.medications = {'Placebo', '10mg';} ; % List as cell array {medication, dose}
% sub_info.neuropsych_testing =  ; % Maybe just IQ
% sub_info.electrode_locations =  ; %!  Probably needs to come after colocalization
% sub_info.electrode_characteristics =  ; % Manufacturer, model, impedance, etc.
% sub_info.electrodes_in_excised_areas =  ;
% sub_info.channel_names = sub_info.notes =  ; % Notes that will help contextualize unusual behavioral
%                                              %  or neural results for researchers who are not familiar with the subject



%% Paths useful for all projects
%_____________________________________________________________________________
%%% THESE PATHS ASSUME BIDS-COMPLIANT STRUCTURE %%%

subjID          = ['sub-', num2str(subjectnum)];

sub_paths.canlabdir     = ['//dartfs-hpc/rc/lab/C/CANlab'];
% sub_paths.HIEdir      = ['//dartfs-hpc/rc/lab/H/HIE/HIE_data'];    
sub_paths.subjrawdir    = [canlabdir '/labdata/data/EEE/ieeg/raw/sub-', num2str(subjectnum)];
sub_paths.anatdir       = [subjrawdir '/anat'];
sub_paths.anat_outdir   = [canlabdir '/labdata/data/EEE/ieeg/processed/sub-', num2str(subjectnum) '/anat'];
sub_paths.fsdir         = [subjrawdir '/freesurfer'];

sub_paths.mrfile        = [anatdir '/EEE_' subjID  '_T1.nii']; % single file of a DICOM series or a nifti file
sub_paths.ctfile        = [anatdir '/EEE_', subjID, '_CT.nii']; % single file of a DICOM series or a nifti file

% create output directory if non-existent
if ~exist(sub_paths.anat_outdir, 'dir')
  mkdir(sub_paths.anat_outdir);
end

% Check if any FreeSurfer data exists
if ~exist(sub_paths.fsdir, 'dir')
  warning('Freesurfer directory does not exist. Please run recon-all for this subject.')
end

cd(sub_paths.subjrawdir)
save(['sub-' num2str(subjectnum) '_info.mat'], "sub_info")
save(['sub-' num2str(subjectnum) '_paths.mat'], "sub_paths")
