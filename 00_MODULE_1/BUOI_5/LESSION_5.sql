------------------------------------------------------------------------ LESSION 5 -----------------------------------------------------------------------------------
USE AdventureWorks2022
GO

/*
Bài toán 1: Với dữ liệu đã import ở bài 1, bảng dữ liệu SalesOrderHeader
bạn hãy tìm ra những đơn hàng có giá trị lớn nhất thuộc khu vực Territory số 5
*/
-- Sub querry
SELECT *
FROM [Sales].[SalesOrderHeader]
WHERE [TerritoryID] = 5 AND [TotalDue] = 
(
	SELECT MAX([TotalDue]) AS [MaxTotalDue]
	FROM [Sales].[SalesOrderHeader]
	WHERE [TerritoryID] = 5
);

-- DÙNG CTE
WITH cteMaxTotalDue AS
(
	SELECT MAX([TotalDue]) AS [MaxTotalDue]
	FROM [Sales].[SalesOrderHeader]
	WHERE [TerritoryID] = 5 
)

SELECT *
FROM [Sales].[SalesOrderHeader]
WHERE [TerritoryID] = 5 AND [TotalDue] = (SELECT * FROM cteMaxTotalDue);

--Bài toán 2: Với dữ liệu đã import ở bài 1, bảng dữ liệu SalesOrderHeader,
--bạn hãy tìm ra những khách hàng có số lần mua nhiều nhất thuộc khu vực Territory số 5
-- Sub querry
-- B1: TỔNG SỐ ĐƠN HÀNG CỦA MỖI CUSTOMER THUỘC KHU VỰC TERRITORY SỐ 5
SELECT [CustomerID],
       COUNT([SalesOrderID]) AS [TotalSalesOrderID]
FROM [Sales].[SalesOrderHeader]
WHERE [TerritoryID] = 5
GROUP BY [CustomerID]

-- TÌM MAX TỔNG SỐ ĐƠN HÀNG TỪ B1
SELECT MAX(maxTotalSalesOrderID.TotalSalesOrderID)
FROM
(
	SELECT [CustomerID],
           COUNT([SalesOrderID]) AS [TotalSalesOrderID]
	FROM [Sales].[SalesOrderHeader]
	WHERE [TerritoryID] = 5
	GROUP BY [CustomerID]
) AS maxTotalSalesOrderID

-- TÌM RA NHỮNG KHÁCH HÀNG CÓ SỐ LẦN MUA NHIỀU NHẤT THUỘC KHU VỰC TERRITORY SỐ 5
SELECT [CustomerID],
       COUNT([SalesOrderID])
FROM [Sales].[SalesOrderHeader]
WHERE [TerritoryID] = 5
GROUP BY [CustomerID]
HAVING COUNT([SalesOrderID]) = 
(
	SELECT MAX(maxTotalSalesOrderID.TotalSalesOrderID)
	FROM
	(
		SELECT [CustomerID],
			   COUNT([SalesOrderID]) AS [TotalSalesOrderID]
		FROM [Sales].[SalesOrderHeader]
		WHERE [TerritoryID] = 5
		GROUP BY [CustomerID]
	) AS maxTotalSalesOrderID
);

-- DÙNG CTE
WITH cteTotalSalesOrderID AS
(
	SELECT [CustomerID],
		   COUNT([SalesOrderID]) AS [TotalSalesOrderID]
	FROM [Sales].[SalesOrderHeader]
	WHERE [TerritoryID] = 5
	GROUP BY [CustomerID]
),
cteMaxTotalSalesOrderID AS
(
	SELECT MAX(TotalSalesOrderID) AS [MaxTotalSalesOrderID]
	FROM cteTotalSalesOrderID
)
SELECT [CustomerID],
       TotalSalesOrderID
FROM cteTotalSalesOrderID
WHERE TotalSalesOrderID = (SELECT MaxTotalSalesOrderID FROM cteMaxTotalSalesOrderID)

-- Với bảng SalesOrderHeader:
-- Tìm ra những khu vực Territory nào có doanh số cao hơn doanh số trung bình của tất cả khu vực.
-- Sub querry
-- B1: TỔNG DOANH SỐ THEO TỪNG KHU VỰC
SELECT [TerritoryID],
       SUM([TotalDue]) AS [SumTotalDue]
FROM [Sales].[SalesOrderHeader]
GROUP BY [TerritoryID]

