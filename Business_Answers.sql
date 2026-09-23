USE E_Commerce_Project;

# Retrieve Data From Tables
select count(*) from customers; # Total Record
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;

# Business Problem
/*
What is our total revenue so far?
How many total orders have we received?
How many total customers do we have?
How many total products do we sell?
What is the average amount a customer spends per order?
What are the top 5 best-selling products?
Which category is generating the most revenue?
Who are our top 5 most valuable customers?
How has our revenue trended month by month?
Which city is generating the most sales?
Which customers purchase repeatedly?
Which customers have never placed an order?
Which customers have been inactive in the last 90 days?
What is the best-selling category?
Which product generates the highest revenue?
Which product generates the lowest revenue?
On average, how many products are bought per order?
Which orders are worth more than 10,000?
Which customers have the highest average order value?
What are the top 3 cities by revenue?
How are customers ranked based on revenue?
What is the top-selling product in each category?
How has our revenue accumulated over time (running total)?
When was each customer's previous order placed?
When was each customer's next order placed (if any)?
How many days are there between a customer's consecutive orders?
Who are the top 3 customers by revenue?
What percentage does each product contribute to total revenue?
What is the month-over-month revenue growth?
What was each customer's highest-value order?
What is each customer's lifetime value (LTV)?
What percentage of customers make repeat purchases (repeat purchase rate)?
How many customers are new vs. returning?
How many customers were active each month (retention)?
Which customers purchase from more than one category?
Which two products are most frequently purchased together?
On average, how many days pass between a customer's orders?
Which product category is growing the fastest?
Which customers are at risk of churn?
How do customers look based on RFM (Recency, Frequency, Monetary) analysis?
What is the daily sales trend?
What are the top 10 best-selling products?
Who are the top 10 customers by revenue?
How much revenue comes from male vs. female customers?
What is our customer churn rate?
What percentage of orders get cancelled?
How many orders were delivered vs. cancelled?
What is the worst-selling category?
What is the most expensive product sold?
Which month had the highest revenue?
How many new customers were acquired each month?
What percentage does each category contribute to total revenue?
*/

SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT COUNT(*) FROM order_items; # TOTAL RECORDS OF Orders_Items.

-- Check Data Types
DESC customers;
DESC products;
DESC orders;
DESC order_items;

# Bussiness Solutions

-- 1 What is our total revenue so far?
SELECT ROUND(SUM(ABS(unit_price*quantity)),2) AS Total_Revenue FROM order_items;

-- 2 How many total orders have we received?
SELECT COUNT(*) AS total_orders FROM orders;

-- 3 How many total customers do we have?
SELECT COUNT(*) AS Total_Customers FROM customers;

-- 4 How many total products do we sell?
SELECT COUNT(product_name) AS Total_Products FROM products;

-- 5 What is the average amount a customer spends per order?
SELECT  ROUND(SUM(quantity*unit_price)/count(DISTINCT order_id),2) AS AVG_Amount FROM order_items;	

-- 6 What are the top 5 best-selling products?
SELECT products.product_name AS Product_Name, SUM(order_items.quantity) as Total_Quantity
FROM order_items JOIN products
ON products.product_id  = order_items.product_id
GROUP BY Product_Name
ORDER BY Total_Quantity DESC LIMIT 5;


-- 7 Which category is generating the most revenue?
SELECT products.category AS Category, ROUND(SUM(ABS(order_items.quantity * order_items.unit_price)),2) AS  Total_Revenue 
FROM order_items JOIN products
ON products.product_id = order_items.product_id
GROUP BY Category
ORDER BY Total_Revenue DESC;

-- 8 Who are our top 5 most valuable customers?
SELECT customers.customer_name AS Customer_Name, ROUND(SUM(ABS(order_items.quantity * order_items.unit_price)),2) AS Total_Amount
FROM order_items JOIN orders
ON orders.order_id = order_items.order_id
JOIN customers
ON customers.customer_id = orders.customer_id
GROUP BY Customer_Name
ORDER BY Total_Amount DESC LIMIT 5;
 
-- 9 How has our revenue trended month by month?
SELECT 
DATE_FORMAT(orders.order_date, '%Y-%m') AS Month_Wise,
ROUND(SUM(order_items.quantity * order_items.unit_price),2) AS Total_Revenue
FROM order_items JOIN orders
ON orders.order_id = order_items.order_id
GROUP BY Month_Wise
ORDER BY Month_Wise DESC;

