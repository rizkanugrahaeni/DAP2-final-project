# SHINY

library(shiny)
library(tidyverse)
library(sf)
library(leaflet)

# Load and prepare data for App 1
final_data <- merged_data %>%
  left_join(co2_data, by = c("country" = "Country")) %>%
  mutate(
    Share_of_World = as.numeric(sub("%", "", Share_of_World)),  # Convert percentage to numeric
    total_financing = mitigation_finance + adaptation_finance  # Calculate total financing
  ) %>%
  select(country, total_financing, renewable_energy, co2_emissions, Share_of_World) %>%
  pivot_longer(
    cols = c(total_financing, renewable_energy, co2_emissions, Share_of_World),
    names_to = "variable",
    values_to = "value"
  ) %>%
  mutate(variable = case_when(
    variable == "total_financing" ~ "Financing Commitments ($M)",
    variable == "renewable_energy" ~ "Renewable Energy Consumption (%)",
    variable == "co2_emissions" ~ "CO2 Emissions (Mt CO2e)",
    variable == "Share_of_World" ~ "Share of World Emissions (%)",
    TRUE ~ variable
  ))

# Load and prepare data for App 2
shapefile_path <- "/Users/rizkanugrahaeni/Documents/DAP - FINAL PROJECT/shapefiles asia/world-administrative-boundaries.shp"
world_shapefile <- st_read(shapefile_path)

scatter_data <- merged_data %>%
  left_join(co2_data, by = c("country" = "Country")) %>%
  mutate(
    Share_of_World = as.numeric(sub("%", "", Share_of_World)) / 100,
    total_financing = mitigation_finance + adaptation_finance
  ) %>%
  filter(!is.na(total_financing), !is.na(Share_of_World)) %>%
  mutate(country = str_to_title(country))

geo_data <- world_shapefile %>%
  left_join(scatter_data, by = c("name" = "country"))

# UI for combined app
ui <- navbarPage(
  "Combined Shiny App",
  
  # Tab for Bar Plot
  tabPanel(
    "Bar Plot",
    sidebarLayout(
      sidebarPanel(
        checkboxGroupInput(
          inputId = "selected_variables",
          label = "Select Variables to Display:",
          choices = c(
            "Financing Commitments ($M)" = "Financing Commitments ($M)",
            "Renewable Energy Consumption (%)" = "Renewable Energy Consumption (%)",
            "CO2 Emissions (Mt CO2e)" = "CO2 Emissions (Mt CO2e)",
            "Share of World Emissions (%)" = "Share of World Emissions (%)"
          ),
          selected = c("Financing Commitments ($M)", "Share of World Emissions (%)")
        ),
        selectInput(
          inputId = "country_filter",
          label = "Filter by Country:",
          choices = unique(final_data$country),
          selected = unique(final_data$country),
          multiple = TRUE
        )
      ),
      mainPanel(
        plotOutput("barPlot"),
        helpText("Data Source: ADB and World Bank.")
      )
    )
  ),
  
  # Tab for Choropleth Map
  tabPanel(
    "Choropleth Map",
    sidebarLayout(
      sidebarPanel(
        selectInput(
          inputId = "variable",
          label = "Select Variable to Display:",
          choices = c(
            "Share of World Emissions (%)" = "Share_of_World",
            "Financing Commitments (Mitigation + Adaptation)" = "total_financing"
          ),
          selected = "Share_of_World"
        ),
        sliderInput(
          inputId = "opacity",
          label = "Map Opacity:",
          min = 0.1, max = 1, value = 0.8
        )
      ),
      mainPanel(
        leafletOutput("map")
      )
    )
  )
)

# Server for combined app
server <- function(input, output, session) {
  # Bar Plot logic
  filtered_data <- reactive({
    final_data %>%
      filter(
        variable %in% input$selected_variables,
        country %in% input$country_filter
      )
  })
  
  output$barPlot <- renderPlot({
    ggplot(filtered_data(), aes(x = reorder(country, -value), y = value, fill = variable)) +
      geom_bar(stat = "identity", position = "dodge", color = "black") +
      scale_fill_manual(
        values = c(
          "Financing Commitments ($M)" = "blue",
          "Renewable Energy Consumption (%)" = "green",
          "CO2 Emissions (Mt CO2e)" = "purple",
          "Share of World Emissions (%)" = "red"
        ),
        name = "Variable"
      ) +
      labs(
        title = "Comparison of Financing, Renewable Energy, and Emissions",
        subtitle = "Bar plot for selected countries and variables",
        x = "Country",
        y = "Value",
        caption = "Data Source: ADB and World Bank"
      ) +
      theme_minimal(base_size = 14) +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "top"
      )
  })
  
  # Choropleth Map logic
  output$map <- renderLeaflet({
    leaflet(data = geo_data) %>%
      addTiles() %>%
      addPolygons(
        fillColor = ~colorNumeric(
          palette = "YlGnBu",
          domain = geo_data[[input$variable]]
        )(geo_data[[input$variable]]),
        weight = 1,
        color = "white",
        fillOpacity = input$opacity,
        label = ~paste(name, "<br>",
                       "Value:", round(geo_data[[input$variable]], 2)),
        highlight = highlightOptions(
          weight = 3,
          color = "black",
          fillOpacity = 0.7,
          bringToFront = TRUE
        )
      ) %>%
      addLegend(
        position = "bottomright",
        pal = colorNumeric(
          palette = "YlGnBu",
          domain = geo_data[[input$variable]]
        ),
        values = geo_data[[input$variable]],
        title = input$variable,
        opacity = input$opacity
      )
  })
}

# Run the Shiny App
shinyApp(ui, server)






