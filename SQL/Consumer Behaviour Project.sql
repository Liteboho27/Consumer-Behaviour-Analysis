SELECT * FROM consumer_behaviour.`shopping_behavior_updated (1)`;

-- Create backup table to preserve original data
CREATE TABLE consumer_shopping_behaviour
LIKE `shopping_behavior_updated (1)`;

INSERT consumer_shopping_behaviour
SELECT * FROM  `shopping_behavior_updated (1)`;

-- Check data types
DESCRIBE consumer_shopping_behaviour;

-- Change column names
ALTER TABLE consumer_shopping_behaviour
CHANGE COLUMN `Customer ID` Customer_ID INT,
CHANGE COLUMN `Item Purchased` Item_Purchased VARCHAR(20),
CHANGE COLUMN `Purchase Amount (USD)` Purchase_Amount_USD DECIMAL (10,2),
CHANGE COLUMN `Review Rating` Review_Rating DOUBLE,
CHANGE COLUMN `Subscription Status` Subscription_Status VARCHAR(20),
CHANGE COLUMN `Discount Applied` Discount_Applied VARCHAR(20),
CHANGE COLUMN `Previous Purchases` Previous_Purchases VARCHAR(20),
CHANGE COLUMN `Payment Method` Payment_Method VARCHAR(20),
CHANGE COLUMN `Frequency of Purchases` Frequency_of_Purchases VARCHAR(20);

-- Change to correct data types
ALTER TABLE consumer_shopping_behaviour
MODIFY COLUMN gender VARCHAR(20),
MODIFY COLUMN category VARCHAR(20),
MODIFY COLUMN location VARCHAR(20),
MODIFY COLUMN size VARCHAR(20),
MODIFY COLUMN color VARCHAR(20),
MODIFY COLUMN season VARCHAR(20);

DESCRIBE consumer_shopping_behaviour;

ALTER TABLE consumer_shopping_behaviour
CHANGE COLUMN `Discount Applied` Discount_Applied VARCHAR(20);

-- Check for duplicates
WITH duplicates AS 
	(SELECT ROW_NUMBER() OVER (PARTITION BY customer_id, age, gender, item_purchased, category, purchase_amount_usd, location, size, season, review_rating,subscription_status, discount_applied, previous_purchases, payment_method) AS row_num
	FROM consumer_shopping_behaviour) rn
SELECT *
FROM duplicates
WHERE row_num > 1; 

-- Remove duplicates by creating table with distinct records
CREATE TABLE consumer_behaviour AS
SELECT DISTINCT *
FROM consumer_shopping_behaviour;

-- Purchase patterns by demographics
SELECT MIN(age) AS youngest_customer,
	MAX(age) AS oldest_customer
FROM consumer_behaviour;

-- Number of orders by age and gender
SELECT
	CASE
		WHEN age <= 30 THEN 'Young'
        WHEN age BETWEEN 30 AND 45 THEN 'Middle Age'
        WHEN age > 45 THEN 'Old'
	END AS age_bracket,
    gender,
    COUNT(*) AS total_orders
  FROM consumer_behaviour
  GROUP BY age_bracket, gender
  ORDER BY total_orders DESC;
  
  -- Total purchases
  SELECT COUNT(item_purchased) FROM consumer_behaviour;
  
  -- Total sales
  SELECT SUM(Purchase_Amount_USD) AS total_sales
  FROM consumer_behaviour;
  
  -- Total sales by age and gender
  SELECT
	CASE
		WHEN age <= 30 THEN 'Young'
        WHEN age BETWEEN 30 AND 45 THEN 'Middle Age'
        WHEN age > 45 THEN 'Old'
	END AS age_bracket,
    gender,
    SUM(purchase_amount_usd) AS total_sales
FROM consumer_behaviour
GROUP BY age_bracket, gender
ORDER BY total_sales DESC;

-- Product and Category analysis
SELECT * FROM consumer_behaviour;

