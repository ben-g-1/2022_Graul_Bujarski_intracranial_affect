library(tidyverse)
library(readxl)
library(ggplot2)

oasis_all = as_tibble(read_csv("OASIS.csv")) %>%
  rename(Image = '...1')
oasis_gender = as_tibble(read_csv("OASIS_bygender_CORRECTED_092617.csv"))
oasis_gender = select(oasis_gender, !Category)
head(oasis_all)

oasis_filtered = filter(oasis_all, Valence_mean >= 2, Valence_mean <= 6, Valence_SD < 1.5) %>%
  #arrange(desc(Valence_mean)) %>%
  as_tibble()
oasis_filtered_no_sd = filter(oasis_all, Valence_mean >= 2, Valence_mean <= 6)
  
oasis_filtered

## Counts
# count(oasis_all, Valence_SD > 1.5) #50
# count(oasis_all, Valence_mean < 2) #36
# count(oasis_all, Valence_mean > 6) #46
# count(oasis_all, Valence_mean < 2.5) #88
# count(oasis_all, Valence_mean > 5.5) #174
# count(oasis_all, Valence_mean < 3) #162
# count(oasis_all, Valence_mean > 5) #315
# count(oasis_all, Valence_SD < .5)

control_ratings = oasis_filtered

overlap_high = filter(oasis_all, Valence_mean >= 6, Valence_SD > 1.5)
overlap_low = filter(oasis_all, Valence_mean <= 2, Valence_SD > 1.5)
#None on both
#Strong valence (positive or negative) did not have high variability in ratings

oasis_gender_valence_variable = mutate(oasis_gender, Valence_difference = abs(Valence_mean_men - Valence_mean_women)) %>%
  filter(Valence_difference >= 1.5) %>%
  rename(Image = '...1') %>%
  as_tibble()


#Returns 26 rows
#17 are of nude women (universal male preference)
#5 are nude men (universal female preference)
#1 is of a gun (male preference)
#1 is of a wedding ring (female preference)

gender_difference_images <- select(oasis_gender_valence_variable, 'Image')
filtered_images <- select(oasis_filtered, 'Image')
oasis_potential_index = anti_join(filtered_images, gender_difference_images)
oasis_potential_set = right_join(oasis_filtered, oasis_potential_index)
oasis_potential_set_full = left_join(oasis_potential_set, oasis_gender)
#767 pictures

count(oasis_potential_set, Valence_mean > 4.52)
summarise(oasis_potential_set, avg = median(Valence_mean))
ggplot(oasis_potential_set, aes(Valence_mean, Arousal_mean)) +
  geom_point()
