/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouseAnalytics' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, this script creates a schema called gold
	
WARNING:
    Running this script will drop the entire 'DataWarehouseAnalytics' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'DataWarehouseAnalytics' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseAnalytics')
BEGIN
    ALTER DATABASE DataWarehouseAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouseAnalytics;
END;
GO

-- Create the 'DataWarehouseAnalytics' database
CREATE DATABASE DataWarehouseAnalytics;
GO

USE DataWarehouseAnalytics;
GO

-- Create Schemas

CREATE SCHEMA gold;
GO

CREATE TABLE gold.dim_customers(
	customer_key int,
	customer_id int,
	customer_number nvarchar(50),
	first_name nvarchar(50),
	last_name nvarchar(50),
	country nvarchar(50),
	marital_status nvarchar(50),
	gender nvarchar(50),
	birthdate date,
	create_date date
);
GO

CREATE TABLE gold.dim_products(
	product_key int ,
	product_id int ,
	product_number nvarchar(50) ,
	product_name nvarchar(50) ,
	category_id nvarchar(50) ,
	category nvarchar(50) ,
	subcategory nvarchar(50) ,
	maintenance nvarchar(50) ,
	cost int,
	product_line nvarchar(50),
	start_date date 
);
GO

CREATE TABLE gold.fact_sales(
	order_number nvarchar(50),
	product_key int,
	customer_key int,
	order_date date,
	shipping_date date,
	due_date date,
	sales_amount int,
	quantity tinyint,
	price int 
);
GO

TRUNCATE TABLE gold.dim_customers;
GO

BULK INSERT gold.dim_customers
FROM 'D:\SQL\sql-data-analytics-project\sql-data-analytics-project\datasets\csv-files\gold.dim_customers.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE gold.dim_products;
GO

BULK INSERT gold.dim_products
FROM 'D:\SQL\sql-data-analytics-project\sql-data-analytics-project\datasets\csv-files\gold.dim_products.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE gold.fact_sales;
GO

BULK INSERT gold.fact_sales
FROM 'D:\SQL\sql-data-analytics-project\sql-data-analytics-project\datasets\csv-files\gold.fact_sales.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

-- Database Exploration
-- Explore all objects in the Database
select * from INFORMATION_SCHEMA.TABLES

--Explore all columns in the database
select * from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'dim_customers'


--Dimention Exploration
--Explore all countries our customers come from
select DISTINCT country from gold.dim_customers

--Explore all categories 'the major Divisions'
select DISTINCT category, subcategory, product_name from gold.dim_products 
order by 1,2,3



--Date Exploration
--Find the date of the first and last order
--How many years of sales are available
select 
MIN(order_date) as first_order_date,
MAX(order_date) as last_order_date,
DATEDIFF(month,min(order_date), max(order_date)) as order_range_months
from gold.fact_sales

-- Find the youngest and the oldest customer
select 
MIN(birthdate) as first_order_date,
DATEDIFF(YEAR,min(birthdate), GETDATE()) as oldest_age,
MAX(birthdate) as last_order_date,
DATEDIFF(YEAR,max(birthdate), GETDATE()) as youngest_age
from gold.dim_customers


--Measure Exploration
--Find how many itmes are sold
select sum(quantity) as total_quantity from gold.fact_sales

--Find the average selling price
select avg(price) as avg_price from gold.fact_sales

--Find the Total number of Orders
select count(order_number) as total_orders from gold.fact_sales      
select count(distinct order_number) as total_orders from gold.fact_sales      

--Find the total number of products
select count(product_name) as total_products from gold.dim_products      
select count(distinct product_name) as total_products from gold.dim_products      

--Find the total number of customers
select count(customer_key) as total_customers from gold.dim_customers      

--Find the total number of customers that has placed an order
select count(distinct customer_key) as total_customers from gold.fact_sales      


--Generate a report that show all key metrics of the business
select 'Total Sales' as measure_name, sum(sales_amount) as measure_value from gold.fact_sales
union all
select 'Total Quantity', sum(quantity) from gold.fact_sales
union all
select 'Average Price', avg(price) from gold.fact_sales
union all
select 'Total Nr. Orders', count(distinct order_number) from gold.fact_sales
union all
select 'Total Nr. Products', count(product_name) from gold.dim_products
union all
select 'Total Nr. Customers', count(customer_key) from gold.dim_customers


