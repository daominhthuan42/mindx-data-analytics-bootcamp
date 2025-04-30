--CREATE DATABASE D4E_LESSION2_HOMEWORK
--GO
-- LESSION 1
USE D4E_LESSION2_HOMEWORK
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

CREATE TABLE ENROLLMENTS (
	sID CHAR(5),
	cID VARCHAR(10),
	tID CHAR(5),
);

INSERT INTO ENROLLMENTS(sID,cID,tID) VALUES ('M0001','MC001','T0005');
INSERT INTO ENROLLMENTS(sID,cID,tID) VALUES ('M0002','MC002','T0006');
INSERT INTO ENROLLMENTS(sID,cID,tID) VALUES ('M0003','MC003','T0006');
INSERT INTO ENROLLMENTS(sID,cID,tID) VALUES ('M0004','MC004','T0002');
INSERT INTO ENROLLMENTS(sID,cID,tID) VALUES ('M0005','MC005',NULL);
INSERT INTO ENROLLMENTS(sID,cID,tID) VALUES ('M0003','MC001','T0005');
INSERT INTO ENROLLMENTS(sID,cID,tID) VALUES ('M0006','MC002','T0006');
INSERT INTO ENROLLMENTS(sID,cID,tID) VALUES ('M0002','MC003','T0006');
INSERT INTO ENROLLMENTS(sID,cID,tID) VALUES ('M0002','MC004','T0002');
INSERT INTO ENROLLMENTS(sID,cID,tID) VALUES ('M0006','MC005','T0003');
INSERT INTO ENROLLMENTS(sID,cID,tID) VALUES ('M0004','MC001','T0005');
INSERT INTO ENROLLMENTS(sID,cID,tID) VALUES ('M0001','MC002','T0006');
INSERT INTO ENROLLMENTS(sID,cID,tID) VALUES ('M0006','MC003',NULL);
INSERT INTO ENROLLMENTS(sID,cID,tID) VALUES ('M0006','MC004','T0002');
INSERT INTO ENROLLMENTS(sID,cID,tID) VALUES ('M0002','MC005','T0003');
INSERT INTO ENROLLMENTS(sID,cID,tID) VALUES ('M0002','MC006',NULL);

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

-- LESSION 2
/*
Bạn hãy xác định khoá chính, khóa ngoại cho các bảng và tiến hành thêm các ràng buộc dữ liệu giữa các bảng theo như thông tin tham chiếu trong dữ liệu mẫu
*/
-- TẠO KHÓA CHÍNH CHO CÁC BẢNG STUDENTS, TEACHER, COURSE
-- COURSE
ALTER TABLE [dbo].[COURSE]
ALTER COLUMN cID CHAR(5) NOT NULL
ALTER TABLE [dbo].[COURSE] ADD PRIMARY KEY([cID]);

-- STUDENTS
ALTER TABLE [dbo].[STUDENTS]
ALTER COLUMN sID CHAR(5) NOT NULL 
ALTER TABLE [dbo].[STUDENTS] ADD PRIMARY KEY([sID]);

-- TEACHER
ALTER TABLE [dbo].[TEACHER]
ALTER COLUMN tID CHAR(5) NOT NULL
ALTER TABLE [dbo].[TEACHER] ADD PRIMARY KEY(tID);

-- TẠO KHÓA NGOẠI ENROLLMENTS
ALTER TABLE [dbo].[ENROLLMENTS]
ALTER COLUMN cID CHAR(5)

ALTER TABLE [dbo].[ENROLLMENTS]
ADD CONSTRAINT FK_ENROLLMENTS FOREIGN KEY(cID) REFERENCES [dbo].[COURSE](cID)

ALTER TABLE [dbo].[ENROLLMENTS]
ADD CONSTRAINT FK_ENROLLMENTS_STUDENT FOREIGN KEY(sID) REFERENCES [dbo].[STUDENTS](sID)

ALTER TABLE [dbo].[ENROLLMENTS]
ADD CONSTRAINT FK_ENROLLMENTS_TEACHER FOREIGN KEY(tID) REFERENCES [dbo].[TEACHER](tID)

-- Bạn hãy tìm ra những giảng viên là Super Teacher của khoa Data
SELECT T.*
FROM [dbo].[TEACHER] AS T
WHERE T.tType = 1 AND T.tMajor LIKE 'Data';

--Bạn hãy tìm ra những học viên nào học cùng môn MC005, được dạy bởi giáo viên T0003
SELECT S.*
FROM [dbo].[STUDENTS] AS S, [dbo].[ENROLLMENTS] AS E, [dbo].[TEACHER] AS T, [dbo].[COURSE] AS C
WHERE  C.cID LIKE 'MC005' AND 
	   T.tID LIKE 'T0003' AND 
	   S.sID = E.sID AND 
	   C.cID = E.cID AND 
	   T.tID = E.tID;

