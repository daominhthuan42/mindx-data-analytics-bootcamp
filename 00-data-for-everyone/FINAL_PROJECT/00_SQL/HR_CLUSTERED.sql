-- KHỞI TẠO DATABASE HR_CLUSTERED
DROP DATABASE IF EXISTS HR_CLUSTERED
CREATE DATABASE HR_CLUSTERED

USE HR_CLUSTERED
GO

-- TỔNG SỐ NHÂN VIÊN NAM VÀ PHẦN TRĂM NHÂN VIÊN NAM TRONG CÔNG TY
SELECT 
	COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees Male],
	COUNT(CASE WHEN HR.Gender = 'Male' THEN 1 END) * 100.0 / (SELECT COUNT(DISTINCT EmployeeNumber) FROM [dbo].[HR Analytics Data]) AS [Percentage of women]
FROM [dbo].[HR Analytics Data] AS HR
WHERE HR.Gender = 'Male';

-- TỔNG SỐ NHÂN VIÊN NỮ VÀ PHẦN TRĂM NHÂN VIÊN NỮ TRONG CÔNG TY
SELECT 
	COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees Male],
	COUNT(CASE WHEN HR.Gender = 'Female' THEN 1 END) * 100.0 / (SELECT COUNT(DISTINCT EmployeeNumber) FROM [dbo].[HR Analytics Data]) AS [Percentage of women]
FROM [dbo].[HR Analytics Data] AS HR
WHERE HR.Gender = 'Female';

-- COLUMN "Attrition" CÓ Ý NGHĨA LÀ CẮT GIẢM NHÂN SỰ. NẾU LÀ 1 THÌ NHÂN VIÊN ĐÓ SẼ BỊ CẮT GIẢM NGƯỢC LẠI BẰNG 0 THÌ VẪN TIẾP TỤC CÔNG VIỆC.
-- SỐ NHÂN VIÊN CẮT GIẢM.
SELECT
	COUNT(DISTINCT HR.EmployeeNumber) AS [Next retrenchment],
	COUNT(CASE WHEN HR.Attrition = 1 THEN 1 END) * 100.0 / (SELECT COUNT(DISTINCT EmployeeNumber) FROM [dbo].[HR Analytics Data]) AS [Percentage next retrenchment]
FROM [dbo].[HR Analytics Data] AS HR
WHERE HR.Attrition = 1;

-- SỐ NHÂN VIÊN VẪN ĐANG LÀM VIỆC.
SELECT
	COUNT(DISTINCT HR.EmployeeNumber) AS [Active worker],
	COUNT(CASE WHEN HR.Attrition = 0 THEN 1 END) * 100.0 / (SELECT COUNT(DISTINCT EmployeeNumber) FROM [dbo].[HR Analytics Data]) AS [Percentage active worker]
FROM [dbo].[HR Analytics Data] AS HR
WHERE HR.Attrition = 0;

-- SUY GIẢM NHÂN SỰ (Attrition) THEO GENDER
SELECT 
	HR.Gender,
	HR.Attrition,
	COUNT(DISTINCT HR.EmployeeNumber) AS [Attrition by gender]
FROM [dbo].[HR Analytics Data] AS HR
GROUP BY HR.Gender, HR.Attrition

-- TÌM ĐỘ TUỔI TRUNG BÌNH CỦA NHÂN VIÊN NGHỈ VIỆC OR CẮT GIẢM (Attrition)
SELECT HR.Attrition,
       AVG(HR.Age) AS [AVG AGE]
FROM [dbo].[HR Analytics Data] AS HR
GROUP BY HR.Attrition;
-- ĐỘ TUỔI TRUNG BÌNH CỦA NHỮNG NGƯỜI NGHỈ VIỆC < ĐỘ TUỔI TRUNG BÌNH NHỮNG NGƯỜI Ở LẠI.
-- ĐIỀU NÀY CHO THẤY NHÂN VIÊN Ở LẠI TRONG CÔNG TY CÓ XU HƯỚNG GIÀ HÓA ĐIỀU NÀY CÓ THỂ TIỀM ẨN NHIỀU RỦI RO TRONG CÔNG VIỆC.

-- CẮT GIẢM NHÂN SỰ (Attrition) THEO BUSSINESS TRAVEL
SELECT 
	HR.BusinessTravel,
	HR.Attrition,
	COUNT(DISTINCT HR.EmployeeNumber) AS [Attrition by BusinessTravel]
