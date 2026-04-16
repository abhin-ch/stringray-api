create table stng.Plugin_Version
(
	VersionID uniqueidentifier not null primary key default(newid()),
	BLOBName varchar(50) not null,
	RAD datetime not null default(stng.getbptime(getdate())),
	RAB varchar(20) not null foreign key references stng.Admin_User(EmployeeID),
	constraint CNST_Plugin_Version_Unique unique(BLOBName, RAD)
);

insert into stng.Plugin_Version
(BLOBName, RAB)
values
('1.0.0.0','612497');