WITH monthly_sales AS (
SELECT DATE_FORMAT(orders.order_date, '%Y-%m') AS sales_month, SUM(order_items.quantity * order_items.unit_price) AS revenue
FROM orders JOIN order_items ON orders.order_id = order_items.order_id
WHERE orders.status = 'Completed'
GROUP BY DATE_FORMAT(orders.order_date, '%Y-%m')
)
SELECT sales_month, revenue
FROM monthly_sales
ORDER BY sales_month;