-- B2: LẤY TRUNG BÌNH DOANH SỐ
SELECT AVG(SumTotalDue) FROM
(
	SELECT [TerritoryID],
           SUM([TotalDue]) AS [SumTotalDue]
	FROM [Sales].[SalesOrderHeader]
	GROUP BY [TerritoryID]
) AS avgSumTotalDue

-- B3: TÌM RA NHỮNG KHU VỰC TERRITORY NÀO CÓ DOANH SỐ CAO HƠN DOANH SỐ TRUNG BÌNH CỦA TẤT CẢ KHU VỰC.
SELECT [TerritoryID],
       SUM([TotalDue])
FROM [Sales].[SalesOrderHeader]
GROUP BY [TerritoryID]
HAVING SUM([TotalDue]) > 
(
	SELECT AVG(SumTotalDue) FROM
	(
		SELECT [TerritoryID],
			   SUM([TotalDue]) AS [SumTotalDue]
		FROM [Sales].[SalesOrderHeader]
		GROUP BY [TerritoryID]
	) AS avgSumTotalDue
);

-- DÙNG CTE
WITH cteSumTotalDue AS
(
	SELECT [TerritoryID],
			SUM([TotalDue]) AS [SumTotalDue]
	FROM [Sales].[SalesOrderHeader]
	GROUP BY [TerritoryID]
),
cteAVGSumTotalDue AS
(
	SELECT AVG(SumTotalDue) AS [avgSumTotalDue]
	FROM cteSumTotalDue
)
SELECT [TerritoryID],
       SumTotalDue
FROM cteSumTotalDue
WHERE SumTotalDue > (SELECT avgSumTotalDue FROM cteAVGSumTotalDue);

-- 2. Hãy tìm ra salesman có doanh số lớn nhất của từng khu vực Territory
-- Sub querry
-- BƯỚC 1: LẤY RA TỔNG DOANH SỐ CỦA TỪNG salesman TỪNG khu vực Territory
SELECT [SalesPersonID],
	    [TerritoryID],
		SUM([TotalDue]) AS [SumTotalDue]
FROM [Sales].[SalesOrderHeader]
WHERE [SalesPersonID] IS NOT NULL
GROUP BY [SalesPersonID], [TerritoryID]

-- BƯỚC 2: LẤY RA DOANH SỐ CAO NHẤT CỦA TỪNG KHU VỰC TỪ B1.
SELECT TempMaxTotalDue.[TerritoryID], 
	   MAX(TempMaxTotalDue.SumTotalDue) AS [MaxSumTotalDue]
FROM 
(
	SELECT [SalesPersonID],
	       [TerritoryID],
		   SUM([TotalDue]) AS [SumTotalDue]
	FROM [Sales].[SalesOrderHeader]
	WHERE [SalesPersonID] IS NOT NULL
	GROUP BY [SalesPersonID], [TerritoryID]
) AS TempMaxTotalDue
GROUP BY TempMaxTotalDue.[TerritoryID]

-- BƯỚC 3: tìm ra salesman có doanh số lớn nhất của từng khu vực Territory
SELECT SO.SalesPersonID,
       SO.TerritoryID,
       SUM([TotalDue]) AS MaxSumTotalDueForEachTerritory,
	   TEMP.MaxSumTotalDue
FROM
(
		SELECT TempMaxTotalDue.[TerritoryID], 
		       MAX(TempMaxTotalDue.SumTotalDue) AS [MaxSumTotalDue]
		FROM 
		(
			SELECT [SalesPersonID],
				   [TerritoryID],
				   SUM([TotalDue]) AS [SumTotalDue]
			FROM [Sales].[SalesOrderHeader]
			WHERE [SalesPersonID] IS NOT NULL
			GROUP BY [SalesPersonID], [TerritoryID]
		) AS TempMaxTotalDue
		GROUP BY TempMaxTotalDue.[TerritoryID]
) AS TEMP,
[Sales].[SalesOrderHeader] AS SO
WHERE SO.TerritoryID = TEMP.TerritoryID
GROUP BY SO.SalesPersonID, SO.TerritoryID, TEMP.MaxSumTotalDue
HAVING SUM([TotalDue]) = TEMP.MaxSumTotalDue
ORDER BY SO.TerritoryID;

