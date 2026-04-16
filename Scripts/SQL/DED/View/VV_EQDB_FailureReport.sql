CREATE or ALTER view [stng].[VV_EQDB_FailureReport] as
	
with EQEBOMFailure as (
	SELECT location, facility, string_agg(cast(failuremessage as nvarchar(MAX)), char(10) + char(13)) as FailureMessage
	FROM stng.VV_EQDB_EQEBOMFlag
	group by location, facility
),
PredefinedCompFailure as (
	SELECT location, facility, string_agg(cast(failuremessage as nvarchar(MAX)), char(10) + char(13)) as FailureMessage
	FROM stng.VV_EQDB_PredefinedCompFlag
	group by location, facility
),
AssetFailure as (
	SELECT location, facility, string_agg(cast(failuremessage as nvarchar(MAX)), char(10) + char(13)) as FailureMessage
	FROM stng.[VV_EQDB_AssetFlag]
	group by location, facility
),
EQDOCFailure as (
	SELECT location, facility, string_agg(cast(failuremessage as nvarchar(MAX)), char(10) + char(13)) as FailureMessage
	FROM stng.[VV_EQDB_EQDOCFlag]
	group by location, facility
),
EQPMFailure as (
	SELECT location, facility, string_agg(cast(failuremessage as nvarchar(MAX)), char(10) + char(13)) as FailureMessage
	FROM stng.VV_EQDB_EQPMFlag
	group by location, facility
)

select 
a.Location
,a.Facility as SiteID
,a.Unit
,a.LocationStatus
,a.LocationDesc
,b.FailureMessage as EQEBOM
,e.FailureMessage as Asset
,f.FailureMessage as EQPM
,c.FailureMessage as EQDOC
,d.FailureMessage as PredefinedComp
from stngetl.EQDB_IndexInfo as a
left join EQEBOMFailure as b on a.Location = b.LOCATION and a.Facility = b.FACILITY
left join EQDOCFailure as c on a.Location = c.LOCATION and a.Facility = c.FACILITY
left join PredefinedCompFailure as d on a.Location = d.LOCATION and a.Facility = d.FACILITY
left join AssetFailure as e on a.Location = e.LOCATION and a.Facility = e.FACILITY
left join EQPMFailure as f on a.Location = f.LOCATION and a.Facility = f.FACILITY


GO