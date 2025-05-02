USE superstore_db;

SELECT COUNT(*) FROM superstore_raw;

-- First 20 rows
SELECT * FROM superstore_raw LIMIT 20;

-- For checking column names and data types
DESCRIBE superstore_raw;

-- Count distinct values 
SELECT COUNT(DISTINCT Order_ID) AS unique_orders,
       COUNT(DISTINCT Customer_ID) AS unique_customers,
       COUNT(DISTINCT Product_ID) AS unique_products
FROM superstore_raw;


-- Create cleaned version of data with data and decimal form
CREATE TABLE superstore_clean AS
SELECT 
    Row_ID,
    Order_ID,
    STR_TO_DATE(Order_Date, '%d/%m/%Y') AS Order_Date,
    STR_TO_DATE(Ship_Date, '%d/%m/%Y') AS Ship_Date,
    Ship_Mode,
    Customer_ID,
    Customer_Name,
    Segment,
    Country,
    City,
    State,
    Postal_Code,
    Region,
    Product_ID,
    Category,
    Sub_Category,
    Product_Name,
    CAST(Sales AS DECIMAL(10,2)) AS Sales
FROM superstore_raw;


SELECT * FROM superstore_clean LIMIT 10;

SELECT COUNT(*) AS total_rows FROM superstore_clean;


-- Check for any duplicate rows
SELECT COUNT(*) AS unique_rows
FROM (
  SELECT DISTINCT *
  FROM superstore_clean
) AS sub;

-- Count missing values
SELECT
  SUM(Order_Date IS NULL) AS null_order_date,
  SUM(Ship_Date IS NULL) AS null_ship_date,
  SUM(Sales IS NULL) AS null_sales,
  SUM(Customer_ID IS NULL) AS null_customer_id,
  SUM(Product_ID IS NULL) AS null_product_id
FROM superstore_clean;


-- Various sales by region, category, ship mode
SELECT 
  Region, Category, Ship_Mode, 
  SUM(Sales) AS total_sales,
  AVG(Sales) AS avg_sales,
  MIN(Sales) AS min_sales,
  MAX(Sales) AS max_sales
FROM superstore_clean
GROUP BY Region, Category, Ship_Mode
ORDER BY total_sales DESC;


-- Total sales by category
SELECT 
  Category,
  SUM(Sales) AS total_sales
FROM superstore_clean
GROUP BY Category
ORDER BY total_sales DESC;



-- Total sales by region
SELECT 
  Region,
  SUM(Sales) AS total_sales
FROM superstore_clean
GROUP BY Region
ORDER BY total_sales DESC;


-- Sales trends by month
SELECT 
  YEAR(Order_Date) AS year,
  MONTH(Order_Date) AS month,
  SUM(Sales) AS total_sales
FROM superstore_clean
GROUP BY year, month
ORDER BY year, month;



-- Top 10 products by average sales per order
SELECT 
  Product_Name,
  COUNT(DISTINCT Order_ID) AS total_orders,
  SUM(Sales) AS total_sales,
  ROUND(SUM(Sales)/COUNT(DISTINCT Order_ID), 2) AS avg_sales_per_order
FROM superstore_clean
GROUP BY Product_Name
HAVING total_orders > 5
ORDER BY avg_sales_per_order DESC
LIMIT 10;


-- Annual Sales by category
SELECT 
  Category,
  YEAR(Order_Date) AS year,
  SUM(Sales) AS yearly_sales
FROM superstore_clean
GROUP BY Category, year
ORDER BY Category, year;


-- Average delivery time by ship mode
SELECT 
  Ship_Mode,
  ROUND(AVG(DATEDIFF(Ship_Date, Order_Date)), 2) AS avg_delivery_days,
  COUNT(*) AS total_orders
FROM superstore_clean
GROUP BY Ship_Mode
ORDER BY avg_delivery_days DESC;


-- Top 10 repeating customers by total orders and sales
SELECT 
  Customer_ID,
  Customer_Name,
  COUNT(DISTINCT Order_ID) AS total_orders,
  SUM(Sales) AS total_sales
FROM superstore_clean
GROUP BY Customer_ID, Customer_Name
HAVING total_orders > 1
ORDER BY total_orders DESC
LIMIT 10;







