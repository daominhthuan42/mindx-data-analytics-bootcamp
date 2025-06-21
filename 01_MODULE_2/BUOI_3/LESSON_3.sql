DROP DATABASE IF EXISTS MINDX_LESSION_3
CREATE DATABASE MINDX_LESSION_3


USE MINDX_LESSION_3

DROP TABLE IF EXISTS employee
CREATE TABLE employee (
    employee_name VARCHAR(250),
    department VARCHAR (50),
    salary INT
);
INSERT INTO employee VALUES 
    ('John Roberts', 'Finance', 2300),
    ('Peter Hudson', 'Marketing', 1800),
    ('Sue Gibson', 'Finance', 2000),
    ('Melinda Bishop', 'Marketing', 1500),
    ('Nancy Hudson', 'IT', 1950);

--1. TÍNH MỨC LƯƠNG TRUNG BÌNH Ở TỪNG PHÒNG BAN
SELECT E.department, 
	   AVG(E.salary) AS [ZF_AVG_SALARY]
FROM employee AS E
GROUP BY E.department;

--2. TÍNH MỨC LƯƠNG CAO NHẤT Ở MỖI PHÒNG BAN
SELECT E.department, 
       MAX(E.salary) AS [ZF_MAX_SALARY]
FROM employee AS E
GROUP BY E.department;

--3. TÌM NGƯỜI CÓ MỨC LƯƠNG CAO NHẤT Ở MỖI PHÒNG BAN
WITH CTE_MAX_SLARY_BY_DEPT AS (
	SELECT department, 
           MAX(salary) AS [ZF_MAX_SALARY]
	FROM employee
	GROUP BY department
)
SELECT E.employee_name, 
       E.department,
	   E.salary
FROM employee AS E
JOIN CTE_MAX_SLARY_BY_DEPT AS M ON M.department = E.department AND M.ZF_MAX_SALARY = E.salary

-- WINDOW FUNCTION TRONG SQL
WITH CTE_MAX_SLARY_BY_DEPT AS (
    SELECT *,
        MAX(salary) OVER (PARTITION BY department) AS ZF_MAX_SALARY
    FROM employee
)
SELECT 
    TEMP.employee_name,
    TEMP.department,
    TEMP.salary
FROM CTE_MAX_SLARY_BY_DEPT AS TEMP
WHERE TEMP.salary = TEMP.ZF_MAX_SALARY

-------------------------------------------------------------------------------------------------------------------
USE AdventureWorks2022

-- 1. TÍNH TỔNG DOANH SỐ MÀ CÔNG TY ĐẠT ĐƯỢC
SELECT 
    SUM(S.TotalDue) AS ZF_SUM_TOTAL_DUE
FROM Sales.SalesOrderHeader AS S

-- 2. TÍNH TỔNG DOANH SỐ MÀ CÔNG TY ĐẠT ĐƯỢC THEO KHU VỰC
SELECT
    S.TerritoryID,
    SUM(S.TotalDue) AS ZF_SUM_TOTAL_DUE
FROM Sales.SalesOrderHeader AS S
GROUP BY S.TerritoryID
ORDER BY S.TerritoryID

-- 3. TÍNH TỶ LỆ PHẦN TRĂM DOANH THU TỪNG KHU VỰC
-- CÁCH 1: DÙNG GROUP BY, AGGREGATE FUNCTION
SELECT
    S.TerritoryID,
    SUM(S.TotalDue) AS ZF_SUM_TOTAL_DUE,
    (SELECT SUM(TotalDue) FROM Sales.SalesOrderHeader) AS ZF_TOTAL_DUE_AMOUNT,
    (SUM(S.TotalDue) / (SELECT SUM(TotalDue) FROM Sales.SalesOrderHeader)) * 100  AS ZF_RAITO_TOTAL_DUE_BY_TERR
FROM Sales.SalesOrderHeader AS S
GROUP BY S.TerritoryID
ORDER BY S.TerritoryID

-- CÁCH 2: DÙNG WINDOWN FUNCTION
WITH CTE_TOTAL_DUE AS(
    SELECT 
        TerritoryID, 
        SUM(TotalDue) AS ZF_TOTAL_DUE
    FROM sales.SalesOrderHeader
    GROUP BY TerritoryID
), CTE_TOTAL_DUE_AMOUNT AS (
    SELECT 
        *, 
        SUM(ZF_TOTAL_DUE) OVER() AS ZF_TOTAL_DUE_AMOUNT
    FROM CTE_TOTAL_DUE 
)
SELECT 
    *,
    ZF_TOTAL_DUE / ZF_TOTAL_DUE_AMOUNT * 100 AS ZF_RAITO
FROM CTE_TOTAL_DUE_AMOUNT
ORDER BY TerritoryID

-- 4. TÍNH DOANH SỐ THEO TỪNG KHU VỰC VÀ SalesPersonID
SELECT
    S.TerritoryID,
    S.SalesPersonID,
    SUM(S.TotalDue) AS ZF_SUM_TOTAL_DUE
    -- (SELECT SUM(TotalDue) FROM Sales.SalesOrderHeader) AS ZF_TOTAL_DUE_AMOUNT,
    -- (SUM(S.TotalDue) / (SELECT SUM(TotalDue) FROM Sales.SalesOrderHeader)) * 100  AS ZF_RAITO_TOTAL_DUE_BY_TERR
FROM Sales.SalesOrderHeader AS S
-- WHERE S.SalesPersonID IS NOT NULL
GROUP BY S.TerritoryID, S.SalesPersonID
ORDER BY S.TerritoryID

