CREATE TABLE stng.Budgeting_SDQVerificationChecklist(
	UniqueID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	VerificationChecklistLinkID UNIQUEIDENTIFIER REFERENCES stng.Budgeting_SDQVerificationChecklistLink(UniqueID) ON DELETE CASCADE NOT NULL,
	QuestionID UNIQUEIDENTIFIER REFERENCES stng.Common_ValueLabel(UniqueID),
	Answer NVARCHAR(3),
	Comment NVARCHAR(255),
	SupportData NVARCHAR(255),
	CreatedDate DATETIME DEFAULT stng.GetDate(),
	CreatedBy VARCHAR(20) REFERENCES stng.Admin_User(EmployeeID)
)