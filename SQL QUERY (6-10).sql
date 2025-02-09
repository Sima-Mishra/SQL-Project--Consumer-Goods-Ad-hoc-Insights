#TASK 6
-- Q6. Generate a report which contains the top 5 customers who received an average high pre_invoice_discount_pct for the fiscal year 2021 and in the Indian market. 
-- The final output contains these fields, 
-- customer_code 
-- customer 
-- average_discount_percentage
	
SELECT c.customer_code,c.customer,ROUND(AVG(pre_invoice_discount_pct),4) AS average_discount_percentage
FROM fact_pre_invoice_deductions d
JOIN dim_customer c ON c.customer_code=d.customer_code
WHERE c.market = "India" AND fiscal_year = "2021"
GROUP BY customer_code
ORDER BY average_discount_percentage DESC
LIMIT 5;

#TASK 7 
-- Q7. Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each month . 
-- This analysis helps to get an idea of low and high-performing months and take strategic decisions. 
-- The final report contains these columns: 
-- Month 
-- Year 
-- Gross sales Amount
	
WITH temp_table AS (
     SELECT customer,
            monthname(date) AS months,
            month(date) AS month_number,
            year(date) AS year,
            (sold_quantity * gross_price) AS gross_sales
	 FROM fact_sales_monthly s 
     JOIN fact_gross_price g ON g.product_code = s.product_code
     JOIN dim_customer c ON c.customer_code = s.customer_code
     WHERE customer = "Atliq Exclusive"
	)
    SELECT months,year,CONCAT(ROUND(sum(gross_sales)/1000000,2),"M") AS gross_sales FROM temp_table
    GROUP BY year,months
    ORDER BY year,month_number;
    
    #TASK 8 
-- Q8. In which quarter of 2020, got the maximum total_sold_quantity? 
-- The final output contains these fields sorted by the total_sold_quantity,
-- Quarter 
-- total_sold_quantity
	    
WITH temp_table AS(
   SELECT *,
          CASE 
          WHEN month(s.date) in (9,10,11) then "Q1"
          WHEN month(s.date) in (12,1,2) then "Q2"
          WHEN month(s.date) in (3,4,5) then "Q3"
          ELSE "Q4"
          END AS Quarter
	FROM fact_sales_monthly as s 
    WHERE fiscal_year = 2020
    )
    SELECT Quarter,SUM(sold_quantity) AS total_sold_quantity
    FROM temp_table 
    GROUP BY Quarter
    ORDER BY total_sold_quantity DESC;
    
    #TASK 9
-- Q9. Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution? 
-- The final output contains these fields, 
-- channel 
-- gross_sales_mln 
-- percentage
	    
   WITH temp_table AS(
      SELECT c.channel,
      ROUND(SUM(s.sold_quantity*g.gross_price)/1000000,2) AS gross_sales_mln
      FROM dim_customer c 
      JOIN fact_sales_monthly s 
        ON c.customer_code=s.customer_code
      JOIN fact_gross_price g 
        ON g.product_code=s.product_code
        AND g.fiscal_year=s.fiscal_year 
	WHERE s.fiscal_year = 2021 
    GROUP BY channel
    ORDER BY gross_sales_mln DESC )
    SELECT *,
          CONCAT(ROUND(gross_sales_mln*100/SUM(gross_sales_mln) over(),2),"%") AS percentage
	FROM temp_table;

#TASK 10 
-- Q10. Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021? 
-- The final output contains these fields, 
-- division 
-- product_code	
WITH temp_table AS (
    select division,
    s.product_code, 
    concat(p.product,"(",p.variant,")") AS product ,
    sum(sold_quantity) AS total_sold_quantity,
    rank() OVER (partition by division order by sum(sold_quantity) desc) AS rank_order
 FROM
 fact_sales_monthly s
 JOIN dim_product p
 ON s.product_code = p.product_code
 WHERE fiscal_year = 2021
 GROUP BY product_code
)
SELECT * FROM temp_table
WHERE rank_order IN (1,2,3);











     
            
