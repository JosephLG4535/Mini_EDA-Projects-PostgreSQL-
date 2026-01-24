-- 2: Checking for NULL values
-- apply TRIM to all text/varchar columns
UPDATE orders_staging
SET 
	cust_name = TRIM(cust_name),
	food = TRIM(food),
	category = TRIM(category),
	payment_method = TRIM(payment_method);

-- set all '' and 'NULL' to just NULL values
UPDATE orders_staging
SET 
	cust_name = CASE WHEN TRIM(cust_name) = '' OR UPPER(TRIM(cust_name)) = 'NULL' THEN NULL
		ELSE cust_name END,
	food = CASE WHEN TRIM(food) = '' OR UPPER(TRIM(food)) = 'NULL' THEN NULL
		ELSE food END,
	category = CASE WHEN TRIM(Category) = '' OR UPPER(TRIM(category)) = 'NULL' THEN NULL
		ELSE category END,
	payment_method = CASE WHEN TRIM(payment_method) = '' OR UPPER(TRIM(payment_method)) = 'NULL' THEN NULL
		ELSE payment_method END;

-- delete records with NULL in columns
DELETE FROM orders_staging
WHERE order_id IS NULL OR cust_name IS NULL OR food IS NULL OR category IS NULL OR qty IS NULL OR
	price IS NULL OR payment_method IS NULL OR order_time IS NULL;