
## Project Overview
This project examines climate financing in Asia and its relationship to renewable energy adoption and CO2 emissions. The analysis uses multiple datasets, including climate financing data from the Asian Development Bank (ADB), World Bank indicators, and web-scraped data on CO2 emissions by country. The outputs include static plots, regression models, sentiment analysis, and interactive Shiny applications for exploratory analysis.

The repository is designed for reproducibility, enabling users to replicate the results by following the documented structure and editing paths as needed. 

---

## Original Data Sources and Description

1. **ADB Climate Financing Data (2020)**:
   - **Source**: Asian Development Bank (ADB)
   - **Description**: This dataset provides information on financing commitments for climate adaptation and mitigation projects in 2020.
   - **File Location**: `ADB Climate Change Financing - 2020commitments.csv`

2. **World Bank Indicators**:
   - **Source**: World Bank API
   - **Description**: Contains renewable energy consumption and CO2 emissions data for countries in 2021.
   - **File Location**: `1113e91b-9221-4841-be67-4d11e633ebdc_Series - Metadata.csv`

3. **Web-Scraped Data**:
   - **Source**: [Worldometer CO2 Emissions by Country](https://www.worldometers.info/co2-emissions/)
   - **Description**: Provides the share of world CO2 emissions for selected countries.
   - **File Location**: Dynamically scraped and saved as `co2_share_of_world.csv`.

---

## Code Files and Execution Order

1. **`data.R`**:
   - **Purpose**: Loads, cleans, and merges datasets from ADB, World Bank, and web scraping. Prepares the data for analysis and saves the cleaned dataset.
   - **User Instructions**:
     - Update file paths to match your local system.
     - Example: Replace `/Users/rizkanugrahaeni/Documents/DAP - FINAL PROJECT/` with your directory path.

2. **`staticplot.R`**:
   - **Purpose**: Generates static visualizations of financing vs. renewable energy, financing vs. CO2 emissions, and their relationships with global CO2 shares.
   - **User Instructions**:
     - Ensure `data.R` has been run to generate the cleaned data.
     - Review saved plots in the output directory after running the script.

3. **`model.R`**:
   - **Purpose**: Fits regression models to study the relationships between financing, renewable energy, and CO2 emissions. Outputs results as summaries.
   - **User Instructions**:
     - Ensure that `data.R` has been run before running the regression analysis.

4. **`shinyapp.R`**:
   - **Purpose**: Builds interactive visualizations for exploring financing, renewable energy, and CO2 emissions data. Includes a choropleth map for geographic analysis.
   - **User Instructions**:
     - Update the shapefile path in the code to point to your local shapefile directory.
     - Run the Shiny app and interact with the visualizations.

5. **`textprocess.R`**:
   - **Purpose**: Scrapes and performs sentiment analysis on climate finance-related articles. Outputs sentiment trends for exploratory insights.
   - **User Instructions**:
     - Run this file independently if text analysis is desired.

---

## Modifications Needed for Replication

1. **File Paths**:
   - Update all file paths in `data.R` and `shinyapp.R` to reflect your local project directory.
   - Example:
     ```
     project_path <- "/Users/your-username/Documents/Your-Project-Path"
     ```

2. **Web-Scraped Data**:
   - If web scraping is re-run, ensure an active internet connection. Changes in the source website structure may affect data retrieval.

3. **Shiny Applications**:
   - Verify that the shapefile directory and required libraries are correctly set.

---

## Reproducibility Notes
This repository is structured to ensure smooth reproduction of results:
- All data wrangling and merging are performed within `data.R`.
- If datasets are updated or scraped dynamically, the results may vary, but the scripts are designed to handle these changes gracefully.
- All visualizations and analyses are reproducible after running the provided scripts in the specified order.

---

## Required Environment and Packages

- **R Version**: 4.3.0
- **Packages and Versions**:
  - `tidyverse`: 1.3.1
  - `shiny`: 1.7.4
  - `sf`: 1.0.11
  - `leaflet`: 2.1.1
  - `httr`: 1.4.4
  - `rvest`: 1.0.3

---

## Links to Large Data Files

- **Large Data Files**:
  - ADB Climate Financing Data: [Download here](https://data.adb.org/media/7431/download)
  - World Bank Indicators: [Download here](https://databank.worldbank.org/source/world-development-indicators#)

---

## Author 

- **Author**: Rizka Nugrahaeni
- **Date Created**: November 28, 2024
- **Last Updated**: November 28, 2024

