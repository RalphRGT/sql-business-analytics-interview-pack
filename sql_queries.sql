-- SQL Business Analytics Interview Pack
-- Created using SQLite
-- Purpose: Practice business analytics queries using joins, aggregations, CTEs and window functions




-- 1. CREATE TABLES


DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS OrderDetails;
DROP TABLE IF EXISTS SalesReps;

CREATE TABLE Customers (
    CustomerID INTEGER PRIMARY KEY,
    CustomerName TEXT,
    Segment TEXT,
    Region TEXT
);

CREATE TABLE Products (
    ProductID INTEGER PRIMARY KEY,
    ProductName TEXT,
    Category TEXT,
    UnitPrice REAL,
    UnitCost REAL
);

CREATE TABLE Orders (
    OrderID INTEGER PRIMARY KEY,
    CustomerID INTEGER,
    OrderDate DATE,
    Region TEXT,
    Channel TEXT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE OrderDetails (
    OrderDetailID INTEGER PRIMARY KEY,
    OrderID INTEGER,
    ProductID INTEGER,
    Quantity INTEGER,
    Discount REAL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

CREATE TABLE SalesReps (
    RepID INTEGER PRIMARY KEY,
    RepName TEXT,
    Region TEXT
);


--2.Insert sample data

INSERT INTO Customers VALUES
(1, 'Alpha Retail', 'SMB', 'Dublin'),
(2, 'Cork Supplies', 'SMB', 'Cork'),
(3, 'HealthPlus Ltd', 'Enterprise', 'Galway'),
(4, 'Nova Traders', 'Consumer', 'Limerick'),
(5, 'GreenMart', 'SMB', 'Waterford'),
(6, 'Urban Tech', 'Enterprise', 'Dublin'),
(7, 'West Coast Buyers', 'Consumer', 'Galway'),
(8, 'Munster Goods', 'SMB', 'Cork'),
(9, 'Capital Wholesale', 'Enterprise', 'Dublin'),
(10, 'Belfast Retail Group', 'SMB', 'Belfast');

INSERT INTO Products VALUES
(1, 'Laptop Pro', 'Electronics', 950, 720),
(2, 'Wireless Headphones', 'Electronics', 120, 65),
(3, 'Office Chair', 'Home & Office', 180, 95),
(4, 'Standing Desk', 'Home & Office', 420, 260),
(5, 'Protein Powder', 'Health', 55, 28),
(6, 'Vitamin Pack', 'Health', 35, 16),
(7, 'Running Shoes', 'Sports', 90, 48),
(8, 'Yoga Mat', 'Sports', 30, 12),
(9, 'Coffee Machine', 'Home & Office', 160, 85),
(10, 'Smartwatch', 'Electronics', 220, 130);

INSERT INTO SalesReps VALUES
(1, 'Sarah Murphy', 'Dublin'),
(2, 'John OBrien', 'Cork'),
(3, 'Emma Kelly', 'Galway'),
(4, 'David Walsh', 'Limerick'),
(5, 'Aoife Byrne', 'Waterford'),
(6, 'Mark Wilson', 'Belfast');


--3. Insert orders and order details

INSERT INTO Orders VALUES
(101, 1, '2025-01-05', 'Dublin', 'Online'),
(102, 2, '2025-01-12', 'Cork', 'In-Store'),
(103, 3, '2025-01-18', 'Galway', 'Online'),
(104, 4, '2025-02-03', 'Limerick', 'Wholesale'),
(105, 5, '2025-02-10', 'Waterford', 'Online'),
(106, 6, '2025-02-15', 'Dublin', 'In-Store'),
(107, 7, '2025-03-02', 'Galway', 'Online'),
(108, 8, '2025-03-08', 'Cork', 'Wholesale'),
(109, 9, '2025-03-14', 'Dublin', 'Online'),
(110, 10, '2025-03-20', 'Belfast', 'In-Store'),
(111, 1, '2025-04-05', 'Dublin', 'Online'),
(112, 2, '2025-04-11', 'Cork', 'In-Store'),
(113, 3, '2025-04-18', 'Galway', 'Wholesale'),
(114, 6, '2025-05-02', 'Dublin', 'Online'),
(115, 8, '2025-05-09', 'Cork', 'Online');

INSERT INTO OrderDetails VALUES
(1, 101, 1, 2, 0.05),
(2, 101, 2, 5, 0.10),
(3, 102, 3, 4, 0.00),
(4, 103, 5, 10, 0.05),
(5, 104, 4, 1, 0.00),
(6, 105, 6, 12, 0.10),
(7, 106, 10, 3, 0.05),
(8, 107, 7, 6, 0.00),
(9, 108, 8, 15, 0.10),
(10, 109, 1, 1, 0.00),
(11, 109, 10, 4, 0.05),
(12, 110, 9, 3, 0.00),
(13, 111, 2, 8, 0.15),
(14, 112, 3, 2, 0.00),
(15, 113, 5, 20, 0.10),
(16, 114, 1, 3, 0.05),
(17, 114, 4, 2, 0.00),
(18, 115, 7, 5, 0.05),
(19, 115, 8, 10, 0.00);

--4.Total Sales, Cost, Profit and Margin

SELECT
    ROUND(SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)), 2) AS TotalSales,
    ROUND(SUM(od.Quantity * p.UnitCost), 2) AS TotalCost,
    ROUND(SUM((od.Quantity * p.UnitPrice * (1 - od.Discount)) - (od.Quantity * p.UnitCost)), 2) AS GrossProfit,
    ROUND(
        SUM((od.Quantity * p.UnitPrice * (1 - od.Discount)) - (od.Quantity * p.UnitCost)) 
        / SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)) * 100, 
        2
    ) AS GrossMarginPercent
