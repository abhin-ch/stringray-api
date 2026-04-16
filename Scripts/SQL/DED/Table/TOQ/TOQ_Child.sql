create table stng.TOQ_Child
(
	UniqueID bigint not null primary key identity(1,1),
	ParentTOQID uniqueidentifier not null foreign key references stng.TOQ_Main(UniqueID),
	ChildTOQID uniqueidentifier not null foreign key references stng.TOQ_Main(UniqueID),
	RAD datetime not null default(stng.getbptime(getdate())),
	RAB varchar(20) not null foreign key references stng.Admin_User(EmployeeID),
	Deleted bit not null default 0,
	DeletedBy varchar(20) null foreign key references stng.Admin_User(EmployeeID),
	DeletedOn datetime null,
	constraint stng_TOQ_Child_Unique unique(ParentTOQID, ChildTOQID),
	constraint stng_TOQ_Child_Deleted check(Deleted = 0 or (Deleted = 1 and DeletedOn is not null and DeletedBy is not null))
);