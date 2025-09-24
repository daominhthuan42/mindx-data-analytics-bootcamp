USE [D4E_LESSION1_HOMEWORK]
GO

/*
Đề bài : Bạn hãy lấy ra các sản phẩm có giá bán từ 50$ trở lên và tạo thêm trường thông tin để hiển thị nhóm sản phẩm thuộc loại “giá trị cao”,
các sản phẩm còn lại thuộc loại “ giá trị thấp”
*/
SELECT *,
	   CASE
			WHEN [Price] > 50 THEN N'GIÁ TRỊ CAO'
			ELSE N'GIÁ TRỊ THẤP'
		END [RANKING_PRODUCT]
FROM [dbo].[MX_SANPHAM]

/*
Bạn hãy tìm ra tổng doanh số và tổng số sản phẩm bán được của từng ProductCategoryID
*/
-- 'BÁN ĐƯỢC'. TỨC LÀ SẢN PHẨM PHẢI ĐƯỢC ĐẶT HÀNG VÀ THANH TOÁN THÀNH CÔNG THÌ MỚI XEM LÀ BÁN ĐƯỢC.
-- VÌ CÓ THỂ NHIỀU SẢN PHẨM KHÔNG ĐƯỢC ĐẶT HÀNG NÊN CẦN JOIN VỚI [MX_HOADON_MOI] ĐỂ ĐẢM BẢO LẤY RA NHỮNG SẢN PHẨM ĐÃ ĐƯỢC ĐẶT HÀNG
-- VÀ KHÔNG QUAN TÂM NHỮNG SP CHƯA ĐẶT HÀNG.
SELECT [ProductCategoryID],
       SUM(HDM.[Price]) AS [SUM_PRICE],
	   COUNT(HDM.[ProductId]) AS [TOTAL_PRODUCT]
FROM [dbo].[MX_SANPHAM] AS SP
-- JOIN VỚI BẢNG [MX_HOADON_MOI]
JOIN [dbo].[MX_HOADON_MOI] AS HDM ON HDM.ProductID = SP.ProductId
WHERE HDM.DateCreate IS NOT NULL -- [DateCreate] PHẢI KO NULL VÌ DateCreate ĐƯỢC HIỂU LÀ CUSTOMER ĐÃ THANH TOÁN VÀ BÊN CTY SẼ XUẤT HÓA ĐƠN ĐÍNH KÈM.
GROUP BY [ProductCategoryID]

/*
-	Đề bài : Bạn hãy tìm tổng doanh số của các nhân viên bán hàng và tạo thêm trường thông tin sale_type trong kết quả truy vấn với điều kiện: 
+	Tổng doanh số trên 350$ thì hiển thị “Excellent Staff”
+	Các trường hợp còn lại thì hiển thị “Normal Staff”
*/
SELECT NV.EmID, NV.EmName,
	   SUM(HDM.Price) AS [SUM_PRICE],
	   CASE
			WHEN SUM(HDM.Price) > 350 THEN 'Excellent Staff'
			ELSE 'Normal Staff'
	   END [sale_type]
FROM [dbo].[MX_NHANVIEN] NV
JOIN [dbo].[MX_HOADON_MOI] HDM ON HDM.SalesID = NV.EmID
GROUP BY NV.EmID, NV.EmName;

/*
Bạn hãy tìm tổng số lượng sản phẩm được mua của từng category vào tháng 3, tháng 5
và tạo thêm trường thông tin hiển thị chi tiết tỷ lệ tăng/giảm bao nhiêu % của tháng 3 -5.
*/
-- SỬ DỤNG KỸ THUẬT CTE ĐỂ TẠO RA BẢNG ẢO.
WITH CTE_TOTAL_ORDER_3 AS (
	SELECT [ProductID], COUNT([OrderID]) AS [NUMBER_ID_3]
	FROM [dbo].[MX_HOADON_UNION]
	WHERE MONTH([DateCreate]) = 3
	GROUP BY [ProductID]
),
CTE_TOTAL_ORDER_5 AS (
	SELECT [ProductID], COUNT([OrderID]) AS [NUMBER_ID_5]
	FROM [dbo].[MX_HOADON_UNION]
	WHERE MONTH([DateCreate]) = 5
	GROUP BY [ProductID]
)

