# SQL Data Warehouse Analytics

End-to-end SQL Data Warehouse Analytics project built using Microsoft SQL Server and T-SQL.

## Project Overview

This project demonstrates an end-to-end SQL Data Warehouse Analytics solution built using Microsoft SQL Server.

It covers:

- Database creation
- Star schema (fact and dimension tables)
- Data loading from CSV files using `BULK INSERT`
- Exploratory data analysis
- Business KPI reporting
- Customer segmentation
- Performance analysis using advanced T-SQL

## Tech Stack

- **Database:** Microsoft SQL Server
- **Language:** T-SQL
- **Data Source:** CSV files
- **Modeling:** Star Schema

## Dataset

The project uses three CSV datasets:

- Customers
- Products
- Sales Transactions

These datasets are imported into SQL Server using `BULK INSERT`.

## Database Schema

The project follows a **Star Schema**.

### Schema

- `gold`

### Dimension Tables

- `gold.dim_customers`
- `gold.dim_products`

### Fact Table

- `gold.fact_sales`

  ## Tables

Table and Description 

`gold.dim_customers` - Stores customer demographic information 
`gold.dim_products` - Stores product information such as category, cost, and product line 
`gold.fact_sales` - Stores sales transactions including order details, quantity, price, and sales amount 


## Features

- Database creation using T-SQL
- Star schema design
- Data loading using `BULK INSERT`
- Exploratory Data Analysis (EDA)
- KPI reporting
- Customer segmentation
- Product performance analysis
- Sales trend analysis
- Window functions (`ROW_NUMBER`, `LAG`, `SUM OVER`, `AVG OVER`)
- Common Table Expressions (CTEs)
- Views for reporting


## Sample Query

```sql
BULK INSERT gold.fact_sales
FROM 'path_to_csv_file'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
