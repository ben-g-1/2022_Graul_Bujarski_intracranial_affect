lme = fitlme(master, 'img_rate ~ ')
%%
load flu
flu2 = stack(flu,2:10,'NewDataVarName','FluRate',...
    'IndVarName','Region');
flu2.Date = nominal(flu2.Date);

flu2 = dataset2table(flu2);

plot(flu2.WtdILI,flu2.FluRate,'ro')
xlabel('WtdILI')
ylabel('Flu Rate')

lme = fitlme(flu2,'FluRate ~ 1 + WtdILI + (1|Date)')

figure();
plotResiduals(lme,'fitted')

find(residuals(lme) > 1.5)

lme = fitlme(flu2,'FluRate ~ 1 + WtdILI + (1|Date)','Exclude',[98,107]);

%%

plot(master.cue_observed_mean, master.img_rate, 'ro');
xlabel('Observed Mean Score')
ylabel('Valence Rating')

figure;
plot(master.Valence_mean, master.img_rate, 'go');
xlabel('Normative Mean Score')
ylabel('Valence Rating')
%%

lme = fitlme(master, 'img_rate ~ Valence_mean + (Pair|subj) + (1 - highcue_indx| Pair)')

figure();
plotResiduals(lme, 'fitted')