-- DÙNG CTE
WITH cteSumTotalDue AS
(
	SELECT [SalesPersonID],
		   [TerritoryID],
		   SUM([TotalDue]) AS [SumTotalDue]
	FROM [Sales].[SalesOrderHeader]
	WHERE [SalesPersonID] IS NOT NULL
	GROUP BY [SalesPersonID], [TerritoryID]
),
cteMaxSumTotalDue AS
(
	SELECT [TerritoryID],
	       MAX(SumTotalDue) AS [MaxSumTotalDue]
	FROM cteSumTotalDue
	GROUP BY [TerritoryID]
)
SELECT TEMP.[SalesPersonID],
       TEMP.[TerritoryID],
	   TEMP.[SumTotalDue]
FROM cteSumTotalDue AS TEMP
JOIN cteMaxSumTotalDue TEMP1 ON TEMP1.[TerritoryID] = TEMP.[TerritoryID]
WHERE TEMP.[SumTotalDue] = TEMP1.[MaxSumTotalDue]
ORDER BY TEMP.[TerritoryID]

--Với bảng Person:
--1. Xây dựng VIEW để tìm ra các nhân viên Salesman của công ty. Biết rằng, Salesman trong bảng Person sẽ có thuộc tính PersonType là SP
DROP VIEW IF EXISTS viewSalesman
CREATE VIEW vSalesman AS
SELECT *
FROM [Person].[Person]
WHERE [PersonType] = 'SP';

--Với bảng Person và Customer
--2. Xây dựng VIEW để tìm ra các thông tin của khách hàng gồm mã KH, họ, tên, khu vực họ đăng ký mua hàng và cửa hàng họ đăng ký thành viên.
DROP VIEW IF EXISTS vInformationCustomer
CREATE VIEW vInformationCustomer AS
SELECT CU.CustomerID, P.FirstName, P.LastName, CU.TerritoryID, CU.StoreID
FROM [Sales].[Customer] AS CU
JOIN [Person].[Person] AS P ON P.BusinessEntityID = CU.PersonID

-- BÀI TOÀN: HÃY TÍNH DOANH THU CAO NHẤT THEO THÁNG VÀ TỪNG QUÝ
-- TỨC LÀ TRONG QUÝ ĐÓ THÁNG NÀO CÓ THU NHẬP CAO NHẤT THÌ LIST RA.
-- SUB QUERRY
-- BƯỚC 1: TÌM TỔNG DOANH THU THEO THÁNG VÀ THEO QUÝ
SELECT 
    MONTH(OrderDate) AS ZF_MONTH, 
    DATEPART(Q, OrderDate) ZF_QUARTER,
    SUM(TotalDue) AS ZF_TOTAL_SALES
FROM [Sales].[SalesOrderHeader]
GROUP BY MONTH(OrderDate), DATEPART(Q, OrderDate)
-- ORDER BY ZF_MONTH

-- BƯỚC 2: TÌM DOANH THU CAO NHẤT THEO QUÝ TỪ BƯỚC 1
SELECT ZF_QUARTER, 
       MAX(TEMP.ZF_TOTAL_SALES)
FROM
(
	SELECT 
		MONTH(OrderDate) AS ZF_MONTH, 
		DATEPART(Q, OrderDate) ZF_QUARTER,
		SUM(TotalDue) AS ZF_TOTAL_SALES
	FROM [Sales].[SalesOrderHeader]
	GROUP BY MONTH(OrderDate), DATEPART(Q, OrderDate)
) AS TEMP

-- BƯỚC 3: TÍNH DOANH THU CAO NHẤT THEO THÁNG VÀ TỪNG QUÝ
SELECT 
    MONTH(OrderDate) AS ZF_MONTH, 
    DATEPART(Q, OrderDate) ZF_QUARTER,
    SUM(TotalDue) AS ZF_TOTAL_SALES
FROM [Sales].[SalesOrderHeader]
GROUP BY MONTH(OrderDate), DATEPART(Q, OrderDate)
HAVING SUM(TotalDue) IN (
	SELECT TEMP1.Max_TEMP_TOTAL_SALES
	FROM 
	(
		SELECT TEMP_QUARTER,
			   MAX(TEMP.TEMP_TOTAL_SALES) AS [Max_TEMP_TOTAL_SALES]
		FROM
		(
			SELECT 
				MONTH(OrderDate) AS TEMP_MONTH, 
				DATEPART(Q, OrderDate) TEMP_QUARTER,
				SUM(TotalDue) AS TEMP_TOTAL_SALES
			FROM [Sales].[SalesOrderHeader]
			GROUP BY MONTH(OrderDate), DATEPART(Q, OrderDate)
		) AS TEMP
		GROUP BY TEMP_QUARTER
	) AS TEMP1
);

