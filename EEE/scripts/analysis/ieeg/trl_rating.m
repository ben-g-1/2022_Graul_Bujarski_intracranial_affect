function [trl, event] = trl_rating(cfg)

% read the header information and import events 
hdr   = ft_read_header(cfg.dataset);
etable = struct2table(cfg.trialdef.event);
eventvalue = cfg.trialdef.eventvalue;

% determine the number of seconds before and after the trigger
% for rating, pretrig determines when the window will begin.
pretrig  = -round(cfg.trialdef.pre  * hdr.Fs);
posttrig =  round(cfg.trialdef.post * hdr.Fs);


trl = [];
event = [];
for j = 1:(length(etable.phase))

trg1 = etable.phase(j);

if trg1 == eventvalue 

  trlbegin = (etable.duration(j) * hdr.Fs) + etable.sample(j) + pretrig;
  trlend   = (etable.duration(j) * hdr.Fs) + etable.sample(j) + posttrig;
  offset   = pretrig/2;
  newtrl   = [trlbegin trlend offset];
  newevent = etable(j,:); 
  % etrl     = [newtrl newevent];
  event    = [event; newevent];
  trl      = [trl; newtrl];
end

end

end