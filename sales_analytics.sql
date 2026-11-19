SELECT
orders.order_id,
customers.customer_name,
orders.order_date,
orders.status
FROM orders
JOIN customers
ON orders.customer_id = customers.customer_id;

SELECT
customers.customer_name,
orders.order_date,
products.product_name,
products.category,
order_items.quantity,
order_items.unit_price
FROM orders
JOIN customers
ON orders.customer_id = customers.customer_id
JOIN order_items
ON orders.order_id = order_items.order_id
JOIN products
ON order_items.product_id = products.product_id;

WITH customer_totals AS (
SELECT orders.customer_id, SUM(order_items.quantity * order_items.unit_price) AS total_spent
FROM orders JOIN order_items ON orders.order_id = order_items.order_id
WHERE orders.status = 'Completed'
GROUP BY orders.customer_id
)
SELECT customers.customer_name, customer_totals.total_spent
FROM customer_totals JOIN customers ON customer_totals.customer_id = customers.customer_id
ORDER BY customer_totals.total_spent DESC LIMIT 10;

WITH monthly_sales AS (
SELECT DATE_FORMAT(orders.order_date, '%Y-%m') AS sales_month, SUM(order_items.quantity * order_items.unit_price) AS revenue
FROM orders JOIN order_items ON orders.order_id = order_items.order_id
WHERE orders.status = 'Completed'
GROUP BY DATE_FORMAT(orders.order_date, '%Y-%m')
)
SELECT sales_month, revenue
FROM monthly_sales
ORDER BY sales_month;

-- Window functions: running total and monthly growth
WITH monthly_sales AS (
SELECT DATE_FORMAT(orders.order_date, '%Y-%m') AS sales_month, SUM(order_items.quantity * order_items.unit_price) AS revenue
FROM orders JOIN order_items ON orders.order_id = order_items.order_id
WHERE orders.status = 'Completed'
GROUP BY DATE_FORMAT(orders.order_date, '%Y-%m')
)
SELECT sales_month, revenue, SUM(revenue) OVER (ORDER BY sales_month) AS running_total, LAG(revenue) OVER (ORDER BY sales_month) AS prev_month, ROUND((revenue - LAG(revenue) OVER (ORDER BY sales_month)) / LAG(revenue) OVER (ORDER BY sales_month) * 100, 1) AS growth_pct
FROM monthly_sales
ORDER BY sales_month;

-- Window function: customer ranking
WITH customer_totals AS (
SELECT orders.customer_id, SUM(order_items.quantity * order_items.unit_price) AS total_spent
FROM orders JOIN order_items ON orders.order_id = order_items.order_id
WHERE orders.status = 'Completed'
GROUP BY orders.customer_id
)
SELECT customers.customer_name, customer_totals.total_spent, RANK() OVER (ORDER BY customer_totals.total_spent DESC) AS spending_rank
FROM customer_totals JOIN customers ON customer_totals.customer_id = customers.customer_id
ORDER BY spending_rank LIMIT 10;

--Revenue by product category
SELECT products.category, SUM(order_items.quantity * order_items.unit_price) AS revenue
FROM orders JOIN order_items ON orders.order_id = order_items.order_id
JOIN products ON order_items.product_id = products.product_id
WHERE orders.status = 'Completed'
GROUP BY products.category
ORDER BY revenue DESC;