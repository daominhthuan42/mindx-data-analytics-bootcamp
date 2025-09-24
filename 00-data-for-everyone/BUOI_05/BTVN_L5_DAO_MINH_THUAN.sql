USE [MX_DATABASE]
GO

/*
Bài tập 1
-	Đề bài : Các phòng ban trong công ty khá đa dạng, BOD muốn bạn xây dựng cho mỗi phòng ban một VIEW của riêng họ để chỉ lấy ra các nhân viên thuộc về phòng ban đó. 
Bạn hãy thực hiện yêu cầu của BOD
-	Tài liệu sử dụng để làm bài : 
+	Bảng NHANVIEN trong database MX 
-	Hướng dẫn làm bài: 
+	Công ty có tất cả 5 phòng ban nên bạn hãy xây dựng 5 VIEW riêng dựa vào DepID
*/
SELECT * FROM [dbo].[MX_NHANVIEN]
-- VIEW FOR DEPNAME: Head Office
DROP VIEW IF EXISTS vHeadOffice
CREATE VIEW vHeadOffice AS
SELECT *
FROM [dbo].[MX_NHANVIEN]
WHERE [DepName] = 'Head Office';

-- VIEW FOR DEPNAME: Tài chính
DROP VIEW IF EXISTS vFinance
CREATE VIEW vFinance AS
SELECT *
FROM [dbo].[MX_NHANVIEN]
WHERE [DepName] = N'Tài chính';

-- VIEW FOR DEPNAME: Data
DROP VIEW IF EXISTS vData
CREATE VIEW vData AS
SELECT *
FROM [dbo].[MX_NHANVIEN]
WHERE [DepName] = 'Data';

-- VIEW FOR DEPNAME: Kế toán
DROP VIEW IF EXISTS vAccountingSales
CREATE VIEW vAccountingSales AS
SELECT *
FROM [dbo].[MX_NHANVIEN]
WHERE [DepName] = N'Kế toán';

-- VIEW FOR DEPNAME: Nghiệp vụ
DROP VIEW IF EXISTS vOperation
CREATE VIEW vOperation AS
SELECT *
FROM [dbo].[MX_NHANVIEN]
WHERE [DepName] = N'Nghiệp vụ';

/*
Bài tập 2 
Đề bài : Bạn hãy tìm ra khoảng chênh lệch doanh số của nhân viên bán hàng có doanh số cao nhất,
nhân viên có doanh số thấp nhất với trung bình doanh số bán hàng của tất cả các salesman.
*/
-- [dbo].[MX_HOADON_UNION] LÀ KẾT QUẢ UNION ALL GIỮA [dbo].[MX_HOADON] VÀ [dbo].[MX_HOADON_MOI]
-- SỬ DỤNG SUB QUERRY
SELECT HDN.SalesID,
       -- Max/Min Sales
       SUM(HDN.TotalLine) AS [Max/Min Sales],
       -- [AVERAGE Sales]
       (
           SELECT AVG(TEMP3.sumTotalLine) AS [avg_TotalLine]
           FROM
           (
               SELECT SalesID,
                      SUM(TotalLine) AS [sumTotalLine]
               FROM [dbo].[MX_HOADON_UNION]
               GROUP BY SalesID
           ) AS TEMP3
       ) AS [AVERAGE Sales],
       -- [Range]
       (SUM(HDN.TotalLine) -
        (
            SELECT AVG(TEMP4.sumTotalLine) AS [avg_TotalLine]
            FROM
            (
                SELECT SalesID,
                       SUM(TotalLine) AS [sumTotalLine]
                FROM [dbo].[MX_HOADON_UNION]
                GROUP BY SalesID
            ) AS TEMP4
        )
       ) AS [Range]
FROM [dbo].[MX_HOADON_UNION] HDN
GROUP BY HDN.SalesID
HAVING SUM(HDN.TotalLine) =
(
    SELECT MAX(TEMP1.sumTotalLine)
    FROM
    (
        SELECT SalesID,
               SUM(TotalLine) AS [sumTotalLine]
        FROM [dbo].[MX_HOADON_UNION]
        GROUP BY SalesID
    ) AS TEMP1
)   OR SUM(HDN.TotalLine) =
       (
           SELECT MIN(TEMP2.sumTotalLine)
           FROM
           (
               SELECT SalesID,
                      SUM(TotalLine) AS [sumTotalLine]
               FROM [dbo].[MX_HOADON_UNION]
               GROUP BY SalesID
           ) AS TEMP2);

