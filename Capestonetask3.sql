-- Task 3
-- Project: Online Store Order Management System (PostgreSQL)
-- Objective: Create a system to manage orders, customers, and products for an online store

-- DROP DATABASE Capestone;             	 -- DROP Database (Optional)
CREATE DATABASE Capestone;               -- Create Database named Capestone
USE Capestone; 							 -- Use Capestone Database 

CREATE TABLE Products (PRODUCT_ID int primary key, 				-- Create Table Products
PRODUCT_NAME Varchar(25), 
CATEGORY Varchar(25),
PRICE int, STOCK int);

CREATE TABLE Customers(CUSTOMER_ID int primary key, NAME Varchar(25), 	-- Create Table Customers 
EMAIL Varchar(25), 
PHONE_NO Varchar(25),
ADDRESS Varchar(25));

CREATE TABLE Orders(ORDER_ID int primary key, 							-- Create table Orders
CUSTOMER_ID int, PRODUCT_ID int, QUANTITY INT, ORDER_DATE date,
   FOREIGN KEY (PRODUCT_ID) REFERENCES Products(PRODUCT_ID),				-- Link tables with key PRODUCT_ID
   FOREIGN KEY (CUSTOMER_ID) REFERENCES Customers(CUSTOMER_ID)				-- Link tables with key CUSTOMER_ID
);

INSERT INTO Products(PRODUCT_ID,PRODUCT_NAME,CATEGORY,PRICE,				-- Insert values into Products table
STOCK)
VALUES 
    (1,'Table','Furniture',10000,50),
    (2,'Seat Covers','Automobile',5000,30),
    (3,'Monitor','Electronics',19000,20),
    (4,'Carpets','Home & Kitchen',1300,100),
    (5,'Grooming Kit','Personal Care',1160,83),
    (6,'Jacket','Clothing',2100,66),
    (7,'Monopoly','Toys & Games',666,33),
    (8,'Facewash','Personal Care',550,117),
    (9,'Smartphone','Electronics',48000,22),
    (10,'Wall Art','Home & Kitchen',1500,24);
    
select * from Products;													-- Display table Products

INSERT INTO Customers (CUSTOMER_ID, NAME, EMAIL,						-- Insert values into Customers table
PHONE_NO,ADDRESS)
VALUES 
    (1,'Liana','Liana@gmail.com','2344580 ','Manhattan'),
    (2,'Damon','Damon@hotmail.com','6321567 ','Ohio'),
    (3,'Aria','Aria@rediffmail.com','0937245','Austin'),
    (4,'Felix','Felix@gmail.com','3829532','Chicago'),
    (5,'Sienna','Sienna@yahoo.com','8373528','Nashville'),
    (6,'Abdul','Abdul@yahoo.com','9532235','Seattle'),
    (7,'Rahul','Rahul@gmail.com','9825376','Orlando'),
    (8,'Talia','Talia@yahoo.com','5689321','Jersey city'),
    (9,'Kate','Kate@hotmail.com','4253853','Oklahoma'),
    (10,'Cyrus','Cyrus@hotmail.com','7625421','Pheonix');
    
select * from Customers;														-- Display customer table

INSERT INTO Orders(ORDER_ID, CUSTOMER_ID, 										-- Insert values into Orders table
PRODUCT_ID , QUANTITY, ORDER_DATE)
VALUES 
    (1,6,2,4,'2025-01-02'),
    (2,6,5,5,'2025-05-04'),
    (3,9,8,13,'2025-05-06'),
    (4,9,5,2,'2025-07-08'),
    (5,8,2,1,'2025-10-10'),
    (6,3,7,2,'2024-11-11'),
    (7,1,6,6,'2025-08-13'),
    (8,5,2,8,'2025-04-15'),
    (9,7,1,1,'2025-12-17'),
    (10,9,9,3,'2025-04-19'),
    (11,4,2,5,'2025-07-20'),
    (12,3,8,9,'2025-10-22'),
    (13,8,5,3,'2025-11-24'),
    (14,2,1,6,'2025-09-26'),
    (15,7,7,5,'2025-05-28'),
    (16,1,4,12,'2025-10-30'),
    (17,9,6,1,'2025-07-29'),
    (18,2,9,2,'2025-07-27'),
    (19,5,5,3,'2024-12-01'),
    (20,9,2,4,'2025-11-03');
    