-- DÙNG CTE
WITH cteTotalSales AS 
(
	SELECT 
		MONTH(OrderDate) AS ZF_MONTH, 
		DATEPART(Q, OrderDate) ZF_QUARTER,
		SUM(TotalDue) AS ZF_TOTAL_SALES
	FROM [Sales].[SalesOrderHeader]
	GROUP BY MONTH(OrderDate), DATEPART(Q, OrderDate)
),
cteMaxTotalSales AS (
	SELECT ZF_QUARTER,
	       MAX(ZF_TOTAL_SALES) AS [ZF_MAX_TOTAL_SALES]
	FROM cteTotalSales
	GROUP BY ZF_QUARTER
)

SELECT TEMP.*
FROM cteTotalSales AS TEMP
JOIN cteMaxTotalSales TEMP1 ON TEMP1.ZF_QUARTER = TEMP.ZF_QUARTER AND ZF_TOTAL_SALES = ZF_MAX_TOTAL_SALES

-- Dựa vào bảng CUSTOMER_GROUP, WAIT_TIME đã tạo trong bài trước
-- Bạn hãy viết các đoạn truy vấn dùng SubQuery để tìm ra các thông tin sau:   
-- Tìm ra những khách hàng nào nhận hàng lâu nhất?
SELECT [CustomerID],
       [wait_type]
FROM [dbo].[WAIT_TIME]
WHERE [wait_type] = (SELECT MAX([wait_type]) FROM [dbo].[WAIT_TIME]);

-- Có bao nhiêu đơn hàng mua hàng có giá trị cao hơn giá trị đơn hàng trung bình của tất cả đơn hàng?
SELECT COUNT([SalesOrderID])
FROM [dbo].[WAIT_TIME]
WHERE [TotalDue] > (SELECT AVG([wait_type]) FROM [dbo].[WAIT_TIME])

-- Dựa vào bảng SalesOrderDetail, ProductSubcategory, Product.
-- Hãy tìm ra tổng doanh số của từng Category.
SELECT PS.[ProductCategoryID],
       SUM([LineTotal]) AS TotalLineTotal
FROM [Sales].[SalesOrderDetail] AS SOD
JOIN [Production].[Product] AS P ON P.ProductID = SOD.ProductID
JOIN [Production].[ProductSubcategory] AS PS ON PS.ProductSubcategoryID = P.ProductSubcategoryID
JOIN [Production].[ProductCategory] AS PC ON PC.ProductCategoryID = PS.ProductCategoryID
GROUP BY PS.[ProductCategoryID];

--Hãy tìm ra SubCategory mang lại doanh thu nhiều nhất của mỗi loại Category
-- DÙNG SUB QUERRY
-- BƯỚC 1: LẤY RA Category, SubCategory VÀ DOANH THU
SELECT PS.[ProductCategoryID],
       PS.ProductSubcategoryID,
       SUM([LineTotal]) AS TotalLineTotal
FROM [Sales].[SalesOrderDetail] AS SOD
JOIN [Production].[Product] AS P ON P.ProductID = SOD.ProductID
JOIN [Production].[ProductSubcategory] AS PS ON PS.ProductSubcategoryID = P.ProductSubcategoryID
JOIN [Production].[ProductCategory] AS PC ON PC.ProductCategoryID = PS.ProductCategoryID
GROUP BY PS.[ProductCategoryID], PS.ProductSubcategoryID

-- BƯỚC 2: LẤY RA Category VÀ DOANH THU CAO NHẤT TỪ BƯỚC 1
SELECT MaxTotalLineTotal.ProductCategoryID,
       MAX(MaxTotalLineTotal.TotalLineTotal) AS [MaxLineTotal]