FROM [dbo].[HR Analytics Data] AS HR
GROUP BY HR.BusinessTravel, HR.Attrition;

-- CẮT GIẢM NHÂN SỰ (Attrition only) THEO "DistanceFromHome"
-- TỪ COLUMN "DistanceFromHome" TIẾN HÀNH PHÂN LOẠI KHOẢNG CÁCH TỬ CÔNG TY ĐẾN NHÀ NHÂN VIÊN BỊ CẮT GIẢM:
-- DISTANCE > 20: VERY FAR
-- 10 < DISTANCE <= 20: FAR
-- 5 < DISTANCE <= 10: CLOSE
-- VERY CLOSE
WITH cteDistanceStatus AS
(
	SELECT 
		COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees],
		COUNT(CASE WHEN HR.DistanceFromHome > 20 THEN 1 END) AS [Very far],
		COUNT(CASE WHEN HR.DistanceFromHome > 10 AND HR.DistanceFromHome <= 20 THEN 1 END) AS [Far],
		COUNT(CASE WHEN HR.DistanceFromHome > 5 AND HR.DistanceFromHome <= 10 THEN 1 END) AS [Close],
		COUNT(CASE WHEN HR.DistanceFromHome <= 5 THEN 1 END) AS [Very close]
	FROM [dbo].[HR Analytics Data] AS HR
	WHERE HR.Attrition = 1
)
SELECT 
	TEMP.[Very far],
	ROUND(TEMP.[Very far] * 100.0 / TEMP.[Total Employees], 2) AS [Percentage very far],
	TEMP.[Far],
	ROUND(TEMP.Far * 100.0 / TEMP.[Total Employees], 2) AS [Percentage far],
	TEMP.[Close],
	ROUND(TEMP.[Close] * 100.0 / TEMP.[Total Employees], 2) AS [Percentage close],
	TEMP.[Very close],
	ROUND(TEMP.[Very close] * 100.0 / TEMP.[Total Employees], 2) AS [Percentage very close] 
FROM cteDistanceStatus AS TEMP;

-- TÌM KHOẢNG CÁCH TRUNG BÌNH TỪ NHÀ ĐẾN CÔNG TY CỦA NHÂN VIÊN (Attrition)
SELECT HR.Attrition,
       AVG(HR.DistanceFromHome) AS [AVG_DistanceFromHome]
FROM [dbo].[HR Analytics Data] AS HR
GROUP BY HR.Attrition;
-- KHOẢNG CÁCH TB TỪ NHÀ ĐẾN CÔNG TY CỦA NHỮNG NHÂN VIÊN NGHỈ VIỆC LỚN HƠN SO VỚI NHỮNG NHÂN VIÊN VẪN CÒN LÀM VIỆC 
-- NÊN CÓ THỂ KHOẢNG CÁCH CŨNG LÀ YẾU TỐ DẪN ĐẾN SUY GIẢM NHÂN SỰ 

-- CẮT GIẢM NHÂN SỰ (Attrition) THEO "JobLevel"
SELECT 
	HR.JobLevel,
	HR.Attrition,
	COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees]
FROM [dbo].[HR Analytics Data] AS HR
GROUP BY HR.JobLevel, HR.Attrition
ORDER BY HR.JobLevel;

-- CẮT GIẢM NHÂN SỰ (Attrition) THEO "Education"
-- ĐÂY LÀ CỘT PHÂN LOẠI BIỂU THỊ TRÌNH ĐỘ HỌC VẤN CỦA NHÂN VIÊN: (1 'Below college', 2 'College', 3 'Bachelor', 4 'Master', 5 'Doctor')
SELECT
	HR.Education,
	HR.Attrition,
	COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees]
FROM [dbo].[HR Analytics Data] AS HR
GROUP BY HR.Education, HR.Attrition
ORDER BY HR.Education;

-- CẮT GIẢM NHÂN SỰ (Attrition) THEO "Department"
SELECT 
	HR.Department,
	HR.Attrition,
	COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees]
FROM [dbo].[HR Analytics Data] AS HR
GROUP BY HR.Department, HR.Attrition;

-- CẮT GIẢM NHÂN SỰ (Attrition) THEO "JobSatisfaction"
SELECT 
	HR.JobSatisfaction,
	HR.Attrition,
	COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees]
FROM [dbo].[HR Analytics Data] AS HR
GROUP BY HR.JobSatisfaction, HR.Attrition
ORDER BY HR.JobSatisfaction;

