library(tidyverse)
set.seed(110)

ratings_high <- matrix(floor(runif(10*20, min = 2.5, max = 7.1)), ncol = 20, nrow = 10) %>%
  as_tibble()
  
ratings_high_subset <- ratings_high %>%
  select_if(colMeans(.) > 4)
  
ratings_high_mean <- mutate(colMeans(ratings_high))
  # rowwise() %>%
  
ratings_high %>%
  rowwise() %>%
  summarise(mean = mean(ratings_high))


ratings2<- matrix(floor(runif(10, min = 1, max = 7)), ncol = 10, nrow = 64) %>%
  as_tibble()

ggplot(data = ratings_high, mapping = aes(V1)) +
  geom_dotplot(aes(fill = ..x..)) +
  xlim(1, 7) +
  scale_fill_gradientn(colors=rainbow(7))

## THIS ONE
colors <- c("1" = "red",
            "2" = "orange",
            "3" = "yellow",
            "4" = "green",
            "5" = "blue",
            "6" = "violet",
            "7" = "purple")

ggplot(data = ratings_high_subset, mapping = aes(V5)) +
  geom_dotplot(aes(fill = factor(V5))) +
  expand_limits(x = c(1,2,3,4,5,6,7)) +
  scale_x_continuous(breaks = c(1,2,3,4,5,6,7)) +
  coord_fixed() +
  scale_fill_manual(values = colors) +
  xlab("Valence") +
  ylab("Number of Ratings") +
  scale_y_continuous(breaks=NULL) +
  theme(panel.grid.minor=element_blank(),
        panel.grid.major=element_blank()) +
  theme(legend.position = "none")
  
  
ggplot(data = ratings_high_subset, mapping = aes(V5)) +
  geom_dotplot() +
  expand_limits(x = c(1,2,3,4,5,6,7)) +
  scale_x_continuous(breaks = c(1,2,3,4,5,6,7)) +
  coord_fixed() +
  #scale_fill_manual(values = colors) +
  xlab("Valence") +
  ylab("Number of Ratings") +
  geom_vline(aes(xintercept=mean(V5)), colour="red", linetype="dashed") +
  scale_y_continuous(breaks=NULL) +
  theme(panel.grid.minor=element_blank(),
        panel.grid.major=element_blank()) #+
  theme(legend.position = "none")


##
ggplot(data = ratings_high_subset, mapping = aes(V4)) +
  geom_dotplot() 
  #scale_fill_gradientn(colors=rainbow(7))


# Load the jpeg images
img1 <- readPNG("~/GitHub/git_ieeg_affect/Task/Ratings/1_verynegative.png")
img2 <- readPNG("~/GitHub/git_ieeg_affect/Task/Ratings/2_modnegative.png")
img3 <- readPNG("~/GitHub/git_ieeg_affect/Task/Ratings/3_somenegative.png")

# Generate some random data
data <- sample(1:3, 50, replace = TRUE)

# Create the dotplot
dotchart(data) +

# Add the images to the plot
rasterImage(img1, 1, 1, 3, 3)
rasterImage(img2, 70, 10, 50, 50)
rasterImage(img3, 130, 10, 50, 50)


data <- tibble(x = sample(1:3, 50, replace = TRUE))

# Create the dotplot
ggplot(data = ratings, mapping = aes(V3)) +
  geom_dotplot() +
  scale_shape_manual(values = c(img1, img2, img3))

?shape_manual

sample <- floor(runif(n = 64, min = 1, max = 699))
oasis_set <-  read_csv("~/GitHub/git_ieeg_affect/oasis/Oasis_no_overlap.csv")
oasis_sample <- sample_n(oasis_set, 64)
oasis_sample
mean(oasis_sample$Valence_mean)
mean(oasis_set$Valence_mean)

ggplot(oasis_sample, aes(Valence_mean)) +
  geom_density()

ggplot(oasis_set, aes(Valence_mean)) +
  geom_density()


ggplot(data = ratings_high_long, aes(x = variable, y = value)) +
       geom_dotplot(aes(fill = ..x..)) +
       scale_fill_gradientn(colors=rainbow(7)) +
       facet_wrap(~variable, scales = "free_y")


##
data_frames_list <- split(data_frame, names(data_frame))