-- 10 Which city is generating the most sales?
SELECT customers.city AS City, ROUND(SUM(ABS(order_items.quantity * order_items.unit_price)),2) AS Total_Sales
FROM customers JOIN orders
ON orders.customer_id = customers.customer_id
JOIN order_items
ON order_items.order_id = orders.order_id
GROUP BY City
ORDER BY Total_Sales DESC LIMIT 1;

-- 11 Which customers purchase repeatedly?
SELECT customers.customer_name, orders.customer_id, COUNT(orders.order_id) AS Total_Order
FROM orders JOIN customers
ON customers.customer_id = orders.customer_id
GROUP BY customers.customer_name, orders.customer_id
HAVING  COUNT(orders.order_id)> 1
ORDER BY Total_Order DESC;

-- 12 Which customers have never placed an order?
SELECT customers.customer_id, customers.customer_name, COUNT(orders.order_id) AS Total_Order
FROM customers LEFT JOIN orders
ON customers.customer_id = orders.customer_id
WHERE orders.order_id IS NULL
GROUP BY customers.customer_id, customers.customer_name;

-- 13 Which customers have been inactive in the last 90 days?

SELECT customers.customer_id, customers.customer_name, MAX(orders.order_date) AS Last_Orders
FROM customers JOIN orders ON orders.customer_id = customers.customer_id
GROUP BY customers.customer_id, customers.customer_name
HAVING MAX(orders.order_date) < '2026-04-30' OR MAX(orders.order_date)  IS NULL
ORDER BY Last_Orders;

-- 14 What is the best-selling category?
SELECT products.category AS Category_Name, SUM(order_items.quantity) AS Total_Quantity_Sold
FROM products JOIN order_items
ON order_items.product_id = products.product_id
GROUP BY Category_Name ORDER BY Total_Quantity_Sold DESC LIMIT 1; 

-- 15 Which product generates the highest revenue?

SELECT products.product_name AS Product_Name, ROUND(SUM(ABS(order_items.unit_price * order_items.quantity)),2) AS Highest_Revenue
FROM products JOIN order_items
ON order_items.product_id = products.product_id
GROUP BY Product_Name
ORDER BY Highest_Revenue DESC LIMIT 1;

-- 16  Which product generates the Lowest revenue?

SELECT products.product_name AS Product_Name, SUM(ABS(order_items.quantity* order_items.unit_price)) AS Lowest_Revenue
FROM products JOIN order_items
ON order_items.product_id =  products.product_id
GROUP BY Product_Name 
ORDER BY Lowest_Revenue ASC LIMIT 1;	

-- 17 On average, how many products are bought per order?
SELECT ROUND(AVG(Total_quantity),2) AS Avg_Producs_Per_Counts FROM 
( SELECT order_id, SUM(quantity)  AS Total_quantity
FROM order_items
GROUP BY order_id) AS T;

-- 18 Which orders are worth more than 10,000?
SELECT orders.order_id AS Order_Id, SUM(ABS(quantity* order_items.unit_price)) AS Total_Income
FROM orders JOIN order_items
ON order_items.order_id = orders.order_id
GROUP BY Order_Id
HAVING SUM(ABS(order_items.quantity* order_items.unit_price)) >10000
ORDER BY Total_Income DESC;

-- 19 Which customers have the highest average order value?

SELECT customer_id, ROUND(AVG(Order_Value)) AS Avg_Order_Value FROM (
SELECT orders.customer_id,orders.order_id, SUM(order_items.quantity * order_items.unit_price) AS Order_Value
FROM orders JOIN order_items
ON orders.order_id = order_items.order_id
GROUP BY orders.customer_id,orders.order_id) AS t
GROUP BY customer_id
ORDER BY Avg_Order_Value DESC LIMIT 5;	

-- 20 What are the top 3 cities by revenue?
SELECT customers.city AS City, ROUND(SUM(ABS(order_items.quantity * order_items.unit_price)),2) AS Total_Revenue
FROM customers JOIN orders
ON orders.customer_id =  customers.customer_id
JOIN order_items
ON order_items.order_id =  orders.order_id
GROUP BY City
ORDER BY Total_Revenue DESC LIMIT 3;

-- 21 How are customers ranked based on revenue?

