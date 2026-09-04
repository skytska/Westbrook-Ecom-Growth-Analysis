-- ===========================================
-- Data Validation for Amazon Sales Analysis
-- ===========================================


-- ===========================================
-- 1. Row Count Checks
-- ===========================================

SELECT
    'orders' AS table_name,
    COUNT(*) AS row_count
FROM public.orders

UNION ALL

SELECT
    'customers' AS table_name,
    COUNT(*) AS row_count
FROM public.customers

UNION ALL

SELECT
    'products' AS table_name,
    COUNT(*) AS row_count
FROM public.products;


-- ===========================================
-- 2. Duplicate Checks
-- ===========================================

-- Duplicate Order IDs
SELECT
    order_id,
    COUNT(*) AS order_count
FROM public.orders
GROUP BY order_id
HAVING COUNT(*) > 1;


-- Duplicate Customer IDs
SELECT
    customer_id,
    COUNT(*) AS customer_count
FROM public.customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- Duplicate Product IDs
SELECT
    product_id,
    COUNT(*) AS product_count
FROM public.products
GROUP BY product_id
HAVING COUNT(*) > 1;


-- ===========================================
-- 3. NULL Checks
-- ===========================================

-- Orders
SELECT
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS null_quantity,
    SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS null_unit_price,
    SUM(CASE WHEN discount IS NULL THEN 1 ELSE 0 END) AS null_discount,
    SUM(CASE WHEN tax IS NULL THEN 1 ELSE 0 END) AS null_tax,
    SUM(CASE WHEN shipping_cost IS NULL THEN 1 ELSE 0 END) AS null_shipping_cost,
    SUM(CASE WHEN total_amount IS NULL THEN 1 ELSE 0 END) AS null_total_amount,
    SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS null_order_status,
    SUM(CASE WHEN payment_method IS NULL THEN 1 ELSE 0 END) AS null_payment_method
FROM public.orders;


-- Customers
SELECT
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN customer_name IS NULL THEN 1 ELSE 0 END) AS null_customer_name,
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) AS null_state,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS null_country
FROM public.customers;


-- Products
SELECT
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) AS null_product_name,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN brand IS NULL THEN 1 ELSE 0 END) AS null_brand
FROM public.products;


-- ===========================================
-- 4. Referential Integrity Checks
-- ===========================================

-- Orders without a matching customer
SELECT
    o.order_id,
    o.customer_id
FROM public.orders o
LEFT JOIN public.customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- Orders without a matching product
SELECT
    o.order_id,
    o.product_id
FROM public.orders o
LEFT JOIN public.products p
    ON o.product_id = p.product_id
WHERE p.product_id IS NULL;


-- ===========================================
-- 5. Distinct Value Checks
-- ===========================================

-- Order statuses
SELECT DISTINCT order_status
FROM public.orders
ORDER BY 1;


-- Payment methods
SELECT DISTINCT payment_method
FROM public.orders
ORDER BY 1;


-- Product categories
SELECT DISTINCT category
FROM public.products
ORDER BY 1;


-- Countries
SELECT DISTINCT country
FROM public.customers
ORDER BY 1;


-- ===========================================
-- 6. Date Range Check
-- ===========================================

SELECT
    MIN(order_date) AS earliest_order_date,
    MAX(order_date) AS latest_order_date
FROM public.orders;


-- ===========================================
-- 7. Numeric Range Checks
-- ===========================================

-- Quantity
SELECT
    MIN(quantity) AS min_quantity,
    MAX(quantity) AS max_quantity
FROM public.orders;


-- Unit price
SELECT
    MIN(unit_price) AS min_unit_price,
    MAX(unit_price) AS max_unit_price
FROM public.orders;


-- Discount
SELECT
    MIN(discount) AS min_discount,
    MAX(discount) AS max_discount
FROM public.orders;


-- Tax
SELECT
    MIN(tax) AS min_tax,
    MAX(tax) AS max_tax
FROM public.orders;


-- Shipping cost
SELECT
    MIN(shipping_cost) AS min_shipping_cost,
    MAX(shipping_cost) AS max_shipping_cost
FROM public.orders;


-- Total amount
SELECT
    MIN(total_amount) AS min_total_amount,
    MAX(total_amount) AS max_total_amount
FROM public.orders;


-- ===========================================
-- 8. Basic Business Logic Checks
-- ===========================================

-- Orders with non-positive quantity
SELECT *
FROM public.orders
WHERE quantity <= 0;


-- Orders with non-positive unit price
SELECT *
FROM public.orders
WHERE unit_price <= 0;


-- Orders with negative financial values
SELECT
    order_id,
    discount,
    tax,
    shipping_cost,
    total_amount
FROM public.orders
WHERE discount < 0
   OR tax < 0
   OR shipping_cost < 0
   OR total_amount < 0;


-- Orders with zero total amount
SELECT
    order_id,
    total_amount
FROM public.orders
WHERE total_amount = 0;