## REGRESSION MODEL

# Prepare data for regression
regression_data <- merged_data %>%
  left_join(co2_data, by = c("country" = "Country")) %>%
  mutate(
    Share_of_World = as.numeric(sub("%", "", Share_of_World)) / 100,  # Convert percentage to decimal
    total_financing = mitigation_finance + adaptation_finance  # Calculate total financing
  ) %>%
  select(country, total_financing, renewable_energy, co2_emissions, Share_of_World) %>%
  filter(!is.na(total_financing), !is.na(renewable_energy), !is.na(co2_emissions))

# Regression model for Renewable Energy
model_renewable <- lm(renewable_energy ~ total_financing, data = regression_data)
summary(model_renewable)

# Regression model for CO2 Emissions
model_co2 <- lm(co2_emissions ~ total_financing, data = regression_data)
summary(model_co2)


