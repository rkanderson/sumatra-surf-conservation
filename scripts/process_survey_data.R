# ------------------------------------------------------------------------------
# Script: clean_wtp_survey_data.R
# Purpose: Clean and summarize surf tourism survey data related to:
#          - General expenditure
#          - Willingness to pay (WTP) for conservation efforts
#          - WTP for crowd management
# ------------------------------------------------------------------------------

# Clear the workspace
rm(list = ls())

# Load required libraries
library(tidyverse)
library(here)
library(lubridate)
library(readxl)
library(knitr)
library(kableExtra)

# ------------------------------------------------------------------------------
# Load survey data (English and Spanish responses)
# ------------------------------------------------------------------------------

path <- here("data", "survey_responses_raw.xlsx")

surf_survey <- read_excel(path, sheet = "Form Responses Eng_Survey") %>%
  janitor::clean_names()

surf_survey_spanish <- read_excel(path, sheet = "Form Responses Spanish_Survey") %>%
  janitor::clean_names()

# ------------------------------------------------------------------------------
# Select relevant columns:
# Column 16 = Expenditure
# Column 20 = WTP for crowd management
# Column 24 = WTP for conservation
# ------------------------------------------------------------------------------

surf_wtp_english <- surf_survey[, c(16, 20, 24)]
colnames(surf_wtp_english) <- c("wtp_expenditure", "wtp_crowd", "wtp_cons")

surf_wtp_spanish <- surf_survey_spanish[, c(16, 20, 24)]
colnames(surf_wtp_spanish) <- c("wtp_expenditure", "wtp_crowd", "wtp_cons")

# Combine English and Spanish responses into one dataset
surf_wtp <- bind_rows(surf_wtp_english, surf_wtp_spanish)

# ------------------------------------------------------------------------------
# Convert expenditure ranges to numeric midpoints
# (e.g., "$2,500 to $5,000" → 3750)
# ------------------------------------------------------------------------------

surf_wtp_processed <- surf_wtp %>%
  mutate(wtp_expenditure = case_when(
    wtp_expenditure == "Less than $500" | wtp_expenditure == "Menos de $500" ~ 250,
    wtp_expenditure == "$500 to $1,000" | wtp_expenditure == "$500 a $1,000" ~ 750,
    wtp_expenditure == "$1,000 to $2,500" | wtp_expenditure == "$1,000 a $2,500" ~ 1750,
    wtp_expenditure == "$2,500 to $5,000" | wtp_expenditure == "$2,500 a $5,000" ~ 3750,
    wtp_expenditure == "More than $5,000" | wtp_expenditure == "Más de $5,000" ~ 5000
  ))

# ------------------------------------------------------------------------------
# Extract numeric values from WTP strings
# If a range is given, extract the upper bound (right-most number)
# ------------------------------------------------------------------------------

surf_wtp_processed <- surf_wtp_processed %>%
  mutate(wtp_crowd = str_extract(wtp_crowd, "\\d+"),
         wtp_cons  = str_extract(wtp_cons, "\\d+")) %>%
  mutate(across(c(wtp_crowd, wtp_cons), as.numeric))

# ------------------------------------------------------------------------------
# Plot histograms of WTP values (Conservation & Crowd Management)
# ------------------------------------------------------------------------------

ggplot(surf_wtp_processed, aes(x = wtp_cons)) +
  geom_histogram() +
  labs(title = "WTP Conservation Fee Distribution",
       x = "WTP Conservation Fee (USD)",
       y = "Frequency")

ggplot(surf_wtp_processed, aes(x = wtp_crowd)) +
  geom_histogram() +
  labs(title = "WTP Crowd Management Distribution",
       x = "WTP Crowd Management (USD)",
       y = "Frequency")

# ------------------------------------------------------------------------------
# Identify and remove outliers (e.g., WTP > $8,000 likely input error)
# ------------------------------------------------------------------------------

