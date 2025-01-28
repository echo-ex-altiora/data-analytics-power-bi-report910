WITH revenue_by_store_type AS (
    SELECT 
        store_type, 
        SUM(orders.product_quantity * dim_products.sale_price) AS store_type_revenue
    FROM dim_products
    JOIN orders ON orders.product_code = dim_products.product_code
    JOIN dim_stores ON dim_stores.store_code = orders.store_code
    WHERE country_code = 'DE' AND order_date LIKE '%22'
    GROUP BY store_type
)
SELECT store_type AS highest_revenue_german_store_type_2022
FROM revenue_by_store_type
WHERE store_type_revenue = (
    SELECT MAX(store_type_revenue)
    FROM revenue_by_store_type)