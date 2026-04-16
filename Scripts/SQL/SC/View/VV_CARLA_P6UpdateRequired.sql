/*
CreatedBy: Habib Shakibanejad
CreatedDate: 12 Feb 2022
Description: Grab activities that are required to be updated in P6. These activities represent changes have been made in Stingray but have not been updated in P6.
*/
CREATE OR ALTER VIEW [stng].[VV_CARLA_P6UpdateRequired] 
AS 
SELECT DISTINCT FA.ProjShortName AS 'ProjectID'
	,FA.ActivityID
	,F.FragnetName AS 'SubFragnetName'
	,(SELECT TOP 1 F.FragnetName FROM stng.CARLA_Fragnet F WHERE F.FragnetID = (SELECT TOP 1 ParentID FROM stng.CARLA_Fragnet S WHERE S.FragnetID = FA.FragnetID)) AS 'FragnetName'
	,FA.ActivityName
	,IIF(C1.[Key]='Actual',C1.NewValue,NULL) AS 'ActualStartDate'
	,IIF(C1.[Key]='Anticipated',C1.NewValue,NULL) AS 'AnticipatedStartDate'
	,IIF(C2.[Key]='Actual',C2.NewValue,NULL) AS 'ActualFinishDate'
	,IIF(C2.[Key]='Anticipated',C2.NewValue,NULL) AS 'AnticipatedFinishDate'
	,(SELECT STRING_AGG(A.Num,',') FROM (
		SELECT 
		CONCAT(FAD.FieldName,'#',FAD.NewValue) AS 'Num'
		,ROW_NUMBER() OVER(PARTITION BY FAD.FKID ORDER BY FAD.CreatedDate DESC) AS RN
		FROM stng.CARLA_ChangeLog FAD WHERE FAD.ActivityID = FA.ActivityID AND FAD.[Key] = 'Number' AND FAD.P6UpdateRequired = 1) A WHERE A.RN = 1) AS 'Numbers'
	,C1.CreatedBy AS 'StartModifiedBy'
	,C2.CreatedBy AS 'FinishModifiedBy'
	,C3.CreatedBy AS 'NumberModifiedBy'
FROM stng.CARLA_FragnetActivity FA
LEFT JOIN stng.CARLA_ChangeLog C1 ON C1.ActivityID = FA.ActivityID AND C1.FieldName = 'StartDate' AND C1.P6UpdateRequired = 1 AND FA.[Status] = 'NotStart'
LEFT JOIN stng.CARLA_ChangeLog C2 ON C2.ActivityID = FA.ActivityID AND C2.FieldName = 'FinishDate' AND C2.P6UpdateRequired = 1
LEFT JOIN stng.CARLA_ChangeLog C3 ON C3.ActivityID = FA.ActivityID AND C3.P6UpdateRequired = 1 AND C3.[Key] = 'Number'
INNER JOIN stng.CARLA_Fragnet F ON F.FragnetID = FA.FragnetID
WHERE (C1.P6UpdateRequired = 1 
OR C2.P6UpdateRequired = 1
OR C3.P6UpdateRequired = 1)
AND FA.Actualized = 0
AND F.FragnetName NOT LIKE 'Milestones (BAS)%'
GO