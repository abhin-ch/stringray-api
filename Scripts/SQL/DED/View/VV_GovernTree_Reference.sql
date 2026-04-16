/****** Object:  View [stng].[VV_GovernTree_Reference]    Script Date: 4/17/2024 8:34:08 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create view [stng].[VV_GovernTree_Reference] as
select a.UniqueID, a.GTID, a.DocumentNo, b.Revision, b.Title, b.[Type], b.SubType,
concat(case when b.filetype = 'CAL' 
	then 'https://ecm.corp.brucepower.com/OTCS/cs.exe?func=brava.bravaviewer&nodeid=' 
	else 'https://ecm.corp.brucepower.com/OTCS/cs.exe?func=ll&objAction=open&objID='
end,b.DATAID) as CSLink
from stng.GovernTree_Reference as a
inner join stngetl.General_ControlledDoc as b on a.DocumentNo = b.[NAME]
GO


