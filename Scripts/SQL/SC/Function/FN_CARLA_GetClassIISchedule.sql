/*
Author: Asiful Hai
Description: Use this function to produce Class II Schedule Table
CreatedDate: 1 Apr 2022
RevisedDate:
RevisedBy: 
*/

CREATE OR ALTER      FUNCTION [stng].[FN_CARLA_GetClassIISchedule](@FragnetID INT, @FragnetName NVARCHAR(255))
RETURNS @T TABLE(
	ActivityID NVARCHAR(255),
	ActivityName NVARCHAR(255),
	PDO NVARCHAR(255),
	StartDate NVARCHAR(255),
	EndDate NVARCHAR(255),
	RoC NVARCHAR(255),
	Header NVARCHAR(255),
	SDS NVARCHAR(255),
	Total float,
	DateSort NVARCHAR(255),
	DateSortS NVARCHAR(255)
)
AS
	BEGIN
		DECLARE @SDS NVARCHAR(50)
		DECLARE @TypeCheck NVARCHAR(50)
		DECLARE @Discipline NVARCHAR(50)
		DECLARE @UnitNumber NVARCHAR(50)
		
		SET @SDS = CASE 
				      WHEN @FragnetName LIKE '%MAJOR%' OR @FragnetName LIKE '%MM%' OR  @FragnetName LIKE '%MR#%' OR @FragnetName LIKE '%MANAGED%' OR  @FragnetName LIKE '%BROKERED%' THEN 'SDS# 50129'
					  WHEN @FragnetName LIKE '%REPAIR%' OR @FragnetName LIKE '%GENERAL EXECUTION%' OR @FragnetName LIKE '%AMENDMENT%' THEN 'SDS# 50149'
					  WHEN @FragnetName LIKE '%ESTIMATING%' OR @FragnetName LIKE '%EBOM%' OR @FragnetName LIKE '%COMMERCIAL%' OR @FragnetName LIKE '%SOURCING%' THEN 'SDS# 50119'
					  WHEN @FragnetName LIKE '%CATEGORY%' THEN 'SDS# 50109'
				   END
		SET @TypeCheck = CASE 
				      WHEN @FragnetName LIKE '%MAJOR%' OR @FragnetName LIKE '%MM%' OR @FragnetName LIKE '%$0%' OR @FragnetName LIKE '%REFURB%' THEN 'Tagged Equipment'
					  WHEN @FragnetName LIKE '%GENERAL EXECUTION%' THEN 'Bulk Material'
					  WHEN @FragnetName LIKE '%TASK%' THEN 'Managed Task Contracts'
					  WHEN @FragnetName LIKE '%BROKERED LABOUR%' THEN 'Brokered Labour Contracts'
					  WHEN @FragnetName LIKE '%MANAGED LABOUR%' THEN 'Managed Labour Contracts'
					  WHEN @FragnetName LIKE '%STRATEGY%' THEN 'Sourcing Strategy'
					  WHEN @FragnetName LIKE '%AMENDMENT%' THEN 'Amendment'
					  ELSE ''
				   END
		
		SET @UnitNumber = IIF(PATINDEX('%[A-B][0-9][0-9][0-9][0-9]%', @FragnetName) <> 0
						, SUBSTRING(@FragnetName, PATINDEX('%[A-B][0-9][0-9][0-9][0-9]%', @FragnetName) + 3, 1)
						, '<#>')

		SET @Discipline = CASE 
					  WHEN @TypeCheck = 'Tagged Equipment' OR @TypeCheck = 'Bulk Material' THEN '<Discipline>'
					  ELSE 'Common'
				   END
		
		

		IF @FragnetName LIKE '%GEM%' OR @FragnetName LIKE '%GENERAL EXECUTION%'
			BEGIN
				DECLARE @GEMRoC INT
				DECLARE @GEMStart Date
				DECLARE @GEMFinish Date
				SET @GEMRoC = (SELECT SUM(CalculatedLabourHours) FROM stng.VV_0028_CSQFinancials WHERE FragnetID = @FragnetID) - (SELECT SUM(CalculatedLabourHours) FROM stng.VV_0028_CSQFinancials WHERE FragnetID = @FragnetID AND SubFragnetName LIKE '%Screening%')
				SET @GEMStart = (SELECT MIN(ActualStartDate) FROM stng.FragnetActivity WHERE FragnetID IN (SELECT SubFragnetID FROM stng.VV_0028_CSQFinancials WHERE FragnetID = @FragnetID))
				SET @GEMFinish = (SELECT MAX(ActualEndDate) FROM stng.FragnetActivity WHERE FragnetID IN (SELECT SubFragnetID FROM stng.VV_0028_CSQFinancials WHERE FragnetID = @FragnetID))
			END

		
		INSERT INTO @T
			SELECT F.ActivityID, F.ActivityName, F.PDO, F.StartDate, F.EndDate, F.RoC, F.Header, F.SDS, SUM(F.RoC) OVER () Total, F.DateSort, F.DateSortS FROM
			(SELECT DISTINCT FA.ActivityID, 
			  FA.ActivityName, 
			  CASE 
				  WHEN FA.Resource = 'Project Manager' THEN 'PMC' 
				  WHEN FA.Resource = 'Engineering' THEN 'ENG' 
				  WHEN FA.Resource LIKE '%CSL%' THEN 'CSL' 
				  WHEN FA.Resource LIKE '%CSW%' THEN 'SCM.WH'
				  WHEN FA.CommitmentOwner IN ('CTS', 'CPB.MMP', 'CPB.GEM') THEN 'SCM' 
				  WHEN FA.CommitmentOwner IN ('CPB.SVC', 'CPP.CA') THEN 'SCC' 
				  ELSE '' 
			  END AS PDO,
			  CASE
				WHEN FA.[N/CSQ] = 'CSQ' THEN IIF(FA.[Status] = 'NotStart', SubFragDate.StartDate, SubFragDate.StartDate + ' A' )
				ELSE IIF(FA.[Status] = 'NotStart',FORMAT(FA.[ActualStartDate],'dd-MMM-yy'),FORMAT(FA.[ActualStartDate],'dd-MMM-yy A') )
			  END StartDate,
			  IIF(FA.[Status] = 'Actualized', FORMAT(FA.ActualEndDate, 'dd-MMM-yy A'), FORMAT(FA.Reenddate, 'dd-MMM-yy')) EndDate,
			  CASE 
				  WHEN FA.[N/CSQ] = 'CSQ' THEN FI.TotalHours 
				  WHEN FA.Resource LIKE '%CSW%' OR FA.ActivityName LIKE '%Buyer Support%' THEN 
				  CASE
					WHEN FA.Status = 'Active' AND FA.ActualStartDate <= '30-Mar-22' THEN FA.RemainingHours 
					WHEN FA.Status = 'Actualized' AND FA.ActualEndDate <= '30-Mar-22' THEN FA.RemainingHours 
					WHEN FA.Status = 'Active' AND FA.ActualStartDate > '30-Mar-22' THEN FA.BudgetedHours 
					WHEN FA.Status = 'Actualized' AND FA.ActualEndDate > '30-Mar-22' THEN FA.BudgetedHours 
					WHEN FA.Status = 'NotStart' THEN FA.BudgetedHours 
				  END
				  WHEN FA.ActivityName LIKE '%Contract Closeout%' THEN FI.TotalHours
				  ELSE NULL
			  END AS RoC,
			  @TypeCheck + ' - Unit ' + @UnitNumber + ' - ' + @Discipline + ' - ' + @FragnetName Header,
			  @SDS SDS,
			  IIF(FA.Status = 'Active', FORMAT(FA.[ReendDate],'yyyy-MM-dd'),FORMAT(FA.[ActualEndDate],'yyyy-MM-dd')) AS 'DateSort',
			  FA.[ActualStartDate] AS 'DateSortS'
			FROM 
			  stng.FragnetActivity FA 
			  INNER JOIN (
				SELECT 
				  F1.FragnetID, 
				CASE 
				  WHEN @FragnetName LIKE '%AMENDMENT%' OR @FragnetName LIKE '%STRATEGY%' THEN F1.FragnetID
				  ELSE F1.ParentID
				END AS ParentID, 
				  F1.FragnetName SubFragnetName, 
				CASE 
				  WHEN @FragnetName LIKE '%AMENDMENT%' OR @FragnetName LIKE '%STRATEGY%' THEN F1.FragnetName 
				  ELSE F2.FragnetName 
				END AS FragnetName			  
				FROM 
				  stng.Fragnet F1 
				  INNER JOIN stng.Fragnet F2 ON F1.ParentID = F2.FragnetID			 
			  ) F ON FA.FragnetID = F.FragnetID 
			  LEFT JOIN (
				SELECT 
				  FragnetID, 
				  FragnetName, 
				  SubFragnetID, 
				  SubFragnetName, 
				  CalculatedLabourHours AS TotalHours 
				FROM 
				  stng.VV_0028_CSQFinancials
			  ) FI ON FI.SubFragnetID = FA.FragnetID 
			  LEFT JOIN
			  (SELECT FF.FragnetID,FF.ParentID,FF.FragnetName,
					(SELECT FORMAT(MIN(FA1.[StartDateMIN]),'dd-MMM-yy') FROM (
						SELECT FA.FragnetID,
						IIF(FA.[Status] = 'NotStart',FA.[StartDate],FA.[ActualStartDate]) AS 'StartDateMIN'
						FROM stng.FragnetActivity FA
					) AS FA1 WHERE FA1.FragnetID = FF.FragnetID) AS 'StartDate'
				FROM stng.Fragnet FF
				INNER JOIN (
				SELECT O.FragnetID FROM (
					SELECT FA.FragnetID
					FROM stng.FragnetActivity FA
					INNER JOIN stng.Fragnet F ON F.FragnetID = FA.FragnetID
					WHERE FA.FragnetID IN (SELECT F.FragnetID FROM stng.Fragnet F WHERE F.ParentID IN 
						(SELECT CSQ.ParentID FROM stng.Fragnet CSQ WHERE CSQ.FragnetID IN (SELECT A.FragnetID FROM stng.FragnetActivity A WHERE A.ActivityID = FA.ActivityID)))
				) O 
				GROUP BY O.FragnetID ) A ON A.FragnetID = FF.FragnetID) SubFragDate ON SubFragDate.FragnetID = FA.FragnetID
			WHERE 
			  F.ParentID = @FragnetID 
			  AND FA.BLStartDate IS NULL
			  AND FA.EndDate IS NULL
			  AND FA.ActivityName NOT LIKE '%Invoices Paid and Documentation%' 
			  AND FA.ActivityName NOT LIKE '%Contract Amendments%'
			  AND ((@FragnetName NOT LIKE '%AMENDMENT%' AND F.SubFragnetName NOT LIKE '%AMENDMENT%') OR (@FragnetName LIKE '%AMENDMENT%' AND F.SubFragnetName LIKE '%AMENDMENT%') OR (@FragnetName LIKE '%STRATEGY%' AND F.SubFragnetName LIKE '%STRATEGY%'))
			  AND (
				FA.Resource = 'Project Manager' 
				OR FA.Resource = 'Engineering' 
				OR FA.[N/CSQ] = 'CSQ' 
				OR FA.Resource LIKE '%CSL%' 
				OR (FA.Resource LIKE '%CSW%' AND FI.FragnetName NOT LIKE '%General Execution Material%') 
				OR (FA.ActivityName LIKE '%Buyer Support%' AND FI.FragnetName NOT LIKE '%General Execution Material%') 
				OR FA.ActivityName LIKE '%Contract Closeout%'
			  )
			  UNION ALL SELECT 'LOE'
				, @FragnetName
				,'SCM'
				,FORMAT(@GEMStart,'dd-MMM-yy')
				,FORMAT(@GEMFinish,'dd-MMM-yy')
				,@GEMRoC
				,@TypeCheck + ' - ' + @UnitNumber + ' - ' + @Discipline + ' - ' + @FragnetName
				,@SDS
				,FORMAT(@GEMFinish,'yyyyMMdd')
				,FORMAT(@GEMStart,'yyyyMMdd') WHERE @FragnetName LIKE '%General Execution Material%'
			) F
			
			

		RETURN;
	END