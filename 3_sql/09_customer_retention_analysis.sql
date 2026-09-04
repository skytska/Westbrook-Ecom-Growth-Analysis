-- =====================================================
-- Customer & Retention Analysis
-- =====================================================


-- =====================================================
-- 1. Repeat Purchase
-- =====================================================

-- Measure the share of customers who placed more than
-- one order during the full analysis period.
SELECT
    ROUND(
        COUNT(DISTINCT CASE
            WHEN order_count > 1 THEN customer_id
        END)::numeric
        / COUNT(DISTINCT customer_id) * 100,
        2
    ) AS repeat_purchase_rate_percent
FROM (
    SELECT
        customer_id,
        COUNT(order_id) AS order_count
    FROM public.orders
    GROUP BY customer_id
) t;

-- Key observations:

-- 68.7% of customers placed more than one order during the
-- full five-year analysis period.
-- This indicates that repeat purchasing is a significant
-- part of the customer base, although the metric is influenced
-- by the five-year observation window.

-------------------------------------------------------------------------------

-- Customer purchase frequency and total spend.
-- This helps assess how customer value is distributed
-- across the customer base.
SELECT
    customer_id,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS total_spent,
    MAX(order_date) AS last_purchase_date
FROM public.orders
GROUP BY customer_id
ORDER BY total_spent DESC;


-- =====================================================
-- 2. Customer Revenue Concentration
-- =====================================================

-- Divide customers into five equal-sized groups based
-- on total revenue contribution to assess customer
-- revenue concentration.
WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(total_amount) AS total_spent
    FROM public.orders
    GROUP BY customer_id
),
ranked_customers AS (
    SELECT
        *,
        NTILE(5) OVER (
            ORDER BY total_spent DESC
        ) AS revenue_quintile
    FROM customer_revenue
)
SELECT
    revenue_quintile,
    SUM(total_spent) AS revenue_in_segment
FROM ranked_customers
GROUP BY revenue_quintile
ORDER BY revenue_quintile;

-- Key observations:

-- The top 20% of customers generate 43.8% of total revenue,
-- while the bottom 20% contribute only 3.5%.
-- This indicates a meaningful concentration of revenue
-- among higher-value customers.


-- =====================================================
-- 3. New vs Returning Customers
-- =====================================================

-- Classify customers based on whether an order was placed
-- in the customer's first purchase year or in a later year.
-- This provides a high-level view of revenue composition
-- between new and returning customers.
WITH customer_first_purchase AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_purchase_date
    FROM public.orders
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN EXTRACT(YEAR FROM o.order_date)
             = EXTRACT(YEAR FROM c.first_purchase_date)
        THEN 'New Customer'
        ELSE 'Returning Customer'
    END AS customer_type,
    SUM(o.total_amount) AS revenue,
    ROUND(
        SUM(o.total_amount)
        / SUM(SUM(o.total_amount)) OVER () * 100,
        2
    ) AS revenue_share
FROM public.orders o
JOIN customer_first_purchase c
    ON o.customer_id = c.customer_id
GROUP BY
    CASE
        WHEN EXTRACT(YEAR FROM o.order_date)
             = EXTRACT(YEAR FROM c.first_purchase_date)
        THEN 'New Customer'
        ELSE 'Returning Customer'
    END
ORDER BY revenue DESC;

-- Key observations:
-- Overall revenue composition 2020–2024 → 52.45% / 47.55%.
-- 52.45% revenue → customers whose purchase occurred in their first purchase year
-- 47.55% → customers acquired in previous years