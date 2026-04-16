/****** Object:  View [stng].[VV_GovernTree_Form]    Script Date: 4/17/2024 8:29:34 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create view [stng].[VV_GovernTree_Form] as
select a.UniqueID, a.GTID, a.FormNo, b.Revision, b.Title, b.[Type], b.SubType,
concat(case when b.filetype = 'CAL' 
	then 'https://ecm.corp.brucepower.com/OTCS/cs.exe?func=brava.bravaviewer&nodeid=' 
	else 'https://ecm.corp.brucepower.com/OTCS/cs.exe?func=ll&objAction=open&objID='
end,b.DATAID) as CSLink
from stng.GovernTree_Form as a
inner join stngetl.General_ControlledDoc as b on a.FormNo = b.[NAME]
GO


