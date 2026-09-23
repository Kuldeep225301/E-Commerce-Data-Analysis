# 🛒 E-Commerce Data Analysis Using SQL

> An end-to-end SQL analysis of an e-commerce database that answers real business questions on revenue, customers, products, cities and time trends.

---

## 📌 Project Overview

An e-commerce company needs clear answers to everyday business questions: *How much are we earning? Who are our best customers? Which products and cities drive growth? Are customers coming back?*

This project answers those questions with SQL, moving from basic aggregations to advanced window functions and CTEs.

---

## 🗂️ Dataset

| Detail | Info |
|---|---|
| **Total Records** | 7,095 |
| **Total Tables** | 4 |
| **Database** | MySQL |
| **Period Covered** | Jan 2025 – _end month_ |

### Tables & Schema

| Table | Rows | Key Columns |
|---|---:|---|
| `customers` | 60 | `customer_id`, `customer_name`, `city` |
| `products` | 38 | `product_id`, `product_name`, `category` |
| `orders` | 2,000 | `order_id`, `customer_id`, `order_date` |
| `order_items` | 4,997 | `order_id`, `product_id`, `quantity`, `unit_price` |

### Relationships

```
customers (1) ──< orders (1) ──< order_items >── (1) products
```

---

## 🛠️ Tools & SQL Concepts Used

- **Database:** MySQL
- **Aggregations:** `SUM`, `COUNT`, `AVG`, `MIN`, `MAX`, `ROUND`
- **Joins:** `INNER JOIN`, `LEFT JOIN`, Self Join
- **Filtering & Grouping:** `WHERE`, `GROUP BY`, `HAVING`, `ORDER BY`, `LIMIT`
- **Subqueries & CTEs:** `WITH` (Common Table Expressions), derived tables
- **Window Functions:** `ROW_NUMBER`, `DENSE_RANK`, `LAG`, `LEAD`, running totals with `SUM() OVER`
- **Date Functions:** `DATE_FORMAT`, `DATEDIFF`
- **Conditional Logic:** `CASE WHEN`, `NULLIF`

---

## ❓ Business Questions Solved

### 1️⃣ Business Overview (KPIs)
| # | Question |
|---|---|
| 1 | What is our total revenue so far? |
| 2 | How many total orders have we received? |
| 3 | How many total customers do we have? |
| 4 | How many total products do we sell? |
| 5 | What is the average amount a customer spends per order? |

### 2️⃣ Product & Category Analysis
| # | Question |
|---|---|
| 6 | What are the top 5 best-selling products? |
| 7 | Which category is generating the most revenue? |
| 14 | What is the best-selling category? |
| 15 | Which product generates the highest revenue? |
| 16 | Which product generates the lowest revenue? |
| 22 | What is the top-selling product in each category? |
| 28 | What percentage does each product contribute to total revenue? |
| 36 | Which two products are most frequently purchased together? |

### 3️⃣ Customer Analysis
| # | Question |
|---|---|
| 8 | Who are our top 5 most valuable customers? |
| 11 | Which customers purchase repeatedly? |
| 12 | Which customers have never placed an order? |
| 13 | Which customers have been inactive in the last 90 days? |
| 19 | Which customers have the highest average order value? |
| 21 | How are customers ranked based on revenue? |
| 27 | Who are the top 3 customers by revenue? |
| 31 | What is each customer's lifetime value (CLV)? |
| 32 | What percentage of customers make repeat purchases? |
| 33 | How many customers are new vs. returning? |
| 35 | Which customers purchase from more than one category? |

### 4️⃣ Revenue & Time Trends
| # | Question |
|---|---|
| 9 | How has our revenue trended month by month? |
| 23 | How has our revenue accumulated over time (running total)? |
| 29 | What is the month-over-month revenue growth? |
| 34 | How many customers were active each month (retention)? |
| 38 | Which month had the highest revenue? |
| 39 | How many customers were acquired each month? |

### 5️⃣ Geographic Analysis
| # | Question |
|---|---|
| 10 | Which city is generating the most sales? |
| 20 | What are the top 3 cities by revenue? |

