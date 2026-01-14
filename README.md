# Predicting Peak Energy Demand

## 📌 Project Overview
This project analyzes **residential peak electricity demand during July**, the highest grid-stress month, for an electricity provider in South Carolina and North Carolina. The objective is to **predict peak demand**, identify key consumption drivers, and propose **cost-effective demand reduction strategies** without expanding infrastructure.


## 📊 Data Collection & Preparation
The analysis integrates three datasets:
- **Static House Data**: 5,710 homes with structural, appliance, and system attributes
- **Energy Usage Data**: 50M+ hourly appliance-level electricity consumption records
- **Weather Data**: 400K+ hourly observations of temperature, humidity, and solar radiation

Data was cleaned, merged, and processed locally. Appliance-level energy usage was aggregated into a single target variable: **total energy consumption**. Analysis was limited to **July hourly data** to capture peak demand behavior.


## 🔎 Exploratory Analysis
Key insights from EDA:
- Peak demand occurs between **8–9 PM**
- Hot-humid counties consume significantly more energy
- **Cooling systems, interior lighting, and plug loads** are the strongest demand drivers
- Energy usage increases sharply with higher temperature and humidity


## 🧠 Modeling Approach
Multiple models were evaluated to predict July peak demand:

- **Linear Regression**: R² ≈ 0.77  
- **Decision Tree**: R² ≈ 0.70 (overfitting risk)  
- **Kernel SVM**: R² ≈ 0.73  
- **Support Vector Machine (SVM)**: **R² ≈ 0.81 (Best Model)**

The **SVM model** provided the best balance of accuracy and generalization.


## ⚡ Key Findings 
- Cooling-related loads dominate peak demand
- Evening hours drive the highest grid stress
- Decision trees overfit without feature selection
- Scenario testing (+5°F) indicates significant future demand growth


## 📈 Visualization Placeholder:
![Shiny App Screenshot](/image.png)  


## 💡 Recommendations
- Smart thermostat incentive programs
- LED lighting rebates
- HVAC efficiency upgrades
- Targeted programs in high-consumption counties
- Customer awareness campaigns for load reduction


## 🛠 Tools & Technologies
- **Language**: R  
- **Libraries**: tidyverse, arrow, e1071, Shiny  
- **Techniques**: Data Wrangling, EDA, Feature Selection, Regression, SVM


## 📌 Conclusion
This project demonstrates how **data science and machine learning** can help utilities manage peak electricity demand, improve grid reliability, and reduce blackout risk in a warming climate.
