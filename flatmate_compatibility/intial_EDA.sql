-- initial data exploratory
-- 1333 pairings
SELECT * FROM flatmates;

-- find records with >=90 score
-- 170 pairings with >=90 score
SELECT * 
FROM flatmates
WHERE compatibility_score >= 90;

-- finding if course affects compatibility score
-- course do not affect compatibility score (3)
WITH t1 AS(
	SELECT *
	FROM flatmates
	WHERE compatibility_score >= 90 
)
SELECT *
FROM t1
WHERE student1_course = student2_course;

-- university and country
-- university moderately affects the compatibility score (40)
-- country affects a little on compatibility score (16)
WITH t1 AS(
	SELECT *
	FROM flatmates
	WHERE compatibility_score >= 90 
)
SELECT *
FROM t1
WHERE student1_uni = student2_uni;

WITH t1 AS(
	SELECT *
	FROM flatmates
	WHERE compatibility_score >= 90 
)
SELECT *
FROM t1
WHERE student1_country = student2_country;

-- smoking, petfriendly and cleanliness (lifestyle)
-- lifestyle when paired individually greatly affects the compatibility score
-- when combined into one category, moderately strong affect (54)
-- individually
WITH t1 AS(
	SELECT *
	FROM flatmates
	WHERE compatibility_score >= 90 
)
SELECT *
FROM t1
WHERE student1_smoking = student2_smoking;

WITH t1 AS(
	SELECT *
	FROM flatmates
	WHERE compatibility_score >= 90 
)
SELECT *
FROM t1
WHERE student1_petfriendly = student2_petfriendly;

WITH t1 AS(
	SELECT *
	FROM flatmates
	WHERE compatibility_score >= 90 
)
SELECT *
FROM t1
WHERE student1_cleanliness = student2_cleanliness;
-- by group
WITH t1 AS(
	SELECT *
	FROM flatmates
	WHERE compatibility_score >= 90 
)
SELECT *
FROM t1
WHERE student1_cleanliness = student2_cleanliness AND
	student1_petfriendly = student2_petfriendly AND
	student1_smoking = student2_smoking AND
	student1_noisetolerance = student2_noisetolerance;

-- budget (use groupings for better accuracy)
-- budget group strongly affects compability score
WITH t1 AS(
	SELECT *
	FROM flatmates
	WHERE compatibility_score >= 90 
),
t2 AS(
	SELECT *, CASE 
		WHEN student1_min_budget <= 600 THEN 'Low'
		WHEN student1_min_budget <= 800 THEN 'Moderate'
		ELSE 'High'
	END AS student1_budget_grp,
	CASE
		WHEN student2_min_budget <= 600 THEN 'Low'
		WHEN student2_min_budget <= 800 THEN 'Moderate'
		ELSE 'High'
	END AS student2_budget_grp
	FROM t1
)
SELECT * 
FROM t2
WHERE student1_budget_grp = student2_budget_grp;

-- age and year of study
-- individually moderate affect, as a grouping low affect
WITH t1 AS(
	SELECT *
	FROM flatmates
	WHERE compatibility_score >= 90 
)
SELECT *
FROM t1
WHERE student1_age = student2_age AND
	student1_yrofstudy = student2_yrofstudy;

-- property type
-- moderately affects
WITH t1 AS(
	SELECT *
	FROM flatmates
	WHERE compatibility_score >= 90 
)
SELECT *
FROM t1
WHERE student1_property = student2_property;

/* in conclusion, budget group and lifestyle affects compability strongest,
   followed by property type, age, yr of study and university,
   rest have very minimal influence. */