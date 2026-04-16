/****** Object:  StoredProcedure [stng].[SP_TOQ_NewRevision]    Script Date: 11/13/2025 12:27:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





ALTER   PROCEDURE [stng].[SP_TOQ_NewRevision]
(
	@TOQMainID NVARCHAR(255),
	@EmployeeID NVARCHAR(20)
) AS
BEGIN
	
DECLARE @UniqueID UNIQUEIDENTIFIER
DECLARE @TMID BIGINT
DECLARE @StatusID NVARCHAR(255)
DECLARE @TOQType NVARCHAR(255)

SET @TMID = NEXT VALUE FOR TOQ_ID;
SET @UniqueID = NEWID()
SET @TOQType = (SELECT T.TypeValue FROM stng.VV_TOQ_Main T WHERE T.UniqueID = @TOQMainID)
SET @StatusID = (SELECT StatusID FROM stng.VV_TOQ_Status T WHERE T.Value = 'INIT' AND Type = @TOQType)
                
/*Copy and paste all info from old TOQ*/
INSERT INTO stng.TOQ_Main(UniqueID
,[BPTOQID]
,[Rev]
,[RequestFrom]
,[StatusID]
,[StatusDate]
,[Title]
,[TDSNo]
,[Project]
,[InternalID]
,[VendorSubmissionDate]
,[VendorClarificationDate]
,[EBSRoutingOption]
,[DeleteRecord]
,[DeleteBy]
,[DeleteDate]
,[CreatedDate]
,[CreatedBy]
,[PPSD]
,[ContractType]
,[Resource]
,[ScopeOfWork]
,[ParentUniqueID]
,[TypeID]
,[ScopeManagedBy]
,[Customer]
,[VendorWorkTypeID]
,[WorkTypeID]
,[VendorStartDate]
,[TMID]
,[EmergentID]
,[VendorSubWorkTypeID]
,[LinkedSDQ]
)
SELECT @UniqueID 
    ,[BPTOQID]
    ,[Rev] + 1 -- Rev
    ,@EmployeeID -- RequestFrom
    ,@StatusID
    ,[StatusDate]
    ,[Title]
    ,[TDSNo]
    --,[Comment]
    ,[Project]
    ,[InternalID]
    ,(
        CAST(CONVERT(VARCHAR(10), (
            SELECT MIN([Date]) -- VendorSubmissionDate
            FROM (
                SELECT [Date]
                FROM [stng].[Common_WorkDate]
                WHERE [IsWorkday] = 1 AND [Date] > stng.GetDate()
                ORDER BY [Date]
                OFFSET 9 ROWS FETCH NEXT 1 ROW ONLY -- 10th business day
            ) AS WorkDate
        ), 120) + ' 23:59:00' AS DATETIME)
    ),
    (
        CAST(CONVERT(VARCHAR(10), (
            SELECT MIN([Date]) -- VendorClarificationDate
            FROM (
                SELECT [Date]
                FROM [stng].[Common_WorkDate]
                WHERE [IsWorkday] = 1 AND [Date] > stng.GetDate()
                ORDER BY [Date]
                OFFSET 4 ROWS FETCH NEXT 1 ROW ONLY -- 5th business day
            ) AS WorkDate
        ), 120) + ' 23:59:00' AS DATETIME)
    )
    ,[EBSRoutingOption]
    ,[DeleteRecord]
    ,[DeleteBy]
    ,[DeleteDate]
    ,stng.GetDate() [CreatedDate]
    ,@EmployeeID [CreatedBy]
    ,[PPSD]
    ,[ContractType]
    ,[Resource]
    ,[ScopeOfWork]
    ,[ParentUniqueID]
    ,[TypeID]
    ,[ScopeManagedBy]
    ,[Customer]
    ,[VendorWorkTypeID]
    ,[WorkTypeID]
    ,[VendorStartDate]
    ,@TMID -- [TMID]
    ,[EmergentID]
    ,[VendorSubWorkTypeID]
    ,[LinkedSDQ]
FROM [stng].[TOQ_Main]
WHERE UniqueID = @TOQMainID

-- Insert Status Log
INSERT INTO stng.TOQ_StatusLog(TOQMainID,TOQStatusID,CreatedBy,CreatedDate,Comment)
VALUES (@UniqueID,@StatusID,@EmployeeID,stng.GetDate(),'New Revision')

-- Akash = DivM, Leon = DMEP
INSERT INTO stng.MPL_Override(RecordUniqueID,DivM,DMEP,RecordType,Project,PCS,OE,SM) 
SELECT @UniqueID,DivM,DMEP,'TOQ',Project,PCS,OE,SM FROM stng.MPL_Override WHERE RecordUniqueID = @TOQMainID

--Add Ram All Fields
INSERT INTO [stng].[TOQ_RAM_AllFields](TOQMainID) Values (@UniqueID)

--Add Ram All Fields
INSERT INTO [stng].[TOQ_RAM_BudgetForm_BudgetSummary](TOQMainID) Values (@UniqueID)

--Add BAND
INSERT INTO stng.TOQ_Band(TOQMainID) VALUES (@UniqueID)

-- Update ParentTMID for MD Consulting, OE/ADE, ER, General
UPDATE T SET 
ParentUniqueID = @UniqueID
FROM stng.TOQ_Main T
INNER JOIN stng.VV_TOQ_Common V ON V.UniqueID = T.TypeID
WHERE T.UniqueID = @UniqueID AND V.Value IN ('MDCC','STDOE','MDER','MDGEN','MDSECC') 

