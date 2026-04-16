CREATE or ALTER view [stng].[VV_EQDB_EQEBOMFlag] as
with EQBOMFlags as (
	select distinct
	a.LOCATION
	, a.FACILITY
	, a.AMLItem as Item
	, b.REPAIR_STRAT
	, cast(case when b.REPAIR_STRAT = '001' or b.REPAIR_STRAT = '002' then 1 else 0 end as bit) as RepairStrat12
	, cast(case when b.REPAIR_STRAT = '003' or b.REPAIR_STRAT = '004' then 1 else 0 end as bit) as RepairStrat34
	, AMLITEMSTATUS as ItemStatus
	, cast(case when AMLITEMSTATUS = 'ACTIVE' then 1 else 0 end as bit) as ActiveItem
	, cast(case when AMLITEMSTATUS = 'ACTIVE' or AMLITEMSTATUS = 'SCREENING REQD' or AMLITEMSTATUS = 'PENDOBS'  then 1 else 0 end as bit) as ActiveScreenPenItem
	, cast(AMLITEMEQ as bit) as EQ
	, cast(AMLITEMVERIFIED as bit) as Verified
	, AMLITEMQL as ProcClass
	, cast(case when AMLITEMQL = 1 or AMLITEMQL = 2 then 1 else 0 end as bit) as ProcClass12
	from [stngetl].[EQDB_IndexEQEBOM] as a
	left join [stngetl].[IQT_MEL] as b on a.LOCATION = b.LOCATION and a.FACILITY = b.SITEID
),

EQEBOM as (
	select 
	a.[LOCATION]
	, a.FACILITY
	, a.Item
	, a.REPAIR_STRAT
	, a.RepairStrat12
	, a.RepairStrat34
	, a.ItemStatus
	, a.ActiveItem
	, a.ActiveScreenPenItem
	, a.EQ
	, a.Verified
	, a.ProcClass
	, a.ProcClass12
	, case when (RepairStrat12 = 1 and ProcClass12 = 1 and EQ = 1 and Verified = 1 and ActiveItem = 1) 
			or (RepairStrat34 = 1 and ActiveScreenPenItem = 1) then 1 
			else 0 end as EQEBOM
	from EQBOMFlags as a
)

select *
, case 
	when EQEBOM = 0
		then case 
			when Item is not null then Item
			else 'No item number available'
		end + char(13) + char(10) +
		case 
			when RepairStrat12 = 1 or RepairStrat34 = 1 then concat('Since the repair strategy for this location is ',REPAIR_STRAT) + char(13) + char(10)
				+ 
				case 
					when RepairStrat12 = 1 
						then 
							case 
								when ActiveItem = 0 then 'The item needs an ACTIVE status' + char(13) + char(10)
								else ''
							end
							+
							case 
								when Verified = 0 then 'The item needs to be verified' + char(13) + char(10)
								else ''
							end
							+
							case 
								when EQ = 0 then 'Needs to be an EQ item' + char(13) + char(10)
								else ''
							end
							+
							case 
								when ProcClass12 = 0 then 'Has to have a Procurement class of 1 or 2' + char(13) + char(10)
								else ''
							end
					when RepairStrat34 = 1 
						then 
							case 
								when ActiveScreenPenItem = 0 then 'The item needs a status of either ACTIVE, PENDOBS, or SCREENING REQD' + char(13) + char(10)
								else ''
							end
				end
			
			else 'No Repair Strategy' + char(13) + char(10)
		end
	else null	
end as FailureMessage
from EQEBOM


GO
