-- ==========================================================
-- PROYECT: Bellabeat Data Analysis
-- FILE: 02_exploratory_analysis.sql
-- DESCRIPTION: Analyze AVG Metrics, Activity Trends and Segmentation
-- ==========================================================

--Query 1: Overall Average Metrics

SELECT 
  COUNT(DISTINCT user_id) AS total_unique_users,
  ROUND(AVG(total_steps), 0) AS avg_daily_steps,
  ROUND(AVG(calories), 0) AS avg_calories,
  ROUND(AVG(sedentary_minutes) / 60, 2) AS avg_sedentary_hours,
  ROUND(AVG(total_active_minutes), 0) AS avg_active_minutes,
  ROUND(AVG(total_minutes_asleep) / 60, 2) AS avg_sleep_hours
FROM `project-941e89dd-df86-4a8c-ba4.Bellabeat.bellabeat_daily_clean`;

--Query 2: Activity Trends by Day of the Week

SELECT 
  day_of_week,
  day_name,
  COUNT(user_id) AS total_records,
  ROUND(AVG(total_steps), 0) AS avg_steps,
  ROUND(AVG(calories), 0) AS avg_calories,
  ROUND(AVG(sedentary_minutes) / 60, 1) AS avg_sedentary_hours,
  ROUND(AVG(total_minutes_asleep) / 60, 2) AS avg_sleep_hours
FROM `project-941e89dd-df86-4a8c-ba4.Bellabeat.bellabeat_daily_clean`
GROUP BY day_of_week, day_name
ORDER BY day_of_week;

--Query 3: Activity Level Segmentation (CDC / WHO)

WITH user_averages AS (
  SELECT 
    user_id,
    AVG(total_steps) AS avg_steps
  FROM `project-941e89dd-df86-4a8c-ba4.Bellabeat.bellabeat_daily_clean`
  GROUP BY user_id
)
SELECT 
  CASE 
    WHEN avg_steps < 5000 THEN 'Sedentary (< 5,000 steps)'
    WHEN avg_steps BETWEEN 5000 AND 7499 THEN 'Lightly Active (5,000 - 7,499)'
    WHEN avg_steps BETWEEN 7500 AND 9999 THEN 'Moderately Active (7,500 - 9,999)'
    ELSE 'Very Active (>= 10,000 steps)'
  END AS activity_category,
  COUNT(user_id) AS user_count,
  ROUND(COUNT(user_id) * 100.0 / SUM(COUNT(user_id)) OVER(), 1) AS percentage
FROM user_averages
GROUP BY activity_category
ORDER BY user_count DESC;
