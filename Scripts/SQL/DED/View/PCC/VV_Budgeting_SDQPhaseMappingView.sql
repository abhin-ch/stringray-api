CREATE OR ALTER view [stng].[VV_Budgeting_SDQPhaseMappingView] as
    SELECT a.SharedProjectID as ProjectID, b.MPLPhase, CAST(C.Value AS INT) SDQPhase
    FROM stng.VV_MPL_ENG as a
    INNER JOIN stng.Budgeting_SDQPhaseMapping as b on a.Phase = b.MPLPhase
    INNER JOIN stng.Common_ValueLabel C ON C.UniqueID = B.SDQPhase