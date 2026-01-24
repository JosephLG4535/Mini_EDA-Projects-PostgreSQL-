-- 3: Formatting columns for EDA
-- remove space between titles and first name
UPDATE orders_staging
SET 
	cust_name = REGEXP_REPLACE(cust_name, '\.\s+', '.', 'g');

-- remove 'DDS' customer last name with last_name+DDS
UPDATE orders_staging
SET
	cust_name = REGEXP_REPLACE(cust_name,'\s+DDS$', 'DDS', 'i');

-- split cust_name to cust_first and cust_last
ALTER TABLE orders_staging
ADD COLUMN cust_first TEXT;

UPDATE orders_staging
	SET cust_first = split_part(cust_name, ' ', 1);

ALTER TABLE orders_staging
ADD COLUMN cust_last TEXT;

UPDATE orders_staging
	SET cust_last = split_part(cust_name, ' ', -1);






-- split order_time to order_time and order_date
ALTER TABLE orders_staging
ADD COLUMN order_date DATE;

UPDATE orders_staging
SET order_date = order_time::date;

ALTER TABLE orders_staging
ALTER COLUMN order_time TYPE time
USING order_time::time;



