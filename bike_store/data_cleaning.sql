-- preprocessing on tables
-- categories
UPDATE categories
SET
	category_name = REGEXP_REPLACE(category_name, '\s(Bikes|Bicycles)', ' Bicycles', 'i');



-- customers
UPDATE customers
SET
	phone = CASE 
		WHEN phone = 'NULL' THEN 'Not Provided'
		ELSE phone
	END;

UPDATE customers
SET 
	street = REGEXP_REPLACE(street, '^(\d+)\s+(.+)\.?', '\1, \2');

ALTER TABLE customers
ADD COLUMN full_name TEXT;

UPDATE customers
SET full_name = INITCAP(CONCAT(first_name,' ',last_name));

ALTER TABLE customers
DROP COLUMN first_name,
DROP COLUMN last_name;



-- orders
ALTER TABLE orders
ALTER COLUMN order_status TYPE TEXT USING order_status::TEXT;

UPDATE orders
SET
	order_status = CASE
		WHEN order_status = '1' THEN 'Pending'
		WHEN order_status = '2' THEN 'Processing'
		WHEN order_status = '3' THEN 'Rejected'
		WHEN order_status = '4' THEN 'Completed'
		ELSE 'Unknown'
	END;

UPDATE orders
SET
	shipped_date = CASE
		WHEN shipped_date = 'NULL' THEN 'Order Rejected'
		ELSE shipped_date
	END;
		


-- products
UPDATE products
SET
	product_name = REGEXP_REPLACE(product_name, '\s*-\s*.*', '', 'g');



-- staffs
UPDATE staffs
SET
	manager_id = CASE 
		WHEN manager_id = 'NULL' THEN 'Regular Staff'
		ELSE manager_id
	END;

ALTER TABLE staffs
ADD COLUMN full_name TEXT;

UPDATE staffs
SET full_name = INITCAP(CONCAT(first_name,' ',last_name));

ALTER TABLE staffs
DROP COLUMN first_name,
DROP COLUMN last_name;



-- stores
UPDATE stores
SET
	street = REGEXP_REPLACE(street, '(\d+)\s+(.+)','\1, \2','g');



