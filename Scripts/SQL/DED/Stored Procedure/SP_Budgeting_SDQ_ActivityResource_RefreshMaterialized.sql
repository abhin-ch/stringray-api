CREATE OR ALTER PROCEDURE [stngetl].[SP_Budgeting_SDQ_ActivityResource_RefreshMaterialized]
AS
BEGIN
    SET NOCOUNT ON;

    ---------------------------------------------------------------------
    -- 1. Clear the materialized table
    ---------------------------------------------------------------------
    TRUNCATE TABLE stngetl.Budgeting_SDQ_P6_ActivityResource_Materialized;

    ---------------------------------------------------------------------
    -- 2. Reload from the view
    ---------------------------------------------------------------------
    INSERT INTO stngetl.Budgeting_SDQ_P6_ActivityResource_Materialized
    (
        RunID, Task_ID, RoleName, Baseline,
        LabourRemainingCost, LabourRemainingUnits, LabourActualCost, LabourActualUnits,
        NonLabourRemainingCost, NonLabourRemainingUnits, NonLabourActualCost, NonLabourActualUnits,
        SunkCost, RemainingCost, RequestCost, BLBudgetedCost
    )
    SELECT
        RunID, Task_ID, RoleName, Baseline,
        LabourRemainingCost, LabourRemainingUnits, LabourActualCost, LabourActualUnits,
        NonLabourRemainingCost, NonLabourRemainingUnits, NonLabourActualCost, NonLabourActualUnits,
        SunkCost, RemainingCost, RequestCost, BLBudgetedCost
    FROM stngetl.VV_Budgeting_P6_ActivityResource;
END;