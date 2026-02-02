-- 1: drop columns 'drop1' & 'drop2'
ALTER TABLE credit_cust
DROP COLUMN drop1, 
DROP COLUMN drop2;




-- 2: identify and drop duplicate records
-- create staging table
CREATE TABLE IF NOT EXISTS credit_staging(
	client_no BIGINT NOT NULL,
	attrition TEXT,
	age INT,
	gender VARCHAR(10),
	dependent_no INT,
	edu_level TEXT,
	marital_status VARCHAR(20),
	income_type TEXT,
	card_type VARCHAR(10),
	months_on_book INT,
	no_of_service INT,
	no_12months_inactive INT,
	no_12contacts INT,
	credit_limit TEXT,
	revol_balance BIGINT,
	avg_open_buy TEXT,
	total_amt_chng_q4q1 NUMERIC (10,2),
	total_trans_amt BIGINT,
	total_trans_no INT,
	total_no_chng_q4q1 NUMERIC (10,2),
	avg_utilize NUMERIC (10,2),
	row_num INT,
	PRIMARY KEY (client_no)
);

-- insert into staging table
INSERT INTO credit_staging(
	SELECT *, ROW_NUMBER() OVER(PARTITION BY client_no, attrition, age, gender, dependent_no, edu_level,
		marital_status, income_type, card_type, months_on_book, no_of_service, no_12months_inactive,
		no_12contacts, credit_limit, revol_balance, avg_open_buy, total_amt_chng_q4q1, total_trans_amt,
		total_trans_no, total_no_chng_q4q1, avg_utilize) AS row_num
	FROM credit_cust
);

-- drop duplicates
DELETE FROM credit_staging
WHERE row_num > 1;




-- 3: Normalizing Values 
-- gender
UPDATE credit_staging
SET gender = CASE 
	WHEN LOWER(gender) = 'f' THEN 'Female'
	WHEN LOWER(gender) = 'm' THEN 'Male'
	ELSE gender
END;

-- education level
UPDATE credit_staging
SET edu_level = CASE
	WHEN edu_level ILIKE 'Post%' THEN 'Masters'
	WHEN LOWER(edu_level) = 'graduate' THEN 'Bachelors'
	ELSE edu_level
END;

-- credit limit
UPDATE credit_staging
SET credit_limit =
	ROUND(credit_limit::NUMERIC)::INT;
	
-- open amount available to buy
UPDATE credit_staging
SET avg_open_buy =
	ROUND(avg_open_buy::NUMERIC)::INT;

-- average ulitization rate
UPDATE credit_staging
SET avg_utilize = avg_utilize * 100;
	


-- 4: Changing 'credit limit' and 'avg open buy' column type
ALTER TABLE credit_staging
ALTER COLUMN credit_limit TYPE BIGINT USING credit_limit::INT,
ALTER COLUMN avg_open_buy TYPE BIGINT USING avg_open_buy::INT;




-- 5: Drop 'row_num' column
ALTER TABLE credit_staging
DROP COLUMN row_num;


SELECT * FROM credit_staging;