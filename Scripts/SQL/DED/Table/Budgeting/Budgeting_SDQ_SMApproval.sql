create table stng.Budgeting_SDQ_SMApproval
(
	SMApprovalID bigint not null primary key identity(1,1),
	P6RunID uniqueidentifier not null foreign key references stngetl.Budgeting_SDQ_Run(RunID),
	PersonGroup varchar(50) not null foreign key references stng.General_Organization(PersonGroup),
	ApprovalStatus uniqueidentifier not null foreign key references stng.Budgeting_SDQ_SMApproval_Status(SMApprovalStatusID),
	RAD datetime not null default(stng.getbptime(getdate())),
	RAB varchar(20) not null foreign key references stng.Admin_User(EmployeeID),
	LUD datetime not null default(stng.getbptime(getdate())),
	LUB varchar(20) not null foreign key references stng.Admin_User(EmployeeID),
	Deleted bit not null default 0,
	DeletedBy varchar(20) null foreign key references stng.Admin_User(EmployeeID),
	DeletedOn datetime null,
	constraint CNST_stng_Budgeting_SDQ_SMApproval_Deleted check(Deleted = 0 or (Deleted = 1 and DeletedBy is not null and DeletedOn is not null)),
	constraint CNST_stng_Budgeting_SDQ_SMApproval_Unique unique(P6RunID, PersonGroup, Deleted)
);