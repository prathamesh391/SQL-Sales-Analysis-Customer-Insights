SELECT 
YEAR(order_date) AS order_year,
MONTH(order_date) AS order_month,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
GROUP BY 
YEAR(order_date),
MONTH(order_date) 
ORDER BY 
YEAR(order_date),
MONTH(order_date)

SELECT 
DATETRUNC(year, order_date) AS order_date,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
GROUP BY 
DATETRUNC(year, order_date) 
ORDER BY 
DATETRUNC(year, order_date)

SELECT 
FORMAT(order_date, 'yyyy-MMM') AS order_date,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
GROUP BY 
FORMAT(order_date, 'yyyy-MMM') 
ORDER BY 
FORMAT(order_date, 'yyyy-MMM') 

--Calculate the total sales per month
--and running total of sales over time

SELECT
order_date,
total_sales,
SUM(total_sales) OVER (PARTITION BY order_date ORDER BY order_date) AS running_total_sales
FROM
(
SELECT
DATETRUNC(month, order_date) AS order_date,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)  
)t

--Calculate the avg_price per month
--and running avg of sales over time

SELECT
order_date,
total_sales,
SUM(total_sales) OVER (PARTITION BY order_date ORDER BY order_date) AS running_total_sales,
AVG(avg_price) OVER (PARTITION BY order_date ORDER BY order_date) AS moving_average_price
FROM
(
SELECT
DATETRUNC(month, order_date) AS order_date,
SUM(sales_amount) AS total_sales,
AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)  
)t

--Analyze the yearly performance of products by comparing each 
--products saels to both its average sales performance and the previous years sales

WITH yearly_product_sales AS (
SELECT 
YEAR(f.order_date) AS order_year,
p.product_name,
SUM(f.sales_amount) current_sales
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL
GROUP BY
YEAR(f.order_date), 
p.product_name
)

SELECT
order_year,
product_name,
current_sales,
AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above_avg'
	 WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below_avg'
	 ELSE 'Avg'
END avg_change,
--year over year analyses
LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS previous_year_sales,
current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_yr,
CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
	 WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
	 ELSE 'No Change'
END py_change
FROM yearly_product_sales
ORDER BY 
product_name,
order_year

--Which categoires contribute the most to overall sales?
WITH category_sales AS (
SELECT 
category,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
GROUP BY category
)

SELECT 
category,
total_sales,
SUM(total_sales) OVER () overall_sales,
CONCAT(ROUND((CAST(total_sales AS FLOAT)/ SUM(total_sales) OVER ()) * 100,2), '%') AS percentage_of_total 
FROM category_sales
ORDER BY total_sales DESC

--Segment products into cost ranges and count how many products fail into each segment
WITH product_segment AS (
SELECT 
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
	 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	 ELSE 'Above 1000'
END AS cost_range
FROM gold.dim_products)

SELECT 
cost_range,
COUNT(product_key) AS total_products
FROM product_segment
GROUP BY cost_range
ORDER BY total_products DESC

--Group customers into three segments based on their spending behaviour:
	--VIP: Customers with at least 12 months of history and spending more than 5,0000,
	--Regular: Customers with at least 12 months of history but spending 5,000 or less.
	--New: Customers with a lifespan less than 12 months.
--And find the total number of customers by each group

WITH customer_spending AS (
SELECT 
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(order_date) AS first_order,
MAX(order_date) AS last_order,
DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key)

SELECT 
customer_segment,
COUNT(customer_key) AS total_customers
FROM (
SELECT 
customer_key,
total_spending,
lifespan,
CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
	 WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
	 ELSE 'New'
END AS customer_segment
FROM customer_spending) t
GROUP BY customer_segment
ORDER BY total_customers DESC

/* Customer Report 
Purpose:
	- This report consolidates key customers metrics and behaviours 

Highlights:
	1. Gathers essential fields such as names, ages, and transaction details.
	2. segments customers into categodries (VIP, Regualr, New)
	and age groups report.
	3.Aggregates customers-level metrics :
		- total orders
		- total sales 
		- total quantity purchased
		- lifespan (in month)
	4.Calculate valuable KPIS:
		- recency (months since last order)
		- average order value 
		- average monthly spend
*/


CREATE VIEW gold.report_customers AS  
WITH base_query AS (
--1) Base Query: Retrives core columns from tables
SELECT 
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name, ' ',c.last_name) AS customer_name,
DATEDIFF(year, c.birthdate, GETDATE()) AS age
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
ON f.customer_key = c.customer_key
WHERE order_date IS NOT NULL)
,
--2) Customer Aggregation: Summarize key metrics at the customer level
customer_aggregation AS (
SELECT 
customer_key,
customer_number,
customer_name,
age,
COUNT(DISTINCT order_number) AS total_orders,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_quantity,
COUNT(DISTINCT product_key) AS total_products,
MAX(order_date) AS last_order,
DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY  
customer_key,
customer_number,
customer_name,
age)

SELECT
customer_key,
customer_number,
customer_name,
age,
CASE 
	WHEN age < 20 THEN 'Under 20'
	 WHEN age BETWEEN 20 AND 29 THEN '20-29'
	 WHEN age BETWEEN 30 AND 39 THEN '30-39'
	 WHEN age BETWEEN 40 AND 49 THEN '40-49'
	 ELSE '50 and above'
END AS age_group,
CASE 
	WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
	 WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
	 ELSE 'New'
END customer_segment,
last_order,
DATEDIFF(month, last_order, GETDATE()) AS recency,
total_orders,
total_sales,
total_quantity,
total_products,
lifespan,
--Compute average order value (AVO)
CASE WHEN total_orders = 0 THEN 0
ELSE total_sales / total_orders
END AS avg_order_value,

--Compute average monthly spend 
CASE WHEN lifespan = 0 THEN total_sales
	 ELSE total_sales / lifespan 
END AS avg_monthly_spend
FROM customer_aggregation

SELECT * FROM gold.report_customers