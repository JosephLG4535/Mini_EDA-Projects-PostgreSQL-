-- Create Table
CREATE TABLE IF NOT EXISTS orders(
	order_id BIGINT NOT NULL,
	cust_name TEXT,
	food VARCHAR(50),
	category VARCHAR(50),
	qty INT,
	price NUMERIC(10,2),
	payment_method VARCHAR(50),
	order_time TIMESTAMP,
	PRIMARY KEY (order_id)
)