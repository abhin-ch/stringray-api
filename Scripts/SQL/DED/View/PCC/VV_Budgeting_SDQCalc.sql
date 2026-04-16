/*
Author: Habib Shakibanejad
Created Date: 4 Dec 2023
Description: Used for calculating the sum of SDQ Approved amounts
*/
CREATE OR ALTER VIEW [stng].[VV_Budgeting_SDQCalc]
AS
SELECT B.SDQUID
	,CAST(B.PreviouslyApproved AS INT) PreviouslyApproved
	,CAST(B.CurrentRequest AS INT) CurrentRequest
	,CAST(B.TotalApproved AS INT) TotalApproved
	,CAST(B.TotalRemaining AS INT) TotalRemaining
	,CAST(B.RequestedScope AS INT) RequestedScope
	,CAST(B.RequestedScope - B.CurrentRequest AS INT) RequestedTrend
	,IIF(B.TotalApproved >= B.CurrentRequest,1,0) IsFullApproved
FROM (
	SELECT S.SDQUID
		,(T.TotalRemaining - S1.PreviouslyApproved) CurrentRequest
		,S1.PreviouslyApproved
		,A.TotalApproved
		,T.TotalRemaining
		,COALESCE(S.RequestedScope,T.TotalRemaining - S1.PreviouslyApproved) RequestedScope
	FROM stng.Budgeting_SDQMain S
	LEFT JOIN (
		SELECT SDQUID,SUM(CAST(A.ApprovedScope AS INT)) TotalApproved FROM stng.Budgeting_SDQCustomerApprovalDetail A
		INNER JOIN stng.Budgeting_SDQCustomerApproval B ON B.UniqueID = A.CustomerApprovalID
		GROUP BY SDQUID
	) A ON A.SDQUID = S.SDQUID
	LEFT JOIN (
		SELECT COALESCE(SUM(TotalRemaining),0) TotalRemaining,S.SDQUID
		FROM [stngetl].[VV_Budgeting_SDQ_P6_CIIOrg] S
		LEFT JOIN stng.Budgeting_SDQP6Link P ON P.SDQUID = S.SDQUID
		GROUP BY S.SDQUID,P.RunID
	) T ON T.SDQUID = S.SDQUID
	LEFT JOIN (
		SELECT SDQUID,COALESCE(PreviouslyApproved,0) PreviouslyApproved FROM stng.Budgeting_SDQMain
	) S1 ON S1.SDQUID = S.SDQUID
) B