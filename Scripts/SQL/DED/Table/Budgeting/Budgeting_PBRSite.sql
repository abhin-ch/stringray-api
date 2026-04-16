create table stng.Budgeting_PBRSite
(
	UniqueID bigint primary key identity(1,1),
	PBRUID bigint not null foreign key references stng.Budgeting_PBRMain(PBRUID),
	SiteID varchar(10) not null,
	RAD datetime not null default stng.GetDate(),
	RAB varchar(20) not null foreign key references stng.Admin_User(EmployeeID),
	Deleted bit not null default 0,
	constraint CNST_stng_PBRSDQ_PBRSite_SiteID check (SiteID in ('BA','BB','CS'))
);