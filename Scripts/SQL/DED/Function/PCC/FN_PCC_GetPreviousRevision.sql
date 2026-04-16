CREATE OR ALTER FUNCTION stng.FN_PCC_GetPreviousRevision
(
	@SDQUID INT
)
RETURNS TABLE

RETURN (
	WITH sdq AS
	(
		SELECT SDQUID,ProjectNo,B.Phase FROM stng.Budgeting_SDQMain A
		inner join stng.Budgeting_SDQ_Phase as B on B.SDQPhaseID = A.Phase
		WHERE SDQUID = @SDQUID
	),
	previous as 
	(
		select a.ProjectNo, a.SDQUID, b.Phase, a.Revision, c.SDQStatus
		,ROW_NUMBER() OVER (PARTITION BY A.ProjectNo,B.Phase ORDER BY A.Revision DESC) RN
		from stng.Budgeting_SDQMain as a
		inner join stng.Budgeting_SDQ_Phase as b on a.Phase = b.SDQPhaseID
		inner join stng.Budgeting_SDQ_Status as c on a.StatusID = c.SDQStatusID
		where c.SDQStatus not in ('CANC') and a.DeleteRecord = 0
	)
	SELECT P.ProjectNo,S.SDQUID,P.SDQUID PrevRevSDQUID,P.SDQStatus PrevSDQStatus,P.Phase,P.Revision PrevRevision
	FROM previous P
	INNER JOIN sdq S ON S.ProjectNo = P.ProjectNo AND S.Phase = P.Phase
	WHERE Revision = (SELECT Revision - 1 FROM stng.Budgeting_SDQMain WHERE SDQUID = @SDQUID)
	AND SDQStatus IN ('AFRE','APRE')
)