FROM
(
	SELECT PS.[ProductCategoryID],
		   PS.ProductSubcategoryID,
		   SUM([LineTotal]) AS TotalLineTotal
	FROM [Sales].[SalesOrderDetail] AS SOD
	JOIN [Production].[Product] AS P ON P.ProductID = SOD.ProductID
	JOIN [Production].[ProductSubcategory] AS PS ON PS.ProductSubcategoryID = P.ProductSubcategoryID
	JOIN [Production].[ProductCategory] AS PC ON PC.ProductCategoryID = PS.ProductCategoryID
	GROUP BY PS.[ProductCategoryID], PS.ProductSubcategoryID
) AS MaxTotalLineTotal
GROUP BY MaxTotalLineTotal.ProductCategoryID

-- BƯỚC 3: LẤY RA LIST DOANH THU CAO NHẤT TỪ BƯỚC 2
SELECT TEMP.MaxLineTotal
FROM
(
	SELECT MaxTotalLineTotal.ProductCategoryID,
		   MAX(MaxTotalLineTotal.TotalLineTotal) AS [MaxLineTotal]
	FROM
	(
		SELECT PS.[ProductCategoryID],
			   PS.ProductSubcategoryID,
			   SUM([LineTotal]) AS TotalLineTotal
		FROM [Sales].[SalesOrderDetail] AS SOD
		JOIN [Production].[Product] AS P ON P.ProductID = SOD.ProductID
		JOIN [Production].[ProductSubcategory] AS PS ON PS.ProductSubcategoryID = P.ProductSubcategoryID
		JOIN [Production].[ProductCategory] AS PC ON PC.ProductCategoryID = PS.ProductCategoryID
		GROUP BY PS.[ProductCategoryID], PS.ProductSubcategoryID
	) AS MaxTotalLineTotal
	GROUP BY MaxTotalLineTotal.ProductCategoryID
) AS TEMP;

-- BƯỚC 4: tìm ra SubCategory mang lại doanh thu nhiều nhất của mỗi loại Category
SELECT PS.[ProductCategoryID],
       PS.ProductSubcategoryID,
       SUM([LineTotal]) AS TotalLineTotal
FROM [Sales].[SalesOrderDetail] AS SOD
JOIN [Production].[Product] AS P ON P.ProductID = SOD.ProductID
JOIN [Production].[ProductSubcategory] AS PS ON PS.ProductSubcategoryID = P.ProductSubcategoryID
JOIN [Production].[ProductCategory] AS PC ON PC.ProductCategoryID = PS.ProductCategoryID
GROUP BY PS.[ProductCategoryID], PS.ProductSubcategoryID
HAVING SUM([LineTotal]) IN
(
	SELECT TEMP.MaxLineTotal
	FROM
	(
		SELECT MaxTotalLineTotal.ProductCategoryID,
			   MAX(MaxTotalLineTotal.TotalLineTotal) AS [MaxLineTotal]
		FROM
		(
			SELECT PS.[ProductCategoryID],
				   PS.ProductSubcategoryID,
				   SUM([LineTotal]) AS TotalLineTotal
			FROM [Sales].[SalesOrderDetail] AS SOD
			JOIN [Production].[Product] AS P ON P.ProductID = SOD.ProductID
			JOIN [Production].[ProductSubcategory] AS PS ON PS.ProductSubcategoryID = P.ProductSubcategoryID
			JOIN [Production].[ProductCategory] AS PC ON PC.ProductCategoryID = PS.ProductCategoryID
			GROUP BY PS.[ProductCategoryID], PS.ProductSubcategoryID
		) AS MaxTotalLineTotal
		GROUP BY MaxTotalLineTotal.ProductCategoryID
	) AS TEMP
);

-- DÙNG CTE
WITH cteTotalLineTotal AS
(
	SELECT PS.[ProductCategoryID],
		   PS.ProductSubcategoryID,
		   SUM([LineTotal]) AS TotalLineTotal
	FROM [Sales].[SalesOrderDetail] AS SOD
	JOIN [Production].[Product] AS P ON P.ProductID = SOD.ProductID
	JOIN [Production].[ProductSubcategory] AS PS ON PS.ProductSubcategoryID = P.ProductSubcategoryID
	JOIN [Production].[ProductCategory] AS PC ON PC.ProductCategoryID = PS.ProductCategoryID
	GROUP BY PS.[ProductCategoryID], PS.ProductSubcategoryID
),
cteMaxTotalLineTotal AS
(
	SELECT ProductCategoryID,
	       MAX(TotalLineTotal) AS MaxTotalLineTotal
	FROM cteTotalLineTotal
	GROUP BY ProductCategoryID
)

