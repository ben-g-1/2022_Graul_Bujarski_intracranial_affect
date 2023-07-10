function [trl, event] = trl_imageview(cfg)

% read the header information and import events 
hdr   = ft_read_header(cfg.dataset);
event_full = cfg.trialdef.event;
eventvalue = cfg.trialdef.eventvalue;

% determine the number of seconds before and after the trigger
pretrig  = -round(cfg.trialdef.pre  * hdr.Fs);
posttrig =  round(cfg.trialdef.post * hdr.Fs);

% find all trials where phase is 6 for viewing image
% for each trigger except the last one
trl = [];
event = [];
for j = 1:(length([event_full.phase]))

trg1 = event_full(j).phase;

if trg1 == eventvalue 

  trlbegin = event_full(j).sample + pretrig;
  trlend   = event_full(j).duration*hdr.Fs + event_full(j).sample + posttrig;
  offset   = pretrig;
  newtrl   = [trlbegin trlend offset];
  newevent = event_full(j);
  event    = [event; newevent];
  trl      = [trl; newtrl];
end

end