-- Total sales per category
SELECT category, 
	COUNT(item_purchased) orders_per_category,
    SUM(Purchase_Amount_USD) AS total_sales
FROM consumer_behaviour
GROUP BY category
ORDER BY total_sales DESC;

-- Total orders
SELECT COUNT(DISTINCT item_purchased) AS total_products_on_offer
FROM consumer_behaviour;

-- Top 10 best selling items by category
SELECT item_purchased,
	category,
	COUNT(item_purchased) AS number_of_orders
FROM consumer_behaviour
GROUP BY item_purchased, category
ORDER BY number_of_orders DESC
LIMIT 10;

-- Top performing categories by season and location
SELECT category,
	season,
	SUM(purchase_amount_usd) AS total_sales
FROM consumer_behaviour
GROUP BY category, season
ORDER BY total_sales DESC;

-- Total sales by location
SELECT
	location,
    COUNT(location) AS orders_per_location,
	SUM(purchase_amount_usd) AS total_sales
FROM consumer_behaviour
GROUP BY location
ORDER BY total_sales DESC
LIMIT 5;

-- Impact of discounts and subscriptions
SELECT 
    subscription_status,
    discount_applied,
    COUNT(*) AS total_orders,
    ROUND(AVG(purchase_amount_usd), 2) AS avg_sales,
    ROUND(AVG(previous_purchases), 2) AS avg_repeat_indicator,
    SUM(purchase_amount_usd) AS total_sales,
    ROUND(AVG(review_rating), 2) AS avg_satisfaction
FROM consumer_behaviour
GROUP BY subscription_status, discount_applied
ORDER BY total_sales DESC;

SELECT item_purchased,
	ROUND(AVG(total_orders), 2) AS avg_orders,
	avg_rating,
    avg_previous_orders
FROM 
	(SELECT 
		Item_Purchased,
        COUNT(Item_Purchased) AS total_orders,
        ROUND(AVG(review_rating), 2) AS avg_rating,
		ROUND(AVG(Previous_Purchases), 2) AS avg_previous_orders
    FROM consumer_behaviour
    GROUP BY item_purchased) t
GROUP BY item_purchased
ORDER BY avg_previous_orders DESC;


SELECT 
    CASE 
        WHEN Age < 30 THEN 'Young (<30)'
        WHEN Age BETWEEN 30 AND 45 THEN 'Middle (30-45)'
        ELSE 'Older (≥45)'
    END AS age_group,
    Payment_Method,
    Category,
    COUNT(*) AS transactions,
    ROUND(AVG(purchase_amount_usd), 2) AS avg_aov
FROM consumer_behaviour
GROUP BY age_group, Payment_Method, Category
HAVING transactions >= 50
ORDER BY age_group, transactions DESC;

-- Payment methods and purchase frequency
SELECT payment_method,
	COUNT(item_purchased) AS total_orders
FROM consumer_behaviour
GROUP BY payment_method
ORDER BY total_orders DESC;

-- Payment method by age group
SELECT
	CASE
		WHEN age <= 30 THEN 'Young'
        WHEN age BETWEEN 30 AND 45 THEN 'Middle Age'
        WHEN age > 45 THEN 'Old'
	END AS age_bracket,
    payment_method,
    COUNT(customer_id) AS total_customers
FROM consumer_behaviour
GROUP BY age_bracket, payment_method
ORDER BY total_customers DESC;

-- Frequency of purchases by age group
SELECT
	CASE
		WHEN age <= 30 THEN 'Young'
        WHEN age BETWEEN 30 AND 45 THEN 'Middle Age'
        WHEN age > 45 THEN 'Old'
	END AS age_bracket,
    frequency_of_purchases,
    COUNT(*) AS customer_number
FROM consumer_behaviour
GROUP BY CASE
		WHEN age <= 30 THEN 'Young'
        WHEN age BETWEEN 30 AND 45 THEN 'Middle Age'
        WHEN age > 45 THEN 'Old'
	END, frequency_of_purchases
ORDER BY customer_number DESC;

