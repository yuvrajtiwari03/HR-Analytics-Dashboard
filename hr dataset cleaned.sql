DROP TABLE IF EXISTS HRDataset;
CREATE TABLE HRDataset(
    Employee_Name VARCHAR(100),
    Emp_ID INT PRIMARY KEY,
    Married_ID INT,
    Marital_Status_ID INT,
    Gender_ID INT,
    EmpStatus_ID INT,
    Dept_ID INT,
    Perf_Score_ID INT,
    From_Diversity_JobFair_ID INT,
    Salary NUMERIC(10,2),
    Termd INT,
    Position_ID INT,
    Position VARCHAR(100),
    State VARCHAR(50),
    Zip VARCHAR(20),
    DOB DATE,
    Sex VARCHAR(20),
    Marital_Desc VARCHAR(50),
    Citizen_Desc VARCHAR(50),
    Hispanic_Latino VARCHAR(50),
    Race_Desc VARCHAR(50),
    Date_of_Hire DATE,
    Date_of_Termination DATE,
    Term_Reason VARCHAR(255),
    Employment_Status VARCHAR(50),
    Department VARCHAR(100),
    Manager_Name VARCHAR(100),
    Manager_ID INT,
    Recruitment_Source VARCHAR(100),
    Performance_Score VARCHAR(50),
    Engagement_Survey NUMERIC(4,2),
    Emp_Satisfaction INT,
    Special_Projects_Count INT,
    Last_Performance_Review_Date DATE,
    Days_Late_Last_30 INT,
    Absences INT
);

SELECT * FROM HRDataset;

-- DOA to AGE calculate
ALTER TABLE HRDataset
ADD COLUMN age INT;

UPDATE HRDataset
SET age=DATE_PART ('Year',age(DOB));

--tenure_year calculate (hire to termination)

ALTER TABLE HRDataset
ADD COLUMN Tenure_Years DECIMAL(5,2);


UPDATE HRDataset
SET Tenure_Years = CASE
					WHEN Date_of_Termination IS NULL
					THEN DATE_PART('day',AGE (CURRENT_DATE, Date_of_Hire)) / 365
					ELSE DATE_PART('day',AGE (Date_of_Termination, Date_of_Hire)) / 365
				END	;


SELECT * FROM HRDataset;


UPDATE HRDataset
SET Manager_ID = -1,
    Manager_Name = 'Unknown'
WHERE Manager_ID IS NULL;

-- Active vs Terminated Employees
SELECT  CASE
	WHEN Termd = 1 
	THEN 'Terminated' 
	ELSE 'Active' 
	END AS Status,
    COUNT(*) AS Employee_Count
FROM HRDataset
GROUP BY Status;

-- overall percentage of active or terminated

