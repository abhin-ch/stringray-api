CREATE OR ALTER VIEW [stng].[VV_ETL_Main]
AS
SELECT L.LogId
	,L.ETLID
	,L.RAD
	,Map.ETLName
	,C.SourceName as ETLSource
	,C.SourceDescription as SourceDescription
	,Map.ETLDescription
	,A.NameShort
	,A.Name
	,A.Description
	,A.Active
FROM stng.Common_ETLLog L
INNER JOIN stng.Common_ETLMap Map ON L.ETLID = Map.ETLID 
LEFT JOIN stng.Common_ETLModule [Mod] ON [Mod].ETLID = Map.ETLID
LEFT JOIN stng.Admin_Module A ON A.ModuleID = [Mod].ModuleID
LEFT JOIN stng.Common_ETLModuleSource S ON S.ETLID = Map.ETLID
inner JOIN stng.Common_ETLSource C ON C.SourceId = S.SourceID
GO