-- =====================================================
-- Exploratory Business Analysis
-- =====================================================
-- Purpose:
-- Explore the overall business performance and identify
-- potential growth drivers, risks, and areas for deeper analysis.
--
-- This analysis covers the full 2020–2024 period and is
-- intentionally exploratory. Specific year-over-year
-- comparisons are performed separately in file 04.
-- =====================================================


-- =====================================================
-- 1. Revenue & Orders
-- =====================================================

-- 1.1 Annual Revenue, Orders, Customers & AOV
-- Assess overall business performance and identify
-- long-term growth or stagnation.

SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    SUM(total_amount) AS revenue,
    COUNT(order_id) AS orders,
    COUNT(DISTINCT customer_id) AS customers,
    AVG(total_amount) AS aov
FROM orders
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY year;

-- Key observations:
-- Annual revenue remained within a narrow range of approximately
-- $18.2M–$18.5M throughout 2020–2024.
-- Order volume, customer count, and AOV also remained broadly stable,
-- indicating no sustained growth in either demand or transaction value.
-- 2024 recorded the lowest revenue and customer count of the five-year period,
-- suggesting a recent weakening rather than continued stability.
------------------------------------------------------------------


-- 1.2 Monthly Revenue Trend
-- Explore monthly revenue dynamics and identify
-- recurring patterns or unusual fluctuations.

SELECT
    DATE_TRUNC('month', order_date) AS month,
    SUM(total_amount) AS monthly_revenue
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;

-- Key observations:
-- Revenue shows a recurring seasonal pattern across the five-year period.
-- February is consistently one of the weakest months, while August
-- frequently performs above the annual monthly average.
-- Seasonal fluctuations are relatively consistent across years,
-- suggesting a structural demand pattern rather than a one-off anomaly.


-- =====================================================
-- 2. Customers & AOV
-- =====================================================

-- 2.1 Annual Customer Metrics
-- Examine how customer volume and AOV changed
-- across the analysis period.

SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    COUNT(DISTINCT customer_id) AS customers,
    AVG(total_amount) AS aov
FROM orders
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY year;

-- Key observations:
-- Customer volume remained broadly stable at approximately 16.4K–16.6K
-- customers per year.
-- AOV also remained stable at approximately $914–$923,
-- indicating that changes in revenue were driven primarily by customer
-- and order volume rather than changes in average transaction value.
--------------------------------------------------------------------

-- 2.2 Orders per Customer
-- Assess the average number of orders generated
-- per customer across the full analysis period.

SELECT
    COUNT(order_id)::numeric
        / COUNT(DISTINCT customer_id) AS orders_per_customer
FROM orders;

-- Key observations:
-- Customers placed an average of 2.3 orders during the full analysis period.
-- This suggests that the customer base generated multiple purchases over
-- the five-year observation window, supporting the presence of repeat demand.

-- =====================================================
-- 3. Product / Category Performance
-- =====================================================

-- 3.1 Revenue by Category
-- Identify the categories generating the largest
-- share of total revenue.

SELECT
    p.category,
    COUNT(o.order_id) AS orders,
    SUM(o.total_amount) AS revenue,
    AVG(o.total_amount) AS aov
FROM orders o
JOIN products p
    ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- Key observations:
-- Electronics generated approximately $47.8M, making it the dominant
-- revenue category.
-- Together, Electronics and Home & Kitchen accounted for approximately
-- 73% of total revenue.
-- AOV is relatively consistent across categories, suggesting that
-- revenue differences are primarily driven by order volume rather than
-- substantial differences in average order value.

--------------------------------------------------------------------


-- 3.2 Top 10 Products by Revenue
-- Identify the products contributing most to revenue.

SELECT
    p.product_name,
    SUM(o.total_amount) AS total_revenue
FROM orders o
JOIN products p
    ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC
LIMIT 10;

-- Key observations:
-- Revenue is distributed across several leading products rather than
-- being concentrated in a single SKU.
-- The top products generate relatively similar revenue levels,
-- suggesting that category concentration is a more significant
-- portfolio risk than individual product concentration.

-- =====================================================
-- 4. Geography
-- =====================================================

-- 4.1 Revenue by State
-- Identify geographic concentration of revenue.

SELECT
    c.state,
    COUNT(o.order_id) AS orders,
    SUM(o.total_amount) AS revenue
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.state
ORDER BY revenue DESC;

-- Key observations:
-- Revenue is geographically concentrated, with Texas and California
-- generating approximately 45% of total revenue combined.
-- Average shipping costs are relatively consistent across states,
-- suggesting limited geographic variation in logistics costs.

--------------------------------------------------------------------

-- 4.2 Average Shipping Cost by State
-- Explore whether shipping costs differ meaningfully
-- across geographic markets.