/*
-	Đề bài : Bạn hãy tối ưu hoá bài tập 2 bằng cách sử dụng CTE
*/
-- SỬ DỤNG CTE
WITH CTE_TotalSales AS (
	SELECT SalesID,
		   SUM(TotalLine) AS [sumTotalLine]
	FROM [dbo].[MX_HOADON_UNION]
	GROUP BY SalesID
),
CTE_Max_TotalSales AS
(
	SELECT MAX(sumTotalLine) AS [max_TotalLine]
	FROM CTE_TotalSales
),
CTE_Min_TotalSales AS
(
	SELECT MIN(sumTotalLine) AS [min_TotalLine]
	FROM CTE_TotalSales
),
CTE_avg_Sales AS
(
	SELECT AVG(sumTotalLine) AS [avg_TotalLine]
	FROM CTE_TotalSales
)

SELECT HDN.SalesID,
       -- Max/Min Sales
       SUM(HDN.TotalLine) AS [Max/Min Sales],
	   -- AVERAGE Sales
	   (SELECT * FROM CTE_avg_Sales) AS [AVERAGE Sales],
	   -- Range
	   (SUM(HDN.TotalLine) - (SELECT * FROM CTE_avg_Sales)) AS [Range]
FROM [dbo].[MX_HOADON_UNION] HDN
JOIN CTE_TotalSales AS TEMP1 ON TEMP1.SalesID = HDN.SalesID
GROUP BY HDN.SalesID
HAVING SUM(HDN.TotalLine) = (SELECT * FROM CTE_Min_TotalSales) OR
	   SUM(HDN.TotalLine) = (SELECT * FROM CTE_Max_TotalSales);

/*
Bài tập 4
-	Đề bài : Với mỗi sản phẩm, bạn hãy tìm ra khách hàng nào mua nó nhiều nhất (là mua số lượng nhiều nhất)
*/
WITH cte_TotalQTY AS (
	SELECT ProductId,
		   [CusID],
		   SUM([QTY]) AS [TotalQTY]
	FROM [dbo].[MX_HOADON_UNION]
	GROUP BY ProductId, [CusID]
),
cte_MaxQTY AS
(
	SELECT ProductId,
		   MAX(TotalQTY) AS [maxQTY]
	FROM cte_TotalQTY
	GROUP BY ProductId
)

SELECT TEMP.ProductId,
	   TEMP.[CusID],
	   SUM(TEMP.TotalQTY) AS [Total Orders]
FROM cte_TotalQTY AS TEMP
JOIN cte_MaxQTY TEMP2 ON TEMP2.ProductID = TEMP.ProductID
WHERE TEMP.TotalQTY = TEMP2.maxQTY
GROUP BY TEMP.ProductId, TEMP.[CusID]
ORDER BY TEMP.ProductId ASC

/*
Bài tập 5
-	Đề bài : Với mỗi category, hãy tìm chênh lệch doanh số bán hàng của sản phẩm mang
lại doanh số cao nhất và thấp nhất của category đó.
*/
-- LẤY RA DOANH SỐ BÁN HÀNG THEO TỪNG ProductCategoryID VÀ ProductId
WITH cte_DoanhSoSP AS
(
	SELECT SP.ProductCategoryID,
	       SP.ProductId,
	       SUM([TotalLine]) AS [sumTotalLine]
	FROM [dbo].[MX_HOADON_UNION] HDU
	JOIN [dbo].[MX_SANPHAM] AS SP ON SP.ProductId = HDU.ProductID
	GROUP BY SP.ProductCategoryID, SP.ProductId
),
-- LẤY RA ProductCategoryID CÓ DOANH SỐ BÁN HÀNG LỚN NHẤT
cte_MaxDoanhSo AS
(
	SELECT ProductCategoryID,
	       MAX(sumTotalLine) AS [maxDoanhSo]
	FROM cte_DoanhSoSP
	GROUP BY ProductCategoryID
),
-- LẤY RA ProductCategoryID CÓ DOANH SỐ BÁN HÀNG NHỎ NHẤT
cte_MinDoanhSo AS
(
	SELECT ProductCategoryID,
	       MIN(sumTotalLine) AS [minDoanhSo]
	FROM cte_DoanhSoSP
	GROUP BY ProductCategoryID
)

SELECT DISTINCT  TEM.ProductCategoryID,
       (TEM1.maxDoanhSo - TEM2.minDoanhSo) AS [Range]
FROM cte_DoanhSoSP AS TEM
JOIN cte_MaxDoanhSo TEM1 ON TEM1.ProductCategoryID = TEM.ProductCategoryID
JOIN cte_MinDoanhSo TEM2 ON TEM2.ProductCategoryID = TEM.ProductCategoryID
