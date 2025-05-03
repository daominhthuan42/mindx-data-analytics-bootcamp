-- CREATE DATABASE HR_CLUSTERED
DROP DATABASE IF EXISTS HR_CLUSTERED
CREATE DATABASE HR_CLUSTERED
ON
(
	NAME = 'HR_CLUSTERED_DATA',
	FILENAME = 'C:\00_DATA\04_POWER_BI\00_HR_REPORT\HR_CLUSTERED_DATA.mdf',
	SIZE = 10MB,
	MAXSIZE = 100MB,
	FILEGROWTH = 5MB)
LOG ON
(
	NAME = 'HR_CLUSTERED_LOG',
	FILENAME = 'C:\00_DATA\04_POWER_BI\00_HR_REPORT\HR_CLUSTERED_LOG.ldf',
	SIZE = 5MB,
	MAXSIZE = 50MB,
	FILEGROWTH = 5MB
)

USE HR_CLUSTERED
GO

-- Tổng số nhân viên
SELECT COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees]
FROM [dbo].[HR Analytics Data] AS HR;

-- Tổng số nhân viên nam và phần trăm nhân viên nam trong công ty
SELECT COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees Male],
       COUNT(CASE WHEN HR.Gender = 'Male' THEN 1 END) * 100 / (SELECT COUNT(DISTINCT EmployeeNumber) FROM [dbo].[HR Analytics Data]) AS [Percentage of women]
FROM [dbo].[HR Analytics Data] AS HR
WHERE HR.Gender = 'Male';

-- Tổng số nhân viên nữ và phần trăm nhân viên nữ trong công ty
SELECT COUNT(DISTINCT HR.EmployeeNumber) AS [Total Employees Male],
       COUNT(CASE WHEN HR.Gender = 'Female' THEN 1 END) * 100 / (SELECT COUNT(DISTINCT EmployeeNumber) FROM [dbo].[HR Analytics Data]) AS [Percentage of women]
FROM [dbo].[HR Analytics Data] AS HR
WHERE HR.Gender = 'Female';

-- Giả sử những ai chưa được thăng chức trong 10 năm trở lại thì sẽ xét duyệt được thăng chức.
-- YearsSinceLastPromotion >= 10 thì Due for promotion
-- Ngược lại thì Not due for promotion.
-- Phần trăm "Due for promotion" trên tổng số nhân viên
-- Phần trăm "Not due for promotion" trên tống số nhân viên.
SELECT COUNT(CASE WHEN HR.YearsSinceLastPromotion >= 10 THEN 1 END) AS [Due for promotion],
       ROUND(COUNT(CASE WHEN HR.YearsSinceLastPromotion >= 10 THEN 1 END) * 100 * 1.0 / (SELECT COUNT(DISTINCT EmployeeNumber) FROM [dbo].[HR Analytics Data]), 1) AS [Percentage due for promotion],
	   COUNT(CASE WHEN HR.YearsSinceLastPromotion < 10 THEN 1 END) AS [Not due for promotion],
	   ROUND(COUNT(CASE WHEN HR.YearsSinceLastPromotion < 10 THEN 1 END) * 100 * 1.0 / (SELECT COUNT(DISTINCT EmployeeNumber) FROM [dbo].[HR Analytics Data]), 1) AS [Percentage not due for promotion]
FROM [dbo].[HR Analytics Data] AS HR

-- Số năm phục vụ của nhân viên
SELECT HR.YearsAtCompany,
       COUNT(HR.EmployeeNumber) AS [Total Employees]
FROM [dbo].[HR Analytics Data] AS HR
GROUP BY HR.YearsAtCompany
ORDER BY HR.YearsAtCompany;

-- Số nhân viên ứng với Job Level
SELECT HR.JobLevel,
       COUNT(HR.EmployeeNumber) AS [Total Employees]
FROM [dbo].[HR Analytics Data] AS HR
GROUP BY HR.JobLevel
ORDER BY HR.JobLevel;

-- Giả sử bộ phận HR muốn cắt giảm nhân sự với những ai đã làm việc hơn 18 năm thì sẽ bị cắt giảm.
-- Ngược lại thì sẽ vẫn làm việc tại công ty.
-- Tính ra số lượng nhân viên bị cắt giảm (số năm làm việc > 18) và % trên tổng số lượng nhân viên.
SELECT COUNT(CASE WHEN HR.YearsAtCompany >= 18 THEN 1 END) AS [Will be retrenched],
       ROUND(COUNT(CASE WHEN HR.YearsAtCompany >= 18 THEN 1 END) * 100 * 1.0 / (SELECT COUNT(DISTINCT EmployeeNumber) FROM [dbo].[HR Analytics Data]), 1) AS [Percentage will be retrenched]
FROM [dbo].[HR Analytics Data] AS HR;
-- Tính ra số lượng nhân viên còn lại và % trên tổng số lượng nhân viên.
SELECT COUNT(CASE WHEN HR.YearsAtCompany < 18 THEN 1 END) AS [Active worker],
       ROUND(COUNT(CASE WHEN HR.YearsAtCompany < 18 THEN 1 END) * 100 * 1.0 / (SELECT COUNT(DISTINCT EmployeeNumber) FROM [dbo].[HR Analytics Data]), 1) AS [Percentage active worker]
FROM [dbo].[HR Analytics Data] AS HR;

