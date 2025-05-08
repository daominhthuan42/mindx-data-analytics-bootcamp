-- KHỞI TẠO DATABASE HR_CLUSTERED
DROP DATABASE IF EXISTS HR_CLUSTERED
CREATE DATABASE HR_CLUSTERED
ON
(
	NAME = 'HR_CLUSTERED_DATA',
	FILENAME = 'C:/00_DATA/02_KHOA_HOC_MINDX/00_MODULE_1/FINAL_PROJECT/00_SQL/HR_CLUSTERED_DATA.mdf',
	SIZE = 10MB,
	MAXSIZE = 100MB,
	FILEGROWTH = 5MB
)
LOG ON
(
	NAME = 'HR_CLUSTERED_LOG',
	FILENAME = 'C:/00_DATA/02_KHOA_HOC_MINDX/00_MODULE_1/FINAL_PROJECT/00_SQL/HR_CLUSTERED_LOG.ldf',
	SIZE = 5MB,
	MAXSIZE = 50MB,
	FILEGROWTH = 5MB
)

USE HR_CLUSTERED
GO

-- TỔNG SỐ NHÂN VIÊN
SELECT COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees]
FROM [dbo].[HR Analytics Data] AS HR;

-- TỔNG SỐ NHÂN VIÊN NAM VÀ PHẦN TRĂM NHÂN VIÊN NAM TRONG CÔNG TY
SELECT COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees Male],
       COUNT(CASE WHEN HR.Gender = 'Male' THEN 1 END) * 100.0 / (SELECT COUNT(DISTINCT EmployeeNumber) FROM [dbo].[HR Analytics Data]) AS [Percentage of women]
FROM [dbo].[HR Analytics Data] AS HR
WHERE HR.Gender = 'Male';

-- TỔNG SỐ NHÂN VIÊN NỮ VÀ PHẦN TRĂM NHÂN VIÊN NỮ TRONG CÔNG TY
SELECT COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees Male],
       COUNT(CASE WHEN HR.Gender = 'Female' THEN 1 END) * 100.0 / (SELECT COUNT(DISTINCT EmployeeNumber) FROM [dbo].[HR Analytics Data]) AS [Percentage of women]
FROM [dbo].[HR Analytics Data] AS HR
WHERE HR.Gender = 'Female';

-- GIẢ SỬ NHỮNG AI CHƯA ĐƯỢC THĂNG CHỨC TRONG 10 NĂM TRỞ LẠI THÌ SẼ XÉT DUYỆT ĐƯỢC THĂNG CHỨC.
-- YEARSSINCELASTPROMOTION >= 10 THÌ DUE FOR PROMOTION
-- NGƯỢC LẠI THÌ NOT DUE FOR PROMOTION.
-- PHẦN TRĂM "DUE FOR PROMOTION" TRÊN TỔNG SỐ NHÂN VIÊN
-- PHẦN TRĂM "NOT DUE FOR PROMOTION" TRÊN TỐNG SỐ NHÂN VIÊN.
WITH ctePromotionStatus AS
(
	SELECT COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees],
	       COUNT(CASE WHEN HR.YearsSinceLastPromotion >= 10 THEN 1 END) AS [Due for promotion],
		   COUNT(CASE WHEN HR.YearsSinceLastPromotion < 10 THEN 1 END) AS [Not due for promotion]
	FROM [dbo].[HR Analytics Data] AS HR
)
SELECT TEMP.[Due for promotion],
       ROUND(TEMP.[Due for promotion] * 100.0 / TEMP.[Total Employees], 2) AS [Percentage due for promotion],
	   TEMP.[Not due for promotion],
	   ROUND(TEMP.[Not due for promotion] * 100.0 / TEMP.[Total Employees], 2) AS [Percentage not due for promotion]
FROM ctePromotionStatus AS TEMP

-- SỐ NĂM PHỤC VỤ CỦA NHÂN VIÊN
SELECT HR.YearsAtCompany,
       COUNT(HR.EmployeeNumber) AS [Total Employees]
FROM [dbo].[HR Analytics Data] AS HR
GROUP BY HR.YearsAtCompany
ORDER BY HR.YearsAtCompany;

-- SỐ NHÂN VIÊN ỨNG VỚI JOB LEVEL
SELECT HR.JobLevel,
       COUNT(HR.EmployeeNumber) AS [Total Employees]
FROM [dbo].[HR Analytics Data] AS HR
GROUP BY HR.JobLevel
ORDER BY HR.JobLevel;