FROM OrderDetails od
JOIN Products p
    ON od.ProductID = p.ProductID;


--5. Sales by Region

SELECT
    o.Region,
    ROUND(SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)), 2) AS TotalSales,
    ROUND(SUM((od.Quantity * p.UnitPrice * (1 - od.Discount)) - (od.Quantity * p.UnitCost)), 2) AS GrossProfit
FROM Orders o
JOIN OrderDetails od
    ON o.OrderID = od.OrderID
JOIN Products p
    ON od.ProductID = p.ProductID
GROUP BY o.Region
ORDER BY TotalSales DESC;


--6. Monthly Sales Trend

SELECT
    strftime('%Y-%m', o.OrderDate) AS SalesMonth,
    ROUND(SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)), 2) AS TotalSales
FROM Orders o
JOIN OrderDetails od
    ON o.OrderID = od.OrderID
JOIN Products p
    ON od.ProductID = p.ProductID
GROUP BY strftime('%Y-%m', o.OrderDate)
ORDER BY SalesMonth;

--7.Top 5 Products by Sales

SELECT
    p.ProductName,
    p.Category,
    ROUND(SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)), 2) AS TotalSales,
    SUM(od.Quantity) AS TotalQuantitySold
FROM OrderDetails od
JOIN Products p
    ON od.ProductID = p.ProductID
GROUP BY p.ProductName, p.Category
ORDER BY TotalSales DESC
LIMIT 5;

--8. Average Order Value (AOV)

SELECT
    ROUND(AVG(OrderValue), 2) AS AverageOrderValue
FROM (
    SELECT
        o.OrderID,
        SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)) AS OrderValue
    FROM Orders o
    JOIN OrderDetails od
        ON o.OrderID = od.OrderID
    JOIN Products p
        ON od.ProductID = p.ProductID
    GROUP BY o.OrderID
) order_summary;


-- 9: Top Customers by Revenue

SELECT
    c.CustomerName,
    c.Segment,
    c.Region,
    ROUND(SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)), 2) AS TotalRevenue
FROM Customers c
JOIN Orders o
    ON c.CustomerID = o.CustomerID
JOIN OrderDetails od
    ON o.OrderID = od.OrderID
JOIN Products p
    ON od.ProductID = p.ProductID
GROUP BY c.CustomerName, c.Segment, c.Region
ORDER BY TotalRevenue DESC
LIMIT 5;

-- 10: Sales by Channel

SELECT
    o.Channel,
    COUNT(DISTINCT o.OrderID) AS NumberOfOrders,
    ROUND(SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)), 2) AS TotalSales,
    ROUND(AVG(od.Quantity * p.UnitPrice * (1 - od.Discount)), 2) AS AvgLineValue
FROM Orders o
JOIN OrderDetails od
    ON o.OrderID = od.OrderID
JOIN Products p
    ON od.ProductID = p.ProductID
GROUP BY o.Channel
ORDER BY TotalSales DESC;

-- 11: Sales Rep Performance by Region

SELECT
    sr.RepName,
    sr.Region,
    COUNT(DISTINCT o.OrderID) AS NumberOfOrders,
    ROUND(SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)), 2) AS TotalSales,
    ROUND(SUM((od.Quantity * p.UnitPrice * (1 - od.Discount)) - (od.Quantity * p.UnitCost)), 2) AS GrossProfit
FROM SalesReps sr
LEFT JOIN Orders o
    ON sr.Region = o.Region
LEFT JOIN OrderDetails od
    ON o.OrderID = od.OrderID
LEFT JOIN Products p
    ON od.ProductID = p.ProductID
GROUP BY sr.RepName, sr.Region
ORDER BY TotalSales DESC;

-- 12: Profit by Product