SELECT TEMP.ProductCategoryID,
       TEMP.ProductSubcategoryID,
	   TEMP.TotalLineTotal
FROM cteTotalLineTotal AS TEMP
JOIN cteMaxTotalLineTotal AS TEMP1 ON TEMP1.ProductCategoryID = TEMP.ProductCategoryID
AND TEMP.TotalLineTotal = TEMP1.MaxTotalLineTotal

/* Với CSDL “MindX_Lec_1”:
Bạn hãy thực hiện các yêu cầu sau: 
Xây dựng VIEW để tìm danh sách học viên đăng ký các môn học thuộc khoa Data
Xây dựng VIEW để tìm danh sách học viên đăng ký các môn học thuộc khoa Web
Xây dựng VIEW để tìm ra những giảng viên có tham gia giảng dạy nhiều hơn 2 môn học.
Tìm ra những sinh viên có điểm tổng kết môn học cao nhất, thấp nhất của 2 khoa kể trên
(Bài tập nâng cao) Dựa vào các thông tin bạn đã làm tìm ra ở các bài học trước như khoảng chênh lệch điểm, 
số lượng sinh viên đạt loại giỏi, khá, trung bình, … Hãy thử suy luận và đưa ra các kết luận về tình trạng học viên - giảng dạy. 
*/
USE D4E110
GO

--Xây dựng VIEW để tìm danh sách học viên đăng ký các môn học thuộc khoa Data
DROP VIEW IF EXISTS vListStudentData
CREATE VIEW vListStudentData AS
SELECT DISTINCT S.sID, S.sFirstName, S.sLastName
FROM [dbo].[STUDENTS] AS S
JOIN [dbo].[LEARNING] AS L ON L.[sID] = S.sID
JOIN [dbo].[COURSE] AS C ON C.cID = L.cID
WHERE C.cMajor = 'Data';

--Xây dựng VIEW để tìm danh sách học viên đăng ký các môn học thuộc khoa Web
DROP VIEW IF EXISTS vListStudentWeb
CREATE VIEW vListStudentWeb AS
SELECT DISTINCT S.sID, S.sFirstName, S.sLastName
FROM [dbo].[STUDENTS] AS S
JOIN [dbo].[LEARNING] AS L ON L.[sID] = S.sID
JOIN [dbo].[COURSE] AS C ON C.cID = L.cID
WHERE C.cMajor = 'Web';

--Xây dựng VIEW để tìm ra những giảng viên có tham gia giảng dạy nhiều hơn 2 môn học.
DROP VIEW IF EXISTS vListTeacher
CREATE VIEW vListTeacher AS
SELECT T.tID, T.tFirstName, T.tLastName,
       COUNT(C.cID) AS [TotalCourse]
FROM [dbo].[TEACHER] AS T
JOIN [dbo].[ENROLLMENTS] AS E ON E.[tID] = T.tID
JOIN [dbo].[COURSE] AS C ON C.cID = E.[cID]
GROUP BY T.tID, T.tFirstName, T.tLastName
HAVING COUNT(C.cID) > 2;

--Tìm ra những sinh viên có điểm tổng kết môn học cao nhất, thấp nhất của 2 khoa kể trên
DROP VIEW IF EXISTS vStudent
CREATE VIEW vStudent AS
WITH cteInforScore AS
(
	SELECT S.sID, L.cID, S.sFirstName, S.sLastName, L.score, C.cMajor, C.cName
	FROM [dbo].[STUDENTS] AS S
	JOIN [dbo].[LEARNING]  AS L ON L.sID = S.sID
	JOIN [dbo].[COURSE] AS C ON C.cID = L.cID
	WHERE C.cMajor = 'Web' OR C.cMajor = 'Data'
),
cteMaxScore AS
(
	SELECT cID, MAX(score) AS MaxScore
	FROM cteInforScore
	GROUP BY cID
),
cteMinScore AS
(
	SELECT cID, MIN(score) AS MinScore
	FROM cteInforScore
	GROUP BY cID
)
SELECT TEMP.*
FROM cteInforScore AS TEMP
JOIN cteMaxScore AS TEMP1 ON TEMP1.cID = TEMP.cID
JOIN cteMinScore AS TEMP2 ON TEMP2.cID = TEMP.cID
WHERE TEMP.score = TEMP1.MaxScore OR TEMP.score = TEMP2.MinScore
ORDER BY TEMP.cID
