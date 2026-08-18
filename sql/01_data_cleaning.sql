-- ==========================================================
-- PROYECT: Bellabeat Data Analysis
-- FILE: 01_data_cleaning.sql
-- DESCRIPTION: Create a table for sleed data and unify with daily activity data
-- ==========================================================

-- Step 1: Create External Table for sleep data ingestion
CREATE OR REPLACE EXTERNAL TABLE `project-941e89dd-df86-4a8c-ba4.Bellabeat.sleep_day_raw` (
  Id INT64,
  date STRING,
  value INT64,
  logId INT64
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://bucket-cyclistic/cyclistic_folder/Bellabeat/minuteSleep_merged.csv'],
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE
);

-- Step 2: Unify and Clean Data in bellabeat_daily_clean
CREATE OR REPLACE TABLE `project-941e89dd-df86-4a8c-ba4.Bellabeat.bellabeat_daily_clean` AS
WITH sleep_clean AS (
  SELECT 
    CAST(Id AS STRING) AS user_id,
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%m/%d/%Y %I:%M:%S %p', date)) AS activity_date,
    COUNT(date) AS total_time_in_bed,
    COUNTIF(value IN (1, 2)) AS total_minutes_asleep,
    COUNTIF(value = 3) AS minutes_awake_in_bed
  FROM `project-941e89dd-df86-4a8c-ba4.Bellabeat.sleep_day_raw`
  GROUP BY user_id, activity_date
),
activity_clean AS (
  SELECT 
    CAST(Id AS STRING) AS user_id,
    CAST(ActivityDate AS DATE) AS activity_date,
    TotalSteps AS total_steps,
    TotalDistance AS total_distance,
    VeryActiveMinutes AS very_active_minutes,
    FairlyActiveMinutes AS fairly_active_minutes,
    LightlyActiveMinutes AS lightly_active_minutes,
    SedentaryMinutes AS sedentary_minutes,
    Calories AS calories
  FROM `project-941e89dd-df86-4a8c-ba4.Bellabeat.daily_activity_raw`
)
SELECT 
  a.user_id,
  a.activity_date,
  FORMAT_DATE('%A', a.activity_date) AS day_name,
  EXTRACT(DAYOFWEEK FROM a.activity_date) AS day_of_week,
  a.total_steps,
  a.total_distance,
  a.calories,
  a.very_active_minutes,
  a.fairly_active_minutes,
  a.lightly_active_minutes,
  (a.very_active_minutes + a.fairly_active_minutes + a.lightly_active_minutes) AS total_active_minutes,
  a.sedentary_minutes,
  s.total_minutes_asleep,
  s.total_time_in_bed,
  IFNULL(s.minutes_awake_in_bed, 0) AS minutes_awake_in_bed
FROM activity_clean a
LEFT JOIN sleep_clean s 
  ON a.user_id = s.user_id 
  AND a.activity_date = s.activity_date
WHERE a.total_steps > 0 
  AND a.calories > 0;
