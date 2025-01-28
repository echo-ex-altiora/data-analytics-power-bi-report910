WITH profit_by_category AS (
    SELECT 
        category, 
        SUM(orders.product_quantity * (dim_products.sale_price - dim_products.cost_price)) AS category_profit
    FROM dim_products
    JOIN orders ON orders.product_code = dim_products.product_code
    JOIN dim_stores ON dim_stores.store_code = orders.store_code
    WHERE country_code = 'GB' AND country_region = 'Wiltshire' AND order_date LIKE '%21'
    GROUP BY category
)
SELECT category AS most_profitable_product_category_Wiltshire_UK_2021
FROM profit_by_category
WHERE category_profit = (
    SELECT MAX(category_profit)
    FROM profit_by_category)