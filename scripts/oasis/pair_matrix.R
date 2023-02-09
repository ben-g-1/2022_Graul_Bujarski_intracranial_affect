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
oasis_all$Image <- gsub("I", "", oasis_all$Image)

## Remove pictures used in Kris's task
r21 <- as_tibble(read_csv("R21AMY_behavior.csv"))
r21_pics <- distinct(r21, Name) %>%
  rename(Theme = Name)
r21_pics$Theme <-   gsub(" ", "_", r21_pics$Theme)
r21_pics$Theme <- gsub(".jpg", "", r21_pics$Theme)
oasis_no_overlap <- anti_join(oasis_all, r21_pics, by = 'Theme')
oasis_no_overlap <- type_convert(oasis_no_overlap)

## Read in preselected pairs, filter
pairs <- read_csv('pair_numbers.csv', col_names = FALSE) %>%
  as_tibble() %>%
  rename(Image = 'X1')
pair_matrix <- semi_join(oasis_no_overlap, pairs, by = 'Image')

#Descriptive Stats
sample_vmean <- mean(pair_matrix$Valence_mean)
sample_vsd <- mean(pair_matrix$Valence_SD)
sample_amean <- mean(pair_matrix$Arousal_mean)
sample_asd <- mean(pair_matrix$Arousal_SD)
desc_stats <- c("Valence Mean =", sample_vmean,
                "Valence SD = ", sample_vsd,
                "Arousal Mean = ", sample_amean,
                "Arousal SD = ", sample_asd)

ggplot(pair_matrix, aes(Valence_mean, Arousal_mean, color = Valence_SD)) +
  geom_jitter() +
  scale_color_gradientn(colors = rainbow(4)) +
  labs(title = "Distribution of Valence Scores for Paired Oasis Set")

write_csv(pair_matrix, 'pair_matrix.csv')

