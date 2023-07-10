figure; imagesc(OUT.t); 

colorbar
set(gca, 'YDir', 'normal');
set(gca, 'FontSize', 24)
scn_export_papersetup(400);
ylabel('Frequency');
xlabel('Time');
title('t-values for h - L within pair')
set(gca, 'YTick', 1:5:28, 'YTickLabel', imgview_freq.freq);

%%
t_thresh = OUT.t; t_thresh(OUT.p > 0.05) = 0;
t_thresh(isnan(t_thresh)) = 0;
figure;
imagesc(t_thresh)
colorbar
set(gca, 'YDir', 'normal');
set(gca, 'FontSize', 24)
scn_export_papersetup(400);
ylabel('Frequency');
xlabel('Time');
title('t-values for h - L within pair')
set(gca, 'YTick', 1:5:28, 'YTickLabel', imgview_freq.freq);
cm = colormap_tor([0 0 1], [1 1 0], [.7 .7 .7]);
colormap(cm)

%%
figure; hold on;
% y = [mean(sub1pairtable.lo_cue) mean(sub1pairtable.rating_diff); mean(sub2pairtable.lo_cue)  ...
%      mean(sub2pairtable.rating_diff); mean(sub3pairtable.lo_cue) mean(sub3pairtable.rating_diff)];
% bar(y, 'stacked')
y = [mean(sub1pairtable.rating_diff) mean(sub2pairtable.rating_diff) mean(sub3pairtable.rating_diff)];
bar([1 2 3], y)
% errlow = [sub1ci(1), sub2ci(1), sub3ci(1)];
% errhigh = [sub1ci(2), sub2ci(2), sub3ci(2)];
errlow = [mean(sub1pairtable.rating_diff)-sub1SE, mean(sub2pairtable.rating_diff)-sub2SE, mean(sub3pairtable.rating_diff)-sub3SE]
errhigh = [mean(sub1pairtable.rating_diff)+sub1SE, mean(sub2pairtable.rating_diff)+sub2SE, mean(sub3pairtable.rating_diff)+sub3SE]

% er = errorbar([1:3],[mean(sub1pairtable.hi_cue),mean(sub2pairtable.hi_cue), mean(sub3pairtable.hi_cue)],errlow,errhigh);
% er = errorbar([1:3],[mean(sub1pairtable.rating_diff) mean(sub2pairtable.rating_diff) mean(sub3pairtable.rating_diff)],errlow,errhigh);
er = errorbar([1:3],[mean(sub1pairtable.rating_diff) mean(sub2pairtable.rating_diff) mean(sub3pairtable.rating_diff)],[sub1SE sub2SE sub3SE]);

er.Color = [0 0 0];                            
er.LineStyle = 'none'; 
er.LineWidth = 2;

set(gca, 'FontSize', 32)
scn_export_papersetup(400);
% ylim([0 
ylabel('Percent Increase', 'FontWeight', 'bold');
xlabel('Subject Number', 'FontWeight', 'bold');
% title('Positive Social Cues Increase Reported Valence')
set(gca, 'XTick', 1:3, 'XTickLabel', [1 2 3]);
drawnow()
% exportgraphics()