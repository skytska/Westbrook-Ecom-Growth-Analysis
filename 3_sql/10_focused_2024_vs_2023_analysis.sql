-- =====================================================
-- Focused 2024 vs 2023 Analysis
-- =====================================================
-- Purpose:
-- Compare the current year (CY = 2024) with the previous year
-- (PY = 2023) to identify the key changes driving the business story.

-- =====================================================
-- Overall 2024 vs 2023

-- Key observations:
-- Revenue decreased by approximately 1.9% in 2024, accompanied by
-- a 1.1% decline in orders and a 1.2% decline in active customers.
-- AOV remained relatively stable, decreasing by approximately 0.8%.
-- This indicates that the primary pressure on revenue came from lower
-- customer and order volume rather than a significant decline in
-- transaction value.


-- =====================================================
-- 1. Revenue
-- =====================================================

-- 1.1 Revenue: CY vs PY

SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    SUM(total_amount) AS revenue
FROM orders
WHERE order_date >= '2023-01-01'
  AND order_date < '2025-01-01'
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY year;

-- Key observations:
-- Revenue decreased by approximately 1.9% in 2024 compared with 2023.
-- This decline is relatively modest but represents the lowest annual
-- revenue level in the five-year analysis period.

-- =====================================================
-- 2. Orders
-- =====================================================

-- 2.1 Orders: CY vs PY

SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    COUNT(order_id) AS orders
FROM orders
WHERE order_date >= '2023-01-01'
  AND order_date < '2025-01-01'
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY year;

-- Key observations:
-- Order volume decreased by approximately 1.1% in 2024 compared with 2023.
-- The decline in orders is relatively small and broadly consistent
-- with the overall revenue decrease.

-- =====================================================
-- 3. Customers
-- =====================================================

-- 3.1 Customers: CY vs PY

SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    COUNT(DISTINCT customer_id) AS customers
FROM orders
WHERE order_date >= '2023-01-01'
  AND order_date < '2025-01-01'
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY year;

-- Key observations:
-- The number of active customers decreased by approximately 1.2%
-- in 2024 compared with 2023.
-- The decline in customer volume is slightly larger than the decline
-- in orders, indicating a modest reduction in the active customer base.

-- =====================================================
-- 4. AOV
-- =====================================================

-- 4.1 AOV: CY vs PY

SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    AVG(total_amount) AS aov
FROM orders
WHERE order_date >= '2023-01-01'
  AND order_date < '2025-01-01'
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY year;

-- Key observations:
-- AOV decreased by approximately 0.8% in 2024 compared with 2023.
-- The relatively small change suggests that the revenue decline was
-- driven primarily by lower customer and order volume rather than
-- a substantial change in average transaction value.

-- =====================================================
-- 5. Category Performance
-- =====================================================

-- 5.1 Category Revenue: CY vs PY

SELECT
    p.category,
    EXTRACT(YEAR FROM o.order_date) AS year,
    COUNT(o.order_id) AS orders,
    SUM(o.total_amount) AS revenue,
    AVG(o.total_amount) AS aov
FROM orders o
JOIN products p
    ON o.product_id = p.product_id
WHERE o.order_date >= '2023-01-01'
  AND o.order_date < '2025-01-01'
GROUP BY
    p.category,
    EXTRACT(YEAR FROM o.order_date)
ORDER BY
    p.category,
    year;

    -- Key observations:
-- Electronics remained the largest revenue category, although revenue
-- decreased slightly in 2024.
-- Most categories experienced a decline in revenue, with Toys & Games
-- showing the largest decrease.
-- Sports & Outdoors was the main positive exception, with revenue increasing
-- despite relatively stable order volume, supported by higher AOV.
-- Changes in AOV were more pronounced in some smaller categories,
-- particularly Toys & Games and Clothing, suggesting that category-level
-- performance was affected by both order volume and transaction value.


-- =====================================================
-- 6. Regional Performance
-- =====================================================

-- 6.1 Revenue by State: CY vs PY

