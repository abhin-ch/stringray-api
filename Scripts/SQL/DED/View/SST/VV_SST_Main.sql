CREATE OR ALTER view [stng].[VV_SST_Main] as 
with sstconcat as
(
	select SSTID, string_agg(cast(SSTLabel as varchar(max)),'-') as SST
	from stng.VV_SST_Mapping
	group by SSTID
),
locagg as
(
	select SSTID, max(case when SPV = 'Yes' then 1 else 0 end) as SPV,
	string_agg(cast(concat(location,'||',siteid) as varchar(max)),'; ') as Locations
	from stng.VV_SST_Location
	group by SSTID
),
rce as
(
	select x.SSTID, string_agg(cast(x.RCE as varchar(max)),'; ') within group (order by x.RCE) as RCE
	from
	(
		select distinct SSTID, RCE
		from stng.VV_SST_Location
	) as x
	group by x.SSTID
),
rse as
(
	select x.SSTID, string_agg(cast(x.RSE as varchar(max)),'; ') within group (order by x.RSE) as RSE
	from
	(
		select distinct SSTID, RSE
		from stng.VV_SST_Location
	) as x
	group by x.SSTID
),
rde as
(
	select x.SSTID, string_agg(cast(x.RDE as varchar(max)),'; ') within group (order by x.RDE) as RDE
	from
	(
		select distinct SSTID, RDE
		from stng.VV_SST_Location
	) as x
	group by x.SSTID
),
stratowner as
(
	select x.SSTID, string_agg(cast(x.STRATEGY_OWNER as varchar(max)),'; ') within group (order by x.STRATEGY_OWNER) as stratowner
	from
	(
		select distinct SSTID, STRATEGY_OWNER
		from stng.VV_SST_Location
	) as x
	group by x.SSTID
),
systems as
(
	select x.SSTID, string_agg(cast(x.USI as varchar(max)), '; ') within group (order by x.USI asc) as USI
	from
	(
		select distinct SSTID, USI
		from stng.VV_SST_Location
	) as x 
	group by x.SSTID
)



select a.UniqueID as SSTID, a.PM, b.SST,
d.FREQUENCY, d.FREQUNIT, d.PMDESC as SSTTitle, d.PMCATEGORIES, d.SITEID, e.LOCATIONUNIT as pmunit,
concat('https://prod-maximo.corp.brucepower.com/maximo/ui/maximo.jsp?event=loadapp&value=pluspm&uniqueid=',d.PMUID) as MaximoLink,
d.UCR, d.CNSC, d.PRA, d.SOE, d.REACTIVITYMGMT, f.Locations, f.SPV,
g.name as OSRNo, g.URLNAME as OSRLink,
h.RCE, i.RSE, k.stratowner, j.RDE, l.USI,
m.SingleExecutionCost, m.PreDoseCost, m.Dose, m.DoseMREM,
concat(n.ImpairmentCount, ' ', n.ImpairmentUnit) as Impairment, n.ImpairmentNA,
concat(n.ChannelRejectionCount, ' ', n.ChannelRejectionUnit) as ChannelRejection, n.ChannelRejectionNA,
o.Passed as [5 Yr Passed], o.Aborted as [5 Yr Aborted], o.Failed as [5 Yr Failed], o.PassRate as [5 Yr Passed Rate],
p.lastwocompdate as LastWODate, p.CurrentWOPMDueDate as CurrentWODate
from stng.SST_Main as a
inner join sstconcat as b on a.UniqueID = b.SSTID
inner join stngetl.General_PM as d on a.PM = d.PMNUM
left join stngetl.General_PMtoLocation as e on a.PM = e.PMNUM and e.ORIGIN = 'PM Direct Link'
left join locagg as f on a.UniqueID = f.SSTID
OUTER APPLY (select top 1 g.name, g.URLNAME from stngetl.SST_OSR g where a.PM = g.PMNUM order by g.[StatusDate] desc) g
left join rce as h on a.UniqueID = h.SSTID
left join rse as i on a.UniqueID = i.SSTID
left join rde as j on a.UniqueID = j.SSTID
left join stratowner as k on a.UniqueID = k.SSTID
left join systems as l on a.UniqueID = l.SSTID
left join stng.SST_HeaderCosts as m on m.SSTID = a.UniqueID
left join stng.SST_HeaderTimes as n on n.SSTID = a.UniqueID
left join stng.SST_Historical_5Yr as o on a.UniqueID = o.SSTID
left join stng.SST_SupportingInfo p on p.pmnum = a.PM
GO


