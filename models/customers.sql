{{
   config(
     materialized='view'
   )
}}

WITH customers AS (
    SELECT
        id AS customer_id,
        first_name,
        last_name
    FROM dbt_postgresql.jaffle_shop.jaffle_shop_customers
),
orders AS (
    SELECT
        id AS order_id,
        user_id as customer_id,
        order_date,
        status
    FROM dbt_postgresql.jaffle_shop.jaffle_shop_orders
),
payments AS (
    SELECT
        id AS payment_id,
        order_id AS order_id,
        paymentmethod AS payment_type,
        amount
    FROM dbts3.land_jaffle_shop.stripe_payments
    WHERE paymentmethod = 'gift_card' AND status = 'success'
),
customer_orders AS (
    SELECT
        p.payment_type,
        o.customer_id,
        MIN(o.order_date) AS first_order_date,
        MAX(o.order_date) AS most_recent_order_date,
        COUNT(o.order_id) AS number_of_orders,
        SUM(cast(p.amount as int)) AS total_order_amount
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY 1, 2
),
final AS (
    SELECT
        customer_orders.payment_type,
        customer_orders.total_order_amount,
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        customer_orders.first_order_date,
        customer_orders.most_recent_order_date,
        COALESCE(customer_orders.number_of_orders, 0) AS number_of_orders
    FROM customers
    JOIN customer_orders ON customers.customer_id = customer_orders.customer_id
)
SELECT * FROM final