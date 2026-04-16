CREATE OR ALTER view [stng].[VV_TOQ_Main_Child] as

WITH VV_TOQ_Main_light AS (
    -- Mini version of VV_TOQ_Main to improve performance
    SELECT
        t.UniqueID,
        vss.UniqueID AS VendorAwardID, 
        m.PCSID,
        m.PCS,
        m.OEID,
        m.OE,
        m.SMID,
        m.SM,
        m.DMEPID,
        m.DMEP,
        m.DivM,
        m.DivMID
    FROM stng.TOQ_Main t
    LEFT JOIN stng.VV_TOQ_VendorSubmission vss ON vss.TOQMainID = t.UniqueID AND vss.Awarded = 1
    LEFT JOIN stng.VV_MPL_RecordPersonnel m ON m.RecordUniqueID = t.UniqueID AND m.RecordType = 'TOQ'
    WHERE t.DeleteRecord = 0
)
SELECT 
    tc.ParentTOQID,
    a.[UniqueID],
    a.[TMID],
    a.[BPTOQID],
    a.[RequestFrom],
    a.[RequestFromName],
    a.[StatusID],
    a.[StatusDate],
    a.[Project],
    a.[VendorSubmissionDate],
    a.[VendorClarificationDate],
    a.[ScopeOfWork],
    a.[TypeID],
    p.[VendorAwardID],
    a.[VendorWorkTypeID],
    a.[Status],
    a.[StatusValue],
    a.[VendorWorkType],
    a.[Type],
    a.[TypeValue],
    p.[PCSID],
    p.[PCS],
    p.[OEID],
    p.[OE],
    p.[SMID],
    p.[SM],
    p.[DMEPID],
    p.[DMEP],
    p.[DivM],
    p.[DivMID],
    a.[VendorSubWorkTypeID],
    c.RequestAmount AS [EmergentRelease],
    d.RequestAmount AS [AwardedTotalCost],
    e.BaselineRequest AS SVNType,
    e.AffectNewFinishDate AS SVNNewTOQEndDate,
    a.AllVendors,
    f.VendorTOQNumber AS AllVendorTOQNumber,
    f.ContractNumber AS AllVendorContractNumber,
    f.RequestAmount,
    g.DispositionRequired AS SVNDispositionRequired
FROM stng.VV_TOQ_Main a
INNER JOIN stng.TOQ_Child tc ON a.UniqueID = tc.ChildTOQID AND tc.Deleted = 0
LEFT JOIN VV_TOQ_Main_light p ON p.UniqueID = tc.ParentTOQID
LEFT JOIN stng.VV_TOQ_EmergentACC c ON c.UniqueID = a.UniqueID 
LEFT JOIN stng.VV_TOQ_EmergentRES d ON d.UniqueID = a.UniqueID 
LEFT JOIN stng.TOQ_SVN e ON e.UniqueID = a.UniqueID
LEFT JOIN stng.TOQ_EmergentDetail f ON f.UniqueID = a.UniqueID
LEFT JOIN stng.VV_TOQ_SVN_Dispositioned g ON g.UniqueID = a.UniqueID

GO


