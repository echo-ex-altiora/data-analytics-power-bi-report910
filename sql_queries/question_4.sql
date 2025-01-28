CREATE VIEW sales_by_store_type AS 
SELECT
	store_type,
    SUM(product_quantity * sale_price) AS total_sales,
	SUM(product_quantity * sale_price) * 100 / (
                    SELECT SUM(product_quantity * sale_price)
                    FROM dim_products
                    JOIN orders ON orders.product_code = dim_products.product_code 
                    ) AS percentage_of_total_sales,
    COUNT(orders) AS total_orders
FROM dim_products
JOIN orders ON orders.product_code = dim_products.product_code
JOIN dim_stores ON dim_stores.store_code = orders.store_code
GROUP BY store_type




