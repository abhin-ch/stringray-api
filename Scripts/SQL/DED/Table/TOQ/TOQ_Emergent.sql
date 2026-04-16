CREATE TABLE [stng].[TOQ_Emergent](
	[UniqueID] UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID()
	,EmergentID INT DEFAULT NEXT VALUE FOR TOQ_ID
	,BPTOQID VARCHAR(20)
	,[Title] [varchar](255)
	,[Project] [varchar](5)
	,[Request] [decimal](12, 2)
	,[FundingSource] [varchar](10)
	,[VendorTOQNumber] [varchar](25)
	,[ContractNumber] [varchar](25)
	,[ScopeOfWork] [varchar](2000)
	,[StatusID] UNIQUEIDENTIFIER REFERENCES stng.Common_ValueLabel(UniqueID)
	,[VendorID] UNIQUEIDENTIFIER REFERENCES stng.Common_ValueLabel(UniqueID)
	,VendorWorkTypeID UNIQUEIDENTIFIER REFERENCES stng.Common_ValueLabel(UniqueID)
	,[RequestFrom] [varchar](25) 
	,[LinkedTOQUID] UNIQUEIDENTIFIER REFERENCES stng.TOQ_Main(UniqueID)
	,[SM] [varchar](50) 
	,[DeleteDate] DATETIME
	,[DeleteRecord] [int]
	,[DeleteBy] [varchar](50)
	,CreatedDate DATETIME DEFAULT stng.GetDATE()
    ,CreatedBy VARCHAR(20)
)