Select * from Orders;											-- display table Orders
-- -------------------------------------------
-- Order Management:
-- a) Retrieve all orders placed by a specific customer
Select c.Name, p.PRODUCT_NAME, o.ORDER_ID from Products as p
join
Orders as o on p.PRODUCT_ID = o.PRODUCT_ID
JOIN
Customers as c on o.CUSTOMER_ID = c.CUSTOMER_ID
Order by c.Name;
-- ------------------------------
-- b) Find products that are out of stock.

SELECT PRODUCT_NAME, STOCK
FROM Products
WHERE STOCK = 0;
-----------------------------------------
-- c) Calculate the total revenue generated per product.
SELECT 
	p.PRODUCT_NAME, SUM(o.QUANTITY*p.PRICE) AS RevenueGenerated from Orders as o
JOIN
	Products as p on o.PRODUCT_ID = p.PRODUCT_ID 
Group by PRODUCT_NAME;
--------------------------------------------------
-- d) Retrieve the top 5 customers by total purchase amount.
SELECT 
	c.NAME, SUM(o.QUANTITY*p.PRICE) AS TOTAL_PURCHASE_Amount 
from Customers as c
JOIN
Orders as o on c.CUSTOMER_ID = o.CUSTOMER_ID
JOIN
Products as p on o.PRODUCT_ID = p.PRODUCT_ID
Group by c.NAME
Order BY SUM(o.QUANTITY*p.PRICE) Desc LIMIT 5;
------------------------------------------------
-- e) Find customers who placed orders in at least two different product categories 
SELECT 
	c.NAME, count(p.CATEGORY) AS Total_Categories_Purchased
from Customers as c
JOIN
Orders as o on c.CUSTOMER_ID = o.CUSTOMER_ID
JOIN
Products as p on o.PRODUCT_ID = p.PRODUCT_ID
Group by c.NAME
having count(DISTINCT p.CATEGORY) > 1 ;
-------------------------------------------------------------------
-- Analytics
-- a) Find the month with the highest total sales.
SELECT
    MONTHNAME(o.ORDER_DATE) AS MonthName,
	SUM(o.QUANTITY*p.PRICE) AS TOTAL_Sales

FROM
    Orders as o
JOIN
Products as p on o.PRODUCT_ID = p.PRODUCT_ID
GROUP BY
    YEAR(o.ORDER_DATE),
    MONTHNAME(o.ORDER_DATE),
    MONTH(o.ORDER_DATE)
ORDER BY
    SUM(o.QUANTITY*p.PRICE) DESC LIMIT 1;
-----------------------------------------------------
-- b) Identify products with no orders in the last 6 months
SELECT
    p.product_name
FROM
    Products p
WHERE
    NOT EXISTS (
        SELECT *
        FROM
            Orders o
        WHERE
            o.product_id = p.product_id
            AND 
            o.ORDER_DATE >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH));
-------------------------------------------
-- c) Retrieve customers who have never placed an order.
SELECT c.NAME, count(o.ORDER_ID) AS TOTAL_ORDERS  -- Get the sum of borrowings
FROM Customers AS c
LEFT JOIN 
Orders as o ON c.CUSTOMER_ID = o.CUSTOMER_ID
GROUP BY c.NAME
having Count(o.ORDER_ID) =0;
-------------------------------------------------------------
----- d) Calculate the average order value across all orders.
SELECT
    AVG(OrderValue) AS AverageOrderValue
FROM
    (
        SELECT
            SUM(o.QUANTITY * p.PRICE) AS OrderValue
        FROM
            Orders as o 
            JOIN
            Products as p on o.PRODUCT_ID = p.PRODUCT_ID
        GROUP BY
            o.ORDER_ID
    ) AS OrderTotalsAlias; -- A subquery must be given an alias
