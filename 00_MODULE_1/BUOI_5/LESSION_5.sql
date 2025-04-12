------------------------------------------------------------------------ LESSION 5 -----------------------------------------------------------------------------------
USE AdventureWorks2022
GO

/*
Bài toán 1: Với dữ liệu đã import ở bài 1, bảng dữ liệu SalesOrderHeader
bạn hãy tìm ra những đơn hàng có giá trị lớn nhất thuộc khu vực Territory số 5
*/
-- BƯỚC 1: LẤY RA ĐƠN HÀNG CÓ GIÁ TRỊ LỚN NHẤT VỚI Territory = 5.
SELECT MAX([TotalDue]) 
FROM [Sales].[SalesOrderHeader]
WHERE [TerritoryID] = 5

-- BƯỚC 2: LẤY RA ĐƠN HÀNG TƯƠNG ỨNG 
SELECT *
FROM [Sales].[SalesOrderHeader]
WHERE [TotalDue] = 
(
	SELECT MAX([TotalDue]) 
	FROM [Sales].[SalesOrderHeader]
	WHERE [TerritoryID] = 5
);

--Bài toán 2: Với dữ liệu đã import ở bài 1, bảng dữ liệu SalesOrderHeader,
--bạn hãy tìm ra những khách hàng có số lần mua nhiều nhất thuộc khu vực Territory số 5
-- BƯỚC 1: TỔNG SỐ ĐƠN HÀNG LÀ BAO NHIÊU
SELECT [CustomerID],
	   COUNT([SalesOrderID])
FROM [Sales].[SalesOrderHeader]
WHERE [TerritoryID] = 5
GROUP BY [CustomerID]

-- BƯỚC 2: TỪ BƯỚC 1 LẤY RA KHÁCH HÀNG CÓ SỐ ĐƠN LỚN NHẤT
SELECT MAX(TEMP.[TOTAL_ORDER])
FROM 
(
	SELECT [CustomerID],
		   COUNT([SalesOrderID]) AS [TOTAL_ORDER]
	FROM [Sales].[SalesOrderHeader]
	WHERE [TerritoryID] = 5
	GROUP BY [CustomerID]
) AS TEMP

-- BƯỚC 3: TỪ BƯỚC 1 LẤY RA NHỮNG COUNT = BƯỚC 2
SELECT [CustomerID],
	   COUNT([SalesOrderID])
FROM [Sales].[SalesOrderHeader]
WHERE [TerritoryID] = 5
GROUP BY [CustomerID]
HAVING COUNT([SalesOrderID]) = (
	SELECT MAX(TEMP.[TOTAL_ORDER])
	FROM 
	(
		SELECT [CustomerID],
		COUNT([SalesOrderID]) AS [TOTAL_ORDER]
		FROM [Sales].[SalesOrderHeader]
		WHERE [TerritoryID] = 5
		GROUP BY [CustomerID]
	) AS TEMP
);

-- SỬ DỤNG TRUY VẤN LỒNG THÌ QUÁ DÀI KHÓ MAINTANCE KO THÍCH HỢP CHO NHỮNG CÂU TRUY VẤN PHỨC TẠP VÀ DỄ DUPPLICATE
-- SỬ DỤNG CTE
--WITH TABLE1 AS (
--	SELECT [CustomerID],
--		   COUNT([SalesOrderID]) AS [TOTAL_ORDER]
--	FROM [Sales].[SalesOrderHeader]
--	WHERE [TerritoryID] = 5
--	GROUP BY [CustomerID]
--)

-- BÀI TOÀN: HÃY TÍNH DOANH THU CAO NHẤT THEO THÀNG TỪNG QUÝ
WITH TABLE1 AS (    SELECT         MONTH(OrderDate) AS ZF_MONTH,         DATEPART(Q, OrderDate) ZF_QUARTER,        SUM(TotalDue) AS ZF_TOTAL_SALES    FROM SALES.SalesOrderHeader    GROUP BY MONTH(OrderDate), DATEPART(Q, OrderDate)), TABLE2 AS (    SELECT         ZF_QUARTER,        MAX(ZF_TOTAL_SALES) AS MAX_SALES    FROM TABLE1    GROUP BY ZF_QUARTER)SELECT TABLE1.*FROM TABLE1     INNER JOIN TABLE2 ON TABLE1.ZF_QUARTER = TABLE2.ZF_QUARTER                         AND TABLE1.ZF_TOTAL_SALES = TABLE2.MAX_SALES-- Dựa vào bảng CUSTOMER_GROUP, WAIT_TIME đã tạo trong bài trước
-- Bạn hãy viết các đoạn truy vấn dùng SubQuery để tìm ra các thông tin sau:   
-- Tìm ra những khách hàng nào nhận hàng lâu nhất?
SELECT *
FROM [dbo].[WAIT_TIME]
WHERE [wait_type] =
(
    SELECT MAX(wait_type) AS ZF_MAX_WAITYPE FROM [dbo].[WAIT_TIME]
)

-- Có bao nhiêu đơn hàng mua hàng có giá trị cao hơn giá trị đơn hàng trung bình của tất cả đơn hàng?
SELECT COUNT([SalesOrderID]) AS [TOTAL ORDER]
FROM [dbo].[WAIT_TIME]
WHERE [TotalDue] >
(
    SELECT AVG([TotalDue]) FROM [dbo].[WAIT_TIME]
)

--Dựa vào bảng SalesOrderDetail, ProductSubcategory, Product.
--Hãy tìm ra tổng doanh số của từng Category.
SELECT PRC.ProductCategoryID,
	   SUM(SOD.[LineTotal]) AS [TOTAL]
FROM [Sales].[SalesOrderDetail] AS SOD
JOIN [Production].[Product] AS PR ON PR.ProductID = SOD.ProductID
JOIN [Production].[ProductSubcategory] AS PRS ON PRS.ProductSubcategoryID = PR.ProductSubcategoryID
JOIN [Production].[ProductCategory] AS PRC ON PRC.ProductCategoryID = PRS.ProductCategoryID
GROUP BY PRC.ProductCategoryID;

-- Hãy tìm ra SubCategory mang lại doanh thu nhiều nhất của mỗi loại Category
-- BƯỚC 1: TÌM TỔNG DOANH THU CỦA TỪNG ProductSubcategory
WITH cte_ProductSubcategory AS (
	SELECT PRS.ProductCategoryID,
	       PR.ProductSubcategoryID,		   
		   SUM(SOD.[LineTotal]) AS [TOTAL_SALES]
	FROM [Sales].[SalesOrderDetail] AS SOD
	JOIN [Production].[Product] AS PR ON PR.ProductID = SOD.ProductID
	JOIN [Production].[ProductSubcategory] AS PRS ON PRS.ProductSubcategoryID = PR.ProductSubcategoryID
	GROUP BY PRS.ProductCategoryID, PR.ProductSubcategoryID
),
cte_TEMP1 AS
(
	SELECT ProductCategoryID,
		   MAX([TOTAL_SALES]) AS [TOTAL2]
	FROM cte_ProductSubcategory
	GROUP BY ProductCategoryID
)
SELECT *
FROM cte_ProductSubcategory AS CP
JOIN cte_TEMP1 AS TEMP ON TEMP.ProductCategoryID = CP.ProductCategoryID 
						  AND TEMP.TOTAL2 = CP.TOTAL_SALES
