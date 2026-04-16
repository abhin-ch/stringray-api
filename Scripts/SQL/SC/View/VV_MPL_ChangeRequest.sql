CREATE OR ALTER VIEW [stng].[VV_MPL_ChangeRequest]
AS
WITH AttachmentSummary AS (
    SELECT ParentID, COUNT(UUID) AS AttachmentCount
    FROM stng.Common_FileMeta
    WHERE GroupBy = 'ChangeRequest'
    GROUP BY ParentID
)
SELECT
    A.UniqueID,
    A.RAD,
    A.ProjectNo,
    M.ProjectName,
    M.Phase,
    A.Approved,
	A.RAB as ActionByLANID,
    B.EmpName AS ActionBy,
    IIF(C.Field = 'Owners Engineering', 'Owners Engineering Lead', C.Field) AS Field,

    IIF(C.FieldShort IN ('Status', 'Phase', 'Invoice'), A.ChangeFrom, D.EmpName) AS ChangeFrom,
    IIF(C.FieldShort IN ('Status', 'Phase', 'Invoice'), A.ChangeTo, E.EmpName) AS ChangeTo,
    ISNULL(F.AttachmentCount, 0) AS AttachmentCount,

    A.ChangeFrom AS ChangeFromRaw,
    A.ChangeTo AS ChangeToRaw,
    G.ENGSMLANID,
    H.EmployeeID AS ProjectSMEmployeeID,

    CASE C.Field
        WHEN 'Project Control Specialist' THEN 'Angela Pawley'
        WHEN 'Status' THEN 'Leon Cramer'
        WHEN 'Owners Engineering' THEN H.FullName
        ELSE 'Nima Moradi'
    END AS Action_With,

    N.ndq_date,
    R.Resume_Date,
    COALESCE(N.ndq_date, R.Resume_Date) AS NDQ_ResumeDate
FROM stng.MPL_ChangeRequest A
LEFT JOIN stng.MPL_ResumeDate R ON A.UniqueID = R.FK_unique
LEFT JOIN stng.MPL_NDQDate N ON A.UniqueID = N.FK_unique
LEFT JOIN stng.VV_Admin_Users B ON B.EmployeeID = A.RAB
LEFT JOIN stng.MPL_Field C ON C.UniqueID = A.FieldID
LEFT JOIN stng.VV_Admin_Users D ON D.EmployeeID = A.ChangeFrom
LEFT JOIN stng.VV_Admin_Users E ON E.EmployeeID = A.ChangeTo
LEFT JOIN AttachmentSummary F ON A.UniqueID = F.ParentID
LEFT JOIN stng.VV_MPL_AllProjectData G ON G.ProjectID = A.ProjectNo
LEFT JOIN stng.Admin_User H ON G.ENGSMLANID = H.LANID
LEFT JOIN stng.VV_MPL_ENG M ON M.SharedProjectID = A.ProjectNo
GO


