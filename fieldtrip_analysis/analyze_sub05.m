function analyze_sub05

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ANALYZE_SUBXX performs an anatomically informed exploration and
% visualization of the electrophysiological recordings. All methods are 
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
eegfile          = 'EEG Files/EMO12R21#5.ENCODING.09.23.22.EDF'; % recording file (e.g., edf)

% create subject directory if non-existent
subjdir = [pwd filesep subjID];
if ~exist(subjdir, 'dir')
  mkdir(subjdir);
end

%%%% Preprocessing of the neural recordings %%%%
%% Load raw data
cfg               = [];
cfg.dataset       = eegfile; 
data = ft_preprocessing(cfg);
%% View unedited 
cfg = [];
cfg.viewmode = 'vertical';
cfg.linewidth    = 1;
cfg.ylim         = [-50 50];
%cfg.blocksize = 10;
ft_databrowser(cfg, data)

%% NOTES
% DC2 is HUGE in Y axis.
% Large deflection at ~t=77
% DC3 had blip at same time as DC2, but much smaller
% Some are sawtooth, some are long,
% Rejects: DC4, DC1, 

%% 35) define trials
cfg              = [];
cfg.dataset      = eegfile;

% trigger detection (appear to be 3-sec long)
hdr              = ft_read_header(cfg.dataset);
event            = ft_read_event(cfg.dataset, 'detectflank', 'up')
% event            = ft_read_event(cfg.dataset, 'detectflank', 'up', 'chanindx', find(ismember(hdr.label, 'DC3')));
% idx              = [];
% for e = 1:numel(event)
%   if ~isequal(event(e).type, 'DC3')
%     idx = [idx e]; % events to be tossed
%   end
% end
event(idx)       = [];
trigs            = [event.sample]';

% trial definition
pre              = round(1 * hdr.Fs);
post             = round(1 * hdr.Fs);
cfg.trl          = [trigs-pre trigs+post+1 ones(numel(trigs),1)*-pre]; % 1 seconds before and after trigger onset
cfg.trl(any(cfg.trl>hdr.nSamples,2),:) = [] % ensure presence of samples

%% USED IN NATURE PROTOCOLS PAPER
cfg = [];
cfg.dataset = eegfile; 
cfg.trialdef.eventtype = 'TRIGGER';
cfg.trialdef.eventvalue = 4;
cfg.trialdef.prestim = 0.4;
cfg.trialdef.poststim = 0.9;
cfg = ft_definetrial(cfg);

%% 36) import and filter data
cfg.demean       = 'yes'; 
cfg.baselinewindow = 'all'; 
cfg.lpfilter     = 'yes';
cfg.lpfiltord    = 4;
cfg.lpfreq       = 178;
cfg.bsfilter     = 'yes';
cfg.bsfiltord    = 4;
cfg.bsfreq       = [58 62; 118 122]; % 60, 120, 180 Hz
data             = ft_preprocessing(cfg);

%% 37) examine resulting data structure
data

%% 38) add elec structure
load([subjdir filesep subjID '_elec_acpc_f.mat']);
data.elec        = elec_acpc_f;

%% 39) inspect recordings using ft_databrowser
cfg              = [];
cfg.viewmode     = 'vertical';
cfg.linewidth    = 1;
cfg.ylim         = [-50 50];
%cfg.blocksize    = 10; % 10-second blocks
cfg              = ft_databrowser(cfg, data);
% TIP Use 'identify' to pinpoint and note bad channels for later removal
% Note: DC2 and 3 seem to be trigger channels

%% 40) remove bad channels and segments
badchan          = {'-LFMO1','-RTSF14','-RTSF13','-RTSF12','-RFSI5'}; % ,'-LXA4','-LTMH5','-RTMH4'

%% 42) re-reference depth electrodes
% bad channel removal
eegchan          = strcat('-', ft_channelselection({'eeg'}, data.label));
cfg              = [];
cfg.channel      = ft_channelselection({'all', '-*DC*', '-PR', '-Pleth', '-TRIG', '-OSAT', '-C2*', eegchan{:}, badchan{:}}, data.label);
data             = ft_preprocessing(cfg, data);

% bipolar derivations
depths = {'LTMH*','LTMA*','LTSF*','RTMH*','RTMA*','RTSF*','LXA*','LFSI*','LFMO*','LTSS*','LXB*','LXC*','RFSI*','RFMO*','RTSS*','RXA*'};
for d = 1:numel(depths)
  cfg              = [];
  cfg.channel      = ft_channelselection(depths{d}, data.label); 
  cfg.reref        = 'yes';
  cfg.refchannel   = 'all';
  cfg.refmethod    = 'bipolar';
  cfg.updatesens   = 'yes';
  reref_depths{d} = ft_preprocessing(cfg, data);
end

%% 43) combine electrodes
cfg              = [];
cfg.appendsens   = 'yes';
reref            = ft_appenddata(cfg, reref_depths{:});

