CREATE view [stng].[VV_EQDB_IndexLocationDocs] as
select distinct a.[LOCATION]
      ,a.[FACILITY]
      ,a.[DOCNAME]
      ,a.[DocType]
	  ,b.Revision
	  ,case when b.Status = 'ISSUED' then b.StatusDate end as IssueDate
	  ,case 
		  when b.filetype = 'CAL' then
			CONCAT('https://ecm.corp.brucepower.com/OTCS/cs.exe?func=brava.bravaviewer&nodeid=', trim(str(b.dataid))) 
		  when b.DATAID is not NULL then
			CONCAT('https://ecm.corp.brucepower.com/OTCS/cs.exe?func=ll&objAction=open&objID=', trim(str(b.dataid))) 
		  else 
			NULL
	   end as CSLink
from stngetl.EQDB_IndexLocationDocs as a
left join stngetl.General_ControlledDoc as b on a.DOCNAME = b.NAME

GO