-- GIẢ SỬ BỘ PHẬN HR MUỐN CẮT GIẢM NHÂN SỰ VỚI NHỮNG AI ĐÃ LÀM VIỆC HƠN 18 NĂM THÌ SẼ BỊ CẮT GIẢM.
-- NGƯỢC LẠI THÌ SẼ VẪN LÀM VIỆC TẠI CÔNG TY.
-- TÍNH RA SỐ LƯỢNG NHÂN VIÊN BỊ CẮT GIẢM (SỐ NĂM LÀM VIỆC > 18) VÀ % TRÊN TỔNG SỐ LƯỢNG NHÂN VIÊN.
-- TÍNH RA SỐ LƯỢNG NHÂN VIÊN CÒN LẠI VÀ % TRÊN TỔNG SỐ LƯỢNG NHÂN VIÊN.
WITH cteRetrenchmentStatus AS
(
	SELECT COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees],
	       COUNT(CASE WHEN HR.YearsAtCompany >= 18 THEN 1 END) AS [Will be retrenched],
		   COUNT(CASE WHEN HR.YearsAtCompany < 18 THEN 1 END) AS [Active worker]
	FROM [dbo].[HR Analytics Data] AS HR
)
SELECT TEMP.[Active worker],
       ROUND(TEMP.[Active worker] * 100.00 / TEMP.[Total Employees], 2) AS [Percentage active worker],
	   TEMP.[Will be retrenched],
	   ROUND(TEMP.[Will be retrenched] * 100.00 / TEMP.[Total Employees], 2) AS [Percentage will be retrenched]
FROM cteRetrenchmentStatus AS TEMP;

-- TỪ COLUMN DISTANCEFROMHOME TIẾN HÀNH PHÂN LOẠI KHOẢNG CÁCH TỬ CÔNG TY ĐẾN NHÀ NHÂN VIÊN:
-- DISTANCE > 20: VERY FAR
-- 10 < DISTANCE <= 20: FAR
-- 5 < DISTANCE <= 10: CLOSE
-- VERY CLOSE
WITH cteDistanceStatus AS
(
	SELECT COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees],
		   COUNT(CASE WHEN HR.DistanceFromHome > 20 THEN 1 END) AS [Very far],
		   COUNT(CASE WHEN HR.DistanceFromHome > 10 AND HR.DistanceFromHome <= 20 THEN 1 END) AS [Far],
		   COUNT(CASE WHEN HR.DistanceFromHome > 5 AND HR.DistanceFromHome <= 10 THEN 1 END) AS [Close],
		   COUNT(CASE WHEN HR.DistanceFromHome <= 5 THEN 1 END) AS [Very close]
	FROM [dbo].[HR Analytics Data] AS HR
)
SELECT TEMP.[Very far],
       ROUND(TEMP.[Very far] * 100.0 / TEMP.[Total Employees], 2) AS [Percentage very far],
	   TEMP.[Far],
	   ROUND(TEMP.Far * 100.0 / TEMP.[Total Employees], 2) AS [Percentage far],
	   TEMP.[Close],
	   ROUND(TEMP.[Close] * 100.0 / TEMP.[Total Employees], 2) AS [Percentage close],
	   TEMP.[Very close],
	   ROUND(TEMP.[Very close] * 100.0 / TEMP.[Total Employees], 2) AS [Percentage very close] 
FROM cteDistanceStatus AS TEMP;

-- DANH SÁCH TÊN NHÂN VIÊN ĐƯỢC THĂNG CHỨC
SELECT E.Emplyee_name,
       (CASE WHEN HR.YearsSinceLastPromotion >= 10 THEN 1 END) AS [Due for promotion]
FROM [dbo].[HR Analytics Data] AS HR
JOIN [dbo].[HR employee data] AS E ON E.EmployeeNumber = HR.EmployeeNumber
WHERE HR.YearsSinceLastPromotion >= 10;

-- DANH SÁCH TÊN NHÂN VIÊN ĐƯỢC CẮT GIẢM
SELECT E.Emplyee_name,
       (CASE WHEN HR.YearsAtCompany >= 18 THEN 1 END) AS [Will be retrenched]
FROM [dbo].[HR Analytics Data] AS HR
JOIN [dbo].[HR employee data] AS E ON E.EmployeeNumber = HR.EmployeeNumber
WHERE HR.YearsAtCompany >= 18;

-- SỐ LƯỢNG NHÂN VIÊN THĂNG CHỨC VÀ CẮT GIẢM CỦA MỖI DEPARTMENT
SELECT HR.Department,
	   COUNT(CASE WHEN HR.YearsSinceLastPromotion >= 10 THEN 1 END) AS [Due for promotion],
	   COUNT(CASE WHEN HR.YearsAtCompany >= 18 THEN 1 END) AS [Will be retrenched]
FROM [dbo].[HR Analytics Data] AS HR
GROUP BY HR.Department;

-- ĐỘ HÀI LÒNG TRONG CÔNG VIỆC CỦA TOÀN BỘ NHÂN VIÊN
-- 1, 2: HIGH
-- 3: MEDIUM
-- 4: LOW
SELECT COUNT(CASE WHEN HR.JobSatisfaction <= 2 THEN 1 END) AS [HIGH],
       COUNT(CASE WHEN HR.JobSatisfaction = 3 THEN 1 END) AS [MEDIUM],
	   COUNT(CASE WHEN HR.JobSatisfaction = 4 THEN 1 END) AS [LOW]
