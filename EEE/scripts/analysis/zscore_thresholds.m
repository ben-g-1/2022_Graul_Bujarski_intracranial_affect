function [sigelecs, sigelecs_labels] = zscore_thresholds(data, threshtype, thresh)
%% Use as
%     [sigelecs, sigelecs_labels] = zscore_thresholds(data, threshtype, thresh)
% threshtype = 'max'; %'max' or 'min'
% thresh = 0.6;


sigelecs = {};
sigelecs_labels = {};
for c = 1:length(data.label)
    try
  avg = squeeze(nanmean(data.powspctrm(:,c,1,:),1));
    catch
  avg = squeeze(nanmean(data.powspctrm(c,1,:),1));
    end %try
    switch threshtype      
        case 'max'
        if max(avg) > thresh
          sigelecs = [sigelecs data.label{c} c];
          sigelecs_labels = [sigelecs_labels, data.label{c}];
          % plot(data.time, avg)
        end %if
        
        case 'min'
         if min(avg)< thresh
          sigelecs = [sigelecs data.label{c} c];
          sigelecs_labels = [sigelecs_labels, data.label{c}];
          % plot(data.time, avg)
         end %if
    end % casecheck
end %for
end