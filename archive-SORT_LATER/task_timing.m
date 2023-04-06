fixation = seconds(2);
stimcue = seconds(4);
rate = seconds(5);
rest = seconds(240);
teach = seconds(180);
debrief = seconds(180);

trial = (8*(2*stimcue+2*rate+2*fixation))
trialrest = trial + rest
fullrun = 8*trialrest + teach + debrief
minutes(fullrun)