SELECT
    c.state,
    AVG(o.shipping_cost) AS avg_shipping_cost
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.state
ORDER BY avg_shipping_cost DESC;


-- 4.3 Cancellation Rate by State
-- Identify regions with potentially higher
-- order cancellation levels.

SELECT
    c.state,
    COUNT(*) AS total_orders,
    SUM(
        CASE
            WHEN o.order_status = 'Cancelled' THEN 1
            ELSE 0
        END
    ) AS cancelled_orders,
    ROUND(
        SUM(
            CASE
                WHEN o.order_status = 'Cancelled' THEN 1
                ELSE 0
            END
        )::numeric
        / COUNT(*) * 100,
        2
    ) AS cancellation_rate_percent
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.state
ORDER BY cancellation_rate_percent DESC;

-- Key observations:
-- Cancellation rates are relatively similar across most states,
-- generally remaining within a range of approximately 2.5%–3.7%.
-- Indiana has the highest cancellation rate, while North Carolina
-- has the lowest.
-- The variation does not appear to be explained by shipping costs,
-- suggesting that other operational or customer-related factors
-- may contribute to cancellation differences.


-- =====================================================
-- 5. Payment Methods
-- =====================================================

-- 5.1 Revenue by Payment Method
-- Explore the contribution of different payment methods
-- to overall revenue.

SELECT
    payment_method,
    COUNT(order_id) AS orders,
    SUM(total_amount) AS revenue
FROM orders
GROUP BY payment_method
ORDER BY revenue DESC;

-- Key observations:
-- Credit Card is the dominant payment method, accounting for the largest
-- share of both orders and revenue.
-- Cancellation rates are relatively consistent across payment methods,
-- with only limited variation between the highest and lowest rates.
-- This suggests that payment method is unlikely to be a major driver
-- of order cancellations.

--------------------------------------------------------------------


-- 5.2 Cancellation Rate by Payment Method
-- Explore whether cancellation rates differ
-- across payment methods.

SELECT
    payment_method,
    COUNT(*) AS total_orders,
    SUM(
        CASE
            WHEN order_status = 'Cancelled' THEN 1
            ELSE 0
        END
    ) AS cancelled_orders,
    ROUND(
        SUM(
            CASE
                WHEN order_status = 'Cancelled' THEN 1
                ELSE 0
            END
        )::numeric
        / COUNT(*) * 100,
        2
    ) AS cancellation_rate_percent
FROM orders
GROUP BY payment_method
ORDER BY cancellation_rate_percent DESC;


-- =====================================================
-- 6. Order Status
-- =====================================================

-- 6.1 Overall Order Status Distribution
-- Understand the overall mix of delivered, cancelled,
-- shipped, and returned orders.

SELECT
    order_status,
    COUNT(*) AS orders,
    ROUND(
        COUNT(*)::numeric
        / SUM(COUNT(*)) OVER () * 100,
        2
    ) AS order_share_percent
FROM orders
GROUP BY order_status
ORDER BY orders DESC;

-- Key observations:
-- Delivered orders account for approximately 75% of all orders.
-- However, the distribution of order statuses should be interpreted
-- with caution because the dataset does not provide a clear status
-- transition history.
-- In particular, the relationship between Shipped and Delivered statuses
-- cannot be validated from the available data.
--------------------------------------------------------------------

-- 6.2 Monthly Cancellation Rate
-- Explore whether cancellation rates show
-- recurring temporal patterns or anomalies.

SELECT
    DATE_TRUNC('month', order_date) AS month,
    ROUND(
        SUM(
            CASE
                WHEN order_status = 'Cancelled' THEN 1
                ELSE 0
            END
        )::numeric
        / COUNT(*) * 100,
        2
    ) AS monthly_cancellation_rate_percent
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;


-- =====================================================
-- 7. Seasonality
-- =====================================================

-- 7.1 Revenue by Month Across All Years
-- Identify recurring seasonal patterns by calendar month.

SELECT
    EXTRACT(MONTH FROM order_date) AS month,
    SUM(total_amount) AS total_revenue,
    AVG(total_amount) AS avg_order_value
FROM orders
GROUP BY EXTRACT(MONTH FROM order_date)
ORDER BY month;

-- Key observations:
-- February is the weakest month by total revenue across the five-year period.
-- April and October have relatively high AOV, while February and August
-- show lower AOV levels.
-- The recurring monthly revenue pattern suggests that seasonality
-- should be considered when evaluating year-over-year performance.

--------------------------------------------------------------------


-- 7.2 Revenue by Year and Month
-- Examine whether seasonal patterns are consistent
-- across individual years.

SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(MONTH FROM order_date) AS month,
    SUM(total_amount) AS revenue
FROM orders
GROUP BY
    EXTRACT(YEAR FROM order_date),
    EXTRACT(MONTH FROM order_date)
ORDER BY year, month;