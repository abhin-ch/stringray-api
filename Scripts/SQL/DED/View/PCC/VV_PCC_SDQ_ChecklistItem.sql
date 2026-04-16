CREATE OR ALTER VIEW [stng].[VV_PCC_SDQ_ChecklistItem]
AS
SELECT A.UniqueID ChecklistItemID	
	,A.ChecklistID
	,A.QuestionID
	,B.SDQUID
	,ROW_NUMBER() OVER (PARTITION BY A.ChecklistID ORDER BY C.Value1,Label ASC) InternalID
	,C.Label Question
	,C.Value1 Category
	,CAST(IIF(A.Answer = 'Yes', 1,0) AS BIT) Yes
	,CAST(IIF(A.Answer = 'No', 1,0) AS BIT) [No]
	,CAST(IIF(A.Answer = 'NA', 1,0) AS BIT) [NA]
	,A.Comment
	,A.SupportData
	,B.CreatedBy
	,B.CreatedDate
	,B.[Current]
	,B.P6LinkID
FROM stng.PCC_SDQ_ChecklistItem A
INNER JOIN stng.PCC_SDQ_Checklist B ON B.UniqueID = A.ChecklistID
INNER JOIN stng.VV_Budgeting_SDQCommon C ON C.UniqueID = A.QuestionID