/*
Author: Habib Shakibanejad
Description: Scope details used for the global search
CreatedDate: 12 July 2023
*/
CREATE OR ALTER VIEW [stng].[VV_ETDB_ScopeDetails]
AS 
SELECT S.SheetID
	,(SELECT STRING_AGG(CONVERT(NVARCHAR(max),D.Number),',')  FROM stng.ETDB_ScopeDetail D WHERE D.SheetID = S.SheetID) AS 'ItemNumber'
	,(SELECT STRING_AGG(CONVERT(NVARCHAR(max),D.Description),',') FROM stng.ETDB_ScopeDetail D WHERE D.SheetID = S.SheetID) AS 'ItemDescription'
	,(SELECT STRING_AGG(CONVERT(NVARCHAR(max),C.Body),',') FROM stng.Common_Comment C WHERE C.RelatedID = S.SheetID) AS 'ItemComment'
FROM stng.ETDB_ScopingSheet S
GO