SELECT TOTAL_PRODUCT_3_5.ProductCategoryID,
       TOTAL_PRODUCT_3_5.[ORDER M3],
	   TOTAL_PRODUCT_3_5.[ORDER M5], 
	   CASE
			WHEN CAST([ORDER M5] AS FLOAT) / [ORDER M3] > 1 THEN CONCAT(N'TĂNG', ' ', CAST(CAST([ORDER M5] AS FLOAT) / [ORDER M3] AS VARCHAR(10)))
			WHEN [ORDER M5] / [ORDER M3] = 1 THEN N'KHÔNG THAY ĐỔI'
			ELSE CONCAT(N'GIẢM', ' ', CAST(CAST([ORDER M5] AS FLOAT) / [ORDER M3] AS VARCHAR(10)))
	   END [TĂNG/GIẢM]
FROM
(
	SELECT SP.ProductCategoryID,
		   SUM(TEMP3.NUMBER_ID_3) AS [ORDER M3],
		   SUM(TEMP5.NUMBER_ID_5) AS [ORDER M5]
	FROM [dbo].[MX_SANPHAM] AS SP
	JOIN CTE_TOTAL_ORDER_3 AS TEMP3 ON TEMP3.ProductID = SP.ProductId
	JOIN CTE_TOTAL_ORDER_5 AS TEMP5 ON TEMP5.ProductID = SP.ProductId
	GROUP BY SP.ProductCategoryID
) AS [TOTAL_PRODUCT_3_5]

-- CÁCH THƯỜNG
SELECT TOTAL_PRODUCT_3_5.ProductCategoryID,
       TOTAL_PRODUCT_3_5.[ORDER M3],
	   TOTAL_PRODUCT_3_5.[ORDER M5],
	   CASE
			WHEN CAST([ORDER M5] AS FLOAT) / [ORDER M3] > 1 THEN CONCAT(N'TĂNG', ' ', CAST(CAST([ORDER M5] AS FLOAT) / [ORDER M3] AS VARCHAR(10)))
			WHEN [ORDER M5] / [ORDER M3] = 1 THEN N'KHÔNG THAY ĐỔI'
			ELSE CONCAT(N'GIẢM', ' ', CAST(CAST([ORDER M5] AS FLOAT) / [ORDER M3] AS VARCHAR(10)))
	   END [TĂNG/GIẢM]
FROM
(
	SELECT SP.ProductCategoryID,
		   SUM(TOTAL_ORDER_3.NUMBER_ID_3) AS [ORDER M3],
		   SUM(TOTAL_ORDER_5.NUMBER_ID_5) AS [ORDER M5] 
	FROM
	(
		SELECT [ProductID], COUNT([OrderID]) AS [NUMBER_ID_3]
		FROM [dbo].[MX_HOADON_UNION]
		WHERE MONTH([DateCreate]) = 3
		GROUP BY [ProductID]
	) AS TOTAL_ORDER_3,
	(
		SELECT [ProductID], COUNT([OrderID]) AS [NUMBER_ID_5]
		FROM [dbo].[MX_HOADON_UNION]
		WHERE MONTH([DateCreate]) = 5
		GROUP BY [ProductID]
	) AS TOTAL_ORDER_5,
	[dbo].[MX_SANPHAM] AS SP
	WHERE SP.ProductId = TOTAL_ORDER_3.ProductID AND TOTAL_ORDER_5.ProductID = SP.ProductId -- TƯƠNG ĐƯƠNG INNER JOIN
	GROUP BY SP.ProductCategoryID
) AS [TOTAL_PRODUCT_3_5]
