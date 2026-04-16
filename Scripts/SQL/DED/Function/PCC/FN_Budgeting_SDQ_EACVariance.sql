SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [stng].[FN_Budgeting_SDQ_EACVariance]
(
    @SDQUID bigint
)
RETURNS @ReturnInfo TABLE
(
    EACVariance float,
    EACVarianceLAMP float,
    Colour varchar(20),
    EACVarianceComment VARCHAR(4000),
    EACVariance15P BIT,
    EACVarianceLAMP15P BIT,
    EACVarianceENG15P BIT,
    EACVariance20P BIT,
    EACVarianceLAMP20P BIT,
    EACVarianceENG20P BIT,
    EACVarianceLAMPValue float,
    EACVarianceENGValue float,
    EACVarianceValue float
)
AS
BEGIN
    /*
      Single set-based computation:
      - Get current EAC row (p6)
      - OUTER APPLY top previous revision (prev)
      - OUTER APPLY lamp4 / ecosys lookups (lamp)
      - Compute variances and flags in one projection
    */

    INSERT INTO @ReturnInfo
    (
        EACVariance,
        EACVarianceLAMP,
        Colour,
        EACVarianceComment,
        EACVariance15P,
        EACVarianceENG15P,
        EACVarianceLAMP15P,
        EACVariance20P,
        EACVarianceENG20P,
        EACVarianceLAMP20P,
        EACVarianceValue,
        EACVarianceLAMPValue,
        EACVarianceENGValue
    )
    SELECT
        -- EAC variance vs previous revision (NULL if no previous or previous EAC = 0)
        CASE
            WHEN prevRow.PreviousEAC IS NULL OR prevRow.PreviousEAC = 0 THEN NULL
            ELSE (p6.EAC - prevRow.PreviousEAC) / prevRow.PreviousEAC
        END AS EACVariance,

        -- EAC variance vs LAMP4 baseline (0 when no LAMP4 or LAMP4 = 0)
        CASE
            WHEN lamp.LAMP4 IS NOT NULL AND lamp.LAMP4 <> 0 THEN (p6.EAC - lamp.LAMP4) / NULLIF(lamp.LAMP4, 0)
            ELSE 0
        END AS EACVarianceLAMP,

        -- Colour: Red if any threshold breached, otherwise Green.
        CASE
            WHEN
                (CASE WHEN prevRow.PreviousEAC IS NULL OR prevRow.PreviousEAC = 0 THEN NULL ELSE (p6.EAC - prevRow.PreviousEAC) / prevRow.PreviousEAC END) < -0.15
                OR (CASE WHEN lamp.LAMP4 IS NOT NULL AND lamp.LAMP4 <> 0 THEN (p6.EAC - lamp.LAMP4) / NULLIF(lamp.LAMP4, 0) ELSE 0 END) < -0.15
                OR (CASE WHEN prevRow.PreviousEAC IS NULL OR prevRow.PreviousEAC = 0 THEN NULL ELSE (p6.EAC - prevRow.PreviousEAC) / prevRow.PreviousEAC END) > 0.2
                OR (CASE WHEN lamp.LAMP4 IS NOT NULL AND lamp.LAMP4 <> 0 THEN (p6.EAC - lamp.LAMP4) / NULLIF(lamp.LAMP4, 0) ELSE 0 END) > 0.2
                OR (CASE WHEN lamp.EcoSysEAC_ENG IS NOT NULL AND lamp.EcoSysEAC_ENG <> 0 THEN (p6.EAC - lamp.EcoSysEAC_ENG) / NULLIF(lamp.EcoSysEAC_ENG, 0) ELSE 0 END) < -0.15
                OR (CASE WHEN lamp.EcoSysEAC_ENG IS NOT NULL AND lamp.EcoSysEAC_ENG <> 0 THEN (p6.EAC - lamp.EcoSysEAC_ENG) / NULLIF(lamp.EcoSysEAC_ENG, 0) ELSE 0 END) > 0.2
            THEN 'Red'
            ELSE 'Green'
        END AS Colour,

        -- Comment from main table
        S.VarianceComment,

        -- Flags: 15% negative and 20% positive thresholds
        IIF(
            (CASE WHEN prevRow.PreviousEAC IS NULL OR prevRow.PreviousEAC = 0 THEN NULL ELSE (p6.EAC - prevRow.PreviousEAC) / prevRow.PreviousEAC END) < -0.15,
            1, 0
        ) AS EACVariance15P,

        IIF(
            (CASE WHEN lamp.EcoSysEAC_ENG IS NOT NULL AND lamp.EcoSysEAC_ENG <> 0 THEN (p6.EAC - lamp.EcoSysEAC_ENG) / NULLIF(lamp.EcoSysEAC_ENG, 0) ELSE 0 END) < -0.15,
            1, 0
        ) AS EACVarianceENG15P,

        IIF(
            (CASE WHEN lamp.LAMP4 IS NOT NULL AND lamp.LAMP4 <> 0 THEN (p6.EAC - lamp.LAMP4) / NULLIF(lamp.LAMP4, 0) ELSE 0 END) < -0.15,
            1, 0
        ) AS EACVarianceLAMP15P,

        IIF(
            (CASE WHEN prevRow.PreviousEAC IS NULL OR prevRow.PreviousEAC = 0 THEN NULL ELSE (p6.EAC - prevRow.PreviousEAC) / prevRow.PreviousEAC END) > 0.2,
            1, 0
        ) AS EACVariance20P,

        IIF(
            (CASE WHEN lamp.EcoSysEAC_ENG IS NOT NULL AND lamp.EcoSysEAC_ENG <> 0 THEN (p6.EAC - lamp.EcoSysEAC_ENG) / NULLIF(lamp.EcoSysEAC_ENG, 0) ELSE 0 END) > 0.2,
            1, 0
        ) AS EACVarianceENG20P,

        IIF(
            (CASE WHEN lamp.LAMP4 IS NOT NULL AND lamp.LAMP4 <> 0 THEN (p6.EAC - lamp.LAMP4) / NULLIF(lamp.LAMP4, 0) ELSE 0 END) > 0.2,
            1, 0
        ) AS EACVarianceLAMP20P,

        -- Numeric values
        CASE WHEN prevRow.PreviousEAC IS NULL THEN NULL ELSE p6.EAC - prevRow.PreviousEAC END AS EACVarianceValue,
        CASE WHEN lamp.LAMP4 IS NULL THEN NULL ELSE p6.EAC - lamp.LAMP4 END AS EACVarianceLAMPValue,
        CASE WHEN lamp.EcoSysEAC_ENG IS NULL THEN NULL ELSE p6.EAC - lamp.EcoSysEAC_ENG END AS EACVarianceENGValue

    FROM stngetl.VV_Budgeting_SDQ_P6_EAC_2 p6
    LEFT JOIN stng.Budgeting_SDQMain S ON S.SDQUID = p6.SDQUID

    -- previous revision top 1 (same logic as original)
    OUTER APPLY
    (
        SELECT TOP (1)
            PrevSDQUID,
            -- fetch previous EAC in same apply to avoid extra join later
            (SELECT EAC FROM stngetl.VV_Budgeting_SDQ_P6_EAC_2 WHERE SDQUID = PrevSDQUID) AS PreviousEAC
        FROM stng.VV_Budgeting_SDQ_PreviousRevision PR
        WHERE PR.SDQUID = @SDQUID AND PR.MinRev = 0
        ORDER BY PR.PrevSDQPhase DESC, PR.PrevSDQRevision DESC
    ) prevRow

    -- LAMP4 / EcoSys lookups (only when LAMP4Baseline = 'Y' and LAMP4 = 'Y')
    OUTER APPLY
    (
        SELECT
            B.RecordTypeUniqueID AS SDQUID,
            CA.EAC AS LAMP4,
            ENG.EcoSysEAC AS EcoSysEAC_ENG,
            d.EcoSysEAC
        FROM stng.VV_Budgeting_SDQMain B
        INNER JOIN stng.VV_Budgeting_SDQ_CustomerApproval_2 CA ON CA.SDQUID = B.RecordTypeUniqueID
        LEFT JOIN stng.Budgeting_SDQ_EcosysEAC_ENG ENG ON CONCAT('ENG-', ENG.ProjectId) = B.ProjectNo
        LEFT JOIN stngetl.VV_Budgeting_SDQ_P6_EAC_2 d ON d.SDQUID = B.RecordTypeUniqueID
        WHERE B.RecordTypeUniqueID = p6.SDQUID
          AND B.LAMP4Baseline = 'Y'
          AND B.LAMP4 = 'Y'
    ) lamp

    WHERE p6.SDQUID = @SDQUID;

    RETURN;
END
GO
