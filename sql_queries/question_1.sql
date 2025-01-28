SELECT SUM(staff_numbers) AS total_number_staff_uk_store
FROM dim_stores
WHERE country_code LIKE 'GB%'
