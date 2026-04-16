CREATE TABLE stngetl.Budgeting_SDQ_P6_CVWBS_Materialized (
    UniqueRowID UNIQUEIDENTIFIER NOT NULL 
        CONSTRAINT DF_Budgeting_SDQ_P6_CVWBS_Materialized_UniqueRowID DEFAULT NEWID(),

    SDQUID BIGINT NOT NULL,
    RunID UNIQUEIDENTIFIER NOT NULL,

    wbs_name NVARCHAR(255) NULL,
    wbs_code VARCHAR(50) NULL,

    DeliverableType INT NOT NULL,
    DeliverableName NVARCHAR(255) NULL,

    unit VARCHAR(50) NULL,
    Direct BIT NULL,
    PhaseCode INT NULL,
    DisciplineCode VARCHAR(10) NULL,

    CurrentStart DATETIME NULL,
    StartActualized BIT NULL,
    CurrentEnd DATETIME NULL,
    EndActualized BIT NULL,

    LabourActualUnits DECIMAL(18,6) NULL,
    LabourActualCost DECIMAL(18,6) NULL,
    NonLabourActualUnits DECIMAL(18,6) NULL,
    NonLabourActualCost DECIMAL(18,6) NULL,
    SunkCost DECIMAL(18,6) NULL,

    LabourRemainingUnits DECIMAL(18,6) NULL,
    NonLabourRemainingUnits DECIMAL(18,6) NULL,
    LabourRemainingCost DECIMAL(18,6) NULL,
    NonLabourRemainingCost DECIMAL(18,6) NULL,
    RemainingCost DECIMAL(18,6) NULL,

    BLBudgetedCost DECIMAL(18,6) NULL,

    Legacy BIT NOT NULL,
    LoadDate DATETIME NOT NULL DEFAULT GETDATE()
);
