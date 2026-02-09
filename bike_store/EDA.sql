-- 5 business case studies
-- 1: Finding top 3 brands that has the most quantity sold across year 2017
WITH t1 AS(
	SELECT od_it.order_id, brand_name, quantity, shipped_date
	FROM products AS pd
	LEFT JOIN brands AS bd
		ON bd.brand_id = pd.brand_id
	RIGHT JOIN order_items AS od_it
		ON od_it.product_id = pd.product_id
	LEFT JOIN orders AS od
		ON od.order_id = od_it.order_id
	WHERE shipped_date <> 'Order Rejected' AND
		EXTRACT(YEAR FROM shipped_date::DATE) = 2017 
)
SELECT 
    brand_name, SUM(quantity) AS total_sold
FROM t1
GROUP BY brand_name
ORDER BY total_sold DESC
LIMIT 3;



-- 2: Determining bonus for staffs based on no.of orders completed in 2017
WITH t1 AS(
	SELECT od.order_id, order_status, full_name, manager_id, st.staff_id
	FROM orders AS od
	LEFT JOIN staffs AS st
		ON od.staff_id = st.staff_id
	LEFT JOIN order_items AS od_it
		ON od.order_id = od_it.order_id
	WHERE order_status = 'Completed' AND EXTRACT(YEAR FROM shipped_date::DATE) = 2017
),
t2 AS(
	SELECT staff_id, full_name, manager_id, COUNT(DISTINCT order_id) AS order_completed
	FROM t1
	GROUP BY full_name, manager_id, staff_id
)
SELECT full_name AS staff_name, order_completed,
	CASE 
		WHEN manager_id = 'Regular Staff' THEN (order_completed*0.5)
		ELSE order_completed*0.7
	END AS bonus_amt
FROM t2
ORDER BY bonus_amt DESC;



-- 3: Stock quantity control based on quantity sold and stock quantity balance for store 1
WITH t1 AS(
	SELECT od_it.product_id, product_name, od_it.quantity AS order_qty
	FROM order_items AS od_it
	LEFT JOIN orders AS od
		ON od_it.order_id = od.order_id
	INNER JOIN products AS pd
		ON od_it.product_id = pd.product_id
),
t2 AS(
	SELECT t1.product_id, product_name, order_qty, st.quantity AS stock_qty, 
		SUM(order_qty) OVER(PARTITION BY t1.product_id) AS qty_sold
	FROM t1 
	LEFT JOIN stocks AS st 
		ON st.product_id = t1.product_id AND st.store_id = 1
),
t3 AS(
	SELECT product_id, product_name, qty_sold, COALESCE(SUM(stock_qty),0) AS stock_qty, 
		CASE 
			WHEN qty_sold >= 100 THEN 'High'
			WHEN qty_sold >= 50 THEN 'Moderate'
			ELSE 'Low' END AS demand
	FROM t2
	GROUP BY product_id, product_name, qty_sold
)
SELECT product_id, product_name, demand, 
	CASE
		WHEN demand = 'High' AND (stock_qty - qty_sold) >= 200 THEN 'Safe'
		WHEN demand = 'High' AND (stock_qty - qty_sold) < 200 THEN 'Not Safe'
		WHEN demand = 'Moderate' AND (stock_qty - qty_sold) >= 100  THEN 'Safe'
		WHEN demand = 'Moderate' AND (stock_qty - qty_sold) < 100 AND (stock_qty - qty_sold) > 80 THEN 'Not Safe'
		WHEN demand = 'Low' AND (stock_qty - qty_sold) >= 50 THEN 'Safe'
		WHEN demand = 'Low' AND (stock_qty - qty_sold) < 50 THEN 'Not Safe'
		ELSE 'Too little stocks'
	END AS stock_status, stock_qty
FROM t3
ORDER BY CASE demand
	WHEN 'Low' THEN 1
	WHEN 'Moderate' THEN 2
	WHEN 'High' THEN 3
END, stock_status ASC, product_id ASC;


-- 4: Which category is most popular for each store based on number of orders
WITH t1 AS(
	SELECT product_id, product_name, category_name, ct.category_id
	FROM products AS pd
	LEFT JOIN categories AS ct
		ON pd.category_id = ct.category_id
),
t2 AS(
	SELECT st.store_id, store_name, product_id, od_it.order_id
	FROM orders AS od
	LEFT JOIN stores AS st
		ON od.store_id = st.store_id
	RIGHT JOIN order_items AS od_it
		ON od.order_id = od_it.order_id 
	WHERE od.order_status = 'Completed'
), 
t3 AS(
	SELECT store_id, store_name, category_name, COUNT(store_id) AS no_of_order
	FROM t2 
	LEFT JOIN t1 
		ON t2.product_id = t1.product_id
	GROUP BY store_id, store_name, category_name
),
t4 AS(
	SELECT *, RANK() OVER(PARTITION BY store_id, store_name ORDER BY no_of_order) AS rnk
	FROM t3
)
SELECT store_name, category_name, no_of_order
FROM t4
WHERE rnk <= 1
ORDER BY no_of_order DESC;



-- 5: Find top 5 cities with most number of orders
WITH t1 AS(
	SELECT city, COUNT(DISTINCT order_id) AS no_of_order
	FROM orders AS od
	LEFT JOIN customers AS cus
		ON od.customer_id = cus.customer_id
	GROUP BY city
),
t2 AS(
	SELECT *, DENSE_RANK() OVER(ORDER BY no_of_order DESC) AS rnk
	FROM t1
)
SELECT city, no_of_order
FROM t2
WHERE rnk <= 5;