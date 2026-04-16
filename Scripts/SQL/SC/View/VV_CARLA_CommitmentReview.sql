CREATE OR ALTER   VIEW [stng].[VV_CARLA_CommitmentReview]
AS 
SELECT 
	FA.[ProjShortName] AS 'ProjectID'
	,FA.[ActivityID]
	,FA.[ActivityName]
	,FA.[FragnetID]
	,FA.[NCSQ]
	,IIF(FA.Status = 'Active', FORMAT(FA.[ReendDate],'dd-MMM-yyyy'),FORMAT(FA.[EndDate],'dd-MMM-yyyy')) AS 'CommitmentDate'
	,IIF(FA.[Status] = 'NotStart',FORMAT(FA.[StartDate],'dd-MMM-yyyy'),FORMAT(FA.[ActualStartDate],'dd-MMM-yyyy')) AS 'StartDate'					
	,IIF(FA.[Actualized] = 0,FORMAT(FA.[ReendDate],'dd-MMM-yyyy'),FORMAT(FA.[ActualEndDate],'dd-MMM-yyyy')) AS 'FinishDate'
	,FA.[ActualStartDate]
	,FA.[EndDate]
	,FA.[Actualized]
	,FA.[Resource]					
	,SubF.[FragnetName] AS 'SubfragnetName'
	,FF.FragnetName
	,M.ProjectName
	,M.[Portfolio]
	--,M.[CSPCS] AS 'PCS'
	--,M.[OE]
	,M.ProjectManager
	,M.ProjectPlanner
	,M.ProgramManager
	,M.MaterialBuyer
	,M.ContractAdmin
	,M.ServiceBuyer
	,M.BuyerAnalyst
	,M.CSFLM
	--,M.ContractSpecialist
	,M.FastTrack
	,M.ProjectCostAnalyst
	,IIF(FA.[ActualEndDate] <= FA.[EndDate], 'Actualized','Actualized Late') AS 'Status'
	,DATEDIFF(DAY,FA.ActualEndDate,FA.EndDate) AS 'Variance'
	,stng.FN_CARLA_GetSDSNumber(FF.FragnetName) AS 'SDS'
	,C.Name AS 'CommitmentOwner'
	,U.Category
	,IIF(FA.Status = 'Active', FORMAT(FA.[ReendDate],'yyyyMMdd'),FORMAT(FA.[EndDate],'yyyyMMdd')) AS 'EndDateSort' -- This is used for sorting from the FE
FROM stng.CARLA_FragnetActivity FA
INNER JOIN stng.CARLA_Fragnet SubF ON SubF.FragnetID = FA.FragnetID
LEFT JOIN stng.MPL M ON M.ProjectID = FA.ProjShortName
LEFT JOIN stng.VV_CARLA_GetCommitmentOwner C ON C.ProjectID = FA.ProjShortName AND C.CommitmentOwner = FA.CommitmentOwner
LEFT JOIN stng.CARLA_FragnetUpdate U ON U.ActivityID = FA.ActivityID
CROSS APPLY (
	SELECT TOP 1 F.FragnetName FROM stng.CARLA_Fragnet F WHERE F.FragnetID = (SELECT TOP 1 ParentID FROM stng.CARLA_Fragnet S WHERE S.FragnetID = FA.FragnetID)
) AS FF	
WHERE FA.Actualized = 1					
AND (FA.[NCSQ] = 'CSQ' OR FA.[NCSQ] = 'NCSQ')
AND (FA.EndDate > stng.FN_CARLA_PreviousThursday() AND FA.EndDate < stng.FN_CARLA_PreviousWednesday())
AND M.Status = 'ACTIVE'
UNION
SELECT
	FA.[ProjShortName] AS 'ProjectID'
	,FA.[ActivityID]
	,FA.[ActivityName]
	,FA.[FragnetID]
	,FA.[NCSQ]
	,IIF(FA.Status = 'Active', FORMAT(FA.[ReendDate],'dd-MMM-yyyy'),FORMAT(FA.[EndDate],'dd-MMM-yyyy')) AS 'CommitmentDate1'
	,IIF(FA.[Status] = 'NotStart',FORMAT(FA.[StartDate],'dd-MMM-yyyy'),FORMAT(FA.[ActualStartDate],'dd-MMM-yyyy')) AS 'StartDate'					
	,IIF(FA.[Actualized] = 0,FORMAT(FA.[ReendDate],'dd-MMM-yyyy'),FORMAT(FA.[ActualEndDate],'dd-MMM-yyyy')) AS 'FinishDate'
	,FA.[ActualStartDate]
	,FA.[EndDate]
	,FA.[Actualized]
	,FA.[Resource]					
	,SubF.[FragnetName] AS 'SubfragnetName'
	,FF.FragnetName
	,M.ProjectName
	,M.[Portfolio]
	--,M.[CSPCS] AS 'PCS'
	--,M.[OE]
	,M.ProjectManager
	,M.ProjectPlanner
	,M.ProgramManager
	,M.MaterialBuyer
	,M.ContractAdmin
	,M.ServiceBuyer
	,M.BuyerAnalyst
	,M.CSFLM
	--,M.ContractSpecialist
	,M.FastTrack
	,M.ProjectCostAnalyst
	,IIF(FA.[EndDate] < CAST(GETDATE() AS DATE), 'Not Actualized',NULL) AS 'Status'
	,DATEDIFF(DAY,FA.ReendDate,FA.EndDate) AS 'Variance'					
	,stng.FN_CARLA_GetSDSNumber(FF.FragnetName) AS 'SDS'
	,C.Name AS 'CommitmentOwner'
	,U.Category
	,IIF(FA.Status = 'Active', FORMAT(FA.[ReendDate],'yyyyMMdd'),FORMAT(FA.[EndDate],'yyyyMMdd'))
FROM stng.CARLA_FragnetActivity FA
INNER JOIN stng.CARLA_Fragnet SubF ON SubF.FragnetID = FA.FragnetID
LEFT JOIN stng.MPL M ON M.ProjectID = FA.ProjShortName			
LEFT JOIN stng.VV_CARLA_GetCommitmentOwner C ON C.ProjectID = FA.ProjShortName AND C.CommitmentOwner = FA.CommitmentOwner
LEFT JOIN stng.CARLA_FragnetUpdate U ON U.ActivityID = FA.ActivityID
CROSS APPLY (
	SELECT TOP 1 F.FragnetName FROM stng.CARLA_Fragnet F WHERE F.FragnetID = (SELECT TOP 1 ParentID FROM stng.CARLA_Fragnet S WHERE S.FragnetID = FA.FragnetID)
) AS FF	
WHERE FA.Actualized = 0 
AND FA.EndDate < CAST(GETDATE() AS DATE)
AND (FA.[NCSQ] = 'CSQ' OR FA.[NCSQ] = 'NCSQ')
AND (FA.EndDate > stng.FN_CARLA_PreviousThursday() AND FA.EndDate < stng.FN_CARLA_PreviousWednesday())
AND M.Status = 'ACTIVE'
GO