### 6️⃣ Order Analysis
| # | Question |
|---|---|
| 17 | On average, how many products are bought per order? |
| 18 | Which orders are worth more than 10,000? |
| 24 | When was each customer's previous order placed? |
| 25 | When was each customer's next order placed? |
| 26 | How many days are there between a customer's consecutive orders? |
| 30 | What was each customer's highest-value order? |

---

## 💻 Sample Queries

### Total Revenue
```sql
SELECT ROUND(SUM(ABS(unit_price * quantity)), 2) AS Total_Revenue
FROM order_items;
```

### Top 5 Best-Selling Products
```sql
SELECT products.product_name AS Product_Name,
       SUM(order_items.quantity) AS Total_Quantity
FROM order_items
JOIN products ON products.product_id = order_items.product_id
GROUP BY Product_Name
ORDER BY Total_Quantity DESC
LIMIT 5;
```

### Customer Ranking by Revenue (Window Function + CTE)
```sql
WITH Customer_Revenue AS (
    SELECT customers.customer_id,
           customers.customer_name,
           ROUND(SUM(ABS(order_items.quantity * order_items.unit_price)), 2) AS Revenue
    FROM customers
    JOIN orders ON orders.customer_id = customers.customer_id
    JOIN order_items ON order_items.order_id = orders.order_id
    GROUP BY customers.customer_id, customers.customer_name
)
SELECT customer_id, customer_name, Revenue,
       DENSE_RANK() OVER (ORDER BY Revenue DESC) AS Revenue_Rank
FROM Customer_Revenue
ORDER BY Revenue_Rank
LIMIT 5;
```

### Month-over-Month Revenue Growth
```sql
WITH Monthly_revenue AS (
    SELECT DATE_FORMAT(orders.order_date, '%Y-%m') AS Monthly_Wise,
           SUM(order_items.quantity * order_items.unit_price) AS Monthly_Revenue
    FROM orders
    JOIN order_items ON order_items.order_id = orders.order_id
    GROUP BY Monthly_Wise
)
SELECT Monthly_Wise, Monthly_Revenue,
       LAG(Monthly_Revenue) OVER (ORDER BY Monthly_Wise) AS Prev_Month_Revenue,
       ROUND(100 * (Monthly_Revenue - LAG(Monthly_Revenue) OVER (ORDER BY Monthly_Wise))
             / NULLIF(LAG(Monthly_Revenue) OVER (ORDER BY Monthly_Wise), 0), 2) AS MOM_Percentage_Growth
FROM Monthly_revenue
ORDER BY Monthly_Wise;
```

### Products Frequently Bought Together (Self Join)
```sql
SELECT oi1.product_id AS product1,
       oi2.product_id AS product2,
       COUNT(*) AS Total_Purchase
FROM order_items AS oi1
JOIN order_items AS oi2
  ON oi1.order_id = oi2.order_id
 AND oi1.product_id < oi2.product_id
GROUP BY product1, product2
ORDER BY Total_Purchase DESC
LIMIT 10;
```

> 📄 The complete set of queries is in [`Bussiness_Solutions.sql`](./Bussiness_Solutions.sql).

---

## 📊 Results

### 🔑 Key Metrics

| Metric | Result |
|---|---|
| 💰 Total Revenue | **39,553,815.00** |
| 🧾 Total Orders | **2,000** |
| 👥 Total Customers | **60** |
| 📦 Total Products | **38** |
| 🛒 Avg. Order Value | **19,776.91** |
| 🛍️ Avg. products per order | **7.42** |
| 🏙️ Top city by sales | **Delhi — 5,435,283.00** |
| 🏆 Highest-revenue product | **Smartphone X12 — 9,005,526.00** |
| 📉 Lowest-revenue product | **Self-Help Bestseller — 135,761.00** |
| 👑 Top customer by revenue | **Rahul Iyer — 1,673,772.00** |

### 🥇 Top 5 Best-Selling Products (by quantity)
| Rank | Product | Total Quantity |
|---|---|---:|
| 1 | Smartphone X12 | 474 |
| 2 | Fiction Novel Pack | 458 |
| 3 | Badminton Racket | 457 |
| 4 | Cricket Bat | 450 |
| 5 | Organic Rice 5kg | 433 |

