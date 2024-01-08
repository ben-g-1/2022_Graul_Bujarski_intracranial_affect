function [data] = atlas_matching(data,  maxrange, atlas_template)
% atlas template is relative to FieldTrip filepath
% TO DO: Add different atlas 

e = data.elec;
if nargin < 3
    atlas_template = 'template\atlas\aal\ROI_MNI_V4.nii';
end


[~, ftpath] = ft_version;
atlaspath = [ftpath filesep atlas_template];
atlas = ft_read_atlas(atlaspath);


for c = 1:numel(e.label)
    cfg            = [];
    
    cfg.roi        = e.chanpos(c,:);
    cfg.atlas      = atlaspath;
    cfg.output     = 'single';
    cfg.minqueryrange = 1;
    cfg.maxqueryrange = maxrange;
    cfg.round2nearestvoxel = 'yes';
    labels = ft_volumelookup(cfg, atlas);
    
    
    [~, indx] = max(labels.count);
    e.posname(c) = labels.name(indx);
end
    e.nameconfig = cfg;
    
    noloc = sum(strcmp(e.posname, 'no_label_found'));
    fprintf('Failed to provide location for %d out of %d channels using a search range of %d mm. \n', noloc, numel(e.label), cfg.maxqueryrange)

data.elec = e;

end 