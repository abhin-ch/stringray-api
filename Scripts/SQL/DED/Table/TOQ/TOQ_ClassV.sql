CREATE TABLE stng.TOQ_ClassV
(
	UniqueID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
	ClassVTemplateUniqueID UNIQUEIDENTIFIER REFERENCES stng.TOQ_ClassVTemplate(UniqueID),
	ClassVMainUniqueID UNIQUEIDENTIFIER REFERENCES stng.TOQ_ClassVMain(UniqueID),
	Qty INT,
	Resource UNIQUEIDENTIFIER REFERENCES stng.Common_ValueLabel(UniqueID),
	Complexity UNIQUEIDENTIFIER REFERENCES stng.Common_ValueLabel(UniqueID),
	InternalHour INT,
	ExternalHour INT
)

CREATE NONCLUSTERED INDEX IX_TOQ_ClassV_ClassVTemplateUniqueID
ON stng.TOQ_ClassV (ClassVTemplateUniqueID)
INCLUDE (ClassVMainUniqueID, Resource, Complexity)