use dmsstingraysqldevdb
go

create table stng.General_Organization
(
	[PersonGroup] varchar(50) not null primary key,
	[ParentPersonGroup] varchar(50) null foreign key references stng.General_Organization([PersonGroup]),
	Supervisor varchar(20) not null foreign key references stng.Admin_User(EmployeeID),
	[Description] varchar(1000) not null,
	[Type] varchar(50) not null,
	RAD datetime not null default stng.GetBPTime(getdate()),
	RAB varchar(20) not null foreign key references stng.Admin_User(EmployeeID),
	LUD datetime not null default stng.GetBPTime(getdate()),
	LUB varchar(20) not null foreign key references stng.Admin_User(EmployeeID)
);

--Org info as of July 18, 2023
insert into stng.General_Organization
([PersonGroup], [ParentPersonGroup], Supervisor, [Description], [Type], RAB, LUB)
values
('BP',null,'610761','Bruce Power','BP','SYSTEM','SYSTEM'),
('DIVDMES','DIVENG','517817','Design Engineering','Division','SYSTEM','SYSTEM'),
('DIVENG','GRPPFS','504954','Engineering','VP','SYSTEM','SYSTEM'),
('DPTCMDS','DIVDMES','155074','Configuration Management and Design Services','Department','SYSTEM','SYSTEM'),
('DPTFTSCD','DIVDMES','300417','Tooling & Components Design','Department','SYSTEM','SYSTEM'),
('DPTICE','DIVDMES','514374','Electrical & Controls Design','Department','SYSTEM','SYSTEM'),
('DPTMCD','DIVDMES','523496','Reactor, Mechanical, and Civil Design','Department','SYSTEM','SYSTEM'),
('GRPPFS','BP','615034','Projects and Field Services','ExecVP','SYSTEM','SYSTEM'),
('SECCD','DPTICE','611298','Control Design','Section','SYSTEM','SYSTEM'),
('SECCOD','DPTICE','611131','Computer Design','Section','SYSTEM','SYSTEM'),
('SECCVD','DPTMCD','611718','Civil and Security Design','Section','SYSTEM','SYSTEM'),
('SECDP','DPTCMDS','621220','Design Programs','Section','SYSTEM','SYSTEM'),
('SECDS','DPTCMDS','610239','Design Services','Section','SYSTEM','SYSTEM'),
('SECED','DPTICE','523455','Electrical Design','Section','SYSTEM','SYSTEM'),
('SECEIC','DPTFTSCD','521251','Component Design Electrical I&C','Section','SYSTEM','SYSTEM'),
('SECGOS','DPTCMDS','510933','Governance and Oversight','Section','SYSTEM','SYSTEM'),
('SECIECP','DPTICE','611298','I&C and Electrical Design Projects','Section','SYSTEM','SYSTEM'),
('SECMD','DPTMCD','518622','Mechanical Design','Section','SYSTEM','SYSTEM'),
('SECMEC','DPTFTSCD','515667','Component Design Mechanical','Section','SYSTEM','SYSTEM'),
('SECOTGTE','DPTFTSCD','511076','Specialized Tool Engineering','Section','SYSTEM','SYSTEM'),
('SECPBP','DPTMCD','518727','Pressure Boundary and Piping','Section','SYSTEM','SYSTEM'),
('SECRD','DPTMCD','518327','Reactor Design','Section','SYSTEM','SYSTEM'),
('SECRTFH','DPTFTSCD','518572','Reactor Tooling and Fuel Handling','Section','SYSTEM','SYSTEM');