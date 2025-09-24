CREATE DATABASE D4E_LESSION1_HOMEWORK;

USE D4E_LESSION1_HOMEWORK
GO

/*
Bài tập 1: Đã import file csv vào SSMS.
*/

/*
Bài tập 2 : Xuất dữ liệu với các yêu cầu cụ thể ( Câu lệnh SELECT - FROM - WHERE )
Đề bài 2.1: 
Quản lý muốn bạn truy vấn, lấy ra dữ liệu của các sản phẩm thuộc loại ‘Disk’ để làm báo cáo cho BOD.
Bạn hãy viết câu lệnh truy vấn trên CSDL đã tạo ở bài 1 để lấy ra kết quả mà quản lý mong muốn.
*/
SELECT SP.*
FROM [dbo].[MX_SANPHAM] AS SP
WHERE SP.[CategoryName] LIKE 'Disk';

/*
Hiện tại các tỉnh miền Trung đang bị ảnh hưởng chung bởi bão, lũ. Nhất là 2 tỉnh Quảng Bình và Quảng Trị.
BOD quyết định sẽ hỗ trợ cho các nhân viên có quê quán ở 2 tỉnh trên.
Bạn hãy viết câu lệnh truy vấn để tìm ra các nhân viên có quê quán từ 2 tỉnh trên
*/
SELECT *
FROM [dbo].[MX_NHANVIEN] AS NV
WHERE NV.[Address] LIKE N'Quảng Bình' OR NV.[Address] LIKE N'Quảng Trị';
-- WHERE NV.[Address] like 'Qu%B%' OR NV.[Address] like 'Qu%T%';

/*
Bài tập 3 : Cập nhật lại dữ liệu trong CSDL ( Câu lệnh UPDATE - DELETE - WHERE )
Đề bài 3.1: 
BOD nhận thấy các sản phẩm ‘Ổ cứng HDD 1TB’ bán khá chậm và thị trường cũng dần sử dụng ổ cứng SSD để có hiệu quả tốt hơn,
nên quyết định sẽ dừng bán sản phẩm này từ ngày 31/12/2022. Bạn hãy cập nhật lại dữ liệu trong CSDL đã tạo ở trên.
*/
UPDATE [dbo].[MX_SANPHAM]
SET [SalesEndDate] = '2022-12-31'
WHERE [ProductId] LIKE 'MXSP19';

/*
Đề bài 3.2: 
Do trong quá trình làm việc, nhân viên có tên ‘Nguyễn Lê Chí Bẻo’ thể hiện tốt.
Nên BOD quyết định thăng chức cho nhân viên ‘Nguyễn Lê Chí Bẻo’ từ vị trí Bảo vệ thành vị trí ‘Trưởng bộ phận an ninh’ với mức lương mới là 150$.
Bạn hãy cập nhật lại chức danh và mức lương của nhân viên này trên CSDL.
*/
UPDATE [dbo].[MX_NHANVIEN]
SET [Salary] = 150,
	[JobTitle] = N'Trưởng bộ phận an ninh'
WHERE [EmName] LIKE N'Nguyễn Lê Chí Bẻo';

/*
Đề bài 3.3: 
Do có vài sai phạm trong quá trình thực hiện báo cáo tài chính, nên nhân viên ‘Đỗ Đắc Hải’,
vị trí Trưởng phòng tài vụ bị giáng chức và buộc phải chuyển sang phòng Data để công tác với chức danh ‘Chuyên viên phân tích rủi ro’, mức lương là 2000$. 
Bạn hãy cập nhật lại chức danh, phòng ban và mức lương cho nhân viên này.
*/
UPDATE [dbo].[MX_NHANVIEN]
SET [DepName] = 'Data',
	[JobTitle] = N'Chuyên viên phân tích rủi ro',
	[Salary] = 2000
WHERE [EmName] LIKE N'Đỗ Đắc Hải';
