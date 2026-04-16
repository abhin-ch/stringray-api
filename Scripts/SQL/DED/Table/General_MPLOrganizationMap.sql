create table stng.General_MPLOrganizationMap
(
	UniqueID bigint primary key identity(1,1),
	PersonGroup varchar(50) not null foreign key references stng.General_Organization(PersonGroup),
	MPLDiscipline varchar(100) not null,
	RAD datetime not null default stng.GetBPTime(getdate()),
	RAB varchar(20) not null foreign key references stng.Admin_User(EmployeeID),
	LUD datetime not null default stng.GetBPTime(getdate()),
	LUB varchar(20) not null foreign key references stng.Admin_User(EmployeeID)
);

--As of July 18 2023
with maps as
(
	select *
	from
	( values
		('Mechanical Design','SECMD'),
		('EIC Component Programs','SECEIC'),
		('Electrical Design','SECED'),
		('Design Programs','SECDP'),
		('Instrumentation Control','SECCD'),
		('Governance & Oversight','SECGOS'),
		('Pressure Boundary & Piping','SECPBP'),
		('Design Services','SECDS'),
		('Reactor Design','SECRD'),
		('Specialized Tool Engineering','SECOTGTE'),
		('Reactor Tooling and FH','SECRTFH'),
		('Computer Design','SECCOD'),
		('Civil Security Design','SECCVD'),
		('Inst, Comp and Elec Projects','SECIECP'),
		('Component Design Mech','SECMEC')
	) x(MPLDiscipline, PersonGroup)

) 


insert into stng.General_MPLOrganizationMap
(PersonGroup, MPLDiscipline, RAB, LUB)
select PersonGroup, MPLDiscipline, 'SYSTEM', 'SYSTEM'
from maps;