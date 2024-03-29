%% Kris Current Memory Task Time
mem_blocks = 8;
mem_breaks = 7;
mem_breaktime = 60;
mem_pictures = 64;
mem_trialtime = 10;

memtasktime = ((mem_pictures * mem_trialtime) + (mem_breaks * mem_breaktime)) / 60

%% Expectation and Affect Task Time
exaf_blocks = 6;
exaf_breaks = exaf_blocks - 1;
exaf_breaktime = 60;
exaf_pictures = 48;
exaf_trialtime = 10;
exaf_picsperblock = exaf_pictures / exaf_blocks

exaf_tasktime = ((exaf_pictures * exaf_trialtime) + (exaf_breaks * exaf_breaktime)) / 60
exaf_blocktime = exaf_trialtime * exaf_picsperblock