-- CẮT GIẢM NHÂN SỰ (Attrition only) THEO "Overtime"
WITH cteOverTimeStatus AS
(
	SELECT 
		COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees],
		COUNT(CASE WHEN HR.OverTime = 1 THEN 1 END) AS [Over time],
		COUNT(CASE WHEN HR.OverTime = 0 THEN 1 END) AS [No over time]
	FROM [dbo].[HR Analytics Data] AS HR
	WHERE HR.Attrition = 1
)
SELECT 
	TEMP.[Over time],
	ROUND(TEMP.[Over time] * 100.0 / TEMP.[Total Employees], 2) AS [Percentage over time],
	TEMP.[No over time],
	ROUND(TEMP.[No over time] * 100.0 / TEMP.[Total Employees], 2) AS [Percentage no over time]
FROM cteOverTimeStatus AS TEMP;

-- CẮT GIẢM NHÂN SỰ (Attrition only) THEO "PerformanceRating"
-- ĐÂY LÀ CỘT PHÂN LOẠI BIỂU THỊ XẾP HẠNG PERFORMANCE CỦA NHÂN VIÊN (1 'Low', 2 'Middle', 3 'Good', 4 'Excellent')
WITH ctePerformanceRatingStatus AS
(
	SELECT 
		COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees],
		COUNT(CASE WHEN HR.PerformanceRating = 3 THEN 1 END) AS [Good],
		COUNT(CASE WHEN HR.PerformanceRating = 4 THEN 1 END) AS [Excellent]
	FROM [dbo].[HR Analytics Data] AS HR
	WHERE HR.Attrition = 1
)
SELECT 
	TEMP.Good,
	ROUND(TEMP.[Good] * 100.0 / TEMP.[Total Employees], 2) AS [Percentage good],
	TEMP.[Excellent],
	ROUND(TEMP.[Excellent] * 100.0 / TEMP.[Total Employees], 2) AS [Percentage excellent]
FROM ctePerformanceRatingStatus AS TEMP;

-- CẮT GIẢM NHÂN SỰ (Attrition) THEO "JobRole"
SELECT 
	HR.JobRole,
	HR.Attrition,
	COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees]
FROM [dbo].[HR Analytics Data] AS HR
GROUP BY HR.JobRole, HR.Attrition
ORDER BY HR.JobRole;

-- CẮT GIẢM NHÂN SỰ (Attrition) THEO "WorkLifeBalance"
-- ĐÂY LÀ CỘT PHÂN LOẠI BIỂU THỊ SỰ CÂN BẰNG GIỮA CÔNG VIỆC VÀ CUỘC SỐNG (1 'BAD', 2 'GOOD', 3 'BETTER', 4 'BEST')
SELECT 
	HR.WorkLifeBalance,
	HR.Attrition,
	COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees]
FROM [dbo].[HR Analytics Data] AS HR
GROUP BY HR.WorkLifeBalance, HR.Attrition
ORDER BY HR.WorkLifeBalance;

-- CẮT GIẢM NHÂN SỰ (Attrition only) THEO "NumCompaniesWorked"
SELECT 
	HR.NumCompaniesWorked,
	COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees]
FROM [dbo].[HR Analytics Data] AS HR
WHERE HR.Attrition = 1
GROUP BY HR.NumCompaniesWorked
ORDER BY HR.NumCompaniesWorked;

-- CẮT GIẢM NHÂN SỰ (Attrition only) THEO "JobInvolvement"
-- ĐÂY LÀ CỘT THỂ HIỆN SỰ HĂNG HÁI TRONG CÔNG VIỆC: (1 'Low',2 'Medium',3 'High',4 'Very High')
SELECT 
	HR.JobInvolvement,
	COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees]
FROM [dbo].[HR Analytics Data] AS HR
WHERE HR.Attrition = 1
GROUP BY HR.JobInvolvement
ORDER BY HR.JobInvolvement;

-- CẮT GIẢM NHÂN SỰ (Attrition only) THEO "MaritalStatus"
-- ĐÂY LÀ CỘT THỂ HIỆN TRẠNG THÁI BẢN THÂN: Single, Married, Divorced
SELECT 
	HR.MaritalStatus,
	COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees]
FROM [dbo].[HR Analytics Data] AS HR
WHERE HR.Attrition = 1
GROUP BY HR.MaritalStatus;

