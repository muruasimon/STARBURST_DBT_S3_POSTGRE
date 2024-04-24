SELECT
     id AS payment_id,
     order_id AS order_id,
     paymentmethod AS payment_type,
     amount
FROM dbts3.land_jaffle_shop.stripe_payments
WHERE paymentmethod = 'gift_card' AND status = 'success'