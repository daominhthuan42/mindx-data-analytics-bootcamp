-------------------------------------------------------------------------------------------------------------------
USE AdventureWorks2022

-- Với  database AdventureWorks đã import, BOM muốn thực hiện phân tích và báo cáo các tình hình liên quan đến kinh doanh.
-- 1.Bạn hãy xây dựng truy vấn để tìm ra top 5 sản phẩm có doanh số cao nhất.
-- CÁCH 1: KHÔNG DÙNG WINDOWN FUNCTION
WITH CTE_TOTAL_SALES AS(
    SELECT 
        SD.ProductID,
        SUM(SD.LineTotal) AS ZF_MONTHLY_REVENUE
    FROM [Sales].[SalesOrderHeader] AS SH
    JOIN [Sales].[SalesOrderDetail] AS SD ON SD.SalesOrderID = SH.SalesOrderID
    GROUP BY SD.ProductID
)
SELECT 
    TOP 5 TEMP.ProductID,
    TEMP.ZF_MONTHLY_REVENUE,
    MAX(TEMP.ZF_MONTHLY_REVENUE) AS ZF_TOTAL_AMOUNT
FROM CTE_TOTAL_SALES AS TEMP
GROUP BY TEMP.ProductID, TEMP.ZF_MONTHLY_REVENUE
ORDER BY MAX(TEMP.ZF_MONTHLY_REVENUE) DESC

-- CÁCH 2: DÙNG WINDOWN FUNCTION
WITH CTE_TOTAL_SALES AS(
    SELECT 
        SD.ProductID,
        SUM(SD.LineTotal) AS ZF_MONTHLY_REVENUE
    FROM [Sales].[SalesOrderHeader] AS SH
    JOIN [Sales].[SalesOrderDetail] AS SD ON SD.SalesOrderID = SH.SalesOrderID
    GROUP BY SD.ProductID
), CTE_RANKING_TOTAL_SALES AS(
    SELECT
        TEMP.ProductID,
        TEMP.ZF_MONTHLY_REVENUE,
        ROW_NUMBER() OVER (ORDER BY TEMP.ZF_MONTHLY_REVENUE DESC) AS ZF_RANKING_TOTAL_SALES
    FROM CTE_TOTAL_SALES AS TEMP
)
SELECT 
    TEMP1.ProductID,
    TEMP1.ZF_MONTHLY_REVENUE,
    TEMP1.ZF_RANKING_TOTAL_SALES
FROM CTE_RANKING_TOTAL_SALES AS TEMP1
WHERE TEMP1.ZF_RANKING_TOTAL_SALES < 6;


-- 2.Chuyển kết quả của câu 1 thành PIVOT table
WITH CTE_TOTAL_SALES AS(
    SELECT 
        SD.ProductID,
        SUM(SD.LineTotal) AS ZF_MONTHLY_REVENUE
    FROM [Sales].[SalesOrderHeader] AS SH
    JOIN [Sales].[SalesOrderDetail] AS SD ON SD.SalesOrderID = SH.SalesOrderID
    GROUP BY SD.ProductID
), CTE_RANKING_TOTAL_SALES AS(
    SELECT
        TEMP.ProductID,
        TEMP.ZF_MONTHLY_REVENUE,
        ROW_NUMBER() OVER (ORDER BY TEMP.ZF_MONTHLY_REVENUE DESC) AS ZF_RANKING_TOTAL_SALES
    FROM CTE_TOTAL_SALES AS TEMP
), CTE_RANKING_TOP5 AS (
    SELECT 
        TEMP1.ProductID,
        TEMP1.ZF_MONTHLY_REVENUE,
        TEMP1.ZF_RANKING_TOTAL_SALES
    FROM CTE_RANKING_TOTAL_SALES AS TEMP1
    WHERE TEMP1.ZF_RANKING_TOTAL_SALES < 6
)
SELECT *
FROM (
    SELECT ProductID, ZF_MONTHLY_REVENUE
    FROM CTE_RANKING_TOP5
) AS SOURCE_TABLE
PIVOT(
    MAX(ZF_MONTHLY_REVENUE)
    FOR ProductID IN ([782], [783], [779], [780], [781])
) AS PIVOT_TABLE

