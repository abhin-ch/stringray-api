create table stng.Budgeting_SDQUnit
(
	UniqueID uniqueidentifier DEFAULT NEWID() PRIMARY KEY,
	SDQUID bigint not null foreign key references stng.Budgeting_SDQMain(SDQUID),
	Unit uniqueidentifier REFERENCES [stng].Common_ValueLabel (UniqueID),
	CreatedDate datetime DEFAULT stng.GetDate(),
	CreatedBy varchar(20) not null foreign key references stng.Admin_User(EmployeeID)
)