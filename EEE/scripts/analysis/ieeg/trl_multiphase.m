function [trl, event] = trl_multiphase(cfg)

% read the header information and import events 
hdr   = ft_read_header(cfg.dataset);
etable = struct2table(cfg.trialdef.event);
eventvalue = cfg.trialdef.eventvalue;

% determine the number of seconds before and after the trigger
pretrig  = -round(cfg.trialdef.pre  * hdr.Fs);
posttrig =  round(cfg.trialdef.post * hdr.Fs);

% find all trials where phase is 6 for viewing image
% for each trigger except the last one
trl = [];
event = [];
for j = 1:(length(etable.phase))

trg1 = etable.phase(j);

if trg1 == eventvalue 

  trlbegin = etable.sample(j) + pretrig;
  trlend   = etable.sample(j) + posttrig;
  offset   = pretrig;
  newtrl   = [trlbegin trlend offset];
  newevent = etable(j,:); 
  event    = [event; newevent];
  trl      = [trl; newtrl];
end

end

end