WITH Customer_Revenue AS(
SELECT 
customers.customer_id,
customers.customer_name,
ROUND(SUM(ABS(order_items.quantity * order_items.unit_price)),2) AS Revenue
FROM customers JOIN orders
ON orders.customer_id =  customers.customer_id
JOIN order_items
ON order_items.order_id =  orders.order_id
GROUP BY customers.customer_id, customers.customer_name 
)
SELECT customer_id, customer_name , ROUND(Revenue,2) AS Revenue,
DENSE_RANK() OVER(ORDER BY Revenue DESC) AS Revenue_Rank
FROM Customer_Revenue ORDER BY Revenue_Rank ASC LIMIT 5;

-- 22 What is the top-selling product in each category?

WITH Products AS (
SELECT products.product_name, products.category, 
SUM(order_items.quantity)  AS quantity,
ROW_NUMBER() OVER(PARTITION BY products.category ORDER BY SUM(order_items.quantity) DESC)  AS Ranks
FROM products JOIN order_items
ON order_items.product_id = products.product_id
GROUP BY products.product_name, products.category
)

SELECT product_name, category, quantity FROM Products
WHERE Ranks =1;

-- 23 How has our revenue accumulated over time (running total)?

WITH Daily AS (
SELECT order_date, 
SUM(order_items.quantity * order_items.unit_price) AS Daily_Revenue
FROM orders JOIN order_items
ON order_items.order_id =  orders.order_id
GROUP BY order_date
)
SELECT order_date, Daily_Revenue, 
SUM(Daily_Revenue) OVER(ORDER BY order_date) AS Running_Revenue
FROM Daily ORDER BY order_date DESC LIMIT 15;

-- 24 When was each customer's previous order placed?
SELECT customer_id, order_id, order_date, 
LAG(order_date) over(PARTITION BY customer_id ORDER BY order_date) AS Previous_Order_Date
FROM orders ORDER BY customer_id, order_id LIMIT 20;  

-- 25 When was each customer's next order placed (if any)?
SELECT customer_id, order_id, order_date,
LEAD(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS Next_Order_Date
FROM orders ORDER BY customer_id, order_id LIMIT 20;

-- 26 How many days are there between a customer's consecutive orders?
SELECT customer_id, order_id,order_date, 
DATEDIFF(order_date, LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date)) AS Days_Between_Orders 
FROM orders
ORDER BY customer_id, order_id LIMIT 20;

-- 27 Who are the top 3 customers by revenue?

With Customer AS (
SELECT customers.customer_id, customers.customer_name, 
SUM(order_items.quantity * order_items.unit_price) AS Total_Revenue,
DENSE_RANK() OVER(ORDER BY SUM(order_items.quantity * order_items.unit_price) DESC) AS Ranks
FROM orders JOIN customers
ON orders.customer_id = customers.customer_id
JOIN order_items ON order_items.order_id = orders.order_id
GROUP BY customers.customer_id, customers.customer_name
)
SELECT customer_id, customer_name, ROUND(Total_Revenue,2) AS Total_Revenue, Ranks FROM Customer
WHERE Ranks<=3;	

-- 28 What percentage does each product contribute to total revenue?

WITH Product_Details AS(
SELECT products.product_id, products.product_name, 
SUM(order_items.quantity * order_items.unit_price) AS Revenue
FROM products JOIN order_items
ON order_items.product_id =  products.product_id
GROUP BY products.product_id, products.product_name
)
SELECT product_name, Revenue, 
ROUND((Revenue*100)/sum(Revenue) over(),2) AS  Percentage_Contribute 
FROM Product_Details
ORDER BY Revenue DESC LIMIT 10;

-- 29 What is the month-over-month revenue growth?

WITH Monthly_revenue AS (
SELECT 
DATE_FORMAT(orders.order_date, '%Y-%m') as Monthly_Wise,
SUM(order_items.quantity * order_items.unit_price) AS Monthly_Revenue
FROM orders JOIN order_items
ON order_items.order_id = orders.order_id
GROUP BY Monthly_Wise
)
SELECT Monthly_Wise, Monthly_Revenue,
LAG(Monthly_Revenue) OVER (ORDER BY Monthly_Wise DESC) AS Prev_Month_Revenue,
ROUND(100* (Monthly_Revenue - LAG(Monthly_Revenue,1) OVER (ORDER BY Monthly_Wise))/
NULLIF(LAG(Monthly_Revenue,1) OVER (ORDER BY Monthly_Wise),0),2) AS MOM_Percentage_Growth
FROM Monthly_revenue
ORDER BY Monthly_Wise; 

