function [trl] = trl_singlephase(cfg)

% read the header information and import events 
hdr   = ft_read_header(cfg.dataset);
etable = struct2table(cfg.trialdef.event);
eventvalue = cfg.trialdef.eventvalue;

% determine the number of seconds before and after the trigger
pretrig  = -round(cfg.trialdef.pre  * hdr.Fs);
posttrig =  round(cfg.trialdef.post * hdr.Fs);
offset   =  round(cfg.trialdef.offset * hdr.Fs);

% find all trials where phase is 6 for viewing image
% for each trigger except the last one
trl = table();
event = table();
for j = 1:(length(etable.phase))

trg1 = etable.onstim(j);

if trg1 == eventvalue 

  begsample = etable.sample(j) + pretrig;
  endsample   = etable.sample(j) + posttrig;
  offset   = offset;
  newtrl   = table(begsample, endsample, offset);
  newevent = etable(j,:); 
  event    = [event; newevent];
  trl      = [trl; newtrl];
end

end
trl = horzcat(trl, event);
try 
if isequal([trl.begsample], [trl.sample])
    trl = rmfield(trl, 'sample');
end
catch 
    warning('No beg sample')

end
end %function