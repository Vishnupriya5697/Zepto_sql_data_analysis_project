USE zepto_sql_project;

drop table if exists zepto;

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

SELECT COUNT(*) FROM zepto;

SELECT SUM( category IS NULL),
SUM(name IS NULL),
SUM(mrp IS NULL)
FROM zepto;

TRUNCATE TABLE zepto;

SELECT * FROM zepto;

-- Data exploration --

-- count of rows --
SELECT COUNT(*) FROM zepto;

-- sample data
SELECT * FROM zepto
LIMIT 10;

-- Null values
SELECT * FROM zepto
WHERE category IS NULL OR 
name IS NULL OR
mrp IS NULL OR
discountPercent IS NULL OR
availableQuantity IS NULL OR
discountedSellingPrice IS NULL OR
weightInGms IS NULL OR
outOfStock IS NULL OR
quantity IS NULL;

-- different product categories
SELECT DISTINCT category
FROM zepto
ORDER BY category ASC;

-- product stock
SELECT outOfStock, COUNT(*) 
FROM zepto
GROUP BY outOfStock;

-- product names present multiple times
SELECT name, COUNT(*) AS Count_products 
FROM zepto
GROUP BY name
HAVING COUNT(*)>1
ORDER BY Count_products DESC;

-- Data cleaning
-- products with price 0

SELECT *
FROM zepto
WHERE mrp = 0 OR discountedSellingPrice = 0;

DELETE 
FROM zepto
WHERE sku_id = 3607;

-- convert paise to rupees
SET SQL_SAFE_UPDATES = 0;

UPDATE zepto
SET mrp = mrp/100.0,
discountedSellingPrice = discountedSellingPrice/100.0;

SET SQL_SAFE_UPDATES = 1;

-- Business questions
-- 1) find the top 10 best-value products based on the discount percentage.
SELECT *
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;

-- 2) what are the products with high mrp but out of stock?
SELECT *
FROM zepto
WHERE outOfStock = 1 AND mrp > 300
ORDER BY mrp DESC;

-- 3) calculate estimated revenue for each category
SELECT category, SUM(discountedSellingPrice * availableQuantity) as estimated_revenue
FROM zepto
GROUP BY category
ORDER BY estimated_revenue ;

-- 4) Find all products where MRP is greater than ₹500 and discount is less than 10%
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
WHERE mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC ;

-- 5) Identify the top 5 categories offering the highest average discount percentage.
SELECT category, ROUND(AVG(discountPercent),2) AS average_discount
FROM zepto
GROUP BY category
ORDER BY average_discount DESC
LIMIT 5;

-- 6) Find the price per gram for products above 100g and sort by best value.
SELECT DISTINCT name, weightInGms, discountedSellingPrice, ROUND((discountedSellingPrice/weightInGms), 2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;

-- 7) Group the products into categories like Low, Medium, Bulk
SELECT name, weightInGms,
CASE 
WHEN weightInGms <= 500 THEN "Low"
WHEN weightInGms <= 1000 THEN "Medium"
WHEN weightInGms > 1000 THEN "Bulk"
END AS Size_categories_bucket
FROM zepto;

SELECT Size_categories_bucket, COUNT(*)
FROM (SELECT name, weightInGms,
CASE 
WHEN weightInGms <= 500 THEN "Low"
WHEN weightInGms <= 1000 THEN "Medium"
WHEN weightInGms > 1000 THEN "Bulk"
END AS Size_categories_bucket
FROM zepto) AS t1
GROUP BY Size_categories_bucket;

-- 8) what is the total inventory weight per category?

SELECT * FROM zepto;

SELECT category, SUM(weightInGms * availableQuantity) AS Total_inventory_weight
FROM zepto
GROUP BY category
ORDER BY Total_inventory_weight;
