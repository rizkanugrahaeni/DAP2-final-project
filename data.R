#1.  DATA WRANGLING

## Load required libraries
library(tidyverse)
library(httr) # For API-based data retrieval, if needed

## Set file paths
project_path <- "/Users/rizkanugrahaeni/Documents/DAP - FINAL PROJECT"
adb_file <- file.path(project_path, "ADB Climate Change Financing - 2020commitments.csv")
wb_file <- file.path(project_path, "1113e91b-9221-4841-be67-4d11e633ebdc_Series - Metadata.csv")
output_file <- file.path(project_path, "cleaned_climate_data.csv")

## 1. Load Datasets
adb_data <- read_csv(adb_file)
wb_data <- read_csv(wb_file)

## Check the structure of the datasets
glimpse(adb_data)
glimpse(wb_data)


## 2. Select relevant columns from ADB data
adb_cleaned <- adb_data %>%
  select(
    country = `Developing Member Country`,
    year = `Date Signed`, 
    sector = `Primary Sector`,
    mitigation_finance = `Mitigation Finance ($ million)`,
    adaptation_finance = `Adaptation Finance ($ million)`
  ) %>%
  mutate(
    year = as.integer(substr(year, nchar(year) - 3, nchar(year))), # Extract the last 4 characters
    country = trimws(country) # Trim whitespace
  )

adb_cleaned <- adb_cleaned %>%
  mutate(
    country = case_when(
      country == "People's Republic of China" ~ "China",
      country == "Viet Nam" ~ "Vietnam",
      country == "Lao People's Democratic Republic" ~ "Lao PDR",
      TRUE ~ country  # Keep other names unchanged
    )
  )

## 3. Clean World Bank data
wb_cleaned <- wb_data %>%
  pivot_wider(
    names_from = `Series Name`, 
    values_from = `2021 [YR2021]`,
    values_fn = ~ mean(as.numeric(.x), na.rm = TRUE)  # Handle duplicates by taking the mean
  ) %>%
  rename(
    renewable_energy = `Renewable energy consumption (% of total final energy consumption)`,
    co2_emissions = `Carbon dioxide (CO2) emissions from Power Industry (Energy) (Mt CO2e)`
  ) %>%
  mutate(
    country = trimws(`Country Name`),
    renewable_energy = as.numeric(renewable_energy),
    co2_emissions = as.numeric(co2_emissions)
  ) %>%
  select(country, renewable_energy, co2_emissions)

## 4. Merge datasets by country
merged_data <- adb_cleaned %>%
  inner_join(wb_cleaned, by = "country")

### Remove the 'year' column
merged_data <- merged_data %>%
  select(-year)

## 5. Handle missing values
merged_data <- merged_data %>%
  mutate(
    mitigation_finance = replace_na(mitigation_finance, 0),
    adaptation_finance = replace_na(adaptation_finance, 0),
    renewable_energy = replace_na(renewable_energy, 0),
    co2_emissions = replace_na(co2_emissions, mean(co2_emissions, na.rm = TRUE))
  )

## 6. Save cleaned dataset
output_file <- "/Users/rizkanugrahaeni/Documents/DAP - FINAL PROJECT/cleaned_climate_data.csv"
write_csv(merged_data, output_file)
cat("Cleaned data saved to:", output_file, "\n")

## Preview merged data
glimpse(merged_data)

# WEB SCRAPING

## List all unique countries in the merged dataset
country_list <- merged_data %>%
  distinct(country) %>%
  arrange(country)

## Print the country list
print(country_list)

## Save the country list to a file
output_file <- "/Users/rizkanugrahaeni/Documents/DAP - FINAL PROJECT/country_list.csv"
write_csv(country_list, output_file)
cat("Country list saved to:", output_file, "\n")

## add library
library(rvest)

## Define the base URL
base_url <- "https://www.worldometers.info/co2-emissions/"

## Read the country list
country_list <- merged_data %>%
  distinct(country) %>%
  mutate(country = if_else(country == "Viet Nam", "Vietnam", country)) %>% mutate(country = str_to_lower(str_trim(country))) %>% 
  pull(country) # Extract as a vector

## Scrape the webpage
webpage <- read_html(base_url)

## Extract the table
co2_table <- webpage %>%
  html_node("table") %>% # Locate the table element
  html_table(fill = TRUE) # Parse table into a data frame

# Clean and filter CO2 data to include only relevant countries and columns
co2_data <- co2_table %>%
  select(
    Country,                  # Select the "Country" column
    Share_of_World = `Share of world` # Select and rename the "Share of world" column
  )

# Preview the cleaned CO2 data
glimpse(co2_data)


## Save the filtered data
output_file <- "/Users/rizkanugrahaeni/Documents/DAP - FINAL PROJECT/co2_share_of_world.csv"
write_csv(co2_data, output_file)
cat("Filtered CO2 data saved to:", output_file, "\n")