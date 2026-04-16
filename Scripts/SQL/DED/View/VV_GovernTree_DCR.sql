ALTER view [stng].[VV_GovernTree_DCR] as
select distinct a.UniqueID as GTID, a.DocumentNo, b.TICKETID as DCR, Concat(a.UniqueID,'_',b.TICKETID ) as GTID_DCR,c.CRSTATUSDATE as DCRStatusDate,
c.CRDESC as DCRDescription, c.CRSTATUS as DCRStatus
, concat('https://prod-maximo.corp.brucepower.com/maximo/ui/maximo.jsp?event=loadapp&value=plusca&uniqueid=', d.TICKETUID) as DCRURL
from stng.GovernTree_Main as a
inner join stngetl.General_AllCR_Spec as b on a.DocumentNo = b.ALNVALUE and b.ASSETATTRID = 'DOC NUMBER'
inner join stngetl.General_AllCR as c on b.TICKETID = c.CR and c.CRCLASS like '%DCR%'
left join [stngetl].[General_CRMapping] as d on b.TICKETID = d.TICKETID
where a.Deleted = 0
GO


