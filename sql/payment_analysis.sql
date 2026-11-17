
-- =========================================
-- PROJECT: Olist E-commerce SQL Analysis
-- =========================================


-- 1. Total payment value by payment type

SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(payment_value), 2) AS total_payment_value
FROM order_payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;


-- 2. Percentage share of each payment method

WITH payment_summary AS (
    SELECT
        payment_type,
        SUM(payment_value) AS payment_total
    FROM order_payments
    GROUP BY payment_type
)
SELECT
    payment_type,
    ROUND(payment_total, 2) AS payment_value,
    ROUND(
        100.0 * payment_total / SUM(payment_total) OVER (),
        2
    ) AS percentage_share
FROM payment_summary
ORDER BY payment_value DESC;


-- 3. Average payment value by payment type

SELECT
    payment_type,
    ROUND(AVG(payment_value), 2) AS average_payment,
    COUNT(*) AS payment_records
FROM order_payments
GROUP BY payment_type
ORDER BY average_payment DESC;


-- 4. Installment analysis

SELECT
    payment_installments,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(AVG(payment_value), 2) AS average_payment
FROM order_payments
GROUP BY payment_installments
ORDER BY payment_installments;


-- 5. Orders using multiple payment methods

SELECT
    order_id,
    COUNT(DISTINCT payment_type) AS payment_methods_used,
    ROUND(SUM(payment_value), 2) AS total_payment
FROM order_payments
GROUP BY order_id
HAVING COUNT(DISTINCT payment_type) > 1
ORDER BY payment_methods_used DESC, total_payment DESC
LIMIT 20;


-- 6. Monthly payment method trends

SELECT
    TO_CHAR(
        DATE_TRUNC('month', o.order_purchase_timestamp),
        'YYYY-MM'
    ) AS sales_month,
    p.payment_type,
    ROUND(SUM(p.payment_value), 2) AS total_payment
FROM orders o
JOIN order_payments p
    ON o.order_id = p.order_id
GROUP BY
    DATE_TRUNC('month', o.order_purchase_timestamp),
    p.payment_type
ORDER BY
    DATE_TRUNC('month', o.order_purchase_timestamp),
    total_payment DESC;
