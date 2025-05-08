

# Clear env
rm(list = ls())

# Load libraries
library(tidyverse)
library(here)


percent_reductions <- seq(10, 90, by = 10)

# Re-do with tidyverse operations %>%
values_df <- data.frame(
  percent_reduction = percent_reductions
) %>%
  mutate(alpha = 1-(percent_reduction / 100),
         A = (alpha - 1) * 3046 + alpha * 500,
         annual_diff_ments = 1500 * A,
         discounted_diff_ments = annual_diff_ments / (1 - 0.0682))

# display as kable
values_df %>%
  select(percent_reduction, A, discounted_diff_ments) %>%
  rename(`% Annual Guest Reduction` = percent_reduction, `Per Surfer Annual Difference (USD)`=A, `Discounted Difference in Value (USD) for 1500 Surfers Annually` = discounted_diff_ments) %>%
  kable() %>%
  kable_classic()


# ------------------------------------------------------------------------------
# Script: generate_discounted_economic_table.R
# Purpose: Create a clean scenario table with adjustable parameters
# ------------------------------------------------------------------------------

# Load libraries
library(tidyverse)
library(kableExtra)

# ------------------------------------------------------------------------------
# Adjustable Parameters
# ------------------------------------------------------------------------------

# Percentage reductions in tourist numbers (in %)
percent_reductions <- seq(10, 90, by = 10)

# Baseline expenditure per surfer (USD)
baseline_expenditure <- 3046

# Additional fees per surfer (USD)
additional_fee <- 500

# Number of surfers affected per year
n_surfers_per_year <- 1500

# Discount rate (as a decimal)
discount_rate <- 0.0682

# Discount multiplier (assuming perpetuity or fixed method)
discount_multiplier <- 1 / (1 - discount_rate)

# ------------------------------------------------------------------------------
# Create table using tidyverse
# ------------------------------------------------------------------------------

values_df <- tibble(
  percent_reduction = percent_reductions
) %>%
  mutate(
    alpha = 1 - (percent_reduction / 100),
    A = (alpha - 1) * baseline_expenditure + alpha * additional_fee,
    annual_diff_ments = n_surfers_per_year * A,
    discounted_diff_ments = annual_diff_ments * discount_multiplier
  )

# ------------------------------------------------------------------------------
# Create and display final formatted table
# ------------------------------------------------------------------------------

final_kable <- values_df %>%
  select(percent_reduction, A, discounted_diff_ments) %>%
  rename(
    `% Annual Guest Reduction` = percent_reduction,
    `Per Surfer Annual Difference (USD)` = A,
    `Discounted Difference in Value (USD) for 1500 Surfers Annually` = discounted_diff_ments
  ) %>%
  kable(format = "html", digits = 0) %>%
  kable_classic(full_width = FALSE)


# Show kable
final_kable

# Load webshot2
library(webshot2)

# Create figures directory if it doesn't exist
if (!dir.exists("figures")) dir.create("figures")

# Save the kable to a temporary HTML file
temp_html <- tempfile(fileext = ".html")
save_kable(final_kable, file = temp_html)

# Save the HTML as a PNG image in the figures/ directory
webshot(temp_html, file = here("figures", "economic_scenario_table.png"), zoom = 2, vwidth = 1000)

# Optional: print confirmation
message("Table saved to figures/economic_scenario_table.png")