--Magnitude analysis
--Find total customers by countries
select 
country,
count(customer_key) as total_customers
from gold.dim_customers
group by country
order by total_customers desc

--Find total customers by gender
select 
gender,
count(customer_key) as total_customers
from gold.dim_customers
group by gender
order by total_customers desc

--Find total product by category
select 
category,
count(product_key) as total_products
from gold.dim_products
group by category
order by total_products desc

--What is the average costs in each category?
select 
category,
avg(cost) as avg_cost
from gold.dim_products
group by category
order by avg_cost desc

--What is the total revenue  generated for each category?
select
p.category,
sum(f.sales_amount) as total_revenue
from gold.fact_sales f
left join gold.dim_products p
on p.product_key = f.product_key
group by p.category
order by total_revenue desc

--Find is the total revenue generated by each customer?
select 
c.customer_key,
c.first_name,
c.last_name,
sum(f.sales_amount) as total_revenue
from gold.fact_sales f
left join gold.dim_customers c
on c.customer_key = f.customer_key
group by c.customer_key,
c.first_name,
c.last_name
order by total_revenue desc

--What is the distribution of solid items across countries?
select 
c.country,
sum(f.quantity) as total_sold_items
from gold.fact_sales f
left join gold.dim_customers c
on c.customer_key = f.customer_key
group by c.country
order by total_sold_items desc


--Ranking
--Which 5 products generate the highest revenue
select top 5
p.product_name,
sum(f.sales_amount) as total_revenue
from gold.fact_sales f
left join gold.dim_products p
on p.product_key = f.product_key
group by p.product_name
order by total_revenue desc

--What are the 5 worst-performing products in terms of sales
select top 5
p.product_name,
sum(f.sales_amount) as total_revenue
from gold.fact_sales f
left join gold.dim_products p
on p.product_key = f.product_key
group by p.product_name
order by total_revenue asc

--Which 5 Subcategory generate the highest revenue
select top 5
p.subcategory,
sum(f.sales_amount) as total_revenue
from gold.fact_sales f
left join gold.dim_products p
on p.product_key = f.product_key
group by p.subcategory
order by total_revenue desc

--Which 5 products generate the highest revenue using window function
select *
from(
select
p.product_name,
sum(f.sales_amount) as total_revenue,
row_number() over(order by sum(f.sales_amount) desc) as rank_products
from gold.fact_sales f
left join gold.dim_products p
on p.product_key = f.product_key
group by p.product_name)t
where rank_products<=5

--Find the top 10 customers who have generated the highest revenue  
select top 10
c.customer_key,
c.first_name,
c.last_name,
sum(f.sales_amount) as total_revenue
from gold.fact_sales f
left join gold.dim_customers c
on c.customer_key = f.customer_key
group by c.customer_key,
c.first_name,
c.last_name
order by total_revenue desc

--the 3 customers with the fewest orders placed
select top 3
c.customer_key,
c.first_name,
c.last_name,
count(distinct order_number) as total_orders
from gold.fact_sales f
left join gold.dim_customers c
on c.customer_key = f.customer_key
group by c.customer_key,
c.first_name,
c.last_name
order by total_orders asc

--Analyza sales performance over time
select
year(order_date) as order_year,
sum(sales_amount) as total_Sales,
count(distinct customer_key)as total_customers,
sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by year(order_date)
order by year(order_date)

--cumulative analysis
--Calculate the total sales per month and the running total of sales over time and moving average
select
order_date,
total_sales,
sum(total_sales) over(order by order_date ) as running_total_sales,
avg(avg_price) over(order by order_date ) as moving_avg_price

from
(
select 
datetrunc(month,order_date) as order_date,
sum(sales_amount) as total_sales,
avg(price) as avg_price
from gold.fact_sales
where order_date is not null
group by datetrunc(month,order_date)
) t


--performance analysis
--analyze the yearly performance of products by comparing each products sales to both 
--its average sales performance and the previous years sales
with yearly_product_sales as(
select
year(f.order_date) as order_year,
p.product_name,
sum(f.sales_amount) as current_sales
from gold.fact_sales f
left join gold.dim_products p
on f.product_key = p.product_key
where order_date is not null
group by year(f.order_date) , p.product_name
)
select 
order_year,
product_name,
current_sales,
avg(current_sales) over(partition by product_name) avg_sales,
current_sales-avg(current_sales) over(partition by product_name) as diff_avg,
case when current_sales-avg(current_sales) over(partition by product_name) > 0 then 'Above avg'
	when current_sales-avg(current_sales) over(partition by product_name) < 0 then 'Below avg'
	else 'avg'
