------------------------------------------------------------------------ LESSION 4 -----------------------------------------------------------------------------------
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
where PR.ProductID IN (
                          SELECT ProductID
                          FROM Production.ProductCostHistory
                          GROUP BY ProductID
                          HAVING COUNT(ProductID) > 1
                      )
GROUP BY PRS.ProductCategoryID, PRS.Name

/*
Với CSDL “MindX_Lec_1” bạn hãy import thêm dữ liệu cho bảng STUDENTS và LEARNING và làm thêm yêu cầu sau
Bạn hãy viết các đoạn truy vấn để tìm ra các thông tin sau: 
Điểm trung bình của các học viên theo từng khoa
Điểm trung bình của các học viên theo từng môn học
Hãy đếm số lượng học viên đạt kết quả giỏi, khá và trung bình.
Tìm các thông tin sau: điểm lớn nhất, điểm bé nhất, khoảng cách giữa điểm lớn nhất và điểm bé nhất của 
từng môn học là bao nhiêu? (Sau dấu , lấy 1 chữ số thập phân)
*/
USE [D4E_LESSION2_HOMEWORK]
GO

-- Import thêm dữ liệu cho bảng LEARNING
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0010','MC003',7.3);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0010','MC005',5.3);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0017','MC001',7.8);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0025','MC002',3.4);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0028','MC002',5.9);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0014','MC001',9.9);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0035','MC004',10);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0025','MC001',4.4);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0022','MC006',2.3);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0026','MC005',6.7);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0026','MC006',0.4);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0014','MC001',1.3);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0020','MC006',0.6);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0011','MC005',9.9);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0033','MC007',2.6);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0019','MC005',9.2);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0032','MC005',2.8);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0028','MC007',4.5);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0034','MC001',8.6);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0025','MC003',9.5);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0024','MC007',1.4);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0020','MC004',6.8);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0035','MC007',6.7);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0024','MC007',7.1);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0022','MC001',0.2);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0020','MC007',1.7);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0021','MC003',7.5);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0026','MC002',3.1);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0008','MC001',4.9);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0008','MC002',7.8);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0022','MC002',9.3);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0018','MC005',10);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0012','MC001',1.2);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0011','MC007',5.7);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0012','MC003',4.2);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0012','MC004',10);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0014','MC005',5.7);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0037','MC002',9.8);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0009','MC003',0.3);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0016','MC003',9.8);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0031','MC003',9.9);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0027','MC007',5);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0025','MC004',8.9);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0036','MC006',0.7);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0024','MC007',0);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0020','MC003',8.8);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0024','MC004',10);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0010','MC004',8.4);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0028','MC007',2);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0016','MC006',0.5);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0032','MC004',3.8);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0034','MC005',1.4);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0024','MC001',2.5);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0034','MC003',8.2);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0023','MC001',5.7);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0020','MC001',6.5);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0032','MC003',6.3);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0011','MC001',6.5);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0022','MC003',3.3);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0008','MC005',7.2);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0033','MC002',2.6);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0034','MC002',6.4);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0008','MC005',2.1);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0012','MC004',3.7);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0020','MC007',6.1);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0024','MC001',5);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0020','MC001',4.7);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0014','MC004',3.7);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0037','MC007',3.5);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0034','MC001',3.7);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0016','MC001',4.6);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0032','MC002',9.3);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0026','MC003',3.5);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0029','MC003',1.9);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0036','MC007',1.6);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0023','MC002',0.7);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0019','MC005',2.9);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0029','MC004',9.9);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0015','MC001',3.9);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0027','MC003',1);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0012','MC005',9.7);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0026','MC002',5.7);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0017','MC003',10);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0030','MC004',1.3);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0026','MC005',8);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0031','MC003',7.9);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0017','MC001',7.2);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0034','MC004',2.3);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0024','MC004',10);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0037','MC007',4.6);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0021','MC002',1.4);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0019','MC001',2.5);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0009','MC007',4.6);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0029','MC007',4.5);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0018','MC005',5.8);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0029','MC005',0.3);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0012','MC005',5.2);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0023','MC004',6.7);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0008','MC001',1.2);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0009','MC001',7);

