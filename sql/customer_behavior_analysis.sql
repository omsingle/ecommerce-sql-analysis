
-- =========================================
-- PROJECT: Olist E-commerce SQL Analysis
-- =========================================


-- 1. Total unique customers

SELECT
    COUNT(DISTINCT customer_unique_id) AS total_unique_customers
FROM customers;


-- 2. Repeat customers vs one-time customers

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (
        WHERE order_count = 1
    ) AS one_time_customers,
    COUNT(*) FILTER (
        WHERE order_count > 1
    ) AS repeat_customers,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE order_count > 1
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS repeat_customer_percentage
FROM customer_orders;


-- 3. Average orders per customer

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    ROUND(AVG(order_count), 2) AS average_orders_per_customer
FROM customer_orders;


-- 4. Customer order frequency

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    CASE
        WHEN order_count = 1 THEN '1 order'
        WHEN order_count = 2 THEN '2 orders'
        ELSE '3+ orders'
    END AS purchase_frequency,
    COUNT(*) AS number_of_customers
FROM customer_orders
GROUP BY
    CASE
        WHEN order_count = 1 THEN '1 order'
        WHEN order_count = 2 THEN '2 orders'
        ELSE '3+ orders'
    END
ORDER BY number_of_customers DESC;


-- 5. Top 10 cities by number of orders

SELECT
    c.customer_city,
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_city,
    c.customer_state
ORDER BY total_orders DESC
LIMIT 10;


-- 6. Customer spending groups

WITH customer_spending AS (
    SELECT
        c.customer_unique_id,
        SUM(p.payment_value) AS total_spending
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_payments p
        ON o.order_id = p.order_id
    GROUP BY c.customer_unique_id
)
SELECT
    CASE
        WHEN total_spending < 100 THEN 'Below 100'
        WHEN total_spending < 500 THEN '100-499'
        WHEN total_spending < 1000 THEN '500-999'
        ELSE '1000+'
    END AS spending_group,
    COUNT(*) AS number_of_customers
FROM customer_spending
GROUP BY spending_group
ORDER BY MIN(total_spending);
