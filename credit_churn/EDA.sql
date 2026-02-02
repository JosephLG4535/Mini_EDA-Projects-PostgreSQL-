-- business case studies
-- 1: average age of customers who attrified among 'Male' and 'Female'
--both female and male who attrified have average age of 47
--this means behaviours of people approximately this age needs to be investigated 
SELECT gender, ROUND(AVG(age))::INT AS avg_attrified_age
FROM credit_staging
WHERE attrition ILIKE 'Attri%'
GROUP BY gender;


-- 2: identify which marital_status are most likely to attrify in relation to no.of dependents
--divorced, single and unknown group are more likely to attrify with 3 no of dependents 
--married group has most attrified likely due to reasons like 'financial restructuring', 
--'high stakes financial events', this relates to better rank rates offered in other banks
WITH t1 AS(
	SELECT marital_status, dependent_no, COUNT(*) AS no_of_customer 
	FROM credit_staging
	WHERE attrition ILIKE 'Attri%'
	GROUP BY marital_status, dependent_no
),
t2 AS(
	SELECT *, RANK() OVER(PARTITION BY marital_status ORDER BY no_of_customer DESC) AS rnk
	FROM t1
)
SELECT marital_status, dependent_no, no_of_customer
FROM t2
WHERE rnk = 1
ORDER BY no_of_customer DESC;


-- 3: finding the attrified distribution among marital status with different income categories
--all marital status groups share similarities where lowest income show highest attrified,
--highest income show lowest attrified
WITH t1 AS (
    SELECT marital_status, income_type, COUNT(*) AS no_of_customer
    FROM credit_staging
    WHERE income_type != 'Unknown' AND marital_status != 'Unknown' 
		AND attrition ILIKE 'Attri%'
    GROUP BY marital_status, income_type
)
SELECT marital_status, income_type, no_of_customer, ROUND(no_of_customer * 100.0 / 
	SUM(no_of_customer) OVER (PARTITION BY marital_status))::INT AS percent_customer
FROM t1	
ORDER BY marital_status ASC, percent_customer DESC;


-- 4: identify the average credit limit of customer among different income types 
--    in relation to their educational backgrounds (top for each education level group)
--for all education levels the highest average credit limit belongs to highest income_type
--lowest average credit limit belong to lowest income type
WITH t1 AS(
	SELECT edu_level, income_type, AVG(credit_limit) AS avg_credit_limit
	FROM credit_staging
	WHERE edu_level != 'Unknown' AND income_type != 'Unknown'
	GROUP BY edu_level, income_type
),
t2 AS(
	SELECT *, RANK() OVER(PARTITION BY edu_level ORDER BY avg_credit_limit DESC) AS rnk
 	FROM t1
)
SELECT edu_level, income_type, ROUND(avg_credit_limit)::INT AS avg_credit_limit
FROM t2
WHERE rnk = 1 OR rnk = (SELECT MAX(rnk) FROM t2)	
ORDER BY edu_level ASC, avg_credit_limit DESC;


-- 5: finding top 10 customers at risk of attrition based on number of transaction and amount of 
--    transaction over the past 12 months, and their revolting balance
--some customers share identical patterns in the three features investigated, hence dense_rank is used
--resulted in 17 records, these customers are most likely to attrify
WITH t1 AS (
	SELECT client_no, revol_balance, total_trans_amt, total_trans_no
	FROM credit_staging
	WHERE revol_balance >
	(
		SELECT AVG(revol_balance)::INT FROM credit_staging
	)
	AND total_trans_amt <
	(
		SELECT AVG(total_trans_amt)::INT FROM credit_staging
	)
	AND total_trans_no <
	(
		SELECT AVG(total_trans_no)::INT FROM credit_staging
	)
	AND attrition ILIKE 'Existing%'
),
t2 AS(
	SELECT *, DENSE_RANK() OVER(ORDER BY revol_balance DESC, total_trans_no ASC, total_trans_no ASC) AS rnk
	FROM t1
)
SELECT client_no, revol_balance, total_trans_amt, total_trans_no
FROM t2
WHERE rnk <= 10;
