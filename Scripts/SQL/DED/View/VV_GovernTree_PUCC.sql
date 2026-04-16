/****** Object:  View [stng].[VV_GovernTree_PUCC]    Script Date: 4/17/2024 8:33:49 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE view [stng].[VV_GovernTree_PUCC] as
select a.UniqueID as GTID, b.ProcNum, b.ProcRev, b.PUCCID, b.PUCCStatus, b.Requester, b.EC, b.Approver,
b.NewDueDate, b.OriginDate, Concat(a.UniqueID,'_',b.PUCCID,'_',b.EC ) as GTID_PUCC
from stng.GovernTree_Main as a
inner join stngetl.General_PUCC as b on a.DocumentNo = b.ProcNum
where a.Deleted = 0
GO


