# ------------------------------------------------------------------------------
# Script: generate_fake_likupang_data.R
# Purpose: Create a synthetic dataset mimicking the Likupang structure
# ------------------------------------------------------------------------------

# Clear environment
rm(list = ls())

# Load libraries
library(tidyverse)
library(here)

# Create the 'data' directory if it doesn't exist
if (!dir.exists(here("data"))) dir.create(here("data"))

# Set random seed for reproducibility
set.seed(42)

# Define number of rows
n <- 50

# Generate synthetic data
fake_likupang <- tibble(
  milestone_score = pmin(pmax(rnorm(n, mean = 4, sd = 1.2), 0), 8),
  population = round(rnorm(n, mean = 1000, sd = 500)),
  total_meetings_implemented = rpois(n, lambda = 4)
)

# Ensure no negative populations
fake_likupang <- fake_likupang %>%
  mutate(population = ifelse(population < 0, 0, population))

# Save to data/ directory
write_csv(fake_likupang, here("data", "fake_likupang.csv"))

message("Fake dataset saved to data/fake_likupang.csv")