-- CẮT GIẢM NHÂN SỰ (Attrition) THEO "EnvironmentSatisfaction"
-- ĐÂY LÀ CỘT THỂ HIỆN ĐỘ HÀI LÒNG VỚI MÔI TRƯỜNG LÀM VIỆC: (1 'Low',2 'Medium',3 'High',4 'Very High')
SELECT 
	HR.EnvironmentSatisfaction,
	HR.Attrition,
	COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees]
FROM [dbo].[HR Analytics Data] AS HR
GROUP BY HR.EnvironmentSatisfaction, HR.Attrition
ORDER BY HR.EnvironmentSatisfaction;

-- CẮT GIẢM NHÂN SỰ (Attrition) THEO "RelationshipSatisfaction"
-- ĐÂY LÀ CỘT THỂ HIỆN SỰ THÂN THIẾT GIỮA CÁC ĐỒNG NGHIỆP: (1 'Low',2 'Medium',3 'High',4 'Very High')
SELECT 
	HR.RelationshipSatisfaction,
	HR.Attrition,
	COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees]
FROM [dbo].[HR Analytics Data] AS HR
GROUP BY HR.RelationshipSatisfaction, HR.Attrition
ORDER BY HR.RelationshipSatisfaction;

-- CẮT GIẢM NHÂN SỰ (Attrition only) THEO "MaritalStatus"
-- ĐÂY LÀ CỘT THỂ HIỆN TRẠNG THÁI BẢN THÂN: Single, Married, Divorced
SELECT 
	HR.MaritalStatus,
	COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees]
FROM [dbo].[HR Analytics Data] AS HR
WHERE HR.Attrition = 1
GROUP BY HR.MaritalStatus;

-- CẮT GIẢM NHÂN SỰ (Attrition only) THEO "YearsAtCompany"
SELECT 
	HR.YearsAtCompany,
	COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees]
FROM [dbo].[HR Analytics Data] AS HR
WHERE HR.Attrition = 1
GROUP BY HR.YearsAtCompany;

-- CẮT GIẢM NHÂN SỰ (Attrition only) THEO "YearsSinceLastPromotion"
SELECT 
	HR.YearsSinceLastPromotion,
	COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees]
FROM [dbo].[HR Analytics Data] AS HR
WHERE HR.Attrition = 1
GROUP BY HR.YearsSinceLastPromotion;

-- GIẢ SỬ NHỮNG AI CHƯA ĐƯỢC THĂNG CHỨC TRONG 10 NĂM TRỞ LẠI THÌ SẼ XÉT DUYỆT ĐƯỢC THĂNG CHỨC.
-- YEARSSINCELASTPROMOTION >= 10 THÌ DUE FOR PROMOTION
-- NGƯỢC LẠI THÌ NOT DUE FOR PROMOTION.
-- PHẦN TRĂM "DUE FOR PROMOTION" TRÊN TỔNG SỐ NHÂN VIÊN
-- PHẦN TRĂM "NOT DUE FOR PROMOTION" TRÊN TỐNG SỐ NHÂN VIÊN.
WITH ctePromotionStatus AS
(
	SELECT 
		COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees],
		COUNT(CASE WHEN HR.YearsSinceLastPromotion >= 10 THEN 1 END) AS [Due for promotion],
		COUNT(CASE WHEN HR.YearsSinceLastPromotion < 10 THEN 1 END) AS [Not due for promotion]
	FROM [dbo].[HR Analytics Data] AS HR
)
SELECT 
	TEMP.[Due for promotion],
	ROUND(TEMP.[Due for promotion] * 100.0 / TEMP.[Total Employees], 2) AS [Percentage due for promotion],
	TEMP.[Not due for promotion],
	ROUND(TEMP.[Not due for promotion] * 100.0 / TEMP.[Total Employees], 2) AS [Percentage not due for promotion]
FROM ctePromotionStatus AS TEMP;

-- DANH SÁCH TÊN NHÂN VIÊN ĐƯỢC THĂNG CHỨC
SELECT E.Emplyee_name,
       COUNT(CASE WHEN HR.YearsSinceLastPromotion >= 10 THEN 1 END) AS [Due for promotion]
FROM [dbo].[HR Analytics Data] AS HR
JOIN [dbo].[HR employee data] AS E ON E.EmployeeNumber = HR.EmployeeNumber
WHERE HR.YearsSinceLastPromotion >= 10
GROUP BY E.Emplyee_name;

