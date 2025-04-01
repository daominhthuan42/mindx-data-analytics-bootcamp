USE D4E_LESSION2_HOMEWORK
GO

/*
BÀI TẬP 1
Phần 1: 
Dựa vào file mô tả CSDL mà chính bạn đã xây dựng, hãy xác định khoá chính, khoá ngoại cho các bảng trong CSDL của công ty MX ,
sau khi xác định xong, hãy bổ sung các thông tin về khoá chính , 
khóa ngoại và tham chiếu của chúng tới từng bảng trong file mô tả CSDL.

Phần 2: 
Bạn hãy thực hiện bổ sung khoá chính - khoá ngoại và các tham chiếu trong CSDL với SQL dựa vào bản mô tả CSDL mà bạn vừa hoàn thành ở phần 1.

Phần 3: 
Trong bảng HOADON, nếu xóa cột OrderLine, khi đó, trường thông tin nào sẽ làm khóa chính cho bảng?
*/

-- PHẦN 1
-- VỚI BẢNG [MX_HOADON]
-- KHÓA CHÍNH: [OrderLine]
-- KHÓA NGOẠI: [SalesID], [ProductId]

-- VỚI BẢNG [MX_NHANVIEN]
-- KHÓA CHÍNH: [EmID]
-- THAM CHIẾU ĐẾN [SalesID] CỦA BẢNG [MX_HOADON].

-- VỚI BẢNG [MX_SANPHAM]
-- KHÓA CHÍNH: [ProductId]
-- THAM CHIẾU ĐẾN [ProductID] BẢNG [MX_HOADON]

-- PHẦN 2
-- [MX_HOADON]
ALTER TABLE [dbo].[MX_HOADON] ADD PRIMARY KEY([OrderLine]);

-- TẠO KHÓA NGOẠI CHO ProductId
ALTER TABLE [dbo].[MX_HOADON] ADD FOREIGN KEY([ProductID]) REFERENCES [dbo].[MX_SANPHAM]([ProductId]);

-- TẠO KHÓA NGOẠI CHO SalesID
ALTER TABLE [dbo].[MX_HOADON]
ADD FOREIGN KEY([SalesID]) REFERENCES [dbo].[MX_NHANVIEN]([EmID]);

-- PHẦN 3:
-- Nếu xóa cột OrderLine thì ta sẽ dùng 2 coloumn [OrderID] và [CusID] làm khóa chính cho bảng.

/*
Áp dụng các toán tử so sánh để xây dựng các câu truy vấn phục vụ cho việc chuẩn bị dữ liệu
Đề bài : Anh Lê Đức Hiếu, giám đốc bán hàng của công ty đề xuất sẽ tung ra 1 chiến dịch truyền thông giảm giá 10% 
cho tất cả hoá đơn mua hàng vào ngày 3/4/2022 (MM/DD/YYYY). Do vậy anh muốn bạn hãy lấy ra các đơn hàng mua hàng trước ngày 3/4/2022
để có số liệu đối chiếu xem chiến dịch truyền thông giảm giá có ảnh hưởng đến quyết định mua sắm. 
Bạn hãy chuẩn bị dữ liệu bằng cách lấy ra các đơn hàng có ngày lập hoá đơn trước ngày 3/4/2022
*/
SELECT OrderID
FROM [dbo].[MX_HOADON]
WHERE DateCreate < '2022-03-04';

/*
Bài tập 3: Áp dụng các toán tử logic để xây dựng các câu truy vấn phục vụ cho việc chuẩn bị dữ liệu
Bài tập 3.1:
Đề bài : Hiện tại các tỉnh miền Trung đang bị ảnh hưởng chung bởi bão, lũ. Nhất là 2 tỉnh Quảng Bình và Quảng Trị.
BOD quyết định sẽ hỗ trợ cho các nhân viên có quê quán ở 2 tỉnh trên. 
Bạn hãy viết câu lệnh truy vấn để tìm ra các nhân viên có quê quán từ 2 tỉnh trên.

Bài tập 3.2:
Đề bài: Do ảnh hưởng của bão, lũ. Công ty quyết định cho các nhân viên có quê ở các tỉnh miền Trung bị ảnh hưởng được tạm nghỉ về nhà để giúp đỡ gia đình phòng chống bão, lũ.
Bạn hãy chuẩn bị cho BOD 2 danh sách nhân viên gồm: 
- Danh sách các nhân sự ở miền Trung được tạm nghỉ về quê
- Danh sách các nhân sự ở lại làm việc.
Biết rằng, các tỉnh miền Trung bị ảnh hưởng bởi bão, lũ gồm các tỉnh Nghệ An, Hà Tĩnh, Quảng Bình, Quảng Trị và Thừa Thiên Huế.
*/
-- 3.1
SELECT *
FROM [dbo].[MX_NHANVIEN]
WHERE [Address] IN (N'Quảng Bình', N'Quảng Trị');

-- 3.2
-- Danh sách các nhân sự ở miền Trung được tạm nghỉ về quê
SELECT *
FROM [dbo].[MX_NHANVIEN]
WHERE [Address] IN (N'Nghệ An', N'Hà Tĩnh', N'Thừa Thiên Huế', N'Quảng Bình', N'Quảng Trị');

-- Danh sách các nhân sự ở lại làm việc.
SELECT *
FROM [dbo].[MX_NHANVIEN]
WHERE [Address] NOT IN (N'Nghệ An', N'Hà Tĩnh', N'Thừa Thiên Huế', N'Quảng Bình', N'Quảng Trị');

/*
Bài tập 4: Áp dụng các hàm để xác định dữ liệu NULL và xử lý dữ liệu NULL
Đề bài : Do lỗi trong quá trình nhập liệu nên có một số nhân viên có ngày onboarding bị để trống.
BOD muốn bạn tìm ra các nhân viên đó và thay thế ngày onboarding từ NULL thành ngày 1/1/2020. 
*/
-- Tìm ra các nhân viên có StartDate là NULL
SELECT *
FROM [dbo].[MX_NHANVIEN]
WHERE [StartDate] IS NULL;

-- Thay thế ngày onboarding từ NULL thành ngày 1/1/2020.
UPDATE [dbo].[MX_NHANVIEN]
SET [StartDate] = '2020-01-01'
WHERE [StartDate] IS NULL;
