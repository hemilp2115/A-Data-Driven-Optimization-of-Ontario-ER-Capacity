🏥 # A-Data-Driven-Optimization-of-Ontario-ER-Capacity
An end-to-end data engineering and predictive analytics pipeline optimizing Ontario ER capacity. Uses SQL, SARIMA forecasting, and Monte Carlo simulations to solve hospital bottlenecks.

# Solving Hallway Medicine: An Operational and Predictive Analytics Approach to ER Capacity

## 📌 Executive Summary
"Hallway Medicine" is a critical crisis in Ontario's healthcare system, with average urban Emergency Room wait times exceeding 2.1 hours. This Capstone project moves beyond basic reporting to mathematically engineer a staffing solution. By combining robust data engineering, operations math, and machine learning, this project proves that staffing to "average" volumes causes systemic collapse, and identifies the exact operational buffer capacity needed to stabilize hospital flow.

## ⚙️ The Tech Stack
* **Languages:** Python, SQL
* **Environments:** Databricks, SQL Server Management Studio (SSMS), Jupyter
* **Libraries:** Pandas, NumPy, Statsmodels, Matplotlib, SciPy
* **Visualization:** Power BI
* **Methodologies:** M/M/s Queuing Theory, SARIMA Time-Series Forecasting, Monte Carlo Stochastic Simulation

## 🏥 Data Architecture & "Digital Twin" Methodology
Due to Canada's strict PHIPA privacy regulations prohibiting the use of raw patient records, this project utilized a **"Digital Twin"** methodology. 
* Sourced real, aggregate provincial benchmarks from **Health Quality Ontario (HQO)**.
* Mathematically simulated 10,000 granular patient records to mimic a high-volume urban Ontario ER.
* Engineered a production-grade SQL pipeline utilizing Staging Tables and dynamic data casting (`TRY_CAST`) to clean data, extract exact operational parameters, and handle null values for patients who Left Without Being Seen (LWBS).

## 🔬 Advanced Analytics Methodologies

### 1. Operations Analytics: M/M/s Queuing Theory
Extracted a peak arrival rate ($\lambda$) of 19 patients/hour and a service rate ($\mu$) of 0.21. Applied the Erlang C formula to reverse-engineer current capacity, proving that to maintain the 2.1-hour wait time, the hospital operates at a highly brittle **94 active servers** (98.3% utilization).

### 2. Predictive Analytics: SARIMA Forecasting
To ensure operational fixes were future-proof, a Seasonal ARIMA (SARIMA) machine learning model was deployed in Databricks. Utilizing 12 months of provincial data, the model successfully captured the cyclic volatility of ER patient volumes to forecast exact demand spikes for upcoming spring months.

### 3. Stochastic Stress-Testing: Monte Carlo Simulation
Emergency rooms are chaotic; averages are insufficient. Developed a Python-based Monte Carlo simulation using Poisson distributions to stress-test the 94-server baseline across **10,000 randomized shifts**.
* **The Problem:** Staffing for the "average" (94 servers) resulted in a **44% system collapse rate** during random surges, triggering 8+ hour wait times.
* **The Solution:** Iterative simulations revealed that scaling to a **125-server buffer capacity** absorbed stochastic chaos, achieving a **92.4% operational resilience rate** and virtually eliminating severe bottlenecks.

## 📊 Business Impact & Strategic Recommendations
This analysis provides hospital administrators with a mathematically proven roadmap:
1. **The Tipping Point:** Adding just a few servers during peak hours pushes the hospital off the exponential wait-time cliff.
2. **Buffer Capacity:** To achieve 95% confidence in keeping wait times under 1 hour, the hospital must increase peak-hour capacity to 125 fully resourced micro-systems (bed + physician + nurse + diagnostic access).

## 📂 Repository Structure
* `/sql/` - Contains the SSMS DDL/DML scripts for the staging tables, data cleaning, and feature engineering (Views).
* `/notebooks/` - Contains the Databricks Python notebooks for the SARIMA forecasting and Monte Carlo simulations.
* `/dashboards/` - Contains screenshots and PDFs of the final Power BI demographic and bottleneck visualizations.
