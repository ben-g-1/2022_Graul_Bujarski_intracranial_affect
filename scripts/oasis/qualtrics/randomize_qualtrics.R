library(tidyverse)
library(readxl)
library(janitor)

ID <- read_tsv('C:/Users/bgrau/GitHub/git_ieeg_affect/assets/qualtrics/QualtricsID_CLEAN.tsv.txt') %>%
  as_tibble()
ID$CueID <- paste0("<img src=\"https://dartmouth.co1.qualtrics.com/CP/Graphic.php?IM=", ID$CueID, "\">")
ID$StimID <- paste0("<img src=\"https://dartmouth.co1.qualtrics.com/CP/Graphic.php?IM=", ID$StimID, "\">")


for (number in 1: 4) {
  cues <- ID[,1:2]
  stim <- ID[,3:4]
  
  cues <- cues[sample(1:nrow(cues)), ]
  stim <- stim[sample(1:nrow(stim)), ]
  
  randID <- bind_cols(cues, stim)
  write_csv(randID, paste0("QualtricsID_random", number, ".csv"))
  }
done

#<img src="https://dartmouth.co1.qualtrics.com/CP/Graphic.php?IM=$image">
#using Flowers 2 as sample