%%%% Time-frequency analysis %%%%
%% 45) decompose into time and frequency
cfg              = [];
cfg.method       = 'mtmconvol';
cfg.toi          = -.9:.1:.9;
cfg.foi          = 5:5:175;
cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.2;
cfg.taper        = 'hanning';
cfg.output       = 'pow';
cfg.keeptrials   = 'no';
freq             = ft_freqanalysis(cfg, reref);

%% 47) prepare anatomical plotting layout
% pial mesh combination
pial_lh          = ft_read_headshape(fullfile(subjdir, 'freesurfer', 'surf', 'lh.pial'));
pial_lh.coordsys = 'acpc';
pial_rh          = ft_read_headshape(fullfile(subjdir, 'freesurfer', 'surf', 'rh.pial'));
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
cfg.boxchannel   = {freq.label{1}, freq.label{2}}; % determines box size
lay              = ft_prepare_layout(cfg, freq);

%% 48) express as relative change
cfg              = [];
cfg.baseline     = [-.9 -.5];
cfg.baselinetype = 'relchange'; 
freq_blc         = ft_freqbaseline(cfg, freq);

%% 49) visualize on 2D layout
cfg              = [];
cfg.layout       = lay;
cfg.showoutline  = 'yes';
ft_multiplotTFR(cfg, freq_blc); % RTMH4 and LTMH5 appear to have been stimulated

%%%% Data representation %%%%
%% 50) extract high-gamma band activity
cfg              = [];
cfg.frequency    = [70 150]; 
cfg.avgoverfreq  = 'yes';
cfg.latency      = [0 0.5];
cfg.avgovertime  = 'yes';
freq_sel         = ft_selectdata(cfg, freq_blc);

%% 53) create volumetric mask of right hippocampus and amygdala
atlas            = ft_read_atlas(fullfile(subjdir, 'freesurfer', 'mri', 'aparc+aseg.mgz'));
atlas.coordsys   = 'acpc';
cfg              = [];
cfg.inputcoord   = 'acpc';
cfg.atlas        = atlas;
cfg.roi          = {'Right-Hippocampus', 'Right-Amygdala'}; 
mask_rha         = ft_volumelookup(cfg, atlas);
cfg.roi          = {'Left-Hippocampus', 'Left-Amygdala'}; 
mask_lha         = ft_volumelookup(cfg, atlas);

%% 54) create triangulated surface mesh
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

%% 55) select depth probes of interest
cfg              = [];
cfg.channel      = {'RTMH*','RTMA*','RXA*','LTMH*','LTMA*','LXA*'};
freq_sel2        = ft_selectdata(cfg, freq_sel);

%% 56) visualize high-gamma band activity
cfg              = [];
cfg.funparameter = 'powspctrm';
cfg.funcolorlim  = [-1000 1000];
cfg.funcolormap  = 'parula';
cfg.method       = 'cloud';
cfg.facealpha    = .25;
ft_sourceplot(cfg, freq_sel2, {mesh_rha, mesh_lha});
view([120 40]);
lighting gouraud;
camlight;

%% EXTRA: animate high-gamma band dynamics
for t = 1:numel(freq_blc.time)
  cfg              = [];
  cfg.channel      = {'RTMH*','RTMA*','RXA*','LTMH*','LTMA*','LXA*'};
  cfg.frequency    = [70 150];
  cfg.avgoverfreq  = 'yes';
  cfg.latency      = freq_blc.time(t);
  freq_blc2        = ft_selectdata(cfg, freq_blc);

  cfg              = [];
  cfg.funparameter = 'powspctrm';
  cfg.funcolorlim  = [-1000 1000];
  cfg.funcolormap  = 'parula';
  cfg.method       = 'cloud';
  cfg.facealpha    = .25;
  cfg.colorbar     = 'yes';
  ft_sourceplot(cfg, freq_blc2, {mesh_rha, mesh_lha});
  view([120 40]);
  lighting gouraud;
  camlight;
  text(nanmedian(mesh_rha.pos(:,1)),nanmedian(mesh_rha.pos(:,2)),min(mesh_rha.pos(:,3))-50,['time: ' num2str(round(freq_blc2.time,2))],'horizontalalignment','center');
  
  set(gcf, 'position', [10 10 1500 1000]);
  if isequal(t,1) % prevent framesize changes from snapshot to snapshot
    framepos = get(gcf, 'position');
    width = framepos(3);
    height = framepos(4);
    xlims = get(gca,'xlim');
    ylims = get(gca,'ylim');
    zlims = get(gca,'zlim');
  end
  set(gca, 'xlim', xlims, 'ylim', ylims, 'zlim', zlims);
  frame(t) = getframe(gcf);
  close
end

v                = VideoWriter([subjID '_amygstim.mp4'], 'MPEG-4');
v.Quality        = 100;
v.FrameRate      = 2;
open(v);
writeVideo(v, frame)
close(v)
