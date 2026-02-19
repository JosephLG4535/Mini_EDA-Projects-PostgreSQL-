-- check for duplicate records by ID
-- no duplicate IDs found
SELECT freelancer_id, COUNT(freelancer_id) AS no_of_record
FROM freelancers
GROUP BY freelancer_id
HAVING COUNT(freelancer_id) > 1;

-- standardizing gender column
UPDATE freelancers
SET gender = CASE 
	WHEN LOWER(gender) IN ('m','male') THEN 'Male'
	ELSE 'Female' 
END;

-- standardizing age column
UPDATE freelancers
SET age = CASE 
	WHEN age IS NULL THEN 'Not Specified'
	ELSE ROUND(age::NUMERIC, 0)::TEXT 
END;

-- standardizing exp_years column
UPDATE freelancers
SET exp_years = CASE 
	WHEN exp_years IS NULL THEN 'Not Specified'
	ELSE ROUND(exp_years::NUMERIC, 0)::TEXT
END;

-- standardizing hourly_rate column
UPDATE freelancers
SET hourly_rate = CASE
	WHEN hourly_rate IS NULL THEN 'Not Specified'
	ELSE REGEXP_REPLACE(hourly_rate, '[^0-9]', '', 'g')
END;

-- standardizing rating column
UPDATE freelancers
SET rating = CASE
	WHEN rating IS NULL OR rating::NUMERIC = 0  THEN 'Not Specified'
	ELSE rating
END;

-- standardizing is_active column
UPDATE freelancers
SET is_active = CASE 
	WHEN is_active IS NULL THEN 'Not Specified'
	WHEN LOWER(is_active) IN ('yes','1','true','y') THEN 'Yes'
	ELSE 'No'
END;

-- standardizing client_satisfaction column
UPDATE freelancers
SET client_satisfaction = CASE 
	WHEN client_satisfaction IS NULL THEN 'Not Specified'
	WHEN client_satisfaction ~ '%' THEN REGEXP_REPLACE(client_satisfaction,'%','','g')
	ELSE client_satisfaction
END;

-- final dataset check
SELECT * FROM freelancers;
