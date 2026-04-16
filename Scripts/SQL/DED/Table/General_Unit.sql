use dmsstingraysqldevdb
go

create table stng.General_Unit
(
	UniqueID uniqueidentifier not null primary key default newid(),
	Unit varchar(50) not null,
	SiteID varchar(5) not null,
	RAD datetime not null default stng.GetBPTime(getdate()),
	RAB varchar(20) not null foreign key references stng.Admin_User(EmployeeID),
	LUD datetime not null default stng.GetBPTime(getdate()),
	LUB varchar(20) not null foreign key references stng.Admin_User(EmployeeID),
	constraint CNST_stng_General_Unit_Unique unique(Unit, SiteID),
	constraint CNST_stng_General_Unit_SiteID check (SiteID in ('BA','BB','CS'))
);

insert into stng.General_Unit
(Unit, SiteID, RAB, LUB)
values
('1','BA','SYSTEM','SYSTEM'),
('2','BA','SYSTEM','SYSTEM'),
('3','BA','SYSTEM','SYSTEM'),
('4','BA','SYSTEM','SYSTEM'),
('0A','BA','SYSTEM','SYSTEM'),
('5','BB','SYSTEM','SYSTEM'),
('6','BB','SYSTEM','SYSTEM'),
('7','BB','SYSTEM','SYSTEM'),
('8','BB','SYSTEM','SYSTEM'),
('0B','BB','SYSTEM','SYSTEM'),
('Site Services','CS','SYSTEM','SYSTEM');