CREATE OR ALTER     PROCEDURE [stngetl].[SP_SST_HistoricalInfo]
AS
BEGIN

	with OGQuery as
	(
		select distinct dataid, name as DocName, dcomment as SSTNo, url_create as SSTLink 
		from stng.SST_HistoricalContentServer
		where name not like '@%'
	),
	finalHistorical as
	(
		select dataid, DocName, SSTNo, SSTLink, 
		CASE WHEN
		DocName like '%U1%' THEN '1'
		WHEN DocName like '%U2%' THEN '2'
		WHEN DocName like '%U3%' THEN '3'
		WHEN DocName like '%U4%' THEN '4'
		WHEN DocName like '%U5%' THEN '5'
		WHEN DocName like '%U6%' THEN '6'
		WHEN DocName like '%U7%' THEN '7'
		WHEN DocName like '%U8%' THEN '8'
		WHEN DocName like '%U0A%' THEN '0A'
		WHEN DocName like '%U0B%' THEN '0B'
		END AS Unit,
		TRY_PARSE( SUBSTRING(DocName, PATINDEX('%[0-9][0-9][A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9]%', DocName), 9) AS datetime USING 'en-US') as WODate,
		case when DocName like '%ABORTED%' then 'ABORTED' when DocName like '%FAILED%' then 'FAILED' else 'PASSED' end as Result from OGQuery
	), DistinctMapping AS
	(--include unit, then include unit in join
		select distinct a.SSTID, a.SSTNo, e.LOCATIONUNIT as Unit from stng.SST_Mapping a
		join stng.SST_Main b on a.SSTID = b.UniqueID
		left join stngetl.General_PMtoLocation as e on b.PM = e.PMNUM and e.ORIGIN = 'PM Direct Link'
		where e.LOCATIONUNIT is not null and a.Deleted = 0
	),
	joinmap AS 
	( 
		select a.SSTID, 
		a.SSTNo, 
		b.Unit,
		b.Result, 
		b.DocName,
		b.dataid, 
		b.WODate as SSTDate,
		b.SSTLink as MaximoLink,
		row_number() over (partition by a.SSTID, b.dataid order by b.DocName) as rn
		from DistinctMapping a 
		join finalHistorical b on (b.DocName like '%' + a.SSTNo + '%' or b.SSTNo like '%' + a.SSTNo + '%') and b.Unit = a.Unit
		left join stng.SST_HistoricalInfo_Mapped c on b.dataid = c.dataid and a.SSTID = c.SSTID
		where b.Unit is not null and c.dataid is null and c.SSTID is null
	) 

	insert into stng.SST_HistoricalInfo_Mapped(SSTID, SSTNo, Unit, Result, DocName, SSTDate, dataid, MaximoLink)
	select distinct a.SSTID, a.SSTNo, a.Unit, a.Result, a.DocName, a.SSTDate, a.dataid,
	concat('https://ecm.corp.brucepower.com/OTCS/cs.exe?func=ll&objAction=open&objID=', a.dataid) as MaximoLink
	from joinmap a
	where rn = 1
	

	delete from stng.SST_Historical_5Yr

	insert into stng.SST_Historical_5Yr(SSTID, Total, Passed, Aborted, Failed, PassRate)
	select
		  SSTID,
		  count(*)                                 as [5 Yr Total],
		  sum(case when Result = 'PASSED' then 1 else 0 end)  as [5 Yr Passed],
		  sum(case when Result = 'ABORTED' then 1 else 0 end) as [5 Yr Aborted],
		  sum(case when Result = 'FAILED' then 1 else 0 end)  as [5 Yr Failed],
		  case
			when count(*) = 0 then 'N/A'
			else concat(round(100.0 * sum(case when Result = 'PASSED' then 1 else 0 end) / cast(count(*) as float), 2), ' %')
		  end as [5 Yr Passed Rate]
		from stng.SST_HistoricalInfo_Mapped
		where SSTDate >=  DATEADD(year,-5,stng.getbptime(getdate())) or SSTDate is null
		group by SSTID


END


