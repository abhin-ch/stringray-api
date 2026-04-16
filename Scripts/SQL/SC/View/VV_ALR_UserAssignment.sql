CREATE OR ALTER VIEW [stng].[VV_ALR_UserAssignment]
AS
SELECT        A.*, IIF(A.WMID = 'ISS', 'ITEM', 'CR') AS Type, 
                         CASE WHEN Deliverable = 'AMLUP' THEN 'AML Update' WHEN Deliverable = 'CUSTO' THEN 'Custom' WHEN Deliverable = 'ITEME' THEN 'Item Equivalency' WHEN Deliverable = 'PBREV' THEN 'PB Review' WHEN Deliverable =
                          'PROCE' THEN 'Process' WHEN Deliverable = 'SCREE' THEN 'Screening' END AS DeliverableC
FROM            stng.ALR_DAssignment AS A
Where DeleteBy IS Null
GO