CREATE DATABASE sales_analysis;
USE sales_analysis;

SELECT * FROM processed_sales_data LIMIT 5;

-- Total Sales, Profit, Quantity
SELECT SUM(sales) AS total_sales,
SUM(quantity) AS total_quantity,
ROUND(SUM(profit),2) AS total_profit
FROM processed_sales_data;

-- Monthly Sales Trend
SELECT order_year, order_month_name, SUM(sales) AS monthly_sales
FROM processed_sales_data
GROUP BY order_year, order_month_name
ORDER BY order_year, monthly_sales DESC;

-- Top 10 Products by Sales
SELECT product_name, category, 
SUM(sales) AS total_sales,
CONCAT(ROUND((SUM(sales) * 100) / SUM(SUM(sales)) OVER(), 2),'%') AS percentage_share
FROM processed_sales_data
GROUP BY product_name, category
ORDER BY total_sales DESC
LIMIT 10;

-- Loss Making Products
SELECT product_name, SUM(profit) AS total_profit
FROM processed_sales_data
GROUP BY product_name
HAVING total_profit < 0
ORDER BY total_profit;

-- Region-wise Performance
SELECT region, SUM(sales) AS total_sales, 
ROUND(SUM(profit),2) AS total_profit
FROM processed_sales_data
GROUP BY region
ORDER BY total_sales DESC;

-- Discount Impact Analysis
SELECT high_discount, 
CONCAT(ROUND(AVG(profit_margin),2),'%') AS avg_profit_margin,
SUM(sales) AS total_sales
FROM processed_sales_data
GROUP BY high_discount;

-- Top Product in Each Category
SELECT * FROM (
	SELECT category, product_name, SUM(sales) AS total_sales,
	RANK() OVER (PARTITION BY category ORDER BY SUM(sales) DESC) AS rnk
    FROM processed_sales_data
	GROUP BY category, product_name
) AS top_product
WHERE rnk = 1;

-- Customer Segmentation (High Value Customers)
WITH CustomerSpending AS (
	SELECT customer_name, SUM(sales) AS total_sales,
	NTILE(4) OVER (ORDER BY SUM(sales) DESC) AS segment_id
	FROM processed_sales_data
	GROUP BY customer_name
)
SELECT customer_name, total_sales,
CASE WHEN segment_id = 1 THEN '(Top 25%) Top-Tier'
	 WHEN segment_id = 2 THEN '(25% - 50%) Mid-Tier'
     WHEN segment_id = 3 THEN '(50% - 75%) Occasional'
     WHEN segment_id = 4 THEN '(Bottom 25%) Low-Value'
END AS priority
FROM CustomerSpending;

-- Operational Efficiency
SELECT region, ship_mode, 
AVG(delivery_days) AS avg_delivery_days,
SUM(sales) AS total_sales,
ROUND(AVG(profit_margin),2) AS avg_profit_margin
FROM processed_sales_data
GROUP BY region, ship_mode
ORDER BY AVG(delivery_days) DESC;