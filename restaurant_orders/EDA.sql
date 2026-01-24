-- EDA practice
-- 1: Finding out top 5 food based on number of orders & price
-- top 5 no.of orders
WITH order_nums AS (
	SELECT food, COUNT(DISTINCT order_id) AS order_num
	FROM orders_staging
	GROUP BY food
),
rnk_order AS (
	SELECT *, DENSE_RANK() OVER(ORDER BY order_num DESC) AS rnk_order_num
	FROM order_nums
)

SELECT food, order_num
FROM rnk_order
WHERE rnk_order_num <= 5;

-- top 5 total order amount
SELECT food, SUM(price) AS total_price_food
FROM orders_staging
GROUP BY food
ORDER BY total_price_food DESC
LIMIT 5;




-- 2: Finding the most total amount from payment methods, and top 3 categories that uses the payment method
WITH most_price AS (
	SELECT payment_method, SUM(price) AS total_price
	FROM orders_staging
	GROUP BY payment_method
	ORDER BY total_price DESC
	LIMIT 1
)
SELECT od_st.category, SUM(od_st.price) AS total_price
FROM orders_staging AS od_st
JOIN most_price AS mt_price
	ON od_st.payment_method = mt_price.payment_method
GROUP BY od_st.category
ORDER BY total_price DESC
LIMIT 3;



-- 3: Finding the top food with most quantity ordered for each payment method
WITH qty_food AS (
	SELECT food, payment_method, SUM(qty) AS total_qty
	FROM orders_staging
	GROUP BY food, payment_method
),
rnk_payment AS (
	SELECT *, RANK() OVER (PARTITION BY payment_method 
		ORDER BY total_qty DESC) AS rnk
	FROM qty_food
)
SELECT food, payment_method, total_qty
FROM rnk_payment
WHERE rnk = 1
ORDER BY total_qty DESC;





-- 4: Finding the most popular categories for each day (Mon - Sun)
-- using number of orders
WITH order_nums AS (
	SELECT category, TO_CHAR(order_date, 'FMDay') AS day_name, COUNT(DISTINCT order_id) AS order_num
	FROM orders_staging
	GROUP BY category, TO_CHAR(order_date, 'FMDay')
),
rnk_nums AS (
	SELECT *, RANK() OVER(PARTITION BY day_name ORDER BY order_num DESC) AS rnk
	FROM order_nums
)
SELECT day_name, category, order_num
FROM rnk_nums
WHERE rnk = 1
ORDER BY order_num DESC;


-- using total quantity sold
WITH order_price AS (
	SELECT category, TO_CHAR(order_date, 'FMDay') AS day_name, SUM(price) AS total_amt
	FROM orders_staging
	GROUP BY category, TO_CHAR(order_date, 'FMDay')
),
rnk_price AS (
	SELECT *, RANK() OVER(PARTITION BY day_name ORDER BY total_amt DESC) AS rnk
	FROM order_price
)
SELECT day_name, category, total_amt
FROM rnk_price
WHERE rnk = 1
ORDER BY CASE day_name
	WHEN 'Monday' THEN 	1
	WHEN 'Tuesday' THEN 2
	WHEN 'Wednesday' THEN 3
	WHEN 'Thursday' THEN 4
	WHEN 'Friday' THEN 5
	WHEN 'Saturday' THEN 6
	WHEN 'Sunday' THEN 7
END;




-- 5: Finding which time of the day which produces the most amount
-- top 3 hours with most sales
SELECT EXTRACT(HOUR FROM order_time) AS hour_num, SUM(price) AS total_amt
FROM orders_staging
GROUP BY hour_num
ORDER BY total_amt DESC
LIMIT 3;

-- total amount based on time of day
SELECT CASE 
	WHEN EXTRACT(HOUR FROM order_time) < 12 THEN 'Morning'
	WHEN EXTRACT(HOUR FROM order_time) >= 12 AND EXTRACT(HOUR FROM order_time) < 18 THEN 'Afternoon'
	ELSE 'Night'
END AS time_of_day, SUM(price) AS total_amt
FROM orders_staging
GROUP BY time_of_day
ORDER BY total_amt DESC;



