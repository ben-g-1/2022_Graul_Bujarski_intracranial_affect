library(tidyverse)
library(readxl)

## Import Data 
oasis_initial = as_tibble(read_csv("OASIS.csv")) %>%
  rename(Image = '...1')
oasis_gender = as_tibble(read_csv("OASIS_bygender_CORRECTED_092617.csv")) %>%
  rename(Image = '...1') %>%
  select(!Category) %>% #Removed to allow join- maintains category string descriptor
  mutate(oasis_initial, Valence_gender_difference = abs(Valence_mean_men - Valence_mean_women))
oasis_all = left_join(oasis_initial, oasis_gender) 
oasis_filtered = filter(oasis_all, Valence_mean >= 2, Valence_mean <= 6, Valence_SD < 1.5) %>%
  as_tibble()

oasis_filtered_no_sd = filter(oasis_all, Valence_mean >= 2, Valence_mean <= 6)

## Data Exploration 
# count(oasis_all, Valence_SD > 1.5) #50
# count(oasis_all, Valence_mean < 2) #36
# count(oasis_all, Valence_mean > 6) #46
# count(oasis_all, Valence_mean < 2.5) #88
# count(oasis_all, Valence_mean > 5.5) #174
# count(oasis_all, Valence_mean < 3) #162
# count(oasis_all, Valence_mean > 5) #315
# count(oasis_all, Valence_SD < .5)
count(oasis_filtered, Valence_mean <= 4.52)

# filter(oasis_all, Valence_mean >= 6, Valence_SD > 1.5)
# filter(oasis_all, Valence_mean <= 2, Valence_SD > 1.5)
#None on both
#Strong valence (positive or negative) did not have high variability in ratings

## Determining images with high gender variability
oasis_gender_valence_variable = mutate(oasis_all, Valence_difference = abs(Valence_mean_men - Valence_mean_women)) %>%
  filter(Valence_difference >= 1) %>%
  as_tibble()
#Returns 26 rows
#17 are of nude women (universal male preference)
#5 are nude men (universal female preference)
#1 is of a gun (male preference)
#1 is of a wedding ring (female preference)

oasis_filtered_2 = filter(oasis_all, Valence_mean >= 2, Valence_mean <= 6, Valence_SD < 1.5) %>%
  mutate(Valence_difference = abs(Valence_mean_men - Valence_mean_women)) %>%
  filter(Valence_difference <= 1.3) %>%
  as_tibble()

gender_difference_images <- select(oasis_gender_valence_variable, 'Image')
filtered_images <- select(oasis_filtered, 'Image')
oasis_potential_index = anti_join(filtered_images, gender_difference_images)
oasis_potential_set = right_join(oasis_filtered, oasis_potential_index)
oasis_potential_set_full = left_join(oasis_potential_set, oasis_gender) 
# write_csv(oasis_potential_set_full, "Oasis_potential_set.csv")
#767 pictures

## Remove pictures used in Kris's task
r21 <- as_tibble(read_csv("R21AMY_behavior.csv"))
r21_pics <- distinct(r21, Name) %>%
  rename(Theme = Name)
oasis_no_overlap <- anti_join(oasis_potential_set, r21_pics, by = 'Theme')


count(oasis_potential_set, Valence_mean > 4.52)

ggplot(oasis_potential_set, aes(Valence_mean, Arousal_mean, color = Valence_SD)) +
  geom_jitter() +
  scale_color_gradientn(colors = rainbow(4)) +
  labs(title = "Proposed Oasis Set")

ggplot(oasis_no_overlap, aes(Valence_mean, Arousal_mean, color = Valence_SD)) +
  geom_jitter() +
  scale_color_gradientn(colors = rainbow(4)) +
  labs(title = "Proposed Oasis Set Without R21 Pics")

ggplot(oasis_all, aes(Valence_mean, Arousal_mean, color = Valence_gender_difference)) +
  geom_jitter() +
  scale_color_gradientn(colors = rainbow(4)) +
  labs(title = "Difference in Valence Ratings Based on Gender")

ggplot(oasis_all, aes(Valence_mean, Arousal_mean, color = Valence_SD)) +
  geom_jitter() +
  scale_color_gradientn(colors = rainbow(4)) +
  labs(title = "Distribution of Valence Scores for Full Oasis Set")


## Write to .csv
oasis_file_names = (select(oasis_potential_set_full, Theme))
oasis_file_names = gsub(" ", "_", oasis_file_names$Theme)
oasis_file_names = as_tibble(oasis_file_names)
# write_csv(oasis_file_names, "oasis_file_names.csv")
