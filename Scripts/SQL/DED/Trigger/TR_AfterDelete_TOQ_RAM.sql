
CREATE TRIGGER [stng].[TR_AfterDelete_TOQ_RAM]
ON [stng].[TOQ_Main]
AFTER DELETE
AS
BEGIN
    DELETE FROM [stng].[TOQ_RAM_AllFields]
    WHERE [TOQMainID] IN (SELECT [UniqueID] FROM deleted);

	DELETE FROM [stng].[TOQ_RAM_BudgetForm_BudgetSummary]
    WHERE TOQMainID IN (SELECT d.UniqueID FROM deleted d);

END;
GO

ALTER TABLE [stng].[TOQ_Main] ENABLE TRIGGER [TR_AfterDelete_TOQ_RAM]
GO


