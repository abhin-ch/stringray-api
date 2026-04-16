CREATE OR ALTER VIEW stng.VV_Common_ValueLabel
AS 
SELECT C.UniqueID
	,C.[Group]
	,C.Field
	,C.Label
	,C.Value
	,C.Value1
	,C.Value2
	,C.Value3
	,C.Sort
	,C.Active
	,M.NameShort Module FROM stng.Common_ValueLabel C
INNER JOIN stng.Admin_Module M ON M.UniqueID = C.ModuleID