-- Với database Adventure_Work, bạn hãy sử dụng SQL để thực hiện việc xử lý dữ liệu cho việc phân tích dữ liệu bán hàng bằng cách:
-- Kết nối bảng SalesOrderHeader và SalesOrderDetail và Window Function để tính doanh số theo tháng và tháng về trước.
WITH CTE_MONTHLY_SALES AS(
    SELECT 
        YEAR(SH.OrderDate) AS ZF_ORDER_YEAR,
        MONTH(SH.OrderDate) AS ZF_ORDER_MONTH,
        SUM(SD.LineTotal) AS ZF_MONTHLY_REVENUE
    FROM [Sales].[SalesOrderHeader] AS SH
    JOIN [Sales].[SalesOrderDetail] AS SD ON SD.SalesOrderID = SH.SalesOrderID
    GROUP BY YEAR(SH.OrderDate), MONTH(SH.OrderDate)
)
SELECT 
    TEMP.ZF_ORDER_YEAR,
    TEMP.ZF_ORDER_MONTH,
    TEMP.ZF_MONTHLY_REVENUE,
    LAG(TEMP.ZF_MONTHLY_REVENUE, 1) OVER(ORDER BY TEMP.ZF_ORDER_YEAR, TEMP.ZF_ORDER_MONTH) AS ZF_PREV_MONTH_REVENUE
FROM CTE_MONTHLY_SALES AS TEMP;

-- Kết nối bảng SalesOrderHeader và SalesOrderDetail và tạo thêm cột rank để xếp hạng doanh số của SalesMan. Với các SalesMan có cùng doanh số sẽ nhảy rank
WITH CTE_MONTHLY_SALES AS(
    SELECT 
        SH.SalesPersonID,
        SUM(SD.LineTotal) AS ZF_MONTHLY_REVENUE
    FROM [Sales].[SalesOrderHeader] AS SH
    JOIN [Sales].[SalesOrderDetail] AS SD ON SD.SalesOrderID = SH.SalesOrderID
    GROUP BY SH.SalesPersonID
)
SELECT 
    TEMP.SalesPersonID,
    TEMP.ZF_MONTHLY_REVENUE,
    ROW_NUMBER() OVER (ORDER BY TEMP.ZF_MONTHLY_REVENUE DESC) AS RANKING_MONTHLY_REVENUE_BY_SALE_MAN
FROM CTE_MONTHLY_SALES AS TEMP
WHERE TEMP.SalesPersonID IS NOT NULL;

-- Kết nối bảng SalesOrderHeader và SalesOrderDetail và tạo thêm cột rank để xếp hạng doanh số của SalesMan. Với các SalesMan có cùng doanh số sẽ không nhảy rank
WITH CTE_MONTHLY_SALES AS(
    SELECT 
        SH.SalesPersonID,
        SUM(SD.LineTotal) AS ZF_MONTHLY_REVENUE
    FROM [Sales].[SalesOrderHeader] AS SH
    JOIN [Sales].[SalesOrderDetail] AS SD ON SD.SalesOrderID = SH.SalesOrderID
    GROUP BY SH.SalesPersonID
)
SELECT 
    TEMP.SalesPersonID,
    TEMP.ZF_MONTHLY_REVENUE,
    DENSE_RANK() OVER (ORDER BY TEMP.ZF_MONTHLY_REVENUE DESC) AS RANKING_MONTHLY_REVENUE_BY_SALE_MAN
FROM CTE_MONTHLY_SALES AS TEMP
WHERE TEMP.SalesPersonID IS NOT NULL;

-- Kết nối bảng SalesOrderHeader, SalesOrderDetail và tạo thêm cột rank để xếp hạng doanh số của các Product. Với các Product có cùng doanh số sẽ nhảy rank
WITH CTE_MONTHLY_SALES AS(
    SELECT 
        SD.ProductID,
        SUM(SD.LineTotal) AS ZF_MONTHLY_REVENUE
    FROM [Sales].[SalesOrderHeader] AS SH
    JOIN [Sales].[SalesOrderDetail] AS SD ON SD.SalesOrderID = SH.SalesOrderID
    GROUP BY SD.ProductID
)
SELECT 
    TEMP.ProductID,
    TEMP.ZF_MONTHLY_REVENUE,
    ROW_NUMBER() OVER (ORDER BY TEMP.ZF_MONTHLY_REVENUE DESC) AS RANKING_MONTHLY_REVENUE_BY_PRODUCT
FROM CTE_MONTHLY_SALES AS TEMP
WHERE TEMP.ProductID IS NOT NULL;

-- Kết nối bảng SalesOrderHeader, SalesOrderDetail và tạo thêm cột rank để xếp hạng doanh số của các Product. Với các Product có cùng doanh số sẽ không nhảy rank
WITH CTE_MONTHLY_SALES AS(
    SELECT 
        SD.ProductID,
        SUM(SD.LineTotal) AS ZF_MONTHLY_REVENUE
    FROM [Sales].[SalesOrderHeader] AS SH
    JOIN [Sales].[SalesOrderDetail] AS SD ON SD.SalesOrderID = SH.SalesOrderID
    GROUP BY SD.ProductID
)
SELECT 
    TEMP.ProductID,
    TEMP.ZF_MONTHLY_REVENUE,
    DENSE_RANK() OVER (ORDER BY TEMP.ZF_MONTHLY_REVENUE DESC) AS RANKING_MONTHLY_REVENUE_BY_PRODUCT
FROM CTE_MONTHLY_SALES AS TEMP
WHERE TEMP.ProductID IS NOT NULL;
