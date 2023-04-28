function [trl, event] = trialfun_ttl(cfg)

% read the header information
hdr           = ft_read_header(cfg.dataset);

% read the events from the data
chanindx      = find(ismember(hdr.label, ft_channelselection('DC3', hdr.label)));
% chanindx       = 260
detectflank   = 'both'; % detect up and down flanks
threshold     = '(3/2)*nanmedian';
event         = ft_read_event(cfg.dataset, 'chanindx', chanindx, 'detectflank', detectflank, 'threshold', threshold);

% look for up events that are followed by down events (peaks in the analog signal)
trl           = [];
waitfordown   = 0;
for i = 1:numel(event)
if ~isempty(strfind(event(i).type, 'up')) % up event
  uptrl     = i;
  waitfordown = 1;
elseif ~isempty(strfind(event(i).type, 'down')) && waitfordown % down event
  offset    = -hdr.nSamplesPre;  % number of samples prior to the trigger
  trlbegin  = event(uptrl).sample;
  trlend    = event(i).sample;
  newtrl    = [trlbegin trlend offset];
  trl       = [trl; newtrl]; % store in the trl matrix
  waitfordown = 0;
end
end