SELECT
    c.state,
    EXTRACT(YEAR FROM o.order_date) AS year,
    COUNT(o.order_id) AS orders,
    SUM(o.total_amount) AS revenue,
    AVG(o.shipping_cost) AS avg_shipping_cost,
    ROUND(
        SUM(
            CASE
                WHEN o.order_status = 'Cancelled' THEN 1
                ELSE 0
            END
        )::numeric
        / COUNT(*) * 100,
        2
    ) AS cancellation_rate
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_date >= '2023-01-01'
  AND o.order_date < '2025-01-01'
GROUP BY
    c.state,
    EXTRACT(YEAR FROM o.order_date)
ORDER BY
    c.state,
    year;

    -- Key observations:
-- Texas and California remained the largest revenue-generating states,
-- although both experienced a moderate revenue decline in 2024.
-- Revenue performance varied considerably across states.
-- New York and Florida showed the largest revenue declines, while
-- Ohio, North Carolina, and Washington recorded revenue growth.
-- Cancellation rates also changed unevenly across states, with notable
-- increases in California, Ohio, and North Carolina.
-- This suggests that regional performance was driven by factors beyond
-- overall order volume and shipping cost alone.


-- =====================================================
-- 7. Customer Composition
-- =====================================================

-- 7.1 New vs Returning Customer Revenue: CY vs PY
--
-- A customer is classified as:
-- New Customer      → first purchase occurred in the
--                     same year as the order
-- Returning Customer → purchase occurred after the
--                      customer's first purchase year

WITH first_purchase AS (
    SELECT
        customer_id,
        MIN(EXTRACT(YEAR FROM order_date)) AS first_purchase_year
    FROM orders
    GROUP BY customer_id
),
customer_type AS (
    SELECT
        o.order_id,
        o.order_date,
        o.total_amount,
        CASE
            WHEN fp.first_purchase_year =
                 EXTRACT(YEAR FROM o.order_date)
            THEN 'New Customer'
            ELSE 'Returning Customer'
        END AS customer_type
    FROM orders o
    JOIN first_purchase fp
        ON o.customer_id = fp.customer_id
)
SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    customer_type,
    SUM(total_amount) AS revenue,
    ROUND(
        SUM(total_amount)::numeric
        / SUM(SUM(total_amount)) OVER (
            PARTITION BY EXTRACT(YEAR FROM order_date)
        ) * 100,
        2
    ) AS revenue_share_percent
FROM customer_type
WHERE order_date >= '2023-01-01'
  AND order_date < '2025-01-01'
GROUP BY
    EXTRACT(YEAR FROM order_date),
    customer_type
ORDER BY
    year,
    customer_type;

    -- Key observations:
-- Returning customer revenue increased from 69.3% of total revenue in 2023
-- to 80.3% in 2024.
-- At the same time, revenue from new customers decreased from 30.7%
-- to 19.7%.
-- This indicates that the business became significantly more dependent
-- on its existing customer base in 2024.
-- Strong returning-customer revenue provides a stable base, but the decline
-- in new-customer revenue may represent a constraint on future growth.


-- =====================================================
-- 8. Seasonality
-- =====================================================

-- 8.1 Monthly Revenue: CY vs PY

SELECT
    EXTRACT(MONTH FROM order_date) AS month,
    SUM(
        CASE
            WHEN EXTRACT(YEAR FROM order_date) = 2023
            THEN total_amount
            ELSE 0
        END
    ) AS revenue_2023,
    SUM(
        CASE
            WHEN EXTRACT(YEAR FROM order_date) = 2024
            THEN total_amount
            ELSE 0
        END
    ) AS revenue_2024
FROM orders
WHERE order_date >= '2023-01-01'
  AND order_date < '2025-01-01'
GROUP BY EXTRACT(MONTH FROM order_date)
ORDER BY month;

-- Key observations:
-- The recurring seasonal pattern remained visible in 2024,
-- but monthly performance shifted compared with 2023.
-- May and June showed noticeable revenue growth, while July,
-- September, and December experienced significant declines.
-- December revenue decreased by approximately 8.6% year over year,
-- making it one of the most notable negative changes in the annual comparison.
-- This suggests that the overall 2024 decline was not uniform throughout
-- the year but was concentrated in specific months.