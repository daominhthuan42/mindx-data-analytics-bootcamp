USE AdventureWorks2022
GO

/*
1. Với cột TaxAmt, bạn hãy sử dụng CASE WHEN để thêm 1 cột truy vấn 
Order_Type (loại giá trị đơn hàng) có kết quả:
Giá trị TaxAmt < 500 : Low Order
Giá trị 500 <= TaxAmt < 2000: Medium Order
Giá trị TaxAmt >= 2000 : High Order
*/
SELECT *,
	CASE
	WHEN [TaxAmt] < 500 THEN 'Low Order'
	WHEN [TaxAmt] >= 500 AND [TaxAmt] < 2000 THEN 'MEDIUM Order'
	ELSE 'HIGH ORDER'
	END Order_Type
FROM [Sales].[SalesOrderHeader]

/*
2. Sử dụng CASE WHEN và bảng SalesOrderHeader để tạo 1 bảng mới có tên WAIT_TIME,
là bảng thời gian nhận hàng của khách hàng. 
Gồm mã đơn hàng, mã khách hàng, mã nhân viên bán hàng, 
số tiền của đơn hàng, số thời gian chờ giữa ngày OrderDate - DueDate và 
cột wait_type với wait_type được tính bằng số ngày giữa OrderDate và DueDate:
	wait_type >= 20: Long time
	20 > wait_type  >= 5: Medium time
	wait_type < 5 : Short time
*/
DROP TABLE IF EXISTS WAIT_TIME
SELECT [SalesOrderID], 
	   [CustomerID],
	   [SalesPersonID], 
	   [TotalDue],
	   DATEDIFF(day, [OrderDate], [DueDate]) AS wait_type,
	   CASE 
			WHEN DATEDIFF(day, [OrderDate], [DueDate]) >= 20 THEN 'LONG TIME'
			WHEN DATEDIFF(day, [OrderDate], [DueDate]) >= 5 AND
				 DATEDIFF(day, [OrderDate], [DueDate]) < 20 THEN 'MEDIUM TIME'
			ELSE 'SHORT TIME'
			END XH
INTO WAIT_TIME
FROM [Sales].[SalesOrderHeader]

/*
Với bảng SalesOrderHeader:
1. Bạn tạo 1 bảng CUSTOMER_GROUP gồm các mã KH và xếp hạng 
khách hàng dựa vào số lần mua hàng của khách hàng:
Số lần mua > 8 : Khách hàng thân thiết
 8 >= Số lần mua >= 3: Khách hàng tiềm năng
Số lần mua <3  : Khách hàng mới 
*/
DROP TABLE IF EXISTS CUSTOMER_GROUP
SELECT [CustomerID],
	   COUNT([SalesOrderID]) AS TotalOrder,
	   CASE	
			WHEN COUNT([SalesOrderID]) > 8 THEN 'KHACH HANG THAN THIET'
			WHEN COUNT([SalesOrderID]) >= 3 AND 
				 COUNT([SalesOrderID]) <= 8 THEN 'KHACH HANG TIEM NANG'
			ELSE 'KHACH HANG TIEM MOI'				
	   END XH
INTO CUSTOMER_GROUP
FROM [Sales].[SalesOrderHeader]
GROUP BY [CustomerID]

/*
2. Bạn hãy tính tổng doanh thu theo các TerritoryID và kiểm tra xem các Territory nào đạt KPI, 
biết rằng tất các các Territory đều có cùng mốc KPI là 200000
*/
SELECT [TerritoryID], 
       SUM([TotalDue]) AS 'TONG DOANH THU'
FROM [Sales].[SalesOrderHeader]
GROUP BY [TerritoryID]
HAVING SUM([TotalDue]) >= 200000;

/*
3. Với bảng WAIT_TIME đã tạo ở phần trước, bạn hãy đếm tổng số đơn hàng,
tổng số tiền của các đơn hàng đó và tính thời gian chờ trung bình 
của các đơn hàng theo từng wait_type.
*/
SELECT [wait_type],
	   COUNT([SalesOrderID]) 'TOTAL_ORDER',
	   SUM([TotalDue]) 'SUM_TOTOTAL_ORDERS',
	   AVG([wait_type]) 'AVG_WAIT_TIME'	   
FROM [dbo].[WAIT_TIME]
GROUP BY [wait_type];

/*
Dựa vào bảng CUSTOMER_GROUP, WAIT_TIME đã tạo trong lúc học.
Bạn hãy viết các đoạn truy vấn để tìm ra các thông tin sau:   
Số lượng khách hàng của từng nhóm khách hàng trong CUSTOMER_GROUP là bao nhiêu?
Số lượng đơn hàng của từng nhóm wait_type là bao nhiêu?
*/
-- Số lượng khách hàng của từng nhóm khách hàng trong CUSTOMER_GROUP là bao nhiêu?
SELECT COUNT([CustomerID]) AS 'TOTAL CUSTOMER',
	   [XH]
FROM [dbo].[CUSTOMER_GROUP]
GROUP BY [XH]

-- Số lượng đơn hàng của từng nhóm wait_type là bao nhiêu?
SELECT [wait_type],
       COUNT([SalesOrderID])
FROM [dbo].[WAIT_TIME]
GROUP BY [wait_type];

--Dựa vào bảng SalesOrderDetail.
--Hãy tìm ra tổng số item được mua của từng đơn hàng.
SELECT [SalesOrderID],
       COUNT([ProductID]) AS [TOTAL ITEM]
FROM [Sales].[SalesOrderDetail]
GROUP BY [SalesOrderID]

--Dựa vào bảng SalesOrderDetail và Product
--Hãy tìm ra tổng doanh số của từng ProductSubCategory.
SELECT PR.ProductSubcategoryID,
       COUNT(SOD.ProductID) AS [TOTAL_PRODUCT],
	   SUM([LineTotal]) AS [TOTAL]
FROM [Sales].[SalesOrderDetail] AS SOD
JOIN [Production].[Product] AS PR ON PR.ProductID = SOD.ProductID
WHERE PR.ProductSubcategoryID IS NOT NULL
GROUP BY PR.ProductSubcategoryID

--Hãy tính tổng doanh số của các Category có các sản phẩm được thay đổi giá bán.
-- CHECK TRONG BANG ProductCostHistory
SELECT PRS.ProductCategoryID, PRS.Name,
	   SUM(SOD.[LineTotal]) AS [TOTAL]
FROM [Sales].[SalesOrderDetail] AS SOD
JOIN [Production].[Product] AS PR ON PR.ProductID = SOD.ProductID
JOIN [Production].[ProductSubcategory] AS PRS ON PRS.ProductSubcategoryID = PR.ProductSubcategoryID
JOIN [Production].[ProductCategory] AS PRC ON PRC.ProductCategoryID = PRS.ProductCategoryID
where PR.ProductID IN (                          SELECT ProductID                          FROM Production.ProductCostHistory                          GROUP BY ProductID                          HAVING COUNT(ProductID) > 1                      )
GROUP BY PRS.ProductCategoryID, PRS.Name
