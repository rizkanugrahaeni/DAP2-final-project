#2. PLOTTING

## Load required libraries
library(ggplot2)
library(dplyr)
library(stringr)

# Merge co2_data with merged_data
final_data <- merged_data %>%
  mutate(country = str_to_title(country)) %>% # Ensure consistent title case for merging
  left_join(co2_data, by = c("country" = "Country"))

# Replace NA values in Share_of_World with 0 for plotting
final_data <- final_data %>%
  mutate(Share_of_World = ifelse(is.na(Share_of_World), 0, Share_of_World))

# Add a total financing column
final_data <- final_data %>%
  mutate(total_financing = mitigation_finance + adaptation_finance)

final_data <- final_data %>%
  mutate(Share_of_World = as.numeric(str_remove(Share_of_World, "%")) / 100)

# FIRST PLOT
bar_data <- final_data %>%
  select(country, total_financing, renewable_energy, Share_of_World) %>%
  pivot_longer(
    cols = c(total_financing, renewable_energy, Share_of_World),
    names_to = "variable",
    values_to = "value"
  )

# Convert variable names for better readability
bar_data <- bar_data %>%
  mutate(variable = case_when(
    variable == "total_financing" ~ "Financing Commitments ($M)",
    variable == "renewable_energy" ~ "Renewable Energy Consumption (%)",
    variable == "Share_of_World" ~ "Share of World Emissions (%)",
    TRUE ~ variable
  ))

# Grouped bar plot
grouped_bar_plot <- ggplot(bar_data, aes(x = reorder(country, -value), y = value, fill = variable)) +
  geom_bar(stat = "identity", position = "dodge", color = "black") +
  scale_fill_manual(
    values = c("Financing Commitments ($M)" = "blue",
               "Renewable Energy Consumption (%)" = "green",
               "Share of World Emissions (%)" = "red"),
    name = "Variable"
  ) +
  labs(
    title = "Relationship Between Financing, Renewable Energy, and Emissions",
    subtitle = "Grouped bar plot comparing financing commitments, renewable energy consumption, and share of world emissions",
    x = "Country",
    y = "Value (Scaled)",
    caption = "Data Source: ADB and World Bank"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "top"
  )

# Save the plot
ggsave("grouped_bar_plot.png", grouped_bar_plot, width = 12, height = 8)

# Print the plot
print(grouped_bar_plot)

# SECOND PLOT with CO2 emissions
bar_data_co2 <- final_data %>%
  select(country, total_financing, co2_emissions, Share_of_World) %>%
  pivot_longer(
    cols = c(total_financing, co2_emissions, Share_of_World),
    names_to = "variable",
    values_to = "value"
  )

# Convert variable names for better readability
bar_data_co2 <- bar_data_co2 %>%
  mutate(variable = case_when(
    variable == "total_financing" ~ "Financing Commitments ($M)",
    variable == "co2_emissions" ~ "CO2 Emissions (Mt CO2e)",
    variable == "Share_of_World" ~ "Share of World Emissions (%)",
    TRUE ~ variable
  ))

# Grouped bar plot with CO2 emissions
grouped_bar_plot_co2 <- ggplot(bar_data_co2, aes(x = reorder(country, -value), y = value, fill = variable)) +
  geom_bar(stat = "identity", position = "dodge", color = "black") +
  scale_fill_manual(
    values = c("Financing Commitments ($M)" = "blue",
               "CO2 Emissions (Mt CO2e)" = "purple",
               "Share of World Emissions (%)" = "red"),
    name = "Variable"
  ) +
  labs(
    title = "Relationship Between Financing, CO2 Emissions, and Share of World Emissions",
    subtitle = "Grouped bar plot comparing financing commitments, CO2 emissions, and share of world emissions",
    x = "Country",
    y = "Value",
    caption = "Data Source: ADB and World Bank"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "top"
  )

# Save the plot
ggsave("grouped_bar_plot_co2.png", grouped_bar_plot_co2, width = 12, height = 8)

# Print the plot
print(grouped_bar_plot_co2)

# THIRD PLOT
scatter_data <- merged_data %>%
  left_join(co2_data, by = c("country" = "Country")) %>%  # Merge with CO2 data
  mutate(
    Share_of_World = as.numeric(sub("%", "", Share_of_World)) / 100,  # Convert percentage to decimal
    total_financing = mitigation_finance + adaptation_finance  # Calculate total financing
  ) %>%
  filter(!is.na(total_financing), !is.na(Share_of_World))  # Remove missing values

# Create the scatter plot
scatter_plot <- ggplot(scatter_data, aes(x = total_financing, y = Share_of_World, color = country)) +
  geom_point(size = 4, alpha = 0.8) +
  labs(
    title = "Relationship Between Financing Commitments and Share of World Emissions",
    subtitle = "Scatter plot showing how financing relates to emission share",
    x = "Financing Commitments (Mitigation + Adaptation) in $ million",
    y = "Share of World Emissions (%)",
    color = "Country"
  ) +
  scale_y_continuous(labels = scales::percent_format()) +  # Format y-axis as percentage
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "bottom",
    legend.text = element_text(size = 10),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

## Save the scatter plot
ggsave("scatter_financing_vs_share_of_world_emissions.png", scatter_plot, width = 12, height = 8)

## Print the plot
print(scatter_plot)

# PLOT 4

## Load required libraries
library(ggplot2)
library(sf)
library(dplyr)

## Load the shapefile
shapefile_path <- "/Users/rizkanugrahaeni/Documents/DAP - FINAL PROJECT/shapefiles asia/world-administrative-boundaries.shp"
world_shapefile <- st_read(shapefile_path)

# Prepare the data for mapping
map_data <- world_shapefile %>%
  left_join(scatter_data, by = c("name" = "country"))

## Create the static choropleth map
choropleth_map <- ggplot(map_data) +
  geom_sf(aes(fill = Share_of_World * 100), color = "white", size = 0.2) + # Scale to whole numbers
  scale_fill_gradient(
    low = "lightblue", high = "darkblue", na.value = "gray",
    name = "Share of World Emissions (%)",
    labels = scales::number_format(scale = 1)  # Format as whole numbers
  ) +
  labs(
    title = "Global Share of CO2 Emissions by Country",
    subtitle = "Overlayed with Financing Commitments",
    caption = "Data Source: ADB, World Bank, Worldometers"
  ) +
  theme_minimal() +
  theme(
    panel.grid = element_blank(),
    axis.text = element_blank(),
    axis.title = element_blank(),
    legend.position = "bottom"
  )

# Save the static map
ggsave("static_choropleth_map_scaled.png", choropleth_map, width = 10, height = 8)

# Print the map
print(choropleth_map)

