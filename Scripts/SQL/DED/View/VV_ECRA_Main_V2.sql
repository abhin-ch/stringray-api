ALTER VIEW [stng].[VV_ECRA_Main_V2]
AS

WITH EACFILTER AS (  
	SELECT EAC.SDQUID, R.Revision, EAC.ProjectID, EAC.EcoSysEAC
	FROM (SELECT UniqueID, REVISION, ProjectNo, StatusValue, ROW_NUMBER() OVER (PARTITION BY ProjectNo ORDER BY REVISION DESC) AS RN 
		FROM [stng].[VV_Budgeting_SDQMain] WHERE StatusValue IN ('AFRE', 'APRE')) R
	LEFT JOIN STNG.VV_Budgeting_SDQ_EcoSysEAC EAC
	ON EAC.SDQUID = SUBSTRING(R.UniqueID, CHARINDEX('-', R.UniqueID) +1, LEN(R.UNIQUEID)) 
	WHERE R.RN = 1
	)

SELECT DISTINCT  
      main.[EC]
	  ,main.[DESCRIPTION]
	  ,main.Parent
	  ,main.JPNUM
	  ,main.[Location]
	  ,main.SiteID
	  ,main.[Status]
	  ,main.StatusDate
	  ,main.USI
	  ,main.Section
	  ,main.ProjectID
	  ,e.EcoSysEAC
	  ,a.Details
	  ,a.Knowledge
	  ,a.Skill
	  ,a.Familiarity
	  ,a.Understanding
	  ,a.Currency
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
	  ,stng.FN_General_MaximoLink('EC', d.ecuid) as MaximoLink
      ,a.[RAD]
      ,a.[RAB]
      ,a.[LUD]
      ,a.[LUB]
FROM [stngetl].[General_AllEC] AS main
LEFT JOIN [stng].[ECRA_Main] AS a on main.EC = a.EC
LEFT JOIN [stng].[ECRA_Discipline] as c on a.DisciplineType = c.UniqueID
LEFT JOIN [stngetl].[General_ECMapping] as d on a.EC = d.ECNUM
LEFT JOIN EACFILTER e on e.ProjectID = main.ProjectID
where (main.JPNUM = 'MOD DCP' and main.[Status] in ('DEF', 'DEFCOMP')) or (main.JPNUM = 'MOD DCN' and main.Parent is not null)

GO