### 👥 Top 5 Customers by Revenue
| Rank | Customer | Total Amount |
|---|---|---:|
| 1 | Rahul Iyer | 1,673,772.00 |
| 2 | Nikhil Mishra | 1,529,530.00 |
| 3 | Riya Rana | 1,523,531.00 |
| 4 | Simran Verma | 1,500,017.00 |
| 5 | Manish Gupta | 1,449,062.00 |

### 📈 Month-over-Month Revenue Growth

<!-- Add any remaining months if your output has more rows -->

| Month | Monthly Revenue | Previous Month | MoM Growth |
|---|---:|---:|---:|
| 2025-02 | 727,020.00 | 857,038.00 | 🔻 -15.17% |
| 2025-03 | 945,215.00 | 727,020.00 | 🔺 +30.01% |
| 2025-04 | 967,341.00 | 945,215.00 | 🔺 +2.34% |
| 2025-05 | 740,314.00 | 967,341.00 | 🔻 -23.47% |

### 🗂️ Revenue by Category
| Category | Total Revenue |
|---|---:|
| _paste_ | _paste_ |

### 🏙️ Top 3 Cities by Revenue
| Rank | City | Total Revenue |
|---|---|---:|
| 1 | Delhi | 5,435,283.00 |
| 2 | _paste_ | _paste_ |
| 3 | _paste_ | _paste_ |

### 🔁 Customer Behaviour
| Metric | Result |
|---|---|
| Repeat purchase rate | _paste_ % |
| New vs. Returning orders | _paste_ |
| Customers who never ordered | _paste_ |
| Best revenue month | _paste_ |

---

## 💡 Key Insights

- **One product drives almost a quarter of revenue:** Smartphone X12 brings in 9.0M, about **22.8%** of the 39.55M total. It is also the #1 best-seller by volume (474 units).
- **Volume ≠ value:** the top-selling products by quantity are close together (433–474 units), but revenue depends heavily on price. Smartphone X12 leads on both, while the Self-Help Bestseller earns only 135,761.
- **Delhi is the #1 city**, contributing 5.44M, about **13.7%** of total sales.
- **Top customers matter:** the top 5 customers (out of 60) generate 7.68M, roughly **19.4%** of total revenue.
- **Large baskets:** an average order contains **7.42 products** and is worth about **19.8K**, so there is strong cross-sell potential.
- **Fast growth through 2025:** monthly revenue rose from 857K in January to 2.73M in December (about 3x), with four straight months of growth from September to December.
- **Seasonal swings:** the biggest jump was June 2025 (+91%), and February fell in both years (-15% in 2025, -38% in 2026), followed by a March rebound (+30%, +64%).
- _Add insights on categories, repeat customers and product pairs once results are filled in._

---

## 🎯 Business Recommendations

1. **Reduce dependence on Smartphone X12** by promoting other high-value products, while keeping it well stocked.
2. **Double down on Delhi** with targeted campaigns and faster delivery.
3. **Launch a VIP loyalty program** for top customers like Rahul Iyer and Nikhil Mishra.
4. **Plan inventory and marketing for Q4 (Oct–Dec)**, when growth was strongest.
5. **Prepare for the February dip** with early-year promotions to smooth out the slowdown.
6. **Review low performers** like Self-Help Bestseller: reprice, bundle or discontinue.
7. **Bundle frequently bought products** to lift the average basket size beyond 7.42 items.

---

## 📁 Repository Structure

```
├── Bussiness_Solutions.sql   # All SQL queries
├── screenshots/              # Query output screenshots
└── README.md                 # Project documentation
```

---

## 🚀 How to Run

1. Clone this repository
   ```bash
   git clone https://github.com/<your-username>/<repo-name>.git
   ```
2. Create the database and import the 4 tables (`customers`, `products`, `orders`, `order_items`) into MySQL.
3. Open `Bussiness_Solutions.sql` in MySQL Workbench and run the queries one by one.

---

## 📚 Skills Demonstrated

`SQL` · `Data Analysis` · `Joins` · `CTEs` · `Window Functions` · `Customer Analytics` · `Revenue Analysis` · `Business Intelligence`

---

## 👤 Author

**Your Name**
🔗 [LinkedIn](https://linkedin.com/in/your-profile) · 💻 [GitHub](https://github.com/your-username)

⭐ If you found this project useful, please give it a star!
