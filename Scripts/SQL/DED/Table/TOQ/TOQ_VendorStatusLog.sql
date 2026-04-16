CREATE TABLE [stng].[TOQ_VendorStatusLog](
	[UniqueID] UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
	[VendorAssignedID] UNIQUEIDENTIFIER REFERENCES stng.TOQ_VendorAssigned(UniqueID),
	StatusID UNIQUEIDENTIFIER REFERENCES stng.Common_ValueLabel(UniqueID),	
	[Comment] NVARCHAR(255) NULL,
	CreatedDate DATETIME DEFAULT stng.GetDate(),
	CreatedBy VARCHAR(20)
)

ALTER TABLE stng.TOQ_VendorStatusLog ADD ReasonNoBid UNIQUEIDENTIFIER REFERENCES stng.Common_ValueLabel(UniqueID)