# SQL Sales Analysis and Customer Insights

## 📌 Project Overview

This project uses Microsoft SQL Server to perform Exploratory Data Analysis (EDA) on sales data and generate insights into business performance, product sales, and customer behavior.

The project analyzes sales trends over time, evaluates product and category performance, segments customers based on spending behavior, and builds a customer report containing key business metrics.

## 🎯 Project Objectives

- Analyze monthly and yearly sales performance.
- Calculate total sales, customer counts, and quantities sold.
- Evaluate running sales totals and average price trends.
- Compare yearly product sales against average performance and previous-year sales.
- Identify product categories contributing the most to overall revenue.
- Segment products based on cost ranges.
- Classify customers into VIP, Regular, and New segments.
- Create a customer report with business KPIs for further analysis.

## 🛠️ Tools & Technologies

- **Microsoft SQL Server** — Database engine and SQL analysis.
- **SQL Server Management Studio (SSMS)** — Query development and execution.
- **T-SQL** — Data exploration, aggregation, segmentation, and reporting.

## 📊 SQL Concepts Used

- Aggregate Functions: `SUM()`, `AVG()`, `COUNT()`, `MIN()`, `MAX()`
- Filtering and Sorting: `WHERE`, `ORDER BY`
- Data Grouping: `GROUP BY`
- Table Joins: `LEFT JOIN`
- Conditional Logic: `CASE WHEN`
- Common Table Expressions (CTEs)
- Subqueries and derived tables
- Window Functions: `SUM() OVER()`, `AVG() OVER()`, `LAG() OVER()`
- Date Functions: `YEAR()`, `MONTH()`, `DATETRUNC()`, `DATEDIFF()`
- String Functions: `CONCAT()`, `FORMAT()`
- Type Conversion and Formatting: `CAST()`, `ROUND()`
- SQL Views: `CREATE VIEW`

## 🔍 Analysis Performed

### 1. Sales Trend Analysis

- Analyzed sales by year and month.
- Calculated total sales, distinct customers, and total quantities sold.
- Aggregated sales data at different time granularities.

### 2. Running Total and Average Analysis

- Explored monthly sales totals over time.
- Calculated average product prices by month.
- Used SQL window functions to analyze changes in performance over time.

### 3. Product Performance Analysis

- Compared yearly product sales with average yearly performance.
- Compared current-year sales against previous-year sales.
- Classified product performance as above average, below average, or average.
- Identified increases and decreases in yearly sales.

### 4. Category Contribution Analysis

- Calculated total sales for each product category.
- Measured each category's percentage contribution to overall sales.
- Ranked categories by sales contribution.

### 5. Product Cost Segmentation

- Grouped products into cost ranges.
- Counted the number of products in each segment.
- Compared the distribution of products across cost categories.

### 6. Customer Segmentation

Classified customers according to spending and customer lifespan:

- **VIP:** At least 12 months of history and spending above 5,000.
- **Regular:** At least 12 months of history and spending of 5,000 or less.
- **New:** Customer lifespan below 12 months.

The analysis also calculates the number of customers in each segment.

### 7. Customer Report and Business KPIs

Created a SQL view named `gold.report_customers` to consolidate customer information and metrics, including:

- Customer details and age groups.
- Customer segments.
- Total orders and total sales.
- Total quantity purchased.
- Number of distinct products purchased.
- Customer lifespan in months.
- Recency, measured in months since the last order.
- Average order value.
- Average monthly spend.

## 📁 Project Structure

```text
sql-exploratory-data-analysis/
│
├── README.md
├── exploratory_data_analysis.sql
└── dataset.csv
```

The SQL script contains the analysis queries and customer reporting logic. Include the dataset only if it is available and permitted to be shared.

## 💡 Key Learnings

- Applying SQL to business-oriented data analysis.
- Aggregating data across different time periods.
- Using window functions for comparative analysis.
- Measuring product and category performance.
- Creating customer segments using business rules.
- Building SQL views for reusable reporting.
- Converting raw data into metrics that support business decisions.

## 🚀 How to Run the Project

1. Open Microsoft SQL Server Management Studio (SSMS).
2. Connect to your SQL Server instance.
3. Restore or load the database containing the required `gold` schema and tables.
4. Open the SQL script in SSMS.
5. Verify that the required tables and columns exist.
6. Execute the queries in the appropriate order.
7. Create the customer report view and query it to inspect the results.

**Required tables:**
- `gold.fact_sales`
- `gold.dim_products`
- `gold.dim_customers`

## 👨‍💻 Author

**Prathamesh Hedgotre**

Aspiring Data Analyst | SQL | Power BI | Excel | Python

## 📌 Conclusion

This project demonstrates practical SQL skills for exploratory data analysis, sales performance evaluation, product analysis, customer segmentation, and KPI reporting using Microsoft SQL Server.
# SQL-Sales-Analysis-Customer-Insights
SQL-based Sales Analysis and Customer Insights using Microsoft SQL Server (SSMS). Analyzes sales trends, product performance, category contribution, customer segments, and business KPIs using aggregations, window functions, and SQL views.
