library(tidyverse)
library(readxl)
library(splitstackshape)

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
r21_pics$Theme <- gsub(".jpg", "", r21_pics$Theme)
oasis_no_overlap <- anti_join(oasis_all, r21_pics, by = 'Theme')



## Create filter sets
filtered <- filter(oasis_no_overlap, Valence_mean >= 2, Valence_mean <= 6,
                   Valence_gender_difference < .8, Valence_SD >= 1,Valence_SD <= 1.5)


filtered_sample <- filter(filtered, filtered$Theme %in% filter_sample)
#NEED TO GET EVEN SAMPLES (16 EACH)
##
two <- filter(filtered, Valence_mean >= 2, Valence_mean < 3)
twos <- sample(two$Theme, 16, replace = FALSE) %>%
  as_tibble() %>%
  rename(Theme = value)
three <- filter(filtered, Valence_mean >= 3, Valence_mean < 4)
threes <- sample(threes$Theme, 16, replace = FALSE) %>%
  as_tibble() %>%
  rename(Theme = value)
four <- filter(filtered, Valence_mean >= 4, Valence_mean < 5)
fours <- sample(four$Theme, 16, replace = FALSE) %>%
  as_tibble() %>%
  rename(Theme = value)
five <- filter(filtered, Valence_mean >= 5, Valence_mean <= 6)
fives <- sample(five$Theme, 16, replace = FALSE) %>%
  as_tibble() %>%
  rename(Theme = value)

weighted_sample_names <- bind_rows(twos, threes, fours, fives)
weighted_all <- semi_join(filtered, weighted_sample_names, by = 'Theme')


 sample_vmean <- mean(weighted_all$Valence_mean)
  sample_vsd <- mean(weighted_all$Valence_SD)
  sample_amean <- mean(weighted_all$Arousal_mean)
  sample_asd <- mean(weighted_all$Arousal_SD)
  desc_stats <- c("Valence Mean =", sample_vmean,
                  "Valence SD = ", sample_vsd,
                  "Arousal Mean = ", sample_amean,
                  "Arousal SD = ", sample_asd)
##

## Write
write.csv(weighted_all, 'weighted.csv')
write_lines(desc_stats, 'weighted_stats.txt')

