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

## Remove pictures used in Kris's task
r21 <- as_tibble(read_csv("R21AMY_behavior.csv"))
r21_pics <- distinct(r21, Name) %>%
  rename(Theme = Name)
r21_pics$Theme <-   gsub(" ", "_", r21_pics$Theme)
oasis_no_overlap <- anti_join(oasis_all, r21_pics, by = 'Theme')

## Create filter sets
filtered <- filter(oasis_no_overlap, Valence_mean >= 2, Valence_mean <= 6, Valence_gender_difference < .8) 
#%>% 
  #, Valence_SD >= 1.17,Valence_SD <= 1.25) %>%
  #as_tibble()

##
filter_sample <- sample(filtered$Theme, 65, replace = FALSE)# %>%
  # as_tibble() %>%
  # rename(Theme = value)
filtered_sample <- filter(filtered, filtered$Theme %in% filter_sample)
 sample_vmean <- mean(filtered_sample$Valence_mean)
  sample_vsd <- mean(filtered_sample$Valence_SD)
  sample_amean <- mean(filtered_sample$Arousal_mean)
  sample_asd <- mean(filtered_sample$Arousal_SD)
  desc_stats <- c("Valence Mean =", sample_vmean,
                  "Valence SD = ", sample_vsd,
                  "Arousal Mean = ", sample_amean,
                  "Arousal SD = ", sample_asd)
##
  
names <- as_tibble(filtered_sample$Theme) #%>%
  #as_data_frame()

## Write
write_csv(names, '1-27_filter_list.csv')
write_csv(filter_sample, '1-27_filter_order.csv')
write_csv(filtered_sample, '1-27_filter.csv')
write_lines(desc_stats, '1-27_filter_stats.txt')