-- 30  What was each customer's highest-value order?

WITH CustomerOrders AS(
SELECT orders.customer_id, orders.order_id,
SUM(order_items.quantity * order_items.unit_price) AS Value_Order, # Based on Amount
ROW_NUMBER() OVER(PARTITION BY orders.customer_id ORDER BY SUM(order_items.quantity * order_items.unit_price) DESC) AS Rnk
FROM orders JOIN order_items
ON order_items.order_id = orders.order_id
GROUP BY orders.customer_id, orders.order_id
)
SELECT customer_id, order_id, ROUND(Value_Order,2) AS Value_Order FROM  CustomerOrders
WHERE Rnk = 1
ORDER BY Value_Order DESC LIMIT 10;

-- 31 What is each customers's lifetime value (CLV) ?

SELECT orders.customer_id,
SUM(ABS(order_items.quantity * order_items.unit_price)) AS Customers_lifetime_value
FROM  orders JOIN order_items
ON order_items.order_id = orders.order_id
GROUP BY orders.customer_id
ORDER BY Customers_lifetime_value DESC LIMIT 10;

-- 32 What percentage of customers make repeat purchases ?

WITH CustomerOrders AS(
	SELECT customer_id, COUNT(*) AS Total_Orders
    from orders
    group by customer_id
)
SELECT 
round(100.0*COUNT(CASE WHEN Total_Orders>1 THEN 1 END)/COUNT(*),2) AS Repeat_percentage
FROM CustomerOrders;

-- 33 How many customers are new vs. returning?

WITH FIRST_ORDERS AS(
SELECT customer_id, 
MIN(order_date) AS First_Order
FROM orders
GROUP BY customer_id
)
SELECT 
CASE WHEN orders.order_date = f.First_Order THEN 'New Customer' ELSE 'Returning' END AS Customer_Type,
COUNT(*) AS Total_Orders
FROM orders JOIN FIRST_ORDERS AS F
ON orders.customer_id = f.customer_id
GROUP BY Customer_Type;

-- 34 How many customers were active each month (retention)?

WITH Monthly AS(
SELECT 
DATE_FORMAT(order_date, '%Y-%m') AS Monthly_Wise, 
COUNT(DISTINCT customer_id) AS Total_Customer
FROM orders
GROUP BY Monthly_Wise
)
SELECT Monthly_Wise, Total_Customer FROM Monthly
ORDER BY Monthly_Wise;

-- 35 Which customers purchase from more than one category?

SELECT orders.customer_id,
COUNT(DISTINCT products.category) AS Total_Category  
FROM  orders
JOIN order_items ON order_items.order_id = orders.order_id
JOIN products ON products.product_id =  order_items.product_id
GROUP BY orders.customer_id
HAVING COUNT(DISTINCT products.category)>1
ORDER BY Total_Category DESC LIMIT 15;

-- 36 Which two products are most frequently purchased together?
SELECT oi1.product_id as product1, oi2.product_id as product2, COUNT(*) AS Total_Purchase
FROM order_items AS oi1
JOIN order_items AS oi2
	ON oi1.order_id = oi2.order_id
    AND oi1.product_id < oi2.product_id
GROUP BY product1, product2
ORDER BY Total_Purchase DESC LIMIT 10;

-- 36 Which month had the highest revenue.?

WITH Monthly AS (
SELECT 
DATE_FORMAT(orders.order_date,'%Y-%m') AS Monthly_Wise,
SUM(order_items.quantity * order_items.unit_price) AS Total_Revenue
FROM orders JOIN order_items
ON orders.order_id = order_items.order_id 
GROUP BY Monthly_Wise
)
SELECT Monthly_Wise, Total_Revenue
FROM Monthly
ORDER BY Total_Revenue DESC LIMIT 1;

-- 37 How Many customers were acquired each month ?

WITH First_Orders AS(
SELECT customer_id, MIN(order_date) AS First_Orders
FROM orders
GROUP BY customer_id
)
SELECT
DATE_FORMAT(First_Orders,'%Y-%m') AS acquired_month,
COUNT(*) AS New_Customers
FROM First_Orders
GROUP BY acquired_month
ORDER BY acquired_month;
-- 


