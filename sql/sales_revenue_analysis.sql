
-- =========================================
-- PROJECT: Olist E-commerce SQL Analysis
-- =========================================


-- 1. Total recorded payment value

SELECT
    ROUND(SUM(payment_value), 2) AS total_payment_value
FROM order_payments;


-- 2. Monthly revenue trend

SELECT
    TO_CHAR(
        DATE_TRUNC('month', o.order_purchase_timestamp),
        'YYYY-MM'
    ) AS sales_month,
    ROUND(SUM(p.payment_value), 2) AS monthly_revenue
FROM orders o
JOIN order_payments p
    ON o.order_id = p.order_id
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY DATE_TRUNC('month', o.order_purchase_timestamp);


-- 3. Recorded payment value by order status

SELECT
    o.order_status,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value), 2) AS total_payment_value
FROM orders o
JOIN order_payments p
    ON o.order_id = p.order_id
GROUP BY o.order_status
ORDER BY total_payment_value DESC;


-- 4. Top 10 revenue-generating states

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value), 2) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_payments p
    ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC
LIMIT 10;


-- 5. Average Order Value (AOV)

WITH order_totals AS (
    SELECT
        order_id,
        SUM(payment_value) AS order_value
    FROM order_payments
    GROUP BY order_id
)
SELECT
    ROUND(AVG(order_value), 2) AS average_order_value
FROM order_totals;


-- 6. Revenue by product category

SELECT
    p.product_category_name,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS product_sales
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY product_sales DESC
LIMIT 15;
