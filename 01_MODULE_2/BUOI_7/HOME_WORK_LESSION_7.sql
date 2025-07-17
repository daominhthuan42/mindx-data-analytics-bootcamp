-- DROP DATABASE IF EXISTS Ecommerce
-- CREATE DATABASE Ecommerce

USE Ecommerce
GO

-- NUMBER ROW NULL VALUE BY CustomerID
SELECT 
    COUNT(*) AS ZF_RECORDS,
    SUM(CASE WHEN E.CustomerID IS NULL THEN 1 ELSE 0 END) AS ZF_SUM_NULL_CUSTOMER_ID
FROM Ecommerce AS E;

-- DROP ROW NULL
DELETE FROM Ecommerce
WHERE CustomerID IS NULL;

-- KIỂM TRA XEM CustomerID CÓ THỂ CHANGE TYPE ĐƯỢC KHÔNG?
SELECT *
FROM Ecommerce
WHERE TRY_CAST(CustomerID AS NVARCHAR(10)) IS NOT NULL;

ALTER TABLE Ecommerce
ALTER COLUMN CustomerID NVARCHAR(10);

-- TẠO NEW TABLE Ecommerce_NEW VỚI ĐIỀU KIỆN Quantity > 0
DROP TABLE IF EXISTS Ecommerce_NEW
CREATE TABLE Ecommerce_NEW (
     -- Giả sử cột giống bảng Ecommerce, ví dụ:
    InvoiceNo NVARCHAR(50),
    StockCode NVARCHAR(50),
    Description NVARCHAR(50),
    Quantity INT,
    InvoiceDate DATETIME2(7),
    UnitPrice FLOAT(50),
    CustomerID NVARCHAR(10),
    Country NVARCHAR(50)  
);
GO

INSERT INTO Ecommerce_NEW
SELECT *
FROM Ecommerce
WHERE Quantity > 0;
GO

-- TẠO COLUMN TotalPrice = Quantity * UnitPrice
ALTER TABLE Ecommerce_NEW
ADD TotalPrice FLOAT;

UPDATE Ecommerce_NEW
SET TotalPrice = Quantity * UnitPrice;

SELECT * FROM Ecommerce_NEW

-- TÍNH RFM VÀ LƯU TRONG RFM_Table
DROP TABLE IF EXISTS RFM_Table;
SELECT
    EN.CustomerID,
    -- MAX(EN.InvoiceDate) AS ZF_LAST_PURCHASE_DATE,
    DATEDIFF(DAY, MAX(EN.InvoiceDate), GETDATE()) AS R_VALUE,
    COUNT(DISTINCT EN.InvoiceNo) AS F_VALUE,
    SUM(EN.TotalPrice) AS M_VALUE
INTO RFM_Table
FROM Ecommerce_NEW AS EN
GROUP BY  EN.CustomerID;

-- TẠO MỚI COLUMN R_Scoring
ALTER TABLE RFM_Table
ADD R_Score INT;

WITH R_Scoring AS (
    SELECT CustomerID,
           6 - NTILE(5) OVER (ORDER BY R_VALUE ASC) AS R_Score
    FROM RFM_Table
)
UPDATE RFM_Table
SET R_Score = R_Scoring.R_Score
FROM RFM_Table
JOIN R_Scoring ON RFM_Table.CustomerID = R_Scoring.CustomerID;

-- TẠO MỚI COLUMN F_Scoring
ALTER TABLE RFM_Table
ADD F_Score INT;

WITH F_Scoring AS (
    SELECT CustomerID,
           NTILE(5) OVER (ORDER BY F_VALUE ASC) AS F_Score
    FROM RFM_Table
)
UPDATE RFM_Table
SET F_Score = F_Scoring.F_Score
FROM RFM_Table
JOIN F_Scoring ON RFM_Table.CustomerID = F_Scoring.CustomerID;

-- TẠO MỚI COLUMN M_Scoring
ALTER TABLE RFM_Table
ADD M_Score INT;

WITH M_Scoring AS (
    SELECT CustomerID,
           NTILE(5) OVER (ORDER BY M_VALUE ASC) AS M_Score
    FROM RFM_Table
)
UPDATE RFM_Table
SET M_Score = M_Scoring.M_Score
FROM RFM_Table
JOIN M_Scoring ON RFM_Table.CustomerID = M_Scoring.CustomerID;

-- TẠO COLUMN RFM_Score
ALTER TABLE RFM_Table
ADD RFM_Segment VARCHAR(5);

UPDATE RFM_Table
SET RFM_Segment = CONCAT(R_Score, F_Score, M_Score);

-- REPLACE ", " THÀNH "," TRONG TABLE RankRFM
UPDATE [dbo].[RankRFM]
SET [Scores] = REPLACE([Scores], ', ', ',')
WHERE [Scores] LIKE '%, %';

DROP TABLE IF EXISTS RankRFM_Exploded
SELECT
    Segment,
    TRIM(VALUE) AS RFM_Segment -- TRIM(VALUE) SẼ LẤY VALUE TỪ CROSS APPLY STRING_SPLIT(Scores, ',') ĐỂ TRIM -> HAY
INTO RankRFM_Exploded
FROM [dbo].[RankRFM]
CROSS APPLY STRING_SPLIT(Scores, ','); -- Tách chuỗi Scores thành nhiều dòng

SELECT
    RFM.CustomerID,
    RFM.RFM_Segment,
    RE.Segment
FROM [dbo].[RFM_Table] AS RFM
JOIN [dbo].[RankRFM_Exploded] AS RE ON RFM.RFM_Segment = RE.RFM_Segment;

SELECT
    RE.Segment,
    COUNT(*) AS ZF_COUNT_SEGMENT
FROM [dbo].[RFM_Table] AS RFM
JOIN [dbo].[RankRFM_Exploded] AS RE ON RFM.RFM_Segment = RE.RFM_Segment
GROUP BY RE.Segment