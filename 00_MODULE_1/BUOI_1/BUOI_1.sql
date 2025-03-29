USE D4E110
GO

CREATE TABLE STUDENTS (
	sID CHAR(5),
	sFirstName VARCHAR(10),
	sLastName VARCHAR(10),
	sPhone CHAR(10),
	sAddress VARCHAR(50)
);

CREATE TABLE COURSE (
	cID CHAR(5),
	cMajor VARCHAR(10),
	cName VARCHAR(30)
);

CREATE TABLE TEACHER (
	tID CHAR(5),
	tFirstName VARCHAR(10),
	tLastName VARCHAR(10),
	tPhone CHAR(10),
	tType INT,
	tMajor VARCHAR(10)
);

--DROP TABLE [dbo].[COURSE];

INSERT INTO [dbo].[STUDENTS]
VALUES
('M0001', 'Minh', 'Nguyen', '0323456789', 'Quang Binh'),
('M0002', 'Hai', 'Do', '0143456789', 'Ha Noi'),
('M0003', 'Bao', 'Nguyen', '0123656789', 'Quang Binh'),
('M0004', 'Thuan', 'Tran', '0123456289', 'Sai Gon'),
('M0005', 'Thao', 'Doan', '0223456589', 'Sai Gon'),
('M0006', 'Giau', 'Le', '0723456459', 'Binh Phuoc'),
('M0007', 'Khoa', 'Tran', '0343452780', 'Dong Nai');

INSERT INTO [dbo].[COURSE]
VALUES
('MC001', 'Data', 'D4E'),
('MC002', 'Data', 'BI'),
('MC003', 'Data', 'BE BASIC'),
('MC004', 'Web', 'WEB BASIC'),
('MC005', 'Web', 'FullStack'),
('MC006', 'Finance', 'FM Basic'),
('MC007', 'Finance', 'FM Intensive');

INSERT INTO [dbo].[TEACHER]
VALUES
('T0001', 'Bao', 'Nguyen', '0233456789', 1, 'Finance'),
('T0002', 'Duy', 'Vo', '0233456789', 1, 'Web'),
('T0003', 'Khoa', 'Dao', '0113656789', 0, 'Web'),
('T0004', 'Phuoc', 'Nguyen', '0347456289', 0, 'Finance'),
('T0005', 'Nghia', 'Cao', '0562456590', 0, 'Data'),
('T0006', 'Ha', 'San', '0783456459', 1, 'Data');

--Bạn hãy viết các đoạn truy vấn để tìm ra các thông tin sau: 
--Giáo viên nào là Mentor
SELECT T.tFirstName,
	   T.tLastName
FROM [dbo].[TEACHER] AS T
WHERE [tType] = 0;

--Giáo viên nào là Super Teacher
SELECT T.tFirstName, 
	   T.tLastName
FROM [dbo].[TEACHER] AS T
WHERE [tType] = 1;

--Tìm ra các học sinh có địa chỉ ở Nghe An 
SELECT S.sID,
	   S.sFirstName,
	   S.sLastName
FROM [dbo].[STUDENTS] AS S
WHERE S.sAddress LIKE 'Nghe An';

--Trường học vừa quyết định sẽ bỏ chuyên ngành Finance để tập trung giảng dạy về công nghệ. 
--Bạn hãy xoá 
--các dữ liệu của các môn thuộc chuyên ngành Finance và các GV giảng dạy các môn thuộc Finance.
DELETE FROM [dbo].[COURSE]
WHERE [cMajor] LIKE 'Finance';

DELETE FROM [dbo].[TEACHER]
WHERE [tMajor] LIKE 'Finance';

--Bạn hãy đổi Major của khóa học có tên là  ‘BE Basic’ thành ‘Web’
UPDATE [dbo].[COURSE]
SET [cName] = 'Web'
WHERE [cName] LIKE 'BE BASIC';

--Giáo viên có tên là  ‘Duy’ vừa nộp đơn xin nghỉ việc, 
--bạn hãy xoá các thông tin của giáo viên này ra khỏi CSDL.
DELETE FROM [dbo].[TEACHER]
WHERE [tFirstName] LIKE 'Duy'

--Giáo viên có tên ‘Khoa’ vừa đổi bộ môn giảng dạy thành ‘Data’,
--bạn hãy cập nhật lại thông tin của giáo viên này.
UPDATE [dbo].[TEACHER]
SET [tMajor] = 'Data'
WHERE [tFirstName] LIKE 'Khoa'
