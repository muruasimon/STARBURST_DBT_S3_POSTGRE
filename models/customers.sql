{{
config(
materialized='view'
)
}}

WITH customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

payments AS (
    SELECT * FROM {{ ref('stg_payments') }}
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
