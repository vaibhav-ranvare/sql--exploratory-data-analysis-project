# sql--exploratory-data-analysis-project
End-to-end SQL Data Warehouse Analytics project using SQL Server. Includes database design, star schema modeling, data loading via BULK INSERT, and advanced analytical queries such as KPI reporting, customer segmentation, ranking, window functions, and performance analysis.

SQL Data Warehouse Analytics

Project Overview
This project demonstrates an **end-to-end SQL Data Warehouse Analytics solution** built using **SQL Server**.  
It covers database creation, dimensional modeling, data ingestion from CSV files, exploratory analysis, and advanced analytical reporting using SQL.

The goal of this project is to showcase **real-world data analytics skills** including:
Star schema design
Fact & dimension tables
Business KPIs
Customer segmentation
Time-based and performance analysis
Advanced SQL window functions

Tech Stack
Database: Microsoft SQL Server  
Language: T-SQL  
Data Source: CSV files  
Modeling: Star Schema (Fact & Dimension tables)

Dataset
The project uses structured CSV files representing:
Customers
Products
Sales transactions

Data is loaded into SQL Server using `BULK INSERT`.

Database Schema
The database follows a **star schema** design.
Schemas
**gold** – curated analytical tables

### Dimension Tables
`gold.dim_customers`
 `gold.dim_products`

Fact Table
 `gold.fact_sales`

Tables Description

`gold.dim_customers`
Stores customer demographic information such as:
Name
Country
Gender
Marital status
Birthdate

`gold.dim_products`
Contains product attributes including:
Product name
Category & subcategory
Cost
Product line
Start date

`gold.fact_sales`
Stores transactional sales data:
Order details
Sales amount
Quantity
Price
Dates (order, shipping, due)

Data Loading
Data is ingested from CSV files using:

```sql
BULK INSERT gold.fact_sales
FROM 'path_to_csv_file'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