FROM [dbo].[HR Analytics Data] AS HR;

-- SÔ LƯỢNG NHÂN VIÊN OVERTIME VÀ KHÔNG OVERTIME.
WITH cteOverTimeStatus AS
(
	SELECT HR.OverTime AS [Overtime Status],
	       COUNT(CASE WHEN HR.OverTime = 1 THEN 1 END) AS [OVERTIME],
		   COUNT(CASE WHEN HR.OverTime = 0 THEN 1 END) AS [NO OVERTIME]
	FROM [dbo].[HR Analytics Data] AS HR
	GROUP BY HR.OverTime
)
SELECT TEMP.[Overtime Status],
       TEMP.OVERTIME,
	   TEMP.[NO OVERTIME],
       ROUND(TEMP.OVERTIME * 100.0 / (SELECT COUNT(DISTINCT EmployeeNumber) FROM [dbo].[HR Analytics Data]), 2) AS [Percentage overtime],
	   ROUND(TEMP.[NO OVERTIME] * 100.0 / (SELECT COUNT(DISTINCT EmployeeNumber) FROM [dbo].[HR Analytics Data]), 2) AS [Percentage no overtime]
FROM cteOverTimeStatus AS TEMP;

-- SỐ LƯỢNG NHÂN VIÊN DỰA TRÊN PERFORMACE RATING
WITH ctePerformanceRatingStatus AS
(
	SELECT HR.PerformanceRating AS [Performance rating],
		   COUNT(CASE WHEN HR.PerformanceRating = 3 THEN 1 END) AS [LEVEL 3],
		   COUNT(CASE WHEN HR.PerformanceRating = 4 THEN 1 END) AS [LEVEL 4]
	FROM [dbo].[HR Analytics Data] AS HR
	GROUP BY HR.PerformanceRating
)
SELECT TEMP.[Performance rating],
       ROUND(TEMP.[LEVEL 3] * 100.0 / (SELECT COUNT(DISTINCT EmployeeNumber) FROM [dbo].[HR Analytics Data]), 2) AS [Percentage level 3],
	   ROUND(TEMP.[LEVEL 4] * 100.0 / (SELECT COUNT(DISTINCT EmployeeNumber) FROM [dbo].[HR Analytics Data]), 2) AS [Percentage level 4]
FROM ctePerformanceRatingStatus AS TEMP;

-- SỐ LƯỢNG NHÂN VIÊN THĂNG CHỨC VÀ CẮT GIẢM DỰA THEO JOB ROLE
SELECT HR.JobRole,
       COUNT(DISTINCT HR.EmployeeNumber) AS [Total employees],
	   COUNT(CASE WHEN HR.YearsSinceLastPromotion >= 10 THEN 1 END) AS [Due for promotion],
	   COUNT(CASE WHEN HR.YearsAtCompany >= 18 THEN 1 END) AS [Will be retrenched]
FROM [dbo].[HR Analytics Data] AS HR
GROUP BY HR.JobRole;

-- INCOME CỦA NHÂN VIÊN DỰA THEO JOB ROLE
SELECT HR.JobRole,
       SUM(HR.MonthlyIncome) AS [Sum of income by job role]
FROM [dbo].[HR Analytics Data] AS HR
GROUP BY HR.JobRole;

-- TOP 10 NHÂN VIÊN CÓ THU NHẬP CAO NHẤT
SELECT TOP 10 E.Emplyee_name,
       HR.MonthlyIncome
FROM [dbo].[HR Analytics Data] AS HR
JOIN [dbo].[HR employee data] AS E ON E.EmployeeNumber = HR.EmployeeNumber
ORDER BY HR.MonthlyIncome DESC;

-- SỐ LƯỢNG NHÂN VIÊN DỰA THEO PHẦN TRĂM TĂNG LƯƠNG PercentSalaryHike
SELECT HR.PercentSalaryHike,
       COUNT(DISTINCT HR.EmployeeNumber) AS [Total Emp]
FROM [dbo].[HR Analytics Data] AS HR
GROUP BY HR.PercentSalaryHike
ORDER BY HR.PercentSalaryHike;

-- TỔNG THU NHẬP DỰA THEO JOB LEVEL
SELECT HR.JobLevel,
       COUNT(DISTINCT HR.EmployeeNumber) AS [Total Emp],
	   SUM(HR.MonthlyIncome) AS [Sum of income by job level],
	   ROUND(SUM(HR.MonthlyIncome) * 100.0 / (SELECT SUM(MonthlyIncome) FROM [dbo].[HR Analytics Data]), 2) AS [Percentage income by job level]
FROM [dbo].[HR Analytics Data] AS HR
GROUP BY HR.JobLevel
ORDER BY HR.JobLevel;
