# ⚡ Predicting Peak Energy Demand  

## 📌 Project Overview  
This project was developed to support **ESC**, an electricity provider in South Carolina and North Carolina, in understanding and managing **peak summer energy demand**. With rising global temperatures, ESC is concerned about its ability to meet customer cooling needs during July — the highest consumption month — without resorting to costly infrastructure investments.  

Our analysis combines **household attributes, hourly energy consumption, and weather data** to build predictive models, explore energy usage drivers, and propose actionable solutions.  


## 📊 Data Collection & Preparation  
The project used **three major datasets**:  
1. **Static House Data** – 5,710 houses with 171 attributes (size, appliances, construction, systems, etc.).  
2. **Energy Usage Data** – 50M+ hourly records of electricity and appliance-level consumption.  
3. **Weather Data** – 400K+ hourly observations of temperature, humidity, and solar radiation.  

⚡ **Challenge:** The datasets were extremely large and complex, requiring careful handling. While some projects opted for cloud storage, I processed and merged all three datasets **locally on a Mac system** without crashes. This included:  
- Cleaning and filtering noisy or constant-value variables.  
- Handling missing values.  
- Aggregating hourly energy usage into total consumption.  
- Creating derived variables (e.g., sum of appliance energy loads, July-only subsets).  


## 🔎 Exploratory Analysis  
Our exploratory data analysis (EDA) uncovered:  
- **Peak Hours** – Highest usage between **8–9 PM**.  
- **Climate Sensitivity** – Hot-humid counties consistently consumed more than mixed-humid counties.  
- **Top Drivers** – Cooling systems, interior lighting, and plug loads had the strongest correlations with total energy.  
- **Weather Links** – Energy consumption rose sharply with higher temperature and humidity levels.  


## 🧠 Modeling Approach  
We implemented and compared multiple predictive models:  

### 1. Linear Regression  
- Initial model with a few predictors (cooling & lighting loads).  
- R² ≈ 0.62 → improved to **0.77** with more correlated variables.  
- RMSE ≈ 0.35, MAPE ≈ 12%.  

### 2. Decision Tree  
- Captured non-linear relationships better than regression.  
- R² ≈ 0.70 on full dataset.  
- Prone to overfitting when too many predictors included.  

### 3. Support Vector Machine (SVM)  
- **Best performing model.**  
- R² ≈ **0.81**, RMSE ≈ 0.35, MAE ≈ 0.13.  
- Strong predictive power for July peak consumption across counties.    

✅ Across models, **SVM consistently delivered the best balance of accuracy and generalization**.   


## ⚡ Key Findings  
- **Main Drivers of Consumption**: Cooling systems (setpoint & type), interior lighting, plug loads, ovens.  
- **Weather Factors**: Strong positive correlation between consumption, temperature, and humidity.  
- **Peak Demand Timing**: Usage spiked in evenings (20:00–21:00).  
- **Overfitting Risks**: Decision tree models tended to overfit without feature selection.  
- **Scenario Testing**: A +5°F simulation predicted significant future demand surges, emphasizing the need for proactive strategies.  


## 💡 Recommendations for ESC  
1. **Smart Thermostat Incentives** – Encourage optimized cooling schedules.  
2. **LED Lighting Rebates** – Replace high-consumption bulbs with energy-efficient LEDs.  
3. **HVAC Upgrades** – Support upgrades to energy-efficient cooling systems.  
4. **High-Consumption County Focus** – Pilot programs in hot-humid, high-demand regions.  
5. **Customer Awareness Campaigns** – Promote sustainable cooling practices and plug load reduction.  


## 🛠 Deliverables  
- Cleaned and merged multi-source dataset (static house, weather, and energy).  
- **Predictive models (Linear Regression, Decision Tree, SVM, KSVM).**  
- **Shiny App** – Interactive tool for decision-makers to explore predictions, visualize scenarios, and simulate interventions.  


## 📌 Conclusion  
This project demonstrates how **data science and machine learning** can drive real-world impact in **energy sustainability**. By identifying the strongest consumption drivers, testing predictive models, and providing targeted recommendations, we enable ESC to:  
- Reduce peak demand sustainably.  
- Improve grid reliability.  
- Avoid costly blackouts.  
- Advance environmental goals.  


## 🔑 Key Skills & Tools  
- **Languages & Tools:** R, tidyverse, arrow, e1071, Shiny  
- **Techniques:** Data Wrangling, EDA, Correlation Analysis, Regression, Decision Trees, SVM
- **Domains:** Energy Analytics, Forecasting, Climate Impact, Sustainability  
