# ------------------------------------------------------------------------------
# Script: fit_exponential_model_likupang.R
# Purpose: Estimate time to milestone completion based on per capita meeting 
#          frequency using an exponential model, and save model coefficients
# ------------------------------------------------------------------------------

# Clear the R environment
rm(list = ls())

# Load required libraries
library(tidyverse)
library(here)
library(lubridate)
library(readxl)

# ------------------------------------------------------------------------------
# Load preprocessed Likupang data (synthetic version)
# ------------------------------------------------------------------------------

likupang_data_intermed <- read_csv(here("data", "fake_likupang.csv")) %>% 
  janitor::clean_names()

# ------------------------------------------------------------------------------
# Create derived variables
# ------------------------------------------------------------------------------

# Estimate time (in years) to complete all 8 milestones, assuming linear progress:
# Example: 
#   - milestone_score = 8 → 2/8 = 0.25 yrs
#   - milestone_score = 4 → 2/4 = 0.5 yrs
#   - milestone_score = 1 → 2/1 = 2 yrs
likupang_data_intermed <- likupang_data_intermed %>% 
  mutate(expected_time_to_completion_yrs = 2 / milestone_score)

# Calculate per capita meeting frequency (meetings per person per month):
# Meetings occurred over a 3-month period.
likupang_data_intermed <- likupang_data_intermed %>% 
  mutate(per_capita_meeting_frequency = (total_meetings_implemented / 3) / population)

# Optional exploration for scaling (used in model fit below)
likupang_data <- likupang_data_intermed %>% 
  mutate(per_capita_meeting_frequency_x1000 = per_capita_meeting_frequency * 1000)

# ------------------------------------------------------------------------------
# Fit exponential model: expected_time = a * exp(b * frequency) + c
# ------------------------------------------------------------------------------

# Fit the nonlinear least squares model
exponential_likupang_model <- nls(
  expected_time_to_completion_yrs ~ a * exp(b * per_capita_meeting_frequency_x1000) + c,
  data = likupang_data,
  start = list(a = 1, b = -1, c = 0.5)
)

# ------------------------------------------------------------------------------
# Visualize the fitted model
# ------------------------------------------------------------------------------

# Generate smooth prediction curve
x_new <- seq(
  min(likupang_data$per_capita_meeting_frequency_x1000),
  max(likupang_data$per_capita_meeting_frequency_x1000),
  length.out = 100
)
y_pred <- predict(exponential_likupang_model, newdata = data.frame(per_capita_meeting_frequency_x1000 = x_new))

# Plot original data and fitted curve
plot(
  likupang_data$per_capita_meeting_frequency_x1000,
  likupang_data$expected_time_to_completion_yrs,
  main = "Likupang Exponential Model Fit",
  xlab = "Workshops / Month / 1000 People",
  ylab = "Time Required (Years)",
  pch = 16,
  col = "red"
)

lines(x_new, y_pred, col = "blue", lwd = 2)

# Note: this figure can be manually saved if needed

# ------------------------------------------------------------------------------
# Extract and save model coefficients
# ------------------------------------------------------------------------------

# Summarize the fitted model
model_summary <- summary(exponential_likupang_model)
summary(exponential_likupang_model)  # Optional: print to console

# Extract coefficient table (includes Estimate, Std. Error, t value, Pr(>|t|))
coef_info <- as.data.frame(model_summary$coefficients)

# Add a "Term" column for clarity (parameter names)
coef_info$Term <- rownames(coef_info)
coef_info <- coef_info %>%
  select(Term, everything())

# Save coefficients to outputs/ directory
write.csv(
  coef_info,
  here("outputs", "fake_likupang_exponential_model_coefficients.csv"),
  row.names = FALSE
)
