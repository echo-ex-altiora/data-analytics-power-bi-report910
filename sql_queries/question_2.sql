WITH revenue_by_month AS (
    SELECT month_name, 
            SUM(orders.product_quantity * dim_products.sale_price) AS month_revenue
    FROM dim_date 
    JOIN orders ON orders.order_date = dim_date.date 
    JOIN dim_products ON orders.product_code = dim_products.product_code
    WHERE order_date LIKE '%22' 
    GROUP BY month_name
)
SELECT month_name AS highest_revenue_month_2022
FROM revenue_by_month
WHERE month_revenue= (
    SELECT MAX(month_revenue)
    FROM revenue_by_month)
