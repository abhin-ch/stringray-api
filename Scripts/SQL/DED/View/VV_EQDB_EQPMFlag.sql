CREATE or ALTER view [stng].[VV_EQDB_EQPMFlag] as
with EQPMFlags as (
	select distinct
	a.LOCATION
	, a.FACILITY
	, a.EQPM
	, a.EQJP
	, a.OnAMLVerifiedBOM
	, a.EQJPITEM
	, case when a.EQPM is not null then 1 else 0 end as HasPM
	, case when a.EQJP is not null then 1 else 0 end as HasJP
	from stngetl.EQDB_IndexPredefined as a
),

EQPM as (
	select 
	a.LOCATION
	, a.FACILITY
	, a.EQPM
	, a.EQJP
	, a.OnAMLVerifiedBOM
	, a.EQJPITEM
	, a.HasPM
	, a.HasJP
	, case when a.HasPM = 1 and a.HasJP = 1 and a.OnAMLVerifiedBOM = 1 then 1 
			else 0 end as EQPMCHECK
	from EQPMFlags as a
)

select *
, case 
	when EQPMCHECK = 0
		then case 
			when a.HasPM = 1 then EQPM
			else 'No PM'
		end + char(13) + char(10) 
		+
		case 
			when a.HasJP = 1 then EQJP
			else 'No JP'
		end + char(13) + char(10) 
		+
		case 
			when OnAMLVerifiedBOM = 0 then 'Job Plan Item Number is not on AML' + char(13) + char(10)
		end
	
	else null	
end as FailureMessage
from EQPM as a


GO