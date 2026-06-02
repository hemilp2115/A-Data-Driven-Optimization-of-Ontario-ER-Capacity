/* =========================================================================================
   PROJECT: Advanced Data Analytics Application - Healthcare Operations
   PURPOSE: Clean simulated ER data, validate wait times, and extract Queuing Theory parameters.
   DATABASE: EDdata
   TARGET TABLE: december_2024_er (Staging Table - VARCHAR)
========================================================================================= */

USE EDdata;
GO

-- =========================================================================================
-- PHASE 1: DATA CLEANING & FEATURE ENGINEERING (VIEW CREATION)
-- =========================================================================================

-- Drop the view if it already exists so we can run this script cleanly
DROP VIEW IF EXISTS vw_Cleaned_ER;
GO

-- Create the master analytical view, converting text to dates and calculating metrics
CREATE VIEW vw_Cleaned_ER AS
SELECT 
    Patient_ID,
    Sex,
    Age_Group,
    Outcome_Category,
    
    -- Cast text to proper DATETIME2 formats safely
    TRY_CAST(Arrival_Time AS DATETIME2) AS Arrival_Time,
    TRY_CAST(Triage_Time AS DATETIME2) AS Triage_Time,
    TRY_CAST(Assessment_Start_Time AS DATETIME2) AS Assessment_Start_Time,
    TRY_CAST(Discharge_Time AS DATETIME2) AS Discharge_Time,
    
    -- 1. Identify patients who Left Without Being Seen (LWBS)
    CASE 
        WHEN TRY_CAST(Assessment_Start_Time AS DATETIME2) IS NULL THEN 'Did Not Wait - LWBS'
        ELSE 'Assessed'
    END AS Assessment_Status,
    
    -- 2. Calculate the Wait Time (Triage to Doctor) in minutes
    CASE 
        WHEN Outcome_Category = 'LWBS' THEN NULL 
        ELSE DATEDIFF(MINUTE, TRY_CAST(Triage_Time AS DATETIME2), TRY_CAST(Assessment_Start_Time AS DATETIME2)) 
    END AS Wait_Time_Mins,
    
    -- 3. Calculate the Total Length of Stay (Door to Discharge) in minutes
    DATEDIFF(MINUTE, TRY_CAST(Arrival_Time AS DATETIME2), TRY_CAST(Discharge_Time AS DATETIME2)) AS Total_LOS_Mins,
    
    -- 4. Feature Engineering: Flag the 14.4+ Hour Bottlenecks
    CASE 
        WHEN DATEDIFF(MINUTE, TRY_CAST(Arrival_Time AS DATETIME2), TRY_CAST(Discharge_Time AS DATETIME2)) >= 864 
        THEN 'Critical Bottleneck (>14.4 hrs)'
        ELSE 'Standard Processing'
    END AS Bottleneck_Flag

FROM december_2024_er;
GO


-- =========================================================================================
-- PHASE 2: DATA VALIDATION (BENCHMARK CHECK)
-- =========================================================================================

-- Verify the simulated average wait time matches the Health Quality Ontario 2.1-hour benchmark
SELECT 
    Outcome_Category,
    COUNT(Patient_ID) AS Total_Patients,
    AVG(Wait_Time_Mins) AS Avg_Wait_Mins,
    CAST(AVG(Wait_Time_Mins) / 60.0 AS DECIMAL(4,2)) AS Avg_Wait_Hours
FROM vw_Cleaned_ER
WHERE Outcome_Category != 'LWBS'
GROUP BY Outcome_Category;
GO


-- =========================================================================================
-- PHASE 3: OPERATIONS ANALYTICS (QUEUING THEORY PARAMETERS)
-- =========================================================================================

-- Extract Lambda (Arrival Rate) and Mu (Service Rate) during peak hours (10 AM to 10 PM)
WITH PeakArrivals AS (
    SELECT 
        CAST(Arrival_Time AS DATE) AS Visit_Date,
        DATEPART(HOUR, Arrival_Time) AS Visit_Hour,
        COUNT(Patient_ID) AS Patients_Arrived
    FROM vw_Cleaned_ER
    WHERE DATEPART(HOUR, Arrival_Time) BETWEEN 10 AND 22 
    GROUP BY CAST(Arrival_Time AS DATE), DATEPART(HOUR, Arrival_Time)
),
TreatmentTimes AS (
    SELECT 
        AVG(Total_LOS_Mins - Wait_Time_Mins) AS Avg_Treatment_Mins
    FROM vw_Cleaned_ER
    WHERE Assessment_Status = 'Assessed'
)
SELECT 
    (SELECT AVG(Patients_Arrived) FROM PeakArrivals) AS Peak_Lambda_Patients_Per_Hour,
    (SELECT Avg_Treatment_Mins FROM TreatmentTimes) AS Avg_Treatment_Mins,
    CAST(60.0 / (SELECT Avg_Treatment_Mins FROM TreatmentTimes) AS DECIMAL(4,2)) AS Mu_Patients_Per_Hour_Per_Doctor;
GO


-- =========================================================================================
-- PHASE 4: DATA EXPORT FOR VISUALIZATION
-- =========================================================================================

-- Pull the final dataset to export to Power BI or Excel
SELECT * FROM vw_Cleaned_ER;
GO