-- DANH SÁCH TÊN NHÂN VIÊN ĐƯỢC CẮT GIẢM (Attrition only)
SELECT 
	E.Emplyee_name,
	COUNT(CASE WHEN HR.Attrition = 1 THEN 1 END) AS [Will be retrenched]
FROM [dbo].[HR Analytics Data] AS HR
JOIN [dbo].[HR employee data] AS E ON E.EmployeeNumber = HR.EmployeeNumber
WHERE HR.Attrition = 1
GROUP BY E.Emplyee_name;

-- NHỮNG NHÂN VIÊN NẰM TRONG DANH SÁCH THĂNG CHỨC NHƯNG CŨNG CÓ TRONG DANH SÁCH CẮT GIẢM (Attrition only).
-- CẦN LẤY RA DANH SÁCH NHỮNG NHÂN VIÊN NÀY.
-- HỌ SẼ ĐƯỢC NHẬN THÊM NHỮNG TRỢ CẤP CẦN THIẾT
WITH CTE_PROMOTION AS
(
	SELECT
	    E.Emplyee_name,
		COUNT(CASE WHEN HR.YearsSinceLastPromotion >= 10 THEN 1 END) AS [Due for promotion]
	FROM [dbo].[HR Analytics Data] AS HR
	JOIN [dbo].[HR employee data] AS E ON E.EmployeeNumber = HR.EmployeeNumber
	WHERE HR.YearsSinceLastPromotion >= 10
	GROUP BY E.Emplyee_name
),
CTE_RETRENCHMENT AS
(
	SELECT 
		E.Emplyee_name,
		COUNT(CASE WHEN HR.Attrition = 1 THEN 1 END) AS [Will be retrenched]
	FROM [dbo].[HR Analytics Data] AS HR
	JOIN [dbo].[HR employee data] AS E ON E.EmployeeNumber = HR.EmployeeNumber
	WHERE HR.Attrition = 1
	GROUP BY E.Emplyee_name
)
SELECT R.Emplyee_name
FROM CTE_PROMOTION AS P
JOIN CTE_RETRENCHMENT AS R ON R.Emplyee_name = P.Emplyee_name
/*
DANH SÁCH NHỮNG NHÂN NẰM TRONG DANH SÁCH THĂNG CHỨC NHƯNG CŨNG SẼ BỊ CẮT GIẢM:
Candelaria Zajicek
Carlotta T Ryles
Carmelia E Bergeron
Carolin T Loya
Clemente S Wiechmann
Inocencia Z Buteau
Janie P Caswell
Kaye Tubbs
Stephan Q Ranger
*/

-- TOP 10 NHÂN VIÊN CÓ THU NHẬP CAO NHẤT
SELECT TOP 10 E.Emplyee_name,
       HR.MonthlyIncome
FROM [dbo].[HR Analytics Data] AS HR
JOIN [dbo].[HR employee data] AS E ON E.EmployeeNumber = HR.EmployeeNumber
ORDER BY HR.MonthlyIncome DESC;

-- Monthly income (Attrition only) DỰA THEO PHẦN TRĂM TĂNG LƯƠNG PercentSalaryHike
SELECT HR.PercentSalaryHike,
       HR.MonthlyIncome AS [Monthly Income]
FROM [dbo].[HR Analytics Data] AS HR
WHERE HR.Attrition = 1 
ORDER BY HR.PercentSalaryHike;

-- Monthly income (Attrition only) DỰA THEO YearsAtCompany
SELECT HR.YearsAtCompany,
       HR.MonthlyIncome AS [Monthly Income]
FROM [dbo].[HR Analytics Data] AS HR
WHERE HR.Attrition = 1 
ORDER BY HR.YearsAtCompany;

-- Monthly income (Attrition only) DỰA THEO YearsInCurrentRole
SELECT HR.YearsInCurrentRole,
       HR.MonthlyIncome AS [Monthly Income]
FROM [dbo].[HR Analytics Data] AS HR
WHERE HR.Attrition = 1 
ORDER BY HR.YearsInCurrentRole;

-- Monthly income (Attrition only) DỰA THEO job level
SELECT HR.JobLevel,
       HR.MonthlyIncome AS [Monthly Income]
FROM [dbo].[HR Analytics Data] AS HR
WHERE HR.Attrition = 1 
ORDER BY HR.JobLevel;
