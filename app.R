library(shiny)
library(shinydashboard)
library(data.table)
library(dplyr)
library(ggplot2)
library(lubridate)
library(caret)
library(randomForest)
library(arrow)
library(shiny)
library(readr)
library(httr)
library(lubridate) 
library(future)
library(tidyr)

plan(multisession)

# Define UI for application that draws a histogram
# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "Energy Usage Analysis"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Exploratory Data Analysis", tabName = "eda", icon = icon("chart-bar")),
      menuItem("Model Results", tabName = "model_results", icon = icon("cogs")),
      menuItem("Predictions", tabName = "predictions", icon = icon("chart-line")),
      menuItem("Confusion Matrix", tabName = "conf_matrix", icon = icon("table"))
    )
  ),
  dashboardBody(
    tabItems(
      # EDA Tab
      tabItem(tabName = "eda",
              fluidRow(
                box(
                  title = "First 'n' Rows of Dataset", 
                  numericInput("num_rows", "Number of Rows to Display:", 5, min = 1),
                  div(
                    style = "overflow-x: auto; width: 100%;",
                    tableOutput("data_head")
                  ),
                  width = 20
                ),
                box(title = "Total Energy Consumption Over Time", plotOutput("total_energy_plot"), width = 6),
                box(title = "Energy Usage by Category", plotOutput("category_plot"), width = 6),
                box(title = "Cooling vs Heating Energy Usage", plotOutput("cooling_heating_plot"), width = 6),
                box(title = "Temperature vs Energy Usage", plotOutput("temp_vs_usage_plot"), width = 6),
                box(title = "Humidity vs Energy Usage", plotOutput("humidity_vs_usage_plot"), width = 6)
              )
      ),
      # Model Results Tab
      tabItem(tabName = "model_results",
              fluidRow(
                box(title = "Linear Model Results", verbatimTextOutput("linear_results"), width = 6),
                box(title = "Decision Tree Results", verbatimTextOutput("decision_tree_results"), width = 6)
              )
      ),
      # Predictions Tab
      tabItem(tabName = "predictions",
              fluidRow(
                box(title = "Linear Model Actual v/s Predicted Energy Usage", plotOutput("predicted_energy_usage_lm"), width = 6),
                box(title = "Future Energy Demand by County", plotOutput("peak_demand_region"), width = 6),
                box(title = "Future Energy Demand by House Size", plotOutput("peak_demand_sqft"), width = 6),
                box(title = "Prediction Summary", verbatimTextOutput("prediction_summary"), width = 12)
              )
      ),
      # Confusion Matrix Tab
      tabItem(tabName = "conf_matrix",
              fluidRow(
                box(title = "Confusion Matrix", verbatimTextOutput("conf_matrix"), width = 6),
                box(title = "Matrix Explanation", htmlOutput("matrix_explanation"), width = 6)
              )
      )
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  # Keep app alive during idle periods
  observe({
    invalidateLater(10000, session)
  })
  
  # Allow large data uploads
  options(shiny.maxRequestSize = 100 * 1024^2)
  
  # 1. Load pre-saved csv file
  july_data <- readRDS("july_data.rds")
  
  # 2. Model Building
  
  # Sampling 1000 rows from new_july_data with replacement
  sampling_data <- july_data[sample(nrow(july_data), 1000, replace = TRUE), ]
  
  # Create a new data frame with selected columns
  sampling_df <- data.frame(
    clothes_dryer = sampling_data$out.electricity.clothes_dryer.energy_consumption,
    cooling_fans_pumps = sampling_data$out.electricity.cooling_fans_pumps.energy_consumption,
    cooling_energy = sampling_data$out.electricity.cooling.energy_consumption,
    lighting_exterior = sampling_data$out.electricity.lighting_exterior.energy_consumption,
    lighting_interior = sampling_data$out.electricity.lighting_interior.energy_consumption,
    plug_loads = sampling_data$out.electricity.plug_loads.energy_consumption,
    range_oven = sampling_data$out.electricity.range_oven.energy_consumption,
    sqft = sampling_data$in.sqft,
    temperature = sampling_data$Dry.Bulb.Temperature,
    time = sampling_data$time_of_day,
    total_energy_consumption = sampling_data$total_energy_consumption
  )
  
  # Add a new column for raised temperature (+5 degrees)
  sampling_df$raised_temperature <- sampling_df$temperature + 5
  
  # Split the data into training and testing sets
  set.seed(123)  # Ensure reproducibility
  trainList <- createDataPartition(sampling_df$total_energy_consumption, p = 0.8, list = FALSE)
  
  # Create train and test datasets
  trainSet <- sampling_df[trainList, ]  # 80% training set
  testSet <- sampling_df[-trainList, ]
  
  # Train a Linear Regression model
  lm_model <- lm(total_energy_consumption ~ ., data = trainSet)
  
  # Predict on the test set
  lm_predictions <- predict(lm_model, testSet)
  
  # Evaluate the model
  actual <- testSet$total_energy_consumption
  predicted <- lm_predictions
  
  # Calculate RMSE and R-squared
  rmse <- sqrt(mean((actual - predicted)^2))
  r_squared <- 1 - (sum((actual - predicted)^2) / sum((actual - mean(actual))^2))
  lm_mae <- mean(abs(actual - predicted))
  
  
  # Train a Random Forest model
  rf_model <- randomForest(
    total_energy_consumption ~ ., 
    data = trainSet, 
    ntree = 100,                # Number of trees
    importance = TRUE           # Calculate feature importance
  )
  
  # Predict on the test set
  rf_predictions <- predict(rf_model, testSet)
  
  # Evaluate the model
  rf_actual <- testSet$total_energy_consumption
  
  rf_rmse <- sqrt(mean((rf_actual - rf_predictions)^2))
  rf_r_squared <- 1 - (sum((rf_actual - rf_predictions)^2) / sum((rf_actual - mean(rf_actual))^2))
  rf_mae <- mean(abs(rf_actual - rf_predictions))
  
  # Creating confusion matrix
  req(lm_predictions, testSet)
  
  threshold <- mean(testSet$total_energy_consumption)
  predicted_classes <- ifelse(lm_predictions >= threshold, 1, 0)
  actual_classes <- ifelse(testSet$total_energy_consumption >= threshold, 1, 0)
  
  # Generate the confusion matrix
  conf_matrix <- confusionMatrix(factor(predicted_classes), factor(actual_classes))
  
  # Extract key metrics
  accuracy <- conf_matrix$overall['Accuracy']
  sensitivity <- conf_matrix$byClass['Sensitivity']
  specificity <- conf_matrix$byClass['Specificity']
  
  # 3. energy demand by geographic region (in.county)
  region_demand <- july_data %>%
    group_by(in.county) %>%
    summarize(
      Peak_Energy_Demand = max(total_energy_consumption, na.rm = TRUE)
    )
  
  # 4. energy demand by house size (in.sqft)
  sampled_data_bins <- trainSet %>%
    mutate(Sqft_Bin = cut(
      sqft, 
      breaks = c(0, 1000, 2000, 3000, 4000, 5000, Inf), 
      labels = c("<1000", "1000-2000", "2000-3000", "3000-4000", "4000-5000", ">5000")
    )) %>%
    group_by(Sqft_Bin) %>%
    summarize(
      Peak_Energy_Demand = max(total_energy_consumption, na.rm = TRUE)
    )
  
  # 5. Visualizations
  
  # Display first 'n' rows of the dataset
  output$data_head <- renderTable({
    head(july_data, n = input$num_rows)
  })
  
  # EDA plots
  output$total_energy_plot <- renderPlot({
    ggplot(data = july_data, aes(x = time_of_day, y = total_energy_consumption)) +
      geom_line(color = "blue") +
      labs(title = "Total Energy Consumption Over Time (July)",
           x = "Time",
           y = "Total Energy Consumption (kWh)") +
      theme_minimal()
  })
  
  output$category_plot <- renderPlot({
    # Summarize average energy consumption by category
    average_usage <- july_data %>%
      summarise(across(starts_with("out.electricity."), mean, na.rm = TRUE)) %>%
      pivot_longer(cols = everything(), names_to = "Category", values_to = "Average_Usage")
    
    # Bar plot of average energy usage by category
    ggplot(average_usage, aes(x = reorder(Category, Average_Usage), y = Average_Usage)) +
      geom_bar(stat = "identity", fill = "steelblue") +
      coord_flip() +
      labs(title = "Average Energy Consumption by Category (July)",
           x = "Energy Category",
           y = "Average Energy Consumption (kWh)") +
      theme_minimal()
  })
  
  output$cooling_heating_plot <- renderPlot({
    ggplot(data = july_data, aes(x = time_of_day)) +
      geom_line(aes(y = out.electricity.cooling.energy_consumption, color = "Cooling")) +
      geom_line(aes(y = out.electricity.heating.energy_consumption, color = "Heating")) +
      labs(title = "Cooling vs Heating Energy Usage Over Time (July)",
           x = "Time",
           y = "Energy Consumption (kWh)") +
      scale_color_manual(values = c("Cooling" = "blue", "Heating" = "red")) +
      theme_minimal()
  })
  
  output$temp_vs_usage_plot <- renderPlot({
    plot(july_data$Dry.Bulb.Temperature, july_data$total_energy_consumption, 
         main = "Energy vs Temperature", xlab = "Temperature", ylab = "Energy")
  })
  
  output$humidity_vs_usage_plot <- renderPlot({
    plot(july_data$Relative.Humidity, july_data$total_energy_consumption, 
         main = "Energy vs Humidity", xlab = "Humidity", ylab = "Energy")
  })
  
  # Model Results
  output$linear_results <- renderPrint({
    paste(
      "LM RMSE:", rmse, "\n",
      "LM  R-squared:", r_squared
    )
  })
  
  output$decision_tree_results <- renderPrint({
    paste(
      "RF RMSE:", rf_rmse, "\n",
      "RF  R-squared:", rf_r_squared
    )
  })
  
  # Predictions
  output$predicted_energy_usage_lm <- renderPlot({
    ggplot() +
      geom_line(aes(x = seq_along(actual), y = actual, color = "Actual"), size = 1.2) +   # Line for actual values
      geom_line(aes(x = seq_along(predicted), y = predicted, color = "Predicted"), size = 1.2) +  # Line for predicted values
      labs(
        title = "Actual vs Predicted Energy Usage",
        x = "Observation Index",
        y = "Energy Usage (kWh)"
      ) +
      scale_color_manual(values = c("Actual" = "green", "Predicted" = "purple")) +  # Customize colors
      theme_minimal() +
      theme(legend.title = element_blank())  # Remove legend title
  })
  
  output$peak_demand_region <- renderPlot({
    ggplot(region_demand, aes(x = reorder(in.county, -Peak_Energy_Demand), y = Peak_Energy_Demand)) +
      geom_bar(stat = "identity", fill = "blue") +
      labs(
        title = "Future Peak Energy Demand by Geographic Region",
        x = "Geographic Region (County)",
        y = "Peak Energy Demand (kWh)"
      ) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels
  })
  
  output$peak_demand_sqft <- renderPlot({
    ggplot(sampled_data_bins, aes(x = Sqft_Bin, y = Peak_Energy_Demand)) +
      geom_bar(stat = "identity", fill = "purple") +
      labs(
        title = "Future Peak Energy Demand by Square Footage",
        x = "Square Footage Bin",
        y = "Peak Energy Demand (kWh)"
      ) +
      theme_minimal()
  })
  
  
  # Confusion Matrix
  output$conf_matrix <- renderPrint({
    cm <- conf_matrix
    cm
  })
  
  output$matrix_explanation <- renderUI({
    HTML("<p>The confusion matrix provides insights on model performance. Key metrics include:
      <ul>
        <li><b>True Positives:</b> Correctly predicted positives</li>
        <li><b>True Negatives:</b> Correctly predicted negatives</li>
        <li><b>False Positives:</b> Incorrectly predicted positives</li>
        <li><b>False Negatives:</b> Incorrectly predicted negatives</li>
      </ul>
      High True Positives and True Negatives indicate good model accuracy.</p>")
  })
  
  output$prediction_summary <- renderText({
    "There is an increase in future energy usage in 5 degree warm scenario"
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