SELECT 
    COUNT(*) AS Total_Employees,
    SUM(CASE WHEN Termd = 1 
	THEN 1 
	ELSE 0
	END) AS Terminated_Employees,
    ROUND(100.0 * SUM(CASE WHEN Termd = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS Turnover_Rate_Percent
FROM HRDataset;

ALTER TABLE HRDataset
ADD COLUMN Turnover_Status VARCHAR(20);

UPDATE HRDataset
SET Turnover_Status = 
    CASE 
        WHEN termd = 1 THEN 'Terminated'
        ELSE 'Active'
    END;
	
CREATE OR REPLACE VIEW HR_Turnover AS
SELECT 
    COUNT(*) AS Total_Employees,
    SUM(CASE WHEN termd = 1 THEN 1 ELSE 0 END) AS Terminated_Employees,
    ROUND(100.0 * SUM(CASE WHEN termd = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS Turnover_Rate_Percent
FROM HRDataset;

-- percentage calculate of active/ termiated
SELECT 
    Turnover_Status,
    COUNT(*) AS Employee_Count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM HRDataset), 2) AS Percentage
FROM HRDataset
GROUP BY Turnover_Status;


SELECT Emp_ID, Employee_Name, Termd, Turnover_Status
FROM HRDataset
LIMIT 10;

-- age distribution

SELECT 
    CASE 
        WHEN Age < 25 THEN '<25'
        WHEN Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN Age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS Age_Group,
    COUNT(*) AS Employee_Count
FROM HRDataset
GROUP BY Age_Group
ORDER BY Age_Group;

ALTER TABLE HRDataset
ADD COLUMN Age_Group VARCHAR(20);

UPDATE HRDataset
SET Age_Group = CASE
    WHEN Age < 25 THEN '<25'
    WHEN Age BETWEEN 25 AND 34 THEN '25-34'
    WHEN Age BETWEEN 35 AND 44 THEN '35-44'
    WHEN Age BETWEEN 45 AND 54 THEN '45-54'
    ELSE '55+'
END;

ALTER TABLE HRDataset
ADD COLUMN Age_Group_Order INT;

UPDATE HRDataset
SET Age_Group_Order = CASE
    WHEN Age < 25 THEN 1
    WHEN Age BETWEEN 25 AND 34 THEN 2
    WHEN Age BETWEEN 35 AND 44 THEN 3
    WHEN Age BETWEEN 45 AND 54 THEN 4
    ELSE 5
END;

-- Gender Distribution
ALTER TABLE HRDataset
ADD COLUMN Gender_Text VARCHAR(10);

UPDATE HRDataset
SET Gender_Text = CASE
    WHEN gender_id = 0 THEN 'Male'
    WHEN gender_id = 1 THEN 'Female'
    ELSE 'Other'
END;


SELECT Sex, COUNT(*) AS Employee_Count
FROM HRDataset
GROUP BY Sex;

SELECT * FROM HRDataset;

--Department wise Distribution

SELECT Department, COUNT(*) AS Employee_Count
FROM HRDataset
GROUP BY Department
ORDER BY Employee_Count DESC;

--Year-wise Hiring

SELECT 
    EXTRACT(YEAR FROM Date_of_Hire) AS Hire_Year,
    COUNT(*) AS Hires
FROM HRDataset
GROUP BY Hire_Year
ORDER BY Hire_Year;

--Source of Hire

SELECT Recruitment_Source, COUNT(*) AS Hires
FROM HRDataset
GROUP BY Recruitment_Source
ORDER BY Hires DESC;

-- Performance Scores Distribution

SELECT Performance_Score, COUNT(*) AS Employee_Count
FROM HRDataset
GROUP BY Performance_Score
ORDER BY Employee_Count DESC;

--Top Performers (Exceeds Expectations)
ALTER TABLE HRDataset
ADD COLUMN performance_score_num INT;

UPDATE HRDataset
SET performance_score_num = 
    CASE 
        WHEN performance_score = 'Exceeds' THEN 4
        WHEN performance_score = 'Fully Meets' THEN 3
        WHEN performance_score = 'Needs Improvement' THEN 2
        WHEN performance_score = 'PIP' THEN 1
        ELSE NULL
    END;

--------
SELECT Emp_ID, Employee_Name, Department, Position, Salary, Performance_Score
FROM HRDataset
WHERE Performance_Score = 'Exceeds'
ORDER BY Salary DESC
LIMIT 10;

--Performance by Department

SELECT Department, Performance_Score, COUNT(*) AS Employee_Count
FROM HRDataset
GROUP BY Department, Performance_Score
ORDER BY Department;

--Average Satisfaction Score

SELECT ROUND(AVG(Emp_Satisfaction),2) AS Avg_Satisfaction
FROM HRDataset;

--Engagement Survey (overall distribution)

SELECT Engagement_Survey, COUNT(*) AS Employee_Count
FROM HRDataset
GROUP BY Engagement_Survey
ORDER BY Engagement_Survey;

--Engagement vs Satisfaction (for Power BI scatter plot)

SELECT Engagement_Survey, Emp_Satisfaction
FROM HRDataset;

--Total Employees
SELECT COUNT(*) AS Total_Employees
FROM HRDataset;

--Turnover Rate %

SELECT 
    ROUND(100.0 * SUM(CASE WHEN Termd = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS Turnover_Rate_Percent
FROM HRDataset;

--Average Performance Score

SELECT ROUND(AVG(CASE 
    WHEN Performance_Score = 'Exceeds' THEN 4
    WHEN Performance_Score = 'Fully Meets' THEN 3
    WHEN Performance_Score = 'Needs Improvement' THEN 2
    WHEN Performance_Score = 'PIP' THEN 1
END),2) AS Avg_Performance_Score
FROM HRDataset;

--Average Satisfaction Score
SELECT ROUND(AVG(Emp_Satisfaction),2) AS Avg_Satisfaction
FROM HRDataset;


ALTER TABLE HRDataset_v14
ADD COLUMN Turnover_Status VARCHAR(20);

UPDATE HRDataset_v14
SET Turnover_Status = 
    CASE 
        WHEN termd = 1 THEN 'Terminated'
        ELSE 'Active'
    END;

SELECT * FROM HRDataset;

ALTER TABLE HRDataset
ADD COLUMN Hire_Year INT;

UPDATE HRDataset
SET Hire_Year = EXTRACT(YEAR FROM date_of_hire);

DROP VIEW IF EXISTS HR_HiringTrend;

CREATE OR REPLACE VIEW HR_HiringTrend AS
SELECT 
    Hire_Year,
    Yearly_Hires,
    SUM(Yearly_Hires) OVER (ORDER BY Hire_Year) AS Cumulative_Hires
FROM (
    SELECT 
        Hire_Year,
        COUNT(emp_id) AS Yearly_Hires
    FROM HRDataset
    GROUP BY Hire_Year
) sub
ORDER BY Hire_Year;
--

SELECT * FROM HR_HiringTrend;


DROP TABLE IF EXISTS hr_hiringtrend_tbl;

CREATE TABLE hr_hiringtrend_tbl AS
SELECT 
    Hire_Year,
    Yearly_Hires,
    SUM(Yearly_Hires) OVER (ORDER BY Hire_Year) AS Cumulative_Hires
FROM (
    SELECT 
        EXTRACT(YEAR FROM date_of_hire)::INT AS Hire_Year,
        COUNT(emp_id) AS Yearly_Hires
    FROM HRDataset
    GROUP BY EXTRACT(YEAR FROM date_of_hire)
) sub
ORDER BY Hire_Year;


DROP TABLE IF EXISTS hr_hiringtrend_tbl;

CREATE TABLE hr_hiringtrend_tbl AS
SELECT 
    EXTRACT(YEAR FROM date_of_hire)::INT AS hire_year,
    COUNT(emp_id) AS yearly_hires,
    SUM(COUNT(emp_id)) OVER (ORDER BY EXTRACT(YEAR FROM date_of_hire)) AS cumulative_hires
FROM HRDataset
GROUP BY EXTRACT(YEAR FROM date_of_hire)
ORDER BY hire_year;

