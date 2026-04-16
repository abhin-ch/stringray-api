create table stng.Budgeting_SDQ_SMApproval_StatusLog
(
	SMApprovalSLID bigint not null primary key identity(1,1),
	SMApprovalID bigint not null foreign key references stng.Budgeting_SDQ_SMApproval(SMApprovalID),
	ApprovalStatus uniqueidentifier not null foreign key references stng.Budgeting_SDQ_SMApproval_Status(SMApprovalStatusID),
	Comment varchar(500) null,
	RAD datetime not null default(stng.getbptime(getdate())),
	RAB varchar(20) not null foreign key references stng.Admin_User(EmployeeID),
	constraint CNST_stng_Budgeting_SDQ_SMApproval_StatusLog_Unique unique(SMApprovalID, ApprovalStatus, RAD)
);