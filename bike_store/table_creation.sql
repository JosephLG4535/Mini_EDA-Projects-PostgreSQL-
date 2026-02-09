-- tables creation
CREATE TABLE IF NOT EXISTS brands(
	brand_id INT NOT NULL,
	brand_name TEXT,
	PRIMARY KEY (brand_id)
)

CREATE TABLE IF NOT EXISTS categories(
	category_id INT NOT NULL,
	category_name TEXT,
	PRIMARY KEY (category_id)
)

CREATE TABLE IF NOT EXISTS customers(
	customer_id INT NOT NULL,
	first_name TEXT,
	last_name TEXT,
	phone TEXT,
	email TEXT,
	street TEXT,
	city TEXT,
	states TEXT,
	zip_code BIGINT,
	PRIMARY KEY (customer_id)
)

CREATE TABLE IF NOT EXISTS order_items(
	order_id INT,
	item_id INT,
	product_id INT,
	quantity INT,
	list_price NUMERIC(10,2),
	discount NUMERIC(10,2)
)

CREATE TABLE IF NOT EXISTS orders(
	order_id INT NOT NULL,
	customer_id INT,
	order_status INT,
	order_date DATE,
	required_date DATE,
	shipped_date TEXT,
	store_id INT,
	staff_id INT,
	PRIMARY KEY (order_id)
)

CREATE TABLE IF NOT EXISTS products(
	product_id INT NOT NULL,
	product_name TEXT,
	brand_id INT,
	category_id INT,
	model_year BIGINT,
	list_price NUMERIC(10,2),
	PRIMARY KEY (product_id) 
)

CREATE TABLE IF NOT EXISTS staffs(
	staff_id INT NOT NULL,
	first_name TEXT,
	last_name TEXT,
	email TEXT,
	phone TEXT,
	active TEXT,
	store_id INT,
	manager_id TEXT,
	PRIMARY KEY (staff_id)
)

CREATE TABLE IF NOT EXISTS stocks(
	store_id INT,
	product_id INT,
	quantity INT
)

CREATE TABLE IF NOT EXISTS stores(
	store_id INT NOT NULL,
	store_name TEXT,
	phone TEXT,
	email TEXT,
	street TEXT,
	city TEXT,
	states TEXT,
	zip_code BIGINT,
	PRIMARY KEY (store_id)
)
