CREATE OR ALTER FUNCTION [stng].[FN_Budgeting_SDQ_StandardDeliverable]
(
	@SDQUID BIGINT
)
RETURNS TABLE
AS
RETURN (
	SELECT D.*,L.SDQUID FROM stng.Budgeting_SDQ_DeliverableTypeVersion D
	INNER JOIN stngetl.Budgeting_SDQ_Run R ON R.DeliverableTypeVersion = D.[Version]
	LEFT JOIN stng.Budgeting_SDQP6Link L ON L.RunID = R.RunID AND L.Active = 1
	WHERE L.SDQUID = @SDQUID
	UNION
	SELECT D.*,@SDQUID FROM stng.Budgeting_SDQ_DeliverableTypeVersion D WHERE Version = 2
	AND NOT EXISTS (SELECT D.*,L.SDQUID FROM stng.Budgeting_SDQ_DeliverableTypeVersion D
	INNER JOIN stngetl.Budgeting_SDQ_Run R ON R.DeliverableTypeVersion = D.[Version]
	LEFT JOIN stng.Budgeting_SDQP6Link L ON L.RunID = R.RunID AND L.Active = 1
	WHERE L.SDQUID = @SDQUID)
)
GO