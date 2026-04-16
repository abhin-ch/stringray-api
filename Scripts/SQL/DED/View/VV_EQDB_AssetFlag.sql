

CREATE or ALTER view [stng].[VV_EQDB_AssetFlag] as
with AssetFlags as (
	select distinct
	a.LOCATION
	, a.FACILITY
	, a.AMLItem as Item
	, a.AMLINSTALLED
	, b.[ITEMNUM] as RotatingItem
	, case when b.[ITEMNUM] = a.AMLItem then 0 else 1 end as HasMatchingRotatingAMLItem
	from [stngetl].[EQDB_IndexEQEBOM] as a
	left join [stngetl].[IQT_MEL] as b on a.LOCATION = b.LOCATION and a.FACILITY = b.SITEID
),

Asset as (
	select 
	a.[LOCATION]
	, a.FACILITY
	, a.Item
	, a.AMLINSTALLED
	, a.RotatingItem
	, a.HasMatchingRotatingAMLItem
	, case when a.Item is not null and AMLINSTALLED = 1 and HasMatchingRotatingAMLItem = 1 then 1 
			else 0 end as Asset
	from AssetFlags as a
)

select *
, case 
	when Asset = 0
		then case 
			when Item is not null then Item
			else 'No Asset Number'
		end + char(13) + char(10) 
		+
		case 
			when AMLINSTALLED = 0 then 'Requires INSTALLED asset' + char(13) + char(10)
		end
		+
		case 
			when HasMatchingRotatingAMLItem = 0 then 'Rotating Item does not match Item Number on AML' + char(13) + char(10)
		end
	else null	
end as FailureMessage
from Asset
