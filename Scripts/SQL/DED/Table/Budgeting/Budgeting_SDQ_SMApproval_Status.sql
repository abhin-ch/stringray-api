create table stng.Budgeting_SDQ_SMApproval_Status
(
	SMApprovalStatusID uniqueidentifier not null primary key default(newid()),
	SMApprovalStatus varchar(50) not null unique,
	RAD datetime not null default(stng.getbptime(getdate())),
	RAB varchar(20) not null foreign key references stng.Admin_User(EmployeeID)
);

insert into stng.Budgeting_SDQ_SMApproval_Status
(SMApprovalStatus, RAB)
values
('Pending Approval','612497'),
('Approved','612497'),
('Correction Required','612497');