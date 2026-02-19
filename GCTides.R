#  GCTides ---------------------------------------------------------------------
#  code by Reyn Yoshioka
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>#####

# Creating Google Calendar events from NOAA Tides and Currents Predictions

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>#####

# i: Requirements --------------------------------------------------------------
# [ ] 1. Download the annual predictions for your station of interest from
#     NOAA Tides and Currents. Use local time, MLLW, 24-hr clock, and TXT.
#     Download: c
# [ ] 2. Store this file in the same location as this script.
# [ ] 3. Before importing the csv created by this script into your Google 
#     Calendar, make sure your time zone is that of your station.

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>#####

# 1: Getting Started -----------------------------------------------------------
# > 1.1: Clear everything ----- 
# clear workspace
# rm(list=ls()) # Careful clearing out other folks' environments!
# clear console
# cat("\014")

# > 1.2: Load packages -----
library(here) # working directory management
library(tidyverse) # all the tidy things

# > 1.3: Here ----
# here::i_am() points your working directory to where this script lives.
here::i_am("GCTides.R")

# > 1.4: Read in table -----
# read_table will read in the txt file and guess the column types
df_tides = read_table("data/8413079_annual_2026.txt",
                      skip = 19) # there are 19 lines of extra info

glimpse(df_tides)

# > 1.5: Define location -----
location = "Winter Harbor, ME"

# 2: Make calendar event components --------------------------------------------
# > 2.1: Reassign "H" and "L"  ----- 
#   to "High" and "Low", resp.
df_tides$`High/Low` = ifelse(df_tides$`High/Low` == "H",
                             "High",
                             "Low")

# > 2.2: Create event components -----
df_tides =
  df_tides |>
  mutate(Subject = paste(`High/Low`,
                         "Tide:",
                         `Pred(cm)` / 100, "m,",
                         `Pred(Ft)`, "ft",
                         sep = " "),
         `Start Date` = 
           as.character(
           format(`Date`,
                  '%m/%d/%Y')),
         `End Date` = `Start Date`,
         `Start Time` = `Time`,
         `End Time` = hms::hms(hms(`Time`) + minutes(1)),
         `All Day Event` = "False",
         Description = paste0("Tides at ",
                                location),
         Location = location,
         Private = "False")

# > 2.3: Subset low tides,  -----
#   if desired
df_tides =
  df_tides |>
  filter(`High/Low` == "Low")

# > 2.4: Create file for export -----
df_tides_exp = 
  df_tides |>
  select(Subject,
         `Start Date`,
         `Start Time`,
         `End Date`,
         `End Time`,
         `All Day Event`,
         Description,
         Location,
         Private)

# > 2.5: Export -----
write.csv(df_tides_exp,
          paste("outputs/GCTides",
                gsub(",",
                     "",
                     gsub(" ",
                          "",
                          location)),
                unique(year(df_tides$Date)),
                ".csv",
                sep = ""))

# 3: Import into Google Calendar -----
# > 3.1: Create a new calendar for your given tide station
# > 3.2: Import the created csv into that calendar
# !!! Make sure your time zone matches the tide location, the csv does not
# include time zone information and will not be accurate if you're in the 
# wrong time zone.
