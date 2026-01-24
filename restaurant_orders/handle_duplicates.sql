-- 1: check for duplicate records
WITH t1 AS (
	SELECT *, ROW_NUMBER() OVER(PARTITION BY order_id, cust_name, food, category,
		qty, price, payment_method, order_time) AS row_num
	FROM orders
)
SELECT *
FROM t1
WHERE row_num > 1;

-- creating staging table
CREATE TABLE IF NOT EXISTS orders_staging(
	order_id BIGINT NOT NULL,
	cust_name TEXT,
	food VARCHAR(50),
	category VARCHAR(50),
	qty INT,
	price NUMERIC(10,2),
	payment_method VARCHAR(50),
	order_time TIMESTAMP,
	row_num INT,
	PRIMARY KEY (order_id)
);

-- insert into staging table
INSERT INTO orders_staging(
	SELECT *, ROW_NUMBER() OVER(PARTITION BY order_id, cust_name, food, category,
		qty, price, payment_method, order_time) AS row_num
	FROM orders
);

-- delete duplicate records
DELETE FROM orders_staging
WHERE row_num > 1;

-- drop "row_num" column
ALTER TABLE orders_staging
DROP COLUMN row_num;