-- Bạn hãy tìm những học viên nào đăng ký các môn học thuộc khoa Data
SELECT DISTINCT S.*
FROM [dbo].[STUDENTS] AS S, [dbo].[COURSE] AS C, [dbo].[ENROLLMENTS] AS E
WHERE E.cID = C.cID AND
	  E.sID = S.sID AND
	  C.cMajor = 'Data';

-- DÙNG JOIN
SELECT DISTINCT S.*
FROM [dbo].[STUDENTS] AS S
JOIN [dbo].[ENROLLMENTS] AS E ON E.sID = S.sID
JOIN [dbo].[COURSE] AS C ON C.[cID] = E.[cID]
WHERE C.cMajor = 'Data';

--Trong bảng ENROLLMENTS, có 1 số dữ liệu bị NULL ở cột tID, 
--bạn hãy tìm ra chúng và thay thế lại thành giáo viên có mã GV là T0003
SELECT *, ISNULL(tID, 'T0003')
FROM [dbo].[ENROLLMENTS]

UPDATE [dbo].[ENROLLMENTS]
SET tID = 'T0003'
WHERE tID is NULL;

-- LESSION 3
-- TẠO NEW TABLE LEARNING
DROP TABLE IF EXISTS LEARNING
CREATE TABLE LEARNING(
   sID   CHAR(5) NOT NULL
  ,cID   CHAR(5) NOT NULL
  ,score float NOT NULL
);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0001','MC001',4.2);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0002','MC002',3.8);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0003','MC003',6.5);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0004','MC004',2.2);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0005','MC005',5.0);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0003','MC001',8.4);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0006','MC002',6.8);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0002','MC003',9.2);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0002','MC004',7.4);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0006','MC005',5.5);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0004','MC001',8.4);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0001','MC002',4.8);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0006','MC003',9.8);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0006','MC004',4.3);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0002','MC005',4.6);
INSERT INTO LEARNING(sID,cID,score) VALUES ('M0002','MC006',2.2);

-- Bạn hãy tìm ra tất cả mã học viên, tên học viên có đăng ký môn học
SELECT S.sID
FROM [dbo].[STUDENTS] AS S
LEFT JOIN [dbo].[LEARNING] AS L ON L.sID = S.sID
WHERE L.sID IS NOT NULL;

-- Bạn hãy tìm thông tin của những học viên nào không đăng ký môn học.
SELECT S.sID
FROM [dbo].[STUDENTS] AS S
LEFT JOIN [dbo].[LEARNING] AS L ON L.sID = S.sID
WHERE L.sID IS NULL;

-- Bạn hãy tìm những môn học không có học viên nào đăng ký.
SELECT *
FROM [dbo].[COURSE] AS C
LEFT JOIN [dbo].[LEARNING] AS L ON L.cID = C.cID
WHERE L.cID IS NULL;

-- Bạn hãy tìm ra thông tin gồm mã học viên, tên học viên,
-- SĐT của những học viên nào trượt môn. Biết rằng điểm < 4 sẽ trượt môn học.
SELECT S.sID, S.sFirstName, S.sLastName, S.sPhone
FROM [dbo].[STUDENTS] AS S
JOIN [dbo].[LEARNING] AS L ON L.sID = S.sID
WHERE L.score < 4;

-- Hãy tìm ra thông tin học viên có điểm tổng kết môn cao nhất
SELECT TOP 1 S.sID, S.sFirstName, S.sLastName, S.sPhone, L.score
FROM [dbo].[STUDENTS] AS S
JOIN [dbo].[LEARNING] AS L ON L.sID = S.sID
ORDER BY L.score DESC

-- Hãy tìm ra thông tin học viên có điểm tổng kết môn thấp nhất.
SELECT TOP 1 S.sID, S.sFirstName, S.sLastName, S.sPhone, L.score
FROM [dbo].[STUDENTS] AS S
JOIN [dbo].[LEARNING] AS L ON L.sID = S.sID
ORDER BY L.score ASC

--Môn có học viên học điểm thấp nhất là môn nào? 
SELECT TOP 1 S.sID, S.sFirstName, S.sLastName, S.sPhone, L.score, L.cID, C.cName
FROM [dbo].[STUDENTS] AS S
JOIN [dbo].[LEARNING] AS L ON L.sID = S.sID
JOIN [dbo].[COURSE] AS C ON C.cID = L.cID
ORDER BY L.score ASC

-- Sau đó bạn hãy lấy ra danh sách các học viên học cùng môn đó với học viên có điểm thấp nhất,
--và đánh giá sơ bộ nguyên nhân đến từ học viên hay do chất lượng giáo viên? 
SELECT L.sID, L.score
FROM [dbo].[LEARNING] AS L
WHERE L.cID = 'MC004';
