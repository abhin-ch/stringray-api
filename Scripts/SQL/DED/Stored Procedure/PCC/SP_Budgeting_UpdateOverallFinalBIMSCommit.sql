CREATE OR ALTER PROCEDURE [stng].[SP_Budgeting_UpdateOverallFinalBIMSCommit]
    @SDQID bigint,
    @OverallFinalBIMSCommit DECIMAL(18,2),
    @EmployeeID VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    -- Step 1 Get deliverables for this run
    ;WITH Deliverables AS (
        SELECT 
            RunID,
            DeliverableType,
            wbs_code,
            BIMSEstimate,
            FinalBIMSCommit
        FROM [stngetl].[VV_Budgeting_SDQ_P6_CIIDeliverable_MatView]
        WHERE SDQUID = @SDQID
    ),

    -- Step 2 Calculate initial savings per row
    Savings AS (
        SELECT *,
               (FinalBIMSCommit - BIMSEstimate) AS InitialSavings
        FROM Deliverables
    ),

    -- Step 3 Calculate totals across all rows
    Totals AS (
        SELECT 
            SUM(InitialSavings) AS TotalInitialSavings,
            SUM(FinalBIMSCommit) AS TotalFinalBIMSCommit
        FROM Savings
    ),

	-- Step 4 Compute adjusted FinalBIMSCommit per row
	Adjusted AS (
		SELECT 
			s.RunID,
			s.DeliverableType,
			s.wbs_code,
			s.FinalBIMSCommit,
			-- proportion of this row’s savings
			CAST(s.InitialSavings AS DECIMAL(18,6)) / NULLIF(t.TotalInitialSavings,0) AS Portion,
			-- additional savings distributed proportionally
			(CAST(s.InitialSavings AS DECIMAL(18,6)) / NULLIF(t.TotalInitialSavings,0)) 
				* (t.TotalFinalBIMSCommit - @OverallFinalBIMSCommit) AS AdditionalSavings,
			-- NewFinalBIMSCommit = FinalBIMSCommit - AdditionalSavings
			-- Clamp at zero and round to 2 decimals
			ROUND(
				CASE 
					WHEN s.FinalBIMSCommit - (
						(CAST(s.InitialSavings AS DECIMAL(18,6)) / NULLIF(t.TotalInitialSavings,0)) 
						* (t.TotalFinalBIMSCommit - @OverallFinalBIMSCommit)
					) < 0 
					THEN 0 
					ELSE s.FinalBIMSCommit - (
						(CAST(s.InitialSavings AS DECIMAL(18,6)) / NULLIF(t.TotalInitialSavings,0)) 
						* (t.TotalFinalBIMSCommit - @OverallFinalBIMSCommit)
					)
				END, 2
			) AS AdjustedFinalBIMSCommit
		FROM Savings s
		CROSS JOIN Totals t
	)

    -- Step 5 Upsert adjusted values into the mapping table
    MERGE [stng].[Budgeting_SDQ_FinalBIMSCommitMap] AS target
    USING Adjusted AS source
        ON target.RunID = source.RunID
       AND target.DeliverableType = source.DeliverableType
       AND target.WBSCode = source.wbs_code
    WHEN MATCHED THEN
        UPDATE SET FinalBIMSCommit = source.AdjustedFinalBIMSCommit,
                   UpdatedBy = @EmployeeID,
                   UpdateDate = GETDATE()
    WHEN NOT MATCHED THEN
        INSERT (RunID, DeliverableType, WBSCode, FinalBIMSCommit, UpdatedBy, UpdateDate)
        VALUES (source.RunID, source.DeliverableType, source.wbs_code, source.AdjustedFinalBIMSCommit, @EmployeeID, GETDATE());
END
