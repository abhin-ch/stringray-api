ALTER VIEW [stng].[VV_ECRA_Main]
AS

SELECT DISTINCT  
	  a.[UniqueID]
      ,a.[EC]
	  ,b.[DESCRIPTION]
	  ,a.Details
	  ,a.Proficiency
	  ,case 
		when a.FirstTime = 1 then 'Y' 
		when a.FirstTime = 0 then 'N'
		else null 
	  end as FirstTime
	  ,case 
		when a.FirstInAWhile = 1 then 'Y' 
		when a.FirstInAWhile = 0 then 'N'
		else null 
	  end as FirstInAWhile
	  ,case 
		when a.FastTrack = 1 then 'Y' 
		when a.FastTrack = 0 then 'N'
		else null 
	  end as FastTrack
	  ,a.ManagerRiskPerceptionImpact
	  ,a.ManagerRiskPerceptionProbability
	  ,a.DisciplineType
	  ,c.Discipline as DisciplineC
      ,a.[RAD]
      ,a.[RAB]
      ,a.[LUD]
      ,a.[LUB]
FROM [stng].[ECRA_Main] AS a 
INNER JOIN [stngetl].[General_AllEC] as b on a.[EC] = b.[EC]
LEFT JOIN [stng].[ECRA_Discipline] as c on a.DisciplineType = c.UniqueID
where a.Deleted = 0

GO