SELECT
    p.ProductName,
    p.Category,
    ROUND(SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)), 2) AS TotalSales,
    ROUND(SUM(od.Quantity * p.UnitCost), 2) AS TotalCost,
    ROUND(SUM((od.Quantity * p.UnitPrice * (1 - od.Discount)) - (od.Quantity * p.UnitCost)), 2) AS GrossProfit,
    ROUND(
        SUM((od.Quantity * p.UnitPrice * (1 - od.Discount)) - (od.Quantity * p.UnitCost))
        / SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)) * 100,
        2
    ) AS GrossMarginPercent
FROM OrderDetails od
JOIN Products p
    ON od.ProductID = p.ProductID
GROUP BY p.ProductName, p.Category
ORDER BY GrossProfit DESC;

-- 13: Rank Products by Total Sales

SELECT
    p.ProductName,
    p.Category,
    ROUND(SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)), 2) AS TotalSales,
    RANK() OVER (
        ORDER BY SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)) DESC
    ) AS SalesRank
FROM OrderDetails od
JOIN Products p
    ON od.ProductID = p.ProductID
GROUP BY p.ProductName, p.Category
ORDER BY SalesRank;


-- 14: Top 3 Products per Region


WITH ProductRegionSales AS (
    SELECT
        o.Region,
        p.ProductName,
        p.Category,
        ROUND(SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)), 2) AS TotalSales
    FROM Orders o
    JOIN OrderDetails od
        ON o.OrderID = od.OrderID
    JOIN Products p
        ON od.ProductID = p.ProductID
    GROUP BY o.Region, p.ProductName, p.Category
),
RankedProducts AS (
    SELECT
        Region,
        ProductName,
        Category,
        TotalSales,
        ROW_NUMBER() OVER (
            PARTITION BY Region
            ORDER BY TotalSales DESC
        ) AS RegionRank
    FROM ProductRegionSales
)
SELECT
    Region,
    ProductName,
    Category,
    TotalSales,
    RegionRank
FROM RankedProducts
WHERE RegionRank <= 3
ORDER BY Region, RegionRank;


-- 14: Month-on-Month Sales Growth


WITH MonthlySales AS (
    SELECT
        strftime('%Y-%m', o.OrderDate) AS SalesMonth,
        SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)) AS TotalSales
    FROM Orders o
    JOIN OrderDetails od
        ON o.OrderID = od.OrderID
    JOIN Products p
        ON od.ProductID = p.ProductID
    GROUP BY strftime('%Y-%m', o.OrderDate)
),
SalesWithLag AS (
    SELECT
        SalesMonth,
        TotalSales,
        LAG(TotalSales) OVER (ORDER BY SalesMonth) AS PreviousMonthSales
    FROM MonthlySales
)
SELECT
    SalesMonth,
    ROUND(TotalSales, 2) AS TotalSales,
    ROUND(PreviousMonthSales, 2) AS PreviousMonthSales,
    ROUND(
        ((TotalSales - PreviousMonthSales) / PreviousMonthSales) * 100,
        2
    ) AS MoMGrowthPercent
FROM SalesWithLag
ORDER BY SalesMonth;

-- 15: 3-Month Moving Average Sales

WITH MonthlySales AS (
    SELECT
        strftime('%Y-%m', o.OrderDate) AS SalesMonth,
        SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)) AS TotalSales
    FROM Orders o
    JOIN OrderDetails od
        ON o.OrderID = od.OrderID
    JOIN Products p
        ON od.ProductID = p.ProductID
    GROUP BY strftime('%Y-%m', o.OrderDate)
)
SELECT
    SalesMonth,
    ROUND(TotalSales, 2) AS TotalSales,
    ROUND(
        AVG(TotalSales) OVER (
            ORDER BY SalesMonth
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS ThreeMonthMovingAverage
FROM MonthlySales
ORDER BY SalesMonth;

-- 16: Repeat Customer Analysis

WITH CustomerOrderCounts AS (
    SELECT
        c.CustomerID,
        c.CustomerName,
        c.Segment,
        c.Region,
        COUNT(DISTINCT o.OrderID) AS NumberOfOrders,
        ROUND(SUM(od.Quantity * p.UnitPrice * (1 - od.Discount)), 2) AS TotalRevenue
    FROM Customers c
    JOIN Orders o
        ON c.CustomerID = o.CustomerID
    JOIN OrderDetails od
        ON o.OrderID = od.OrderID
    JOIN Products p
        ON od.ProductID = p.ProductID
    GROUP BY c.CustomerID, c.CustomerName, c.Segment, c.Region
)
SELECT
    CustomerName,
    Segment,
    Region,
    NumberOfOrders,
    TotalRevenue,
    CASE
        WHEN NumberOfOrders > 1 THEN 'Repeat Customer'
        ELSE 'One-Time Customer'
    END AS CustomerType
FROM CustomerOrderCounts
ORDER BY NumberOfOrders DESC, TotalRevenue DESC;