-- Import thêm dữ liệu cho bảng STUDENTS
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0008','Minh','Nguyen','0912345678','Hanoi');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0009','Linh','Tran','0987654321','Ho Chi Minh City');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0010','Hoang','Le','0901234567','Da Nang');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0011','Thao','Pham','0976543210','Ho Chi Minh City');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0012','Binh','Hoang','0923456789','Hai Phong');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0013','Huong','Nguyen','0967890123','Hanoi');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0014','Nam','Tran','0945678901','Ho Chi Minh City');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0015','Quang','Ly','0934567890','Hanoi');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0016','Lan','Dang','0956789012','Da Nang');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0017','Tu','Vo','0989012345','Ho Chi Minh City');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0018','Hai','Nguyen','0910123456','Ho Chi Minh City');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0019','Anh','Tran','0943210765','Hanoi');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0020','Duc','Le','0965432109','Da Nang');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0021','Hanh','Hoang','0921098765','Ho Chi Minh City');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0022','Hung','Phan','0978901234','Hanoi');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0023','Hong','Nguyen','0932109876','Ho Chi Minh City');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0024','Tien','Tran','0909876543','Hanoi');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0025','My','Ly','0912345670','Ho Chi Minh City');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0026','Tam','Do','0987654320','Hanoi');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0027','Thanh','Vuong','0943210789','Ho Chi Minh City');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0028','Trang','Le','0965432108','Da Nang');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0029','Quynh','Tran','0921098764','Da Nang');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0030','Duc','Pham','0978901236','Ho Chi Minh City');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0031','Thuy','Le','0932109875','Hanoi');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0032','Hung','Nguyen','0909876541','Ho Chi Minh City');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0033','Thuy','Hoang','0912345672','Hanoi');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0034','Tan','Tran','0987654323','Ho Chi Minh City');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0035','Thanh','Ly','0943210786','Hanoi');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0036','Ngoc','Dang','0965432105','Da Nang');
INSERT INTO STUDENTS(sID,sFirstName,sLastName,sPhone,sAddress) VALUES ('M0037','Duong','Vo','0921098769','Ho Chi Minh City');

-- Điểm trung bình của các học viên theo từng khoa
SELECT C.cMajor, AVG(L.score)
FROM [dbo].[LEARNING] AS L
JOIN [dbo].[COURSE] AS C ON C.cID = L.cID
GROUP BY C.cMajor

-- Điểm trung bình của các học viên theo từng môn học
SELECT C.cName, AVG(L.score)
FROM [dbo].[LEARNING] AS L
JOIN [dbo].[COURSE] AS C ON C.cID = L.cID
GROUP BY C.cName

-- Hãy đếm số lượng học viên đạt kết quả giỏi, khá và trung bình.
SELECT RANKING_STUDENT,
       COUNT(RANKING_STUDENT)
FROM (
	SELECT [sID], 
		   AVG([score]) AS [AVG_SCORE],
		   CASE
				WHEN AVG([score]) >= 8 THEN N'GIỎI'
				WHEN AVG([score]) >= 6.5 AND AVG([score]) < 8 THEN N'KHÁ'
				WHEN AVG([score]) >= 5 AND AVG([score]) < 6.5 THEN N'TRUNG BÌNH'
				ELSE N'YẾU'
			END [RANKING_STUDENT]
	FROM [dbo].[LEARNING]
	GROUP BY [sID]
) TEMP_STUDENTS
GROUP BY RANKING_STUDENT

--Tìm các thông tin sau: điểm lớn nhất, điểm bé nhất, khoảng cách giữa điểm lớn nhất và điểm bé nhất của 
--từng môn học là bao nhiêu? (Sau dấu , lấy 1 chữ số thập phân)
SELECT [cID], (MAX_SCORE - MIN_SCORE) AS [GAP_SCORE]
FROM (
	SELECT [cID],
		   MAX([score]) AS MAX_SCORE,
		   MIN([score]) AS MIN_SCORE
	FROM [dbo].[LEARNING]
	GROUP BY [cID]
) AS TEMP_LEARNING
