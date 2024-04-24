SELECT
     id AS order_id,
     user_id AS customer_id,
     order_date,
     status
FROM dbt_postgresql.jaffle_shop.jaffle_shop_orders