/*
Author: Habib Shakibanejad
Description: Designed to generate SDQ Revision number.If there are already SDQs in the selected Phase and Project, then the Revision number
will increment
Created Date: 23 Sept 2023
*/
CREATE OR ALTER TRIGGER [stng].[TR_Budgeting_SDQGenerateRev]
ON [stng].[Budgeting_SDQMain] 
AFTER INSERT
AS
BEGIN
    DECLARE @NextRev INT
	DECLARE @PreviousSDQUID BIGINT
	DECLARE @SDQUID BIGINT

    -- Find the maximum Rev number for the same Project and Phase
    SELECT @NextRev = IIF(COUNT(*)=1,0,MAX(Revision)+1) FROM stng.Budgeting_SDQMain 
    WHERE ProjectNo = (SELECT ProjectNo FROM INSERTED)
    AND Phase = (SELECT Phase FROM INSERTED)
	GROUP BY ProjectNo,Phase

    -- Set the new Rev number for the INSERTed record
    UPDATE stng.Budgeting_SDQMain 
    SET Revision = @NextRev
    FROM INSERTED
    WHERE stng.Budgeting_SDQMain.SDQUID = Inserted.SDQUID

	/*Update SDQ Revision*/
	UPDATE A 
    SET 
      A.[FundingSource] = B.FundingSource
      ,A.[BusinessDriver] = B.BusinessDriver
      ,A.[Verifier] = B.Verifier
      ,A.[TargetDMApprovalDate] = B.TargetDMApprovalDate
      ,A.[TargetExecutionWindow] = B.TargetExecutionWindow
      ,A.[Complexity] = B.Complexity
      ,A.[ProblemStatement] = B.ProblemStatement
      ,A.[ProblemStatementLong] = B.ProblemStatementLong
      ,A.[CurrentScopeDefinition] = B.CurrentScopeDefinition
      ,A.[CurrentScopeDefinitionLong] = B.CurrentScopeDefinitionLong
      ,A.[Assumption] = B.Assumption
      ,A.[AssumptionLong] = B.AssumptionLong
      ,A.[Risk] = B.Risk
      ,A.[RiskLong] = B.RiskLong
      ,A.[VarianceComment] = B.VarianceComment
      --,A.[PreviouslyApproved]
      --,A.[RequestedScope] = B.RequestedScope
      ,A.[NoTOQFunding] = B.NoTOQFunding
      --,A.[IsStatusValid] =
    FROM stng.Budgeting_SDQMain A
	INNER JOIN inserted I ON I.SDQUID = A.SDQUID
	CROSS APPLY (SELECT * FROM stng.Budgeting_SDQMain WHERE Revision = A.Revision - 1 AND Phase = I.Phase AND ProjectNo = I.ProjectNo) B
    WHERE B.SDQUID IS NOT NULL

	/*Get previous SDQUID */
	SET @PreviousSDQUID = (SELECT A.SDQUID FROM stng.Budgeting_SDQMain A
		INNER JOIN inserted I ON I.Revision = A.Revision - 1 AND I.Phase = A.Phase AND I.ProjectNo = A.ProjectNo)
	
	SET @SDQUID = (SELECT I.SDQUID FROM inserted I)

	INSERT INTO stng.MPL_Override(RecordType,RecordUniqueID,DM,DMEP,OE,PCS,Planner,ProgM,ProjM,SM,Project)
	SELECT RecordType,@SDQUID,DM,DMEP,OE,PCS,Planner,ProgM,ProjM,SM,Project
	FROM stng.MPL_Override M
	WHERE M.RecordUniqueID = @PreviousSDQUID
	AND M.RecordType = 'SDQ'

	INSERT INTO stng.Budgeting_SDQExecution(SDQUID,Execution,CreatedBy)
	SELECT I.SDQUID,E.Execution,I.RAB FROM inserted I
	CROSS APPLY (SELECT * FROM stng.Budgeting_SDQExecution S WHERE S.SDQUID = @PreviousSDQUID) E

	INSERT INTO stng.Budgeting_SDQUnit(SDQUID,Unit,CreatedBy)
	SELECT I.SDQUID,U.Unit,I.RAB FROM inserted I
	CROSS APPLY (SELECT * FROM stng.Budgeting_SDQUnit S WHERE S.SDQUID = @PreviousSDQUID) U
END;