CREATE or ALTER view [stng].[VV_EQDB_IndexMain] as

select distinct concat(a.LOCATION,'-', a.FACILITY) as EQDBIID
      ,a.[Location]
      ,a.[Facility],
	  a.Unit,
	  a.LOCATIONDESC,
	  a.LOCATIONSTATUS,
	  a.LOCATIONTYPE,
	  case when d.EQEBOM = 1 then d.EQEBOM else e.EQEBOM end as EQEBOM,
	  case when d.AMLINSTALLED = 1 then d.AMLINSTALLED else f.AMLINSTALLED end as AMLINSTALLED,
	  case when d.EQDOCCHECK = 1 then d.EQDOCCHECK else g.EQDOCCHECK end as EQDOCCHECK,
	  case when d.PredefinedCheck = 1 then d.PredefinedCheck else i.PredefinedCheck end as PredefinedCheck,
	  case when d.PredefinedComplete = 1 then d.PredefinedComplete else c.PMCompletion end as PMCompletion,
	  d.OutstandingChanges,
	  h.EQEBOM as EQEBOMFailureMessage,
	  h.Asset as AssetFailureMessage,
	  h.EQDOC as EQDOCFailureMessage,
	  h.EQPM as EQPMFailureMessage,
	  h.PredefinedComp as PredefinedCompFailureMessage
from stngetl.EQDB_IndexInfo as a
left join (
	select Location, Facility, min(PredefinedComp) as PMCompletion
	from [stng].[VV_EQDB_PredefinedCompFlag]
	group by LOCATION, FACILITY
) as c on a.LOCATION = c.LOCATION and a.FACILITY = c.FACILITY
left join stng.EQDB_Main as d on concat(a.LOCATION,'-', a.FACILITY) = d.EQDBIID
left join (
	select Location, Facility, max(EQEBOM) as EQEBOM
	from [stng].[VV_EQDB_EQEBOMFlag]
	group by LOCATION, FACILITY
) as e on a.LOCATION = e.LOCATION and a.FACILITY = e.FACILITY
left join (
	select Location, Facility, max(Asset) as AMLINSTALLED
	from [stng].[VV_EQDB_AssetFlag]
	group by LOCATION, FACILITY
) as f on a.LOCATION = f.LOCATION and a.FACILITY = f.FACILITY
left join (
	select Location, Facility, max(EQDOCCHECK) as EQDOCCHECK
	from [stng].VV_EQDB_EQDOCFlag
	group by LOCATION, FACILITY
) as g on a.LOCATION = g.LOCATION and a.FACILITY = g.FACILITY
left join (
	select Location, Facility, max(EQPMCHECK) as PredefinedCheck
	from [stng].VV_EQDB_EQPMFlag
	group by LOCATION, FACILITY
) as i on a.LOCATION = i.LOCATION and a.FACILITY = i.FACILITY
left join stng.VV_EQDB_FailureReport as h on a.LOCATION = h.Location and a.Facility = h.SiteID
GO