CREATE or ALTER view [stng].[VV_EQDB_PredefinedCompFlag] as

with PredefinedCompFlags as (
	SELECT
	a.[LOCATION]
    ,a.[FACILITY]
    ,a.[EQPM]
	,a.EQJPITEM
	,b.PMNEXTDUEDATE
	,b.CURRENTWOPMDUEDATE
	,case when b.PMNEXTDUEDATE > stng.GetBPTime(GETDATE()) then 1 else 0 end as NextDateFlag
	,case when b.CURRENTWOPMDUEDATE > stng.GetBPTime(GETDATE()) then 1 else 0 end as CurrentDateFlag

  FROM [stngetl].[EQDB_IndexPredefined] as a 
  left join stngetl.General_PMRSupportingInfo as b on a.EQPM = b.PMNUM
 ),
 PredefinedComp as (
  select *
  , case when NextDateFlag = 1 or CurrentDateFlag = 1 then 1 else 0 end as PredefinedComp
  from PredefinedCompFlags
 )

select *
,case 
	when PredefinedComp = 0
		then case 
			when EQPM is not null then concat('PM: ', EQPM, ' - ')
			else 'No PM number available'
		end 
		+ case 
			when EQJPITEM is not null then concat('Item: ', EQJPITEM)
			else 'No Item number available'
		end 
		+ char(13) + char(10) 
		+ 'Current PM Due Date or Earliest Next Due Date must be in the past'
	else null	
end as FailureMessage
  from PredefinedComp
GO