-- 3.Sử dụng Window Function, PIVOT Table và các kiến thức có liên quan như SubQuery, CTE và sau đó viết truy vấn để thực hiện việc 
-- tính toán tổng doanh số của các quý trong năm và tổng doanh số của các quý trước đó.
WITH CTE_QUARTERLY_SALES AS(
    SELECT 
        DATEPART(YEAR, SH.OrderDate) AS ZF_ORDER_YEAR,
        DATEPART(QUARTER, SH.OrderDate) AS ZF_ORDER_QUARTER,
        SUM(SD.LineTotal) AS ZF_TOTAL_REVENUE
    FROM [Sales].[SalesOrderHeader] AS SH
    JOIN [Sales].[SalesOrderDetail] AS SD ON SD.SalesOrderID = SH.SalesOrderID
    GROUP BY DATEPART(YEAR, SH.OrderDate), DATEPART(QUARTER, SH.OrderDate)
)
SELECT 
    TEMP.ZF_ORDER_YEAR,
    TEMP.ZF_ORDER_QUARTER,
    TEMP.ZF_TOTAL_REVENUE,
    LAG(TEMP.ZF_TOTAL_REVENUE, 1) OVER(ORDER BY TEMP.ZF_ORDER_YEAR, TEMP.ZF_ORDER_QUARTER) AS ZF_PREV_QUARTER_REVENUE_BY_YEAR
FROM CTE_QUARTERLY_SALES AS TEMP;

-- 4.Bạn hãy phân tích theo vùng kinh doanh bằng cách tính toán tổng doanh số của các vùng trong cả năm và tạo thêm cột 
-- ranking để xếp hạng tổng doanh số của các khu vực đó.
WITH CTE_QUARTERLY_SALES AS(
    SELECT 
        DATEPART(YEAR, SH.OrderDate) AS ZF_ORDER_YEAR,
        SH.TerritoryID,
        SUM(SD.LineTotal) AS ZF_TOTAL_REVENUE
    FROM [Sales].[SalesOrderHeader] AS SH
    JOIN [Sales].[SalesOrderDetail] AS SD ON SD.SalesOrderID = SH.SalesOrderID
    GROUP BY DATEPART(YEAR, SH.OrderDate), SH.TerritoryID
)
SELECT 
    TEMP.ZF_ORDER_YEAR,
    TEMP.TerritoryID,
    TEMP.ZF_TOTAL_REVENUE,
    ROW_NUMBER() OVER(PARTITION BY TEMP.ZF_ORDER_YEAR ORDER BY TEMP.ZF_TOTAL_REVENUE DESC) AS ZF_TOTAL_AMOUNT_BY_TERR_AND_YEAR
FROM CTE_QUARTERLY_SALES AS TEMP;

-- 5.BOM muốn bạn tìm ra top 3 salesman có doanh số lớn nhất của mỗi khu vực để quyết định khen thưởng cho việc có doanh số tốt.
WITH CTE_MONTHLY_SALES AS(
    SELECT 
        SH.SalesPersonID,
        SH.TerritoryID,
        SUM(SD.LineTotal) AS ZF_MONTHLY_REVENUE
    FROM [Sales].[SalesOrderHeader] AS SH
    JOIN [Sales].[SalesOrderDetail] AS SD ON SD.SalesOrderID = SH.SalesOrderID
    WHERE SH.SalesPersonID IS NOT NULL AND SH.TerritoryID IS NOT NULL
    GROUP BY SH.SalesPersonID, SH.TerritoryID
), CTE_RANKING_TOTAL_SALES AS(
    SELECT
        TEMP.SalesPersonID,
        TEMP.TerritoryID,
        TEMP.ZF_MONTHLY_REVENUE,
        ROW_NUMBER() OVER (PARTITION BY TEMP.TerritoryID ORDER BY TEMP.ZF_MONTHLY_REVENUE DESC) AS ZF_RANKING_TOTAL_SALES
    FROM CTE_MONTHLY_SALES AS TEMP
)
SELECT 
    TEMP1.SalesPersonID,
    TEMP1.TerritoryID,
    TEMP1.ZF_MONTHLY_REVENUE,
    TEMP1.ZF_RANKING_TOTAL_SALES
FROM CTE_RANKING_TOTAL_SALES AS TEMP1
WHERE TEMP1.ZF_RANKING_TOTAL_SALES < 4;
