-- Provide the list of markets in which customer  "Atliq  Exclusive"  operates its business in the  APAC  region.
#TASK 1
SELECT 
DISTINCT market FROM dim_customer 
WHERE customer="Atliq Exclusive" AND region = 'APAC';

#TASK 2
-- What is the percentage of unique product increase in 2021 vs. 2020?  

WITH unique_products AS (
  SELECT 
      fiscal_year,
      COUNT(DISTINCT product_code) AS unique_products
  FROM fact_gross_price
  GROUP BY fiscal_year
  )
  SELECT 
       up_2020.unique_products AS unique_products_2020,
	   up_2021.unique_products AS unique_products_2021,
       ROUND((up_2021.unique_products - up_2020.unique_products)/up_2020.unique_products*100,2) AS percentage_change
FROM 
    unique_products up_2020
CROSS JOIN
    unique_products up_2021
WHERE
    up_2020.fiscal_year=2020 
AND up_2021.fiscal_year=2021;

#TASK 3
 -- Provide a report with all the unique product counts for each  segment  and sort them in descending order of product counts.
SELECT segment,COUNT(DISTINCT product_code) AS product_count
FROM dim_product
GROUP BY segment
ORDER BY product_count DESC;

#TASK 4
--  Follow-up: Which segment had the most increase in unique products in 2021 vs 2020? The final output contains these fields, 

WITH temp_table AS (
      SELECT 
          p.segment,
          s.fiscal_year,
          COUNT(DISTINCT s.product_code) AS product_count
	  FROM 
          fact_sales_monthly s 
	  JOIN dim_product p ON s.product_code=p.product_code
      GROUP BY
       p.segment,
       s.fiscal_year
)
SELECT
     up_2020.segment,
     up_2020.product_count AS product_count_2020,
	 up_2021.product_count AS product_count_2021,
     up_2021.product_count - up_2020.product_count AS difference
FROM 
    temp_table AS up_2020
JOIN 
    temp_table AS up_2021
ON 
   up_2020.segment= up_2021.segment
   AND up_2020.fiscal_year=2020
   AND up_2021.fiscal_year=2021
ORDER BY
   difference DESC;
   
   #TASK 5 
   --  Get the products that have the highest and lowest manufacturing costs. 
SELECT m.product_code,CONCAT(product,"(",variant,")") AS product , cost_year,manufacturing_cost
FROM fact_manufacturing_cost m 
JOIN dim_product p ON p.product_code=m.product_code
WHERE manufacturing_cost =
  (SELECT min(manufacturing_cost) FROM fact_manufacturing_cost)
  OR 
  (SELECT max(manufacturing_cost) FROM fact_manufacturing_cost)
ORDER BY manufacturing_cost DESC;