surf_wtp_processed %>%
  filter(wtp_cons > 8000)

surf_wtp_processed <- surf_wtp_processed %>%
  filter(wtp_cons <= 8000)

# ------------------------------------------------------------------------------
# Compute summary statistics: mean and median for each variable
# ------------------------------------------------------------------------------

surf_wtp_summary <- surf_wtp_processed %>%
  summarize_all(list(
    mean = ~mean(.x, na.rm = TRUE),
    median = ~median(.x, na.rm = TRUE)
  ))

# Format and display summary as a table
surf_wtp_summary %>%
  rename(
    "WTP General Expenditure Mean" = wtp_expenditure_mean,
    "WTP Crowd Management Mean" = wtp_crowd_mean,
    "WTP Conservation Fee Mean" = wtp_cons_mean,
    "WTP General Expenditure Median" = wtp_expenditure_median,
    "WTP Crowd Management Median" = wtp_crowd_median,
    "WTP Conservation Fee Median" = wtp_cons_median
  ) %>%
  select(
    "WTP General Expenditure Mean", "WTP General Expenditure Median",
    "WTP Crowd Management Mean", "WTP Crowd Management Median",
    "WTP Conservation Fee Mean", "WTP Conservation Fee Median"
  ) %>%
  kable() %>%
  kable_classic()

# ------------------------------------------------------------------------------
# Generate histograms for all three WTP variables
# ------------------------------------------------------------------------------

plot_hist_wtp_cons <- ggplot(surf_wtp_processed, aes(x = wtp_cons)) +
  geom_histogram() +
  labs(title = "WTP Conservation Fee Distribution",
       x = "WTP Conservation Fee (USD)",
       y = "Frequency")

plot_hist_wtp_crowd <- ggplot(surf_wtp_processed, aes(x = wtp_crowd)) +
  geom_histogram() +
  labs(title = "WTP Crowd Management Distribution",
       x = "WTP Crowd Management (USD)",
       y = "Frequency")

plot_hist_wtp_expenditure <- ggplot(surf_wtp_processed, aes(x = wtp_expenditure)) +
  geom_histogram() +
  labs(title = "WTP General Expenditure Distribution",
       x = "WTP General Expenditure (USD)",
       y = "Frequency")

# ------------------------------------------------------------------------------
# Save histogram plots to /figures folder
# ------------------------------------------------------------------------------

if (!dir.exists(here("figures"))) dir.create(here("figures"))

ggsave(here("figures", "hist_wtp_cons.png"), plot_hist_wtp_cons, width = 6, height = 4)
ggsave(here("figures", "hist_wtp_crowd.png"), plot_hist_wtp_crowd, width = 6, height = 4)
ggsave(here("figures", "hist_wtp_expenditure.png"), plot_hist_wtp_expenditure, width = 6, height = 4)

# ------------------------------------------------------------------------------
# Create box plots for all three variables combined
# ------------------------------------------------------------------------------

plot_box_wtp_all <- surf_wtp_processed %>%
  pivot_longer(cols = c(wtp_expenditure, wtp_crowd, wtp_cons),
               names_to = "WTP Type", values_to = "WTP Value") %>%
  mutate(`WTP Type` = case_when(
    `WTP Type` == "wtp_cons" ~ "Conservation Fee",
    `WTP Type` == "wtp_crowd" ~ "Crowd Management Fee",
    `WTP Type` == "wtp_expenditure" ~ "General Trip Expenditure"
  )) %>%
  ggplot(aes(x = 0, y = `WTP Value`)) +
  geom_boxplot() +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 3, fill = "red") +
  labs(title = "WTP Box Plots",
       y = "USD") +
  facet_wrap(~`WTP Type`, scales = "free_y") +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank())

# Save box plot to file
ggsave(here("figures", "box_wtp_all.png"), plot_box_wtp_all, width = 6, height = 4)

# ------------------------------------------------------------------------------
# End of script
# ------------------------------------------------------------------------------
