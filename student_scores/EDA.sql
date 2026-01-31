-- Some business questions
-- 1: Find the bottom 10% performing students in python & db scores
-- 13 students who are really struggling 
SELECT full_name, python_score, db_score
FROM scores_staging
WHERE python_score <
(
	SELECT PERCENTILE_CONT(0.1) WITHIN GROUP(ORDER BY python_score)
	FROM scores_staging 
)
OR db_score < (
	SELECT PERCENTILE_CONT(0.1) WITHIN GROUP(ORDER BY db_score)
	FROM scores_staging
);



-- 2: Find the top 10 student with combined average scores from db and python
-- high average from 93 to 87
SELECT full_name, ROUND((python_score + db_score) / 2.0)::INT AS avg_score
FROM scores_staging
ORDER BY avg_score DESC
LIMIT 10;



-- 3: Top 3 countries with most students
-- most students are from Norway (49) and rest are scattered around 
WITH t1 AS(
	SELECT country, COUNT(*) AS no_of_student
	FROM scores_staging
	GROUP BY country
),
rnk_t1 AS(
	SELECT *, DENSE_RANK() OVER(ORDER BY no_of_student DESC) AS rnk
	FROM t1
)
SELECT country, no_of_student
FROM rnk_t1
WHERE rnk <=3;



-- 4: Identify how valuable higher tertiary education is towards final scores
-- on average, postgraduates score 6 higher than non-postgraduate students 
WITH t1 AS(
	SELECT prev_education, (python_score + db_score) / 2 AS combined_score, 
		CASE WHEN prev_education IN ('Doctorate', 'Masters') THEN 'Postgraduate'
		ELSE 'Others'
		END AS cluster_grp
	FROM scores_staging
)
SELECT cluster_grp, ROUND(AVG(combined_score))::INT AS avg_score
FROM t1
GROUP BY cluster_grp;




-- 5: On average among 'Male' and 'Female', how many of them with <70 entry exam score
--    score well on final score
-- only 1 for female and male, but percentage higher for 'Female' due to dataset distribution
WITH t1 AS(
	SELECT gender, (python_score + db_score) / 2.0 AS avg_score, 
		COUNT(*) OVER(PARTITION BY gender) AS total_gender
	FROM scores_staging
	WHERE entry_exam <70
),
t2 AS(
	SELECT gender, COUNT(*) AS no_of_student
	FROM t1
	WHERE avg_score >=80
	GROUP BY gender
),
-- in case theres 0
t3 AS(
	SELECT gender, total_gender
	FROM t1
	GROUP BY gender, total_gender
)
SELECT t3.gender, COALESCE(no_of_student,0) AS no_of_student,
	COALESCE(ROUND((no_of_student * 100.0 / total_gender), 2),0.0) AS percent_gender
FROM t3 
LEFT JOIN t2
	ON t2.gender = t3.gender
ORDER BY percent_gender DESC;

/* Better sample answer found for no5
SELECT
    gender,
    COUNT(*) AS total_gender,
    COUNT(CASE WHEN (python_score + db_score)/2.0 >= 80 THEN 1 END) AS no_of_student,
    ROUND(COUNT(CASE WHEN (python_score + db_score)/2.0 >= 80 THEN 1 END) * 100.0 / COUNT(*), 2) AS percent_gender
FROM scores_staging
WHERE entry_exam < 70
GROUP BY gender
ORDER BY percent_gender DESC;
*/