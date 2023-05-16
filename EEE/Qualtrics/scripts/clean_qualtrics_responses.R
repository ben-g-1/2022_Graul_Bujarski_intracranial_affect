library(tidyverse)
library(readxl)

# Import
pilot_1a <- read_excel("C:/Users/bgrau/GitHub/ieeg_affect/EEE/Qualtrics/data/pilot_1a.xlsx")
pilot_1a <- pilot_1a[-c(1),] %>%
  as_tibble()
  
  

# Remove columns with only 'empty' values
pilot_1a = Filter(function(x)!all(is.na(x)), pilot_1a)

# Filter to only ratings
pilot_1a <- pilot_1a %>%
  select(contains('_Q')) %>%
  select(!contains('click')) %>%
  select(!contains('page'))

# Ensure values are numerical
pilot_1a[] <- lapply(pilot_1a, function(x) if(is.character(x)) as.numeric(x) else x)

pilot_1a_exp <- pilot_1a %>%
  select(contains('.3'))

pilot_1a_img <- pilot_1a %>%
  select(contains('.5'))

# a1_img <- transmute(rowwise(pilot_1a_img), average = list(mean)

new_names <- paste0("Image_", 1:ncol(pilot_1a_img))

# Assign new column names to the matrix
colnames(pilot_1a_img) <- new_names

# Interpolate average column values for NAs 
Matrix1[] <- apply(pilot_1a_img, 2, function(x) ifelse(is.na(x), mean(x, na.rm = TRUE), x))
  summarize(Matrix1, across(everything(), mean))


Matrix2[] <- apply(pilot_1#b_img, 2, function(x) ifelse(is.na(x), mean(x, na.rm = TRUE), x))
summarize(Matrix2, across(everything(), mean))

# Perform paired t-tests on each pair of columns
p_values <- vector()
for (i in 1:ncol(Matrix1)) {
  ttest <- t.test(Matrix1[,i], Matrix2[,1], paired = TRUE)
  p_values[i] <- ttest$p.value
}

# Adjust p-values for multiple comparisons using the Benjamini-Hochberg procedure
adjusted_pvalues <- p.adjust(p_values, method = "BH")

# Perform two-sample t-test on the means of the two matrices
ttest_means <- t.test(colMeans(Matrix1), colMeans(Matrix2))

# Check if each pair of columns is significantly different from one another
for (i in 1:ncol(Matrix1)) {
  if (adjusted_pvalues[i] < 0.05) {
    cat("Column", i, "in Matrix1 is significantly different from Column A in Matrix2\n")
  } else {
    cat("Column", i, "in Matrix1 is not significantly different from Column A in Matrix2\n")
  }
}

# Check if the overall matrix averages are not significantly different
if (ttest_means$p.value >= 0.05) {
  cat("The overall matrix averages are not significantly different\n")
} else {
  cat("The overall matrix averages are significantly different\n")
}
