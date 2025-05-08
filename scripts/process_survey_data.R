

# This scripts takes the excel containing the surf tourism survey results and 
# selects the fields for general expenditure, WTP for conservation efforts, 
# and WTP crowd management, and cleans the dataset



# clear env
rm(list=ls())

# load libs
library(tidyverse)
library(here)
library(lubridate)
library(readxl)
library(knitr)
library(kableExtra)



# Load data
# here("benefits_analysis", "data_raw", "Surf in West Sumatra Survey (Responses).xlsx")
# we have an excel file, want to read the tabs
# "Form Responses 1 Eng_Survey"
# Form Responses Spanish_Survey

path <- here("data", "survey_responses_raw.xlsx")

surf_survey <- read_excel(path, sheet = "Form Responses Eng_Survey") %>% 
  janitor::clean_names()

surf_survey_spanish <- read_excel(path, sheet = "Form Responses Spanish_Survey") %>%
  janitor::clean_names()



# get the colnames of the surveys
# colnames(surf_survey)
# colnames(surf_survey_spanish)
# we want column number 16 (wtp_expenditure), column number 20 (wtp_crowd), 24 (wtp_cons)

# grab these columns
surf_wtp_english <- surf_survey[, c(16, 20, 24)]

# force them to have the names above
colnames(surf_wtp_english) <- c("wtp_expenditure", "wtp_crowd", "wtp_cons")

# do the same for the spanish survey
surf_wtp_spanish <- surf_survey_spanish[, c(16, 20, 24)]
colnames(surf_wtp_spanish) <- c("wtp_expenditure", "wtp_crowd", "wtp_cons")

# combine the two datasets
surf_wtp <- bind_rows(surf_wtp_english, surf_wtp_spanish)




# Now we're going to write some code to process the wtp data to be more numeric
# So for the wtp_expenditure we're going to have a set of cases where we set the value to be the halfway point
# for example 2500-5000 will be 3750

# The options you can choose are 
# Less than $500
# $500 to $1,000
# $1,000 to $2,500
# $2,500 to $5,000
# More than $5,000
# and spanish equivalents
# Menos de $500
# $500 a $1,000
# $1,000 a $2,500
# $2,500 a $5,000
# Más de $5,000

# We'll set the values to be the halfway point of the range.
# Note: we'll set the first one to be 250, and the last one to be 7500

surf_wtp_processed <- surf_wtp %>% 
  mutate(wtp_expenditure = case_when(
    wtp_expenditure == "Less than $500" | wtp_expenditure == "Menos de $500" ~ 250,
    wtp_expenditure == "$500 to $1,000" | wtp_expenditure == "$500 a $1,000" ~ 750,
    wtp_expenditure == "$1,000 to $2,500" | wtp_expenditure == "$1,000 a $2,500" ~ 1750,
    wtp_expenditure == "$2,500 to $5,000" | wtp_expenditure == "$2,500 a $5,000" ~ 3750,
    wtp_expenditure == "More than $5,000" | wtp_expenditure == "Más de $5,000" ~ 5000,
    wtp_expenditure == "Menos de $500" ~ 250,
    wtp_expenditure == "$500 a $1,000" ~ 750,
    wtp_expenditure == "$1,000 a $2,500" ~ 1750,
    wtp_expenditure == "$2,500 a $5,000" ~ 3750,
    wtp_expenditure == "Más de $5,000" ~ 5000
  ))


# Now for the other 2 columns, we're going to extract the number in the string.
# if there are multiple numbers, we're going to get whatever the furthest to the right hand side is.
# this is so if they wrote a range, then we'll get the upper end of the range.
surf_wtp_processed <- surf_wtp_processed %>% 
  mutate(wtp_crowd = str_extract(wtp_crowd, "\\d+")) %>% 
  mutate(wtp_cons = str_extract(wtp_cons, "\\d+"))

# convert to numeric
surf_wtp_processed <- surf_wtp_processed %>% 
  mutate(wtp_crowd = as.numeric(wtp_crowd),
         wtp_cons = as.numeric(wtp_cons))





# Now let's make histograpms for wtp_cons and wtp_crowd

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




# There's one data point for conservation that's really high, probably a mistake. They put 10,000 USD.
# let's see that particular row
surf_wtp_processed %>% 
  filter(wtp_cons > 8000)

# Let's remove that row
surf_wtp_processed <- surf_wtp_processed %>% 
  filter(wtp_cons <= 8000)




# Now let's get summary statistics, the means and medians for all 3 wtp values
# and then display in a kableClassic table
# surf_wtp_processed %>% 
#   summarize_all(list(mean = mean, median = median))

# Do again but make sure that we drop the NA values
surf_wtp_summary <- surf_wtp_processed %>%
  summarize_all(list(
    mean = ~mean(.x, na.rm = TRUE),
    median = ~median(.x, na.rm = TRUE)
  ))

# cols
# wtp expenditure mean wtp crowd mean wtp_cons_mean wtp expenditure median wtp_crowd median wtp cons median
# rename to be nicer
surf_wtp_summary %>% 
  rename(
    "WTP General Expenditure Mean" = wtp_expenditure_mean,
    "WTP Crowd Management Mean" = wtp_crowd_mean,
    "WTP Conservation Fee Mean" = wtp_cons_mean,
    "WTP General Expenditure Median" = wtp_expenditure_median,
    "WTP Crowd Management Median" = wtp_crowd_median,
    "WTP Conservation Fee Median" = wtp_cons_median
  ) %>% 
  select("WTP General Expenditure Mean", "WTP General Expenditure Median", "WTP Crowd Management Mean", "WTP Crowd Management Median", "WTP Conservation Fee Mean", "WTP Conservation Fee Median") %>%
  kable() %>% 
  kable_classic()






# Now let's make histograpms for wtp_cons and wtp_crowd, and expenditure as well.

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



# Create the 'figures' directory if it doesn't exist
if (!dir.exists(here("figures"))) dir.create(here("figures"))

# Save each plot to the 'figures' folder
ggsave(
  filename = here("figures", "hist_wtp_cons.png"),
  plot = plot_hist_wtp_cons,
  width = 6, height = 4
)

ggsave(
  filename = here("figures", "hist_wtp_crowd.png"),
  plot = plot_hist_wtp_crowd,
  width = 6, height = 4
)

ggsave(
  filename = here("figures", "hist_wtp_expenditure.png"),
  plot = plot_hist_wtp_expenditure,
  width = 6, height = 4
)




# Now let's get box plots for each
plot_box_wtp_all <- surf_wtp_processed %>% 
  pivot_longer(cols = c(wtp_expenditure, wtp_crowd, wtp_cons), names_to = "WTP Type", values_to = "WTP Value") %>% 
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

# Save the box plot
ggsave(
  filename = here("figures", "box_wtp_all.png"),
  plot = plot_box_wtp_all,
  width = 6, height = 4
)










