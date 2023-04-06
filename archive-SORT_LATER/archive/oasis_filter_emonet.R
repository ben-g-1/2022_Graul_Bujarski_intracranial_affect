library(tidyverse)

emonet <- read.csv(file = 'C:/Users/bgrau/Matlab/projects/ieeg_affect/oasis/t.txt', sep = ",") %>%
  as_tibble()
emonet_cleaner <- str_replace_all(emonet$Image, ".jpg", "") %>%
  as_tibble()
emonet$Image <- emonet_cleaner
overlap_no_space <- str_remove_all(oasis_no_overlap$Theme, " ") %>%
  as_tibble()
oasis_no_overlap$Theme <- overlap_no_space %>%
  as_tibble()
oasis_no_overlap <- rename(oasis_no_overlap, "Name" = "Theme")
emonet <- rename(emonet, "Name" = "Image")

emonet_no_overlap <- semi_join(emonet, oasis_no_overlap, by = "Name")

emonet_no_overlap
oasis_no_overlap

filter(emonet_no_overlap, Prob> 0.9) 
high_prob <- arrange(emonet_no_overlap, desc(Prob)) %>%
  filter(Prob > .95)

ggplot(data = emonet_no_overlap, mapping = aes(CatNumber)) +
  geom_bar()

ggplot(data = high_prob, mapping = aes(CatNumber)) +
  geom_bar()

        