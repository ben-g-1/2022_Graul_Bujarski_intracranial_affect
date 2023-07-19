function [freq_z] = ft_zscore_pow(freq)
for c = 1:length(freq.label)
  for f = 1:length(freq.freq)
    tmp = freq.powspctrm(:,c,f,:);
    avg = nanmean(tmp(:));
    sd = nanstd(tmp(:));
    freq.powspctrm(:,c,f,:) = (tmp-avg)/sd;
  end
end
freq_z = freq;
end