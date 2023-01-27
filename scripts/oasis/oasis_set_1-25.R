library(tidyverse)
library(readxl)

## Import Data 
oasis_initial = as_tibble(read_csv("OASIS.csv")) %>%
  rename(Image = '...1')
oasis_gender = as_tibble(read_csv("OASIS_bygender_CORRECTED_092617.csv")) %>%
  rename(Image = '...1') %>%
  select(!Category) %>% #Removed to allow join- maintains category string descriptor
  mutate(oasis_initial, Valence_gender_difference = abs(Valence_mean_men - Valence_mean_women))
oasis_all <- left_join(oasis_initial, oasis_gender) %>%
  as_tibble()
oasis_all$Theme <-   gsub(" ", "_", oasis_all$Theme)
filtered <- filter(oasis_all, Valence_mean >= 2, Valence_mean <= 6, Valence_gender_difference < .6, Valence_SD >= 1.17,Valence_SD <= 1.22) %>%
  as_tibble()
names <- filtered$Theme




##
mean(filtered$Valence_mean)
low <- filter(filtered, Valence_mean <=  4.326383)
high <- filter(filtered, Valence_mean >=  4.277301)

##
write.csv(names, '1-25_filter_list.csv')
write_csv(filtered, '1-25_filter.csv')
