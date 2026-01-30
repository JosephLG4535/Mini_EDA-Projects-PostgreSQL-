-- create a staging table for cleaning
CREATE TABLE IF NOT EXISTS scores_staging(
	first_name TEXT,
	last_name TEXT,
	age TEXT,
	gender TEXT,
	country TEXT,
	residence TEXT,
	entry_exam TEXT, 
	prev_education TEXT,
	study_hours TEXT,
	python_score TEXT,
	db_score TEXT,
	row_num INT
);

-- 1: Handling duplicates
-- duplication check insert
INSERT INTO scores_staging(
	SELECT *, ROW_NUMBER() OVER(PARTITION BY first_name, last_name, age, gender, country, residence, entry_exam,
		prev_education, study_hours, python_score, db_score) AS row_num
	FROM scores
);

-- delete duplicates
DELETE 
FROM scores_staging 
WHERE row_num > 1;





-- 2: Handling null values in python_score
-- Identify null records
SELECT * FROM scores_staging
WHERE python_score IS NULL;

-- Fill null records with median score
WITH median_val AS(
	SELECT PERCENTILE_CONT(0.5)
		WITHIN GROUP (ORDER BY CAST(python_score AS INT)) AS median_score
	FROM scores_staging
	WHERE python_score IS NOT NULL
)
UPDATE scores_staging
SET python_score = m.median_score
FROM median_val AS m
WHERE python_score IS NULL;





-- 3: Standardizing values in columns
-- country
SELECT DISTINCT country
FROM scores_staging;

UPDATE scores_staging
SET country = CASE
	WHEN LOWER(country) IN ('norway','norge') THEN 'Norway'
	WHEN LOWER(country) = 'uk' THEN 'United Kingdom'
	WHEN LOWER(country) = 'rsa' THEN 'South Africa'
	ELSE country
END;

-- gender
SELECT DISTINCT gender
FROM scores_staging;

UPDATE scores_staging
SET gender = CASE
	WHEN LOWER(gender) ILIKE 'm%' THEN 'Male'
	WHEN LOWER(gender) ILIKE 'f%' THEN 'Female'
	ELSE 'Unknown'
END;

--residence
SELECT DISTINCT residence
FROM scores_staging;

UPDATE scores_staging
SET residence = CASE
	WHEN LOWER(REGEXP_REPLACE(residence, '[_-]', '', 'g')) = 'biresidence' THEN 'BI Residence'
	ELSE residence
END;

--previous education
SELECT DISTINCT prev_education
FROM scores_staging;

UPDATE scores_staging
SET prev_education = CASE
	WHEN LOWER(prev_education) ILIKE 'diploma%' THEN 'Diploma'
	WHEN LOWER(prev_education) ILIKE '%chelors' THEN 'Bachelors'
	WHEN LOWER(prev_education) IN ('high school', 'highschool') THEN 'High School'
	ELSE prev_education
END;





--4: Concatenate names into one column
ALTER TABLE scores_staging
ADD COLUMN full_name TEXT;

UPDATE scores_staging
SET full_name = INITCAP(CONCAT(first_name, ' ', last_name));





--5: Convert columns data type and drop row_num column
ALTER TABLE scores_staging
DROP COLUMN row_num;

ALTER TABLE scores_staging
ALTER COLUMN age TYPE INT USING age::INT,
ALTER COLUMN entry_exam TYPE INT USING entry_exam::INT,
ALTER COLUMN study_hours TYPE INT USING study_hours::INT,
ALTER COLUMN python_score TYPE INT USING python_score::INT,
ALTER COLUMN db_score TYPE INT USING db_score::INT;





--6: Final result
SELECT * 
FROM scores_staging;










