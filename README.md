# Zepto_sql_data_analysis_project

This is a complete, real-world data analyst portfolio project based on an e-commerce inventory dataset scraped from Zepto — one of India’s fastest-growing quick-commerce startups. This project simulates real analyst workflows, from raw data exploration to business-focused data analysis.

## Project Overview

✅ Set up a messy, real-world e-commerce inventory database

✅ Perform Exploratory Data Analysis (EDA) to explore product categories, availability, and pricing inconsistencies

✅ Implement Data Cleaning to handle null values, remove invalid entries, and convert pricing from paise to rupees

✅ Write business-driven SQL queries to derive insights around pricing, inventory, stock availability, revenue and more

## Dataset Overview

The dataset was sourced from Kaggle and was originally scraped from Zepto’s official product listings.

Each row represents a unique SKU (Stock Keeping Unit) for a product. Duplicate product names exist because the same product may appear multiple times in different package sizes, weights, discounts, or categories to improve visibility – exactly how real catalog data looks.

🧾 Data Dictionary:


| Columns                  | Description                                                       |
|--------------------------|-------------------------------------------------------------------|
| sku_id                   | Unique identifier for each product entry (Synthetic Primary Key)  |
| name                     | Product name as it appears on the app                             |
| category                 | Product category like Fruits, Snacks, Beverages, etc.             |
| mrp                      | Maximum Retail Price (originally in paise, converted to ₹)        |
| discountPercent          | Discount applied on MRP                                           |
| discountedSellingPrice   | Final price after discount (also converted to ₹)                  |
| availableQuantity        | Units available in inventory                                      |
| weightInGms              | Product weight in grams                                           |
| outOfStock               | Boolean flag indicating stock availability                        |
| quantity                 | Number of units per package (mixed with grams for loose produce)  |

## Project Workflow
Here’s a step-by-step breakdown of what I did in this project:

### 1. Database & Table Creation
I started by creating a SQL table with appropriate data types:

```sql
CREATE TABLE zepto(
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discountPercent NUMERIC(5,2),
availableQuantity INTEGER,
discountedSellingPrice NUMERIC(8,2),
weightInGms INTEGER,
outOfStock BOOLEAN,
quantity INTEGER
);
```

### 2. Data Import
Loaded CSV using MySQL's Table data import wizard feature.

### 3. Data Exploration
Counted the total number of records in the dataset

Viewed a sample of the dataset to understand structure and content

Checked for null values across all columns

Identified distinct product categories available in the dataset

Compared in-stock vs out-of-stock product counts

Detected products present multiple times, representing different SKUs

### 4. Data Cleaning
Identified and removed rows where MRP or discounted selling price was zero

Converted mrp and discountedSellingPrice from paise to rupees for consistency and readability

### 5. Business questions

#### Q1) find the top 10 best-value products based on the discount percentage.

```sql
SELECT *
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;
```

#### Q2) what are the products with high mrp but out of stock?

```sql
SELECT *
FROM zepto
WHERE outOfStock = 1 AND mrp > 300
ORDER BY mrp DESC;
```

#### Q3) calculate estimated revenue for each category

```sql
SELECT category, SUM(discountedSellingPrice * availableQuantity) as estimated_revenue
FROM zepto
GROUP BY category
ORDER BY estimated_revenue ;
```

#### Q4) Find all products where MRP is greater than ₹500 and discount is less than 10%

```sql
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
WHERE mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC ;
```

#### Q5) Identify the top 5 categories offering the highest average discount percentage.

```sql
SELECT category, ROUND(AVG(discountPercent),2) AS average_discount
FROM zepto
GROUP BY category
ORDER BY average_discount DESC
LIMIT 5;
```

#### Q6) Find the price per gram for products above 100g and sort by best value.

```sql
SELECT DISTINCT name, weightInGms, discountedSellingPrice, ROUND((discountedSellingPrice/weightInGms), 2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;
```

#### Q7) Group the products into categories like Low, Medium, Bulk

```sql
SELECT Size_categories_bucket, COUNT(*)
FROM (SELECT name, weightInGms,
CASE 
WHEN weightInGms <= 500 THEN "Low"
WHEN weightInGms <= 1000 THEN "Medium"
WHEN weightInGms > 1000 THEN "Bulk"
END AS Size_categories_bucket
FROM zepto) AS t1
GROUP BY Size_categories_bucket;
```

#### Q8) what is the total inventory weight per category?

```sql
SELECT category, SUM(weightInGms * availableQuantity) AS Total_inventory_weight
FROM zepto
GROUP BY category
ORDER BY Total_inventory_weight;
```

### 6. Business Insights
Found top 10 best-value products based on discount percentage

Identified high-MRP products that are currently out of stock

Estimated potential revenue for each product category

Filtered expensive products (MRP > ₹500) with minimal discount

Ranked top 5 categories offering highest average discounts

Calculated price per gram to identify value-for-money products

Grouped products based on weight into Low, Medium, and Bulk categories

Measured total inventory weight per product category
