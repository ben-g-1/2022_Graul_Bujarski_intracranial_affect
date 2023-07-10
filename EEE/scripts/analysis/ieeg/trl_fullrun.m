function [trl, event] = trl_fullrun(cfg)

% read the header information and import events 
hdr   = ft_read_header(cfg.dataset);
etable = struct2table(cfg.trialdef.event);
% eventvalue = cfg.trialdef.eventvalue;

% determine the number of seconds before and after the trigger
% for rating, pretrig determines when the window will begin.
pretrig  = -round(cfg.trialdef.pre  * hdr.Fs);
posttrig =  round(cfg.trialdef.post * hdr.Fs);


trl = [];
event = [];
% for j = 1:(length(etable.phase))

% trg1 = etable.phase(j);

% if trg1 == eventvalue 

  trlbegin = etable.sample(1) + pretrig;
  trlend   = (etable.duration(end) * hdr.Fs) + etable.sample(end) + posttrig;
  offset   = pretrig;
  trl = table(trlbegin, trlend, offset);

  % trl = horzcat(newtrl, etable);

% if isequal([trl.trlbegin], [trl.sample])
%     trl = rmfield(trl, 'sample');
event = etable;
end