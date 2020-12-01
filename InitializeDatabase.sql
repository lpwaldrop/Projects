--Create database to store HR Data.
CREATE DATABASE IBM_HR;
GO

--Use database going forward.
USE IBM_HR;
GO

--Create table to load initial data for normalization. Named columns with initial data types.
CREATE TABLE LoadingTable (
	Age tinyint,
	Attrition char(3),
	BusinessTravel char(50),
	DailyRate smallint,
	Department char(50),
	DistanceFromHome tinyint,
	Education tinyint,
	EducationField char(50),
	EmployeeCount tinyint,
	EmployeeNumber smallint,
	EnvironmentalSatisfaction tinyint,
	Gender char(10),
	HourlyRate tinyint,
	JobInvolvement tinyint,
	JobLevel tinyint,
	JobRole char(50),
	JobSatisfaction tinyint,
	MaritalStatus char(50),
	MonthlyIncome smallint,
	MonthlyRate smallint,
	NumCompaniesWorked tinyint,
	Over18 char(1),
	OverTime char(3),
	PercentSalaryHike tinyint,
	PerformanceRating tinyint,
	RelationshipSatisfaction tinyint,
	StandardHours tinyint,
	StockOptionLevel tinyint,
	TotalWorkingYears tinyint,
	TrainingTimesLastYear tinyint,
	WorkLifeBalance tinyint,
	YearsAtCompany tinyint,
	YearsInCurrentRole tinyint,
	YearsSinceLastPromotion tinyint,
	YearsWithCurrManager tinyint,
);
GO

--Load csv file into table from local file. Skip first row headers and identify fields by comma.
BULK INSERT IBM_HR.dbo.LoadingTable
	FROM 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLDEVELOPER2019\MSSQL\IBM_HR_Data.csv'
	WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ','
		);
GO

--Table to store primary key.
CREATE TABLE EmployeeKey (
	EmployeeNumber smallint PRIMARY KEY,
	Attrition char(1)
);
GO

--Create Employee information table table.
CREATE TABLE Employee (
	EmployeeNumber smallint FOREIGN KEY REFERENCES EmployeeKey(EmployeeNumber),
	Age tinyint,
	Gender char(1),
	MaritalStatus char(10),
	DistanceFromHome tinyint,
	YearsAtCompany tinyint,
	TotalWorkingYears tinyint,
	MonthlyIncome smallint,
	StockOptionLevel tinyint,
	BusinessTravel char(20),
	OverTime char(1),
	PerformanceRating tinyint
);
GO

--Create three tables based on Department field
CREATE TABLE SalesDepartment (
	EmployeeNumber smallint FOREIGN KEY REFERENCES EmployeeKey(EmployeeNumber),
	JobRole char(50),
	JobLevel tinyint,
	YearsInCurrentRole tinyint,
	EducationField char(50),
	Education tinyint,
	HourlyRate tinyint,
	DailyRate smallint,
	MonthlyRate smallint
);
GO

CREATE TABLE HumanResourcesDepartment (
	EmployeeNumber smallint FOREIGN KEY REFERENCES EmployeeKey(EmployeeNumber),
	JobRole char(50),
	JobLevel tinyint,
	YearsInCurrentRole tinyint,
	EducationField char(50),
	Education tinyint,
	HourlyRate tinyint,
	DailyRate smallint,
	MonthlyRate smallint
);
GO

CREATE TABLE ResearchDepartment (
	EmployeeNumber smallint FOREIGN KEY REFERENCES EmployeeKey(EmployeeNumber),
	JobRole char(50),
	JobLevel tinyint,
	YearsInCurrentRole tinyint,
	EducationField char(50),
	Education tinyint,
	HourlyRate tinyint,
	DailyRate smallint,
	MonthlyRate smallint
);
GO

CREATE TABLE SurveyResults (
	EmployeeNumber smallint FOREIGN KEY REFERENCES EmployeeKey(EmployeeNumber),
	JobSatisfaction tinyint,
	RelationshipSatisfaction tinyint,
	EnvironmentalSatisfaction tinyint,
	JobInvolvement tinyint,
	WorkLifeBalance tinyint,
	YearsWithCurrManager tinyint,
	YearsSinceLastPromotion tinyint
);
GO

INSERT INTO EmployeeKey(
	EmployeeNumber,
	Attrition
)
	SELECT EmployeeNumber, SUBSTRING(Attrition, 1, 1) AS Attrition
	FROM LoadingTable;
GO

INSERT INTO Employee (
	EmployeeNumber,
	Age,
	Gender,
	MaritalStatus,
	DistanceFromHome,
	YearsAtCompany,
	TotalWorkingYears,
	MonthlyIncome,
	StockOptionLevel,
	BusinessTravel,
	OverTime,
	PerformanceRating
)
	SELECT EmployeeNumber, Age, SUBSTRING(Gender, 1, 1) AS Gender, MaritalStatus, DistanceFromHome, YearsAtCompany, TotalWorkingYears, MonthlyIncome, StockOptionLevel, BusinessTravel, 
		   SUBSTRING(OverTime, 1, 1), PerformanceRating
	FROM LoadingTable;
GO

--Insert into new Department tables information from loading table.
INSERT INTO SalesDepartment(
	EmployeeNumber,
	JobRole,
	JobLevel,
	YearsInCurrentRole,
	EducationField,
	Education,
	HourlyRate,
	DailyRate,
	MonthlyRate
)
	SELECT EmployeeNumber, JobRole, JobLevel, YearsInCurrentRole, EducationField, Education, HourlyRate, DailyRate, MonthlyRate
	FROM LoadingTable
	WHERE Department = 'Sales';
GO

INSERT INTO HumanResourcesDepartment(
	EmployeeNumber,
	JobRole,
	JobLevel,
	YearsInCurrentRole,
	EducationField,
	Education,
	HourlyRate,
	DailyRate,
	MonthlyRate
)
	SELECT EmployeeNumber, JobRole, JobLevel, YearsInCurrentRole, EducationField, Education, HourlyRate, DailyRate, MonthlyRate
	FROM LoadingTable
	WHERE Department = 'Human Resources';
GO

INSERT INTO ResearchDepartment(
	EmployeeNumber,
	JobRole,
	JobLevel,
	YearsInCurrentRole,
	EducationField,
	Education,
	HourlyRate,
	DailyRate,
	MonthlyRate
)
	SELECT EmployeeNumber, JobRole, JobLevel, YearsInCurrentRole, EducationField, Education, HourlyRate, DailyRate, MonthlyRate
	FROM LoadingTable
	WHERE Department = 'Research & Development';
GO

--Store Survey answers in seperate table.
INSERT INTO SurveyResults (
	EmployeeNumber,
	JobSatisfaction,
	RelationshipSatisfaction,
	EnvironmentalSatisfaction,
	JobInvolvement,
	WorkLifeBalance,
	YearsWithCurrManager,
	YearsSinceLastPromotion
)
	SELECT EmployeeNumber, JobSatisfaction, RelationshipSatisfaction, EnvironmentalSatisfaction, JobInvolvement, WorkLifeBalance, YearsWithCurrManager, YearsSinceLastPromotion
	FROM LoadingTable;
GO