end avg_change,
LAG(current_sales) over(partition by product_name order by order_year) py_sales,
current_sales - LAG(current_sales) over(partition by product_name order by order_year) as diff_py,
case when current_sales-LAG(current_sales) over(partition by product_name order by order_year) > 0 then 'Increase'
	when current_sales-LAG(current_sales) over(partition by product_name order by order_year) < 0 then 'Decrease'
	else 'no change'
end py_change
from yearly_product_sales
order by product_name,order_year


--which categories contribute the most to overall sales?
with category_sales as(
select 
category,
sum(sales_amount) as total_sales
from gold.fact_sales f
left join gold.dim_products p
on p.product_key = f.product_key
group by category
)
select
category,
total_sales,
sum(total_sales) over () Overall_Sales,
concat(round((cast(total_sales as float)/sum(total_sales) over())*100,2), '%') as percentage_of_total
from category_sales
order by total_sales desc



--segment products into cost ranges and 
--count how many products fall into each segment
with product_segments as(
select
product_key,
product_name,
cost,
case when cost< 100 then 'below 100'
	when cost between 100 and 500 then '100 - 500'
	when cost between 500 and 1000 then '500 - 1000'
	else'above 1000'
end cost_range
from gold.dim_products
)
select
cost_range,
count(product_key) as total_products
from product_segments
group by cost_range
order by total_products desc


--group custpmers into three segments based on their spending behaviour:
--VIP - at least 12 months of history and spending more than 5000
--Regular - at least 12 months of history but spending 5000 or less
--New - lifespan less than 12 months
-- and find the total number of customers by each group
with customer_spending as(
select
c.customer_key,
SUM(f.sales_amount) as total_spending,
min(order_date) as first_order,
max(order_date) as last_order,
datediff(month, min(order_date), max(order_date)) as lifespan
from gold.fact_sales f
left join gold.dim_customers c
on f.customer_key=c.customer_key
group by c.customer_key
)

select
customer_segment,
count(customer_key) as total_customers
from(
select
customer_key,
case when lifespan >= 12 and total_spending > 5000 then 'vip'
	when lifespan >= 12 and total_spending <= 5000 then 'regular'
	else 'new'
end customer_segment
from customer_spending
)t
group by customer_segment
order by total_customers desc 


/*

Customer Report
Purpose:
- This report consolidates key customer metrics and behaviors
Highlights:
1. Gathers essential fields such as names, ages, and transaction details.
2. Segments customers into categories (VIP, Regular, New) and age groups.
3. Aggregates customer-level metrics:
total orders
total sales
total quantity purchased
- total products
lifespan (in months)
4. Calculates valuable KPIS:
recency (months since last order)
average order value
average monthly spend
*/


--1) Base Query: Retrieves core columns from tables
create view gold.report_customers as
WITH base_query AS(
SELECT
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
CONCAT(c.first_name, c.last_name) as customer_name,
datediff(year, birthdate,getdate()) age
from gold.fact_sales f
left join gold.dim_customers c
on c.customer_key = f.customer_key
where order_date is not null
),customer_aggregation as (
SELECT
customer_key,
customer_name,
age,
COUNT (DISTINCT order_number) AS total_orders,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_quantity,
COUNT (DISTINCT product_key) AS total_products,
MAX(order_date) AS last_order_date,
DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY
customer_key,
customer_name,
age
)
select
customer_key,
customer_name,
age,
case when age < 20 then 'under 20'
	when age between 20 and 29 then '20-29'
	when age between 30 and 39 then '30-39'
	when age between 40 and 49 then '40-49'
	else '50 and above'
end as age_group,
case when lifespan >= 12 and total_sales > 5000 then 'vip'
	when lifespan >= 12 and total_sales <= 5000 then 'regular'
	else 'new'
end as customer_segment,
total_orders,
total_sales,
total_quantity,
total_products,
last_order_date,
lifespan,
case when total_sales = 0 then 0
	else total_sales/total_orders
end as avg_orders_value,
case when lifespan = 0 then total_sales
	else total_sales/lifespan
end as avg_monthly_spend
from customer_aggregation

 