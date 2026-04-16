create or ALTER VIEW [stng].[VV_MPL_ChangeRequestwithEmails] AS

-- CTE: Resolve LANIDs with fallback logic using COALESCE
WITH lanid AS (
    SELECT 
        [ProjectID],
        COALESCE(ProjectManagerLANID, ENGProjectManagerLANID, CSProjectManagerLANID) AS ProjectManagerLANID,
        COALESCE(ProjectPlannerLANID, ENGProjectPlannerLANID, CSProjectPlannerLANID) AS ProjectPlannerLANID,
        COALESCE(PCSLANID, ENGPCSLANID, CSPCSLANID) AS PCSLANID,
        COALESCE(OwnersEngineerLANID, ENGOwnersEngineerLANID, CSProjectPlannerLANID) AS OwnersEngineerLANID,
        ENGDMLANID
    FROM [stng].[VV_MPL_AllProjectData]
),

-- CTE: Change Request Data
changerequest AS (
    SELECT 
        [ProjectNo],
        [ProjectName],
        [Approved],
        [UniqueID],
        [ActionBy],
        [Field],
        [ChangeFrom],
        [ChangeTo],
        [ENGSMLANID],
        [rad],
        [ndq_daTE],
        [resume_date]
    FROM [stng].[VV_MPL_ChangeRequest]
)

-- Final SELECT: Join all relevant data
SELECT 
    cr.[ProjectNo],
    cr.[ProjectName],
    cr.[Approved],
    cr.[UniqueID],
    cr.[ActionBy],
    cr.[Field],
    cr.[ChangeFrom],
    cr.[ChangeTo],
    cr.[ndq_daTE] AS NDQ_DATE,
    cr.[resume_date] AS Resume_Date,
    cr.[ENGSMLANID],

    -- LANID fields
    l.ProjectManagerLANID,
    l.ProjectPlannerLANID,
    l.PCSLANID,
    l.OwnersEngineerLANID,
    l.ENGDMLANID,

    -- ENGSM info
    engsm.FirstName AS ENGSM,
    engsm.Email AS ENGSMEmail,

    -- Emails for roles
    pm.Email AS ProjectManagerEmail,
    pp.Email AS ProjectPlannerEmail,
    pcs.Email AS PCSEmail,
    oe.Email AS OEEmail,
    dm.Email AS DMEmail,
    ab.Email AS ActionByEmail,

    -- Comment
    cc.Body AS Comment,cr.RAD

FROM changerequest cr
LEFT JOIN lanid l ON cr.ProjectNo = l.ProjectID
LEFT JOIN [stng].[Admin_User] engsm ON cr.ENGSMLANID = engsm.LANID
LEFT JOIN [stng].[Admin_User] pm ON l.ProjectManagerLANID = pm.LANID
LEFT JOIN [stng].[Admin_User] pp ON l.ProjectPlannerLANID = pp.LANID
LEFT JOIN [stng].[Admin_User] pcs ON l.PCSLANID = pcs.LANID
LEFT JOIN [stng].[Admin_User] oe ON l.OwnersEngineerLANID = oe.LANID
LEFT JOIN [stng].[Admin_User] dm ON l.ENGDMLANID = dm.LANID
LEFT JOIN [stng].[VV_Admin_Users] ab ON ab.EmpName = cr.ActionBy
LEFT JOIN [stng].[VV_MPL_StatusLog] sl ON sl.ProjectUpdateID =CAST(cr.UniqueID AS NVARCHAR(MAX))
LEFT JOIN [stng].[Common_Comment] cc ON CAST(sl.UniqueID AS NVARCHAR(MAX)) = cc.ParentID
GO


