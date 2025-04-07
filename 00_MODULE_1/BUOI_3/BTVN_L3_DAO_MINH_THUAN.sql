USE D4E_LESSION3_HOMEWORK
GO

-- Dựa vào database của công ty MX, bạn hãy tìm ra những đơn hàng nào mua sản phẩm thuộc thể loại sản phẩm (Category) là Chip
SELECT HD.*
FROM [dbo].[MX_HOADON] HD
JOIN [dbo].[MX_SANPHAM] SP ON SP.ProductId = HD.ProductID
WHERE SP.CategoryName = 'Chip';

-- Bạn hãy tìm những đơn hàng được bán bởi nhân viên có tên là Linh.
SELECT HD.*, NV.EmName
FROM [dbo].[MX_HOADON] HD
JOIN [dbo].[MX_NHANVIEN] NV ON NV.EmID = HD.SalesID
WHERE NV.EmName LIKE '%Linh';

/*
Một chi nhánh cửa hàng khác cũng thực hiện mua bán và các dữ liệu được lưu trữ trong file HOADONMOI.
Hãy import file HOADONMOI.csv thành bảng HOADONMOI.
Sau đó thực hiện lại bài tập 1 và bài tập 2 với dữ liệu được kết hợp từ 2 bảng HOADON và HOADONMOI.
*/
-- Dữ liệu được kết hợp từ 2 bảng HOADON và HOADONMOI.
-- TẠO 1 TABLE KẾT HỢP GIỮA 2 BẢNG HOADON VÀ HOADONMOI SỬ DỤNG CÂU LỆNH SELECT INTO
DROP TABLE IF EXISTS MX_HOADON_UNION
SELECT *
INTO MX_HOADON_UNION
FROM (
	SELECT * FROM [dbo].[MX_HOADON]
	UNION ALL
	SELECT * FROM [dbo].[MX_HOADON_MOI]
) AS HDU;

-- Dựa vào database của công ty MX, bạn hãy tìm ra những đơn hàng nào mua sản phẩm thuộc thể loại sản phẩm (Category) là Chip
-- với bảng kết hợp MX_HOADON_UNION
SELECT HDU.*
FROM [dbo].[MX_HOADON_UNION] HDU
JOIN [dbo].[MX_SANPHAM] SP ON SP.ProductId = HDU.ProductID
WHERE SP.CategoryName = 'Chip';

-- Bạn hãy tìm những đơn hàng được bán bởi nhân viên có tên là Linh với bảng MX_HOADON_UNION.
SELECT HDU.*, NV.EmName
FROM [dbo].[MX_HOADON_UNION] HDU
JOIN [dbo].[MX_NHANVIEN] NV ON NV.EmID = HDU.SalesID
WHERE NV.EmName LIKE '%Linh';

/*
Bạn hãy tìm ra các khoảng thời gian tạo hoá đơn của các đơn hàng sau khi nhận được thông tin Order từ khách hàng
Hướng dẫn làm bài: Sử dụng DATEDIFF() để làm bài.
*/
SELECT DISTINCT DATEDIFF(day, [OrderDate], [DateCreate]) AS [Number Date]
FROM [dbo].[MX_HOADON_UNION];