-- Update OE as Clarissa. this is for mainly for legacy data. OE is most likely be other person so we want to set it as Clarissa.
--UPDATE dems.TT_0109_TOQMain
--SET OE = 'REIDCG'
--WHERE TMID = @TMIDReturn AND (TOQType = 2 OR TOQType = 6 OR TOQType = 7 OR TOQType = 8 OR TOQType = 11) AND PartialEmergent = ''                  

 --Copy and paste TOQ vendor info
/*Revision*/
/*Assign Vendors*/
DECLARE @VendorAssignedID NVARCHAR(255);

SET @VendorAssignedID = NEWID()

INSERT INTO stng.TOQ_VendorAssigned(
	UniqueID,
	TOQMainID, 
	VSS, 
	TOQNumber, 
	ProjectManager, 
	Location, 
	Email,
	Phone,
	TOQStartDate, 
	TOQEndDate, 
	ContractNumber, 
	VendorTOQTitle, 
	CreatedDate,
	CreatedBy,
	VendorID,
	Awarded
)
SELECT
	@VendorAssignedID
	,@UniqueID
	,VSS
	,TOQNumber
	,ProjectManager
	,Location
	,Email
	,Phone
	,TOQStartDate
	,TOQEndDate
	,ContractNumber
	,VendorTOQTitle
	,stng.GetDate()
	,@EmployeeID
	,VendorID
	,Awarded
FROM stng.TOQ_VendorAssigned 
WHERE TOQMainID = @TOQMainID AND Awarded = 1


INSERT INTO stng.TOQ_CostSummary(
    [VendorAssignedID]
    ,[DeliverableCode]
    ,[DeliverableTitle]
    ,[TotalHour]
    ,[TotalCost]
    ,[DeliverableStartDate]
    ,[DeliverableEndDate]
    ,[NewTOQCommitmentDate]
    ,[CurrentTOQCommitmentDate]
    ,[PriorTOQCommitmentDate]
    ,[OriginalTOQCommitmentDate]
    ,[PartialOverride]
    ,[DeliverableAccount]
	,[IsFromRevision]
    ,[CreatedDate]
    ,[CreatedBy]
	,UpdatedBy
	,UpdateDate
)
SELECT @VendorAssignedID
    ,[DeliverableCode]
    ,[DeliverableTitle]
    ,[TotalHour]
    ,[TotalCost]
    ,[DeliverableStartDate]
    ,[DeliverableEndDate]
    ,[NewTOQCommitmentDate]
    ,[CurrentTOQCommitmentDate]
    ,[PriorTOQCommitmentDate]
    ,[OriginalTOQCommitmentDate]
    ,[PartialOverride]
    ,[DeliverableAccount]
	,1 [IsFromRevision]
    ,stng.GetDate() [CreatedDate]
    ,@EmployeeID [CreatedBy]
	,@EmployeeID UpdatedBy
	,stng.GetDate() UpdatedDate
FROM stng.TOQ_CostSummary C 
INNER JOIN stng.TOQ_VendorAssigned V ON V.UniqueID = C.VendorAssignedID
WHERE TOQMainID = @TOQMainID AND Awarded = 1;

INSERT INTO stng.TOQ_VendorStatusLog(VendorAssignedID,StatusID,Comment,CreatedBy)
VALUES (@VendorAssignedID,(SELECT [StatusID] FROM [stng].[VV_TOQ_VendorSubmissionStatus] WHERE Value = 'NOTSUB'),'System initialized','SYSTEM')

INSERT INTO stng.TOQ_RAM_Revision
(
	[TOQMainID]
    ,[CreatedBy]
)
VALUES (@UniqueID, @EmployeeID)

INSERT INTO stng.TOQ_QAProgram(TOQ_MainID,QAProgramID) 
SELECT @UniqueID, A.QAProgramID FROM stng.TOQ_QAProgram A WHERE A.TOQ_MainID = @TOQMainID

--Update current cost summary with new ID
--UPDATE stng.TOQ_CostSummary
--SET TAVID = @TAVIDReturn,
--PartialEmergentReleasedAmount = 0
--WHERE TAVID = @PreviousAwardVendor   


/*
--Copy 0715 record to its table if duplicate value = 0. (FIRST revision)

INSERT INTO dems.TT_0715_TOQEmergentLink (TAVID, PEID, Project, VENID, Rev, RAD, RAB, Duplicate, BPTOQID)
SELECT @TAVIDReturn, PEID, Project, VENID, @RevCurrentTMID, GETDATE(), @CurrentUser, 1, BPTOQID 
FROM dems.TT_0715_TOQEmergentLink WHERE TAVID = @PreviousAwardVendor AND Duplicate = 0                                                          

INSERT INTO dems.TT_0715_TOQEmergentLink (TAVID, PEID, Project, VENID, Rev, RAD, RAB, Duplicate, BPTOQID)
SELECT DISTINCT @TAVIDReturn, B.PEID, B.Project, B.VENID, @RevCurrentTMID, GETDATE(), @CurrentUser, 1, B.BPTOQID FROM dems.TT_0715_TOQEmergentLink AS B LEFT OUTER JOIN  dems.VV_0688_TOQEmergentPartialRelease AS A ON B.PEID = A.PEID                     
WHERE A.[Type]= 'E' AND A.DeleteRecord = 0 AND A.VENID = @VENID AND A.Project = @Project AND A.[Status] IN ('AAC') AND B.TAVID IS NULL AND B.Duplicate = 1 AND B.BPTOQID = @BPTOQID0 AND (B.Rev = @LastApprovedRev)

*/


END
