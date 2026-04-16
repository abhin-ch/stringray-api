CREATE OR ALTER view [stng].[VV_Budgeting_SDQExecutionView] AS
    SELECT a.UniqueID
    ,a.SDQUID
    ,a.Execution ExecutionID
    ,b.Label Execution
    ,b.Value ExecutionValue
FROM stng.Budgeting_SDQExecution as a
INNER JOIN stng.Common_ValueLabel as b on a.Execution = b.UniqueID
