CREATE TABLE stngetl.Budgeting_SDQ_P6_CIIOrg_Materialized (
    UniqueRowID UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT DF_Budgeting_SDQ_P6_CIIOrg_Materialized_UniqueRowID DEFAULT NEWID(),

    UniqueID VARCHAR(300) NOT NULL,   -- RespOrg||MultiVendor
    SDQUID BIGINT NOT NULL,
    RunID UNIQUEIDENTIFIER NOT NULL,

    RespOrg NVARCHAR(255) NULL,
    MultipleVendor NVARCHAR(255) NULL,
    G4017ActivityType NVARCHAR(50) NULL,

    LabourRemainingUnits DECIMAL(18,6) NULL,
    LabourRemainingCost DECIMAL(18,6) NULL,
    NonLabourRemainingCost DECIMAL(18,6) NULL,
    RemainingCost DECIMAL(18,6) NULL,
    SunkCost DECIMAL(18,6) NULL,
    RequestCost DECIMAL(18,6) NULL,
    BLProjectTotalCost DECIMAL(18,6) NULL,
    CurrentRequest DECIMAL(18,6) NULL,

    Legacy BIT NOT NULL,
    LoadDate DATETIME NOT NULL DEFAULT GETDATE()
);
