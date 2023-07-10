indx = stim_table.highcue_indx + 2;
stim_table.demeaned_rating = stim_table.val_rating - stim_table.Valence_mean;

% pair_table.cue_response = [];
for i = 1:numel(pair_table)
    if pair_table.hi_val(i) > pair_table.lo_val(i)  
        pair_table.cue_response(i) = 1;
    elseif pair_table.hi_val(i) < pair_table.lo_val(i)
        pair_table.cue_response(i) = 2;
    elseif pair_table.hi_val(i) == pair_table.lo_val(i)
        pair_table.cue_response(i) = 3;
    end

end
%%
close(gcf)
g = gramm('x', pair_table.pair_number, 'y', d, 'color', pair_table.cue_response);
    % g.stat_violin('fill', 'transparent');
    g.geom_point();
    g.set_names('x', 'High vs. Low Cue', 'y', 'Valence Rating');
    g.draw();

%%
stim_table = table2struct(stim_table);
for i = 1:numel(stim_table)
    if stim_table(i).highcue_indx == 1
        stim_table(i).highcue_indx = 'High';
    elseif stim_table(i).highcue_indx == -1
        stim_table(i).highcue_indx = 'Low';
    end
end
%%
close(gcf)
g = gramm('x', {stim_table.Pair}, 'y', {stim_table.demeaned_rating}, 'color', {stim_table.highcue_indx});
    % g.stat_violin();
    g.geom_point();
    g.set_names('x', 'Low Cue vs. High Cue', 'y', 'Valence Rating', 'color', 'Cue Type');
    g.draw();

    %%
    cuecolors = {[1 0 0] [0 0 1]};


y = [pair_table.hi_val pair_table.lo_val];  % ratings, [high low]
x = [pair_table.pair_number pair_table.pair_number];  % pairs, [high low]


highdots = plot(x(:, 1), y(:, 1), 'o', 'MarkerFaceColor', cuecolors{1}); hold on;

lowdots = plot(x(:, 2), y(:, 2), 'o', 'MarkerFaceColor', cuecolors{2}); 

meandots = plot(pair_table.cue_mean, 'o', 'MarkerFaceColor', 'g');


d = -(diff(y')'); % h - l difference scores for matched pairs

wh_hvsl = d > 0;
line = plot(x(wh_hvsl, :)', y(wh_hvsl, :)', 'k-');
line = plot(x(~wh_hvsl, :)', y(~wh_hvsl, :)', '-', 'Color', [.7 .4 .4]);

xlabel('Pair Number');
ylabel('Valence Rating (unp to pleasant)')
axis([0 33 0 135])
legend([highdots lowdots meandots], {'High Cue', 'Low Cue', 'Normative Rating'})

hold off;
