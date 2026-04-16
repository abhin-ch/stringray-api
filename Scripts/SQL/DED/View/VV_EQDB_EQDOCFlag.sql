CREATE or ALTER view [stng].[VV_EQDB_EQDOCFlag] as

with EQDOC as (
	select distinct
	a.Location
	, a.Facility
	,cast(case when a.FACILITY = 'BA' and c.DOCNAME is not null then 1 else 0 end as bit) as BADocLink
	, cast(case when a.FACILITY = 'BB' and d.DOCNAME is not null then 1 else 0 end as bit) as BBEQAEQSDocLink
	, cast(case when a.FACILITY = 'BB' and e.DOCNAME is not null then 1 else 0 end as bit) as BBEQRDocLink
	, cast(case when a.FACILITY = 'BB' and d.DOCNAME is not null and e.DOCNAME is not null then 1 else 0 end as bit) as BBDocLink
	,case when (a.FACILITY = 'BA' and c.DOCNAME is not null)
	or (a.FACILITY = 'BB' and d.DOCNAME is not null and e.DOCNAME is not null) then 1 else 0 end as EQDOCCHECK
	from stngetl.EQDB_IndexInfo as a
	left join stngetl.EQDB_IndexLocationDocs as c on a.LOCATION = c.LOCATION and a.FACILITY = c.FACILITY and c.DocType in ('EQD')
	left join stngetl.EQDB_IndexLocationDocs as d on a.LOCATION = d.LOCATION and a.FACILITY = d.FACILITY and d.DocType in ('EQA','EQS')
	left join stngetl.EQDB_IndexLocationDocs as e on a.LOCATION = e.LOCATION and a.FACILITY = e.FACILITY and e.DocType in ('EQR')
)

select *
, case 
	when EQDOCCHECK = 0
		then case 
			when FACILITY = 'BA' or FACILITY = 'BB' then concat('Since the Site ID is ', FACILITY) + char(13) + char(10)
				+ 
				case 
					when FACILITY = 'BA'
						then 
							case 
								when BADocLink = 0 then 'An EQD needs to be linked to Bruce A Equipment' + char(13) + char(10)
								else ''
							end
					when FACILITY = 'BB' 
						then 
							case 
								when BBEQAEQSDocLink = 0 then 'Either an EQA or EQS needs to be linked to Bruce B Equipment' + char(13) + char(10)
								else ''
							end
							+
							case 
								when BBEQRDocLink = 0 then 'An EQR needs to be linked to Bruce B Equipment' + char(13) + char(10)
								else ''
							end
				end
			
			else 'No Site ID' + char(13) + char(10)
		end

	else null
end as FailureMessage
from EQDOC
