-- top 3 job roles with highest average satisfaction score among low attrited risk employees
-- data analyst, prompt engineer, backend engineer are the top 3 jobs with low attrition and highest satisfaction score
SELECT job_role, ROUND(AVG(satisfaction_score),2) AS avg_satisfaction
FROM ai_workers
WHERE attrition_risk = 'Low'
GROUP BY job_role
ORDER BY avg_satisfaction DESC
LIMIT 3;

-- average ai_assist_hrs, ai_pct_replace and ai_upskill_weekly_hrs for based on company sizes
-- replacement rate is lowest at mid and large companies but second highest for enterprise
SELECT company_size, ROUND(AVG(ai_assist_hrs),2) AS avg_assist_hrs,
	ROUND(AVG(ai_upskill_weekly_hrs),2) AS avg_upskill_hrs, ROUND(AVG(ai_pct_replace),2) AS avg_replace_rate
FROM ai_workers
GROUP BY company_size
ORDER BY avg_replace_rate DESC;


-- find which jobs use ai tools more per day and hours used, and the percentage to replace labor with AI
-- number of tools used and average assist hours used per day does not translate to AI replacement percentage
SELECT job_role, ROUND(AVG(ai_assist_hrs),2) AS avg_assist_hrs, ROUND(AVG(ai_tools_day),2) AS avg_tools_day,
	ROUND(AVG(ai_pct_replace),2) AS avg_replace_rate
FROM ai_workers
GROUP BY job_role
ORDER BY avg_assist_hrs DESC;

-- top 5 countries with highest burnout rate and lowest satisfaction score among AI workers
-- these countries are more likely to attrition among AI employees
SELECT country, ROUND(AVG(burnout_rate),2) AS avg_burnout, 
	ROUND(AVG(satisfaction_score),2) AS avg_satisfaction
FROM ai_workers
GROUP BY country
HAVING AVG(burnout_rate) > 50
ORDER BY avg_burnout DESC
LIMIT 5;

-- top 5 industries with  highest average AI replacement percentages, among 'High' replacement fear employees
-- 'High' fear employees in these 5 industries have the highest percentage to be replaced by AI 
SELECT industry, ROUND(AVG(ai_pct_replace),2) AS avg_replace_rate
FROM ai_workers
WHERE ai_replacement_fear = 'High'
GROUP BY industry
ORDER BY avg_replace_rate DESC
LIMIT 5;