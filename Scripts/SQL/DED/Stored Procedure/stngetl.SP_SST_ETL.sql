CREATE OR ALTER   PROCEDURE [stngetl].[SP_SST_ETL]
AS
BEGIN
	
	--Drop SST_CSDocs
	IF OBJECT_ID('stng.SST_CSDocs','U') is not null drop table stng.SST_CSDocs;

	select distinct a.pmnum, b.name as DocNum, b.Revision, b.Type, b.SubType,
	case when b.SubType like 'OSR%' then 1 else 0 end as IsOSR
	into stng.SST_CSDocs
	from stngetl.SST_CSDocs as a
	inner join stngetl.General_ControlledDoc as b on a.dataid = b.dataid;

	--SST Mapping Table
	IF OBJECT_ID('stng.SST_Historical_Mapping_Temp', 'U') is not null drop table stng.SST_Historical_Mapping_Temp

	--get PMs, SSTs and split into number and channel
	SELECT DISTINCT
	t.PMNUM,
	s.SSTNo,
	s.SSTNoActual,
	ch.Channel
	INTO stng.SST_Historical_Mapping_Temp
	FROM stngetl.SST_SupportingInfo AS t
	CROSS APPLY (
	  SELECT PATINDEX('%SST [0-9A-Z.]%', t.DESCRIPTION) AS start_pos
	) AS p
	CROSS APPLY (
	  SELECT
		CASE WHEN p.start_pos = 0 THEN NULL
			 ELSE SUBSTRING(t.DESCRIPTION, p.start_pos + 4, 8000) END AS rest
	) AS r
	CROSS APPLY (
	  SELECT
		CASE
		  WHEN r.rest IS NULL THEN NULL
		  WHEN PATINDEX('%[^0-9A-Z.]%', r.rest) = 0 THEN LEN(r.rest) + 1
		  ELSE PATINDEX('%[^0-9A-Z.]%', r.rest)
		END AS first_non_allowed_pos
	) AS n
	CROSS APPLY (
	  SELECT
		CASE WHEN p.start_pos = 0 THEN NULL
			 ELSE LEFT(r.rest, n.first_non_allowed_pos - 1) END AS token_only
	) AS tok
	CROSS APPLY (
	  SELECT
		CASE
		  WHEN tok.token_only IS NULL THEN NULL
		  ELSE
			CASE
			  WHEN PATINDEX('%[^A-Z]%', REVERSE(tok.token_only)) = 0
				THEN '' 
			  ELSE
				LEFT(
				  tok.token_only,
				  LEN(tok.token_only)
				  - (PATINDEX('%[^A-Z]%', REVERSE(tok.token_only)) - 1)
				)
			END
		END AS token_no_trailing_letters
	) AS trimLetters
	CROSS APPLY (
	  -- compute trailing letters (Channel)
	  SELECT
		CASE
		  WHEN tok.token_only IS NULL THEN NULL
		  WHEN LEN(ISNULL(trimLetters.token_no_trailing_letters, '')) = LEN(tok.token_only) THEN NULL
		  ELSE SUBSTRING(
				 tok.token_only,
				 LEN(ISNULL(trimLetters.token_no_trailing_letters, '')) + 1,
				 8000
			   )
		END AS Channel
	) AS ch
	CROSS APPLY (
	  SELECT
		CASE WHEN tok.token_only IS NULL THEN NULL ELSE tok.token_only END AS SSTNo,
		CASE WHEN trimLetters.token_no_trailing_letters IS NULL THEN NULL ELSE trimLetters.token_no_trailing_letters END AS SSTNoActual
	) AS s
	WHERE p.start_pos > 0;


	--Drop stng.SST_SupportingInfo
	IF OBJECT_ID('stng.SST_SupportingInfo','U') is not null drop table stng.SST_SupportingInfo;

	--Concatenate all JPWorkAssets
	select distinct d.SSTNoActual, d.SSTno, a.pmnum, a.description, a.facility, a.unit, a.frequency, a.frequnit, a.planningctr, a.PRAReq, a.soe, a.reactivitymgmt,
	a.cnsc, a.Cat1, a.Cat2, a.Cat3, a.Cat4, a.Cat5, c.usi, a.ucr, a.jpnum, case when e.spv = 1 then 'Yes' else 'No' end as SPV,
	a.LastCompletedWO, a.lastwocompdate, a.lastWOCompletionCode, a.CurrentWOPMDueDate, a.EarliestNextDueDate,
	b.JPWorkAssets, f.DOCNUM,
	g.RSE, h.RDE, i.RCE, j.STRATEGY_OWNER
	into stng.SST_SupportingInfo
	from stngetl.SST_SupportingInfo as a
	left join
	(
		select x1.pmnum, case when len(x1.JPWorkAssets) = 0 then null else left(x1.JPWorkAssets,len(x1.JPWorkAssets)-1) end as JPWorkAssets
		from
		(
			select distinct st4.pmnum,
			(select distinct st3.JPWorkAsset + '; ' as [text()]
			from stngetl.SST_SupportingInfo as st3
			where st3.pmnum = st4.pmnum
			for xml path ('')
			) JPWorkAssets
			from stngetl.SST_SupportingInfo as st4
		) as x1
	) as b on a.pmnum = b.pmnum
	left join
	(
		select x2.JOBPLAN, case when len(x2.USI) = 0 then null else left(x2.USI,len(x2.USI)-1) end as USI
		from
		(
			select distinct st6.JOBPLAN,
			(select distinct st5.USI + '; ' as [text()]
			from stngetl.General_JobPlanWorkAsset as st5
			where st5.JOBPLAN = st6.JOBPLAN
			for xml path ('')
			) USI
			from stngetl.General_JobPlanWorkAsset as st6
		) as x2
	) as c on a.JPNUM = c.JOBPLAN
	left join stng.SST_Historical_Mapping_Temp as d on a.pmnum = d.PMNUM --replaced Jeff's stng.SSTMapping_Temp
	left join 
	(
		select s.PMNUM, max(spv) as spv
		from stngetl.SST_SupportingInfo as s 
		left join 
		(
			select jobplan, case when spvflag = 'Yes' then 1 else 0 end as spv
			from stngetl.General_JobPlanWorkAsset
		) as t on s.jpnum = t.JOBPLAN
		group by s.PMNUM
	) as e on a.PMNUM = e.PMNUM
	left join
	(
		select x3.pmnum, case when len(x3.DOCNUM) = 0 then null else left(x3.DOCNUM,len(x3.DOCNUM)-1) end as DOCNUM
		from
		(
			select distinct st8.pmnum,
			(select distinct st7.docnum + '; ' as [text()]
			from stng.SST_CSDocs as st7
			where st7.pmnum = st8.pmnum and st7.isosr = 1
			for xml path ('')
			) DOCNUM
			from stng.SST_CSDocs as st8
			where st8.isosr = 1
		) as x3
	) as f on a.pmNUM = f.pmnum
	left join
	(
		select x4.JOBPLAN, case when len(x4.RSE) = 0 then null else left(x4.RSE,len(x4.RSE)-1) end as RSE
		from
		(
			select distinct st8.JOBPLAN,
			(select distinct st9.RSE + '; ' as [text()]
			from stngetl.General_JobPlanWorkAsset as st9
			where st9.JOBPLAN = st8.JOBPLAN
			for xml path ('')
			) RSE
			from stngetl.General_JobPlanWorkAsset as st8
		) as x4
	) as g on a.JPNUM = g.JOBPLAN
	left join
	(
		select x4.JOBPLAN, case when len(x4.RDE) = 0 then null else left(x4.RDE,len(x4.RDE)-1) end as RDE
		from
		(
			select distinct st10.JOBPLAN,
			(select distinct st11.RDE + '; ' as [text()]
			from stngetl.General_JobPlanWorkAsset as st11
			where st11.JOBPLAN = st10.JOBPLAN
			for xml path ('')
			) RDE
			from stngetl.General_JobPlanWorkAsset as st10
		) as x4
	) as h on a.JPNUM = h.JOBPLAN
	left join
	(
		select x5.JOBPLAN, case when len(x5.RCE) = 0 then null else left(x5.RCE,len(x5.RCE)-1) end as RCE
		from
		(
			select distinct st12.JOBPLAN,
			(select distinct st13.RCE + '; ' as [text()]
			from stngetl.General_JobPlanWorkAsset as st13
			where st13.JOBPLAN = st12.JOBPLAN
			for xml path ('')
			) RCE
			from stngetl.General_JobPlanWorkAsset as st12
		) as x5
	) as i on a.JPNUM = i.JOBPLAN
	left join
	(
		select x6.JOBPLAN, case when len(x6.STRATEGY_OWNER) = 0 then null else left(x6.STRATEGY_OWNER,len(x6.STRATEGY_OWNER)-1) end as STRATEGY_OWNER
		from
		(
			select distinct st14.JOBPLAN,
			(select distinct st15.STRATEGY_OWNER + '; ' as [text()]
			from stngetl.General_JobPlanWorkAsset as st15
			where st15.JOBPLAN = st14.JOBPLAN
			for xml path ('')
			) STRATEGY_OWNER
			from stngetl.General_JobPlanWorkAsset as st14
		) as x6
	) as j on a.JPNUM = j.JOBPLAN;

	--Create indexes
	create clustered index IX_dems_TT_0051_SSTSupportingInfo_pmnum on stng.SST_SupportingInfo(pmnum);

	create nonclustered index IX_dems_TT_0051_SSTSupportingInfo_jpnum on stng.SST_SupportingInfo(jpnum);
	
	

	--drop temp table
	IF OBJECT_ID('temp.SST_Costs','U') is not null drop table temp.SST_Costs;


	--Add AUP to SSTMaterials, calculate cost, and union to temp.SST_Costs
	select JPNUM, costtype, case when linecost is null then 0 else linecost end as linecost
	into temp.SST_Costs
	from
	(
		select a.jpnum, 'Labour' as costtype, sum(a.quantity*a.rate*a.laborhrs) as linecost
		from stngetl.SST_CostsLabour as a
		group by a.JPNUM
		union
		select a.jpnum, 'Materials' as costtype, sum(a.itemqty*a.avgcost) as linecost
		from stngetl.SST_CostsMaterials as a
		group by a.jpnum
	) as x;

	--Drop Table
	IF OBJECT_ID('stng.SST_Costs','U') is not null drop table stng.SST_Costs;

	--Insert into non-temp table
	select *
	into stng.SST_Costs
	from temp.SST_Costs;

	--Indexes
	create clustered index IX_dems_TT_0054_SSTCosts_CLUSTERED on stng.SST_Costs(JPNUM,costtype);

	--Drop temp.TT_0054
	IF OBJECT_ID('temp.SST_Costs','U') is not null drop table temp.SST_Costs;

	


	--Create stng.SST_HistoricalContentServer
	IF OBJECT_ID('temp.SSTHistoricalContentServer_1','U') is not null drop table temp.SSTHistoricalContentServer_1;

	select
	dataid,
	master_folder
	, parent_folder
	, folder
	, name
	, dcomment
	, createddate
	, created_by
	, modifydate
	, modify_by
	, max(Facility) as Facility
	, max(Rec_Type) as Rec_type
	, max(Sub_type) as sub_type
	, searchtype
	, URL_CREATE
	into temp.SSTHistoricalContentServer_1
	from
	(
		select
		dt.dataid,
		dt4.name as master_folder
		, dt3.name as parent_folder
		, dt2.name as folder
		, dt.name
		, replace(replace(replace(upper(dt.dcomment),' ',''),'-',''),'#','') as search
		, dt.dcomment
		, dt.CREATEDDATE
		, k.name as created_by
		, dt.MODIFYDATE
		, k2.name as modify_by
		, lla2.valstr as Facility
		, lla.valstr as Rec_Type
		, lla3.valstr as Sub_type
		, dt.searchtype 
		, concat('https://ecm.corp.brucepower.com/OTCS/cs.exe?func=ll&objAction=open&objID=',dt.dataid) as URL_CREATE
		from stngetl.SST_DocsMain as dt
		left join stngetl.SST_DocAttributes as lla on lla.id = dt.dataid and lla.defid = 1208238 and lla.attrid = 2
		left join stngetl.SST_DocAttributes as lla2 on lla2.id = dt.dataid and lla2.defid = 49860 and lla2.attrid = 2
		left join stngetl.SST_DocAttributes as lla3 on lla3.id = dt.dataid and lla3.defid = 1208238 and lla3.attrid = 3
		left join stngetl.SST_DTREECORE as dt2 on dt2.dataid = dt.PARENTID
		left join stngetl.SST_DTREECORE as dt3 on dt3.dataid = dt2.PARENTID
		left join stngetl.SST_DTREECORE as dt4 on dt4.dataid = dt3.parentid
		left join stngetl.SST_KUAF k on k.id = dt.CREATEDBY
		left join stngetl.SST_KUAF k2 on k2.id = dt.MODIFIEDBY	
	) as x
	where parent_folder is not null
	group by
	dataid,
	master_folder
	, parent_folder
	, folder
	, name
	, dcomment
	, createddate
	, created_by
	, modifydate
	, modify_by
	, searchtype
	, URL_CREATE;

	--Select into final stng.SSTContentServer
	IF OBJECT_ID('stng.SST_HistoricalContentServer','U') is not null drop table stng.SST_HistoricalContentServer;

	select *
	into stng.SST_HistoricalContentServer
	from temp.SSTHistoricalContentServer_1;

	create clustered index IX_dbo_SSTHistoricalContentServer_dataid on stng.SST_HistoricalContentServer(dataid);
	create nonclustered index IX_dbo_SSTHistoricalContentServer_name on stng.SST_HistoricalContentServer(name);
		
	IF OBJECT_ID('temp.SSTHistoricalContentServer_1','U') is not null drop table temp.SSTHistoricalContentServer_1;

	--Add new rows to SST_Main 
	--get pmnums in mapping table that aren't in main
	insert into stng.SST_Main(UniqueID, PM, RAD, RAB)
	SELECT newid(), A.PMNUM, stng.GetBPTime(GETDATE()), 'SYSTEM'
	FROM stng.SST_Historical_Mapping_Temp A
	LEFT JOIN stng.SST_Main B ON A.pmnum = B.PM
	WHERE B.PM IS NULL;

	--Add new rows to SST_Mapping
	--get records in temp mapping that aren't in mapping (Combination of SSTno, channel, and PM)
	--include deleted records, we don't want to overwrite the delete
	with fullrecord as
	(
		select A.UniqueID, A.PM, B.SSTNo, B.SSTChannel from stng.SST_Main A
		join stng.SST_Mapping B on A.UniqueID = B.SSTID 
	)
	INSERT INTO stng.SST_Mapping(SSTID, SSTNo, SSTChannel, RAD, RAB, LUD, LUB)
	select m.UniqueID, T.SSTNoActual, T.Channel, stng.GetBPTime(GETDATE()), 'SYSTEM', stng.GetBPTime(GETDATE()), 'SYSTEM'
	from stng.SST_Historical_Mapping_Temp T
	left join fullrecord F on F.PM = T.PMNUM and F.SSTNo = T.SSTNoActual 
	and (F.SSTChannel = T.Channel or (F.SSTChannel is null and T.Channel is null))
	left join stng.SST_Main m on m.PM = T.PMNUM
	where F.UniqueID is null;

	--Outage SSTs Separate -- descriptions are in different place
	--take query that gets pmnums and jobplantask descriptions, and extracts SST nums from those
	with Normalized as
	(
		select PMNUM,
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(DESCRIPTION, ' OR ', '/'), ' CH "', '/'), ' CH ', ''), ' + ', '/'), ', ','/'), ',', '/'), '&', '/') as cleandesc,
		UniqueID
		FROM stngetl.SST_Outage
	) 
	,
	tokentable as
	(
	SELECT PMNUM,
		   value AS Token,
		   UniqueID
	FROM Normalized
	CROSS APPLY STRING_SPLIT(cleandesc, ' ')
	WHERE value LIKE '[0-9]%.%[0-9]%[A-Z]%'
	union
	SELECT PMNUM,
		   value AS Token,
		   UniqueID
	FROM Normalized
	CROSS APPLY STRING_SPLIT(cleandesc, ' ')
	WHERE value LIKE '[0-9]%.%[0-9]'
	union
	SELECT PMNUM,
		   value AS Token,
		   UniqueID
	FROM Normalized
	CROSS APPLY STRING_SPLIT(cleandesc, ' ')
	WHERE value LIKE 'SST[0-9]%.%[0-9]%'
	union
	SELECT PMNUM,
		   value AS Token,
		   UniqueID
	FROM Normalized
	CROSS APPLY STRING_SPLIT(cleandesc, ' ')
	WHERE value LIKE 'SST#[0-9]%.%[0-9]'
	),cleanup as
	(
		select PMNUM, 
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		REPLACE(
		Token, 'SST', '')
		, 'ECI', '')
		, 'TESTING', '')
		, 'PAC', '')
		, 'SOR', '')
		, 'CA3', '')
		, 'REMOTE', '')
		, '/POISON', '')
		, '/OPS', '')
		, '(P-TRIP', '')
		, '(', '')
		, '"', '')
		,'#', '')
		,' ', '')
		--Channel ones at end, most important
		, 'KL', 'K/L')
		, 'AG', 'A/G')



		as Token,
		UniqueID from tokentable
	), removeduplicates as
	(
		SELECT 
			PMNUM,
			Token,
			MIN(UniqueID) AS UniqueID
		FROM cleanup
		GROUP BY PMNUM, Token
	)
	, splitslashes as
	(
		SELECT 
			t.PMNUM,
			t.Token,
			t.UniqueID,
			s.value AS Part,
			ROW_NUMBER() OVER (PARTITION BY t.UniqueID ORDER BY (SELECT NULL)) AS rownum
		FROM removeduplicates t
		CROSS APPLY STRING_SPLIT(t.Token, '/') s
		WHERE s.value <> ''
	), replacesinglechannels as
	(
		SELECT 
			s.PMNUM,
			s.Token,
			s.UniqueID,
			LEFT(p.Part, PATINDEX('%[A-Z]%', p.Part + 'X')-1) + s.Part as Part
		from splitslashes s
		OUTER APPLY (
			SELECT TOP 1 Part
			FROM splitslashes p
			WHERE p.UniqueID = s.UniqueID
			  AND p.rownum < s.rownum
			  AND p.Part LIKE '[0-9]%.[0-9]%'
			ORDER BY p.rownum DESC
		) p
		where s.Part LIKE '[A-Z]' 
	), alltogether as
	(
		select PMNUM, Part
		FROM replacesinglechannels
		UNION
		select PMNUM, Part
		FROM splitslashes
		where Part NOT LIKE '[A-Z]'
	)
	
	INSERT INTO stng.SST_OutageSSTs(PMNUM, SSTNo, SSTNoActual, Channel)
	SELECT
	a.PMNUM,
    Part as SSTNo,
    LEFT(Part, PATINDEX('%[A-Z]%', Part + 'X') - 1) AS SSTNoActual,
    CASE 
        WHEN PATINDEX('%[A-Z]%', Part) > 0 
        THEN RIGHT(Part, 1) 
        ELSE NULL 
    END AS Channel
	FROM alltogether a
	left join stng.SST_OutageSSTs F on F.PMNUM = a.PMNUM and F.SSTNo = a.Part
	where F.PMNUM is null;

	--Add new rows to SST_Main 
	--get pmnums in mapping table that aren't in main
	with distinctpms as
	(
		select distinct PMNUM from stng.SST_OutageSSTs
	)

	insert into stng.SST_Main(UniqueID, PM, RAD, RAB)
	SELECT newid(), A.PMNUM, stng.GetBPTime(GETDATE()), 'SYSTEM'
	FROM distinctpms A
	LEFT JOIN stng.SST_Main B ON A.pmnum = B.PM
	WHERE B.PM IS NULL;

	--Add new rows to SST_Mapping
	--get records in temp mapping that aren't in mapping (Combination of SSTno, channel, and PM)
	--include deleted records, as we don't want to overwrite the delete
	with fullrecord as
	(
		select A.UniqueID, A.PM, B.SSTNo, B.SSTChannel from stng.SST_Main A
		join stng.SST_Mapping B on A.UniqueID = B.SSTID
	) 
	INSERT INTO stng.SST_Mapping(SSTID, SSTNo, SSTChannel, RAD, RAB, LUD, LUB)
	select m.UniqueID, T.SSTNoActual, T.Channel, stng.GetBPTime(GETDATE()), 'SYSTEM', stng.GetBPTime(GETDATE()), 'SYSTEM'
	from stng.SST_OutageSSTs T
	left join fullrecord F on F.PM = T.PMNUM and F.SSTNo = T.SSTNoActual 
	and (F.SSTChannel = T.Channel or (F.SSTChannel is null and T.Channel is null))
	left join stng.SST_Main m on m.PM = T.PMNUM
	where F.UniqueID is null

	insert into stng.SST_AdditionalSSTs(SSTNoActual, PMNUM, SSTNo)
	select 'SST ' + s.SSTNoActual, s.PMNUM, 'SST ' + s.SSTNo 
	from stng.SST_OutageSSTs s
	left join stng.SST_AdditionalSSTs a on a.PMNUM = s.PMNUM and ('SST ' + s.SSTNo) = a.SSTNo
	where a.PMNUM is null

	
	--Create temp OSRs table
	IF OBJECT_ID('temp.SST_OSRs','U') is not null drop table temp.SST_OSRs;

	select distinct a.PMNUM, a.URLNAME, b.name, b.Status, b.StatusDate, b.Title
	into temp.SST_OSRs
	from stngetl.SST_PMDoc as a
	inner join stngetl.General_ControlledDoc as b on a.DOCID = b.DATAID and b.Subtype = 'OSR - OPERATIONAL SAFETY REQUIREMENT'
	inner join stng.SST_Main as c on a.PMNUM = c.PM--limits number of records, remove?
	order by a.PMNUM asc;

	--Create real OSRs table
	IF OBJECT_ID('stngetl.SST_OSR','U') is not null drop table stngetl.SST_OSR;

	select *
	into stngetl.SST_OSR
	from temp.SST_OSRs;

	create clustered index IX_TT_0112_SSTOSRs_PK on stngetl.SST_OSR(PMNUM,name);

	--Drop temp tables
	IF OBJECT_ID('temp.TT_0112_SSTOSRs','U') is not null drop table temp.TT_0112_SSTOSRs;
END


