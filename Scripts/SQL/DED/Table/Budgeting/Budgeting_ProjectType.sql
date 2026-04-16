create table stng.Budgeting_ProjectType
(
	ProjectTypeID uniqueidentifier not null primary key default(newid()),
	ProjectType varchar(50) not null unique,
	ProjectTypeLong varchar(500) not null,
	RAD datetime not null default(stng.getbptime(getdate())),
	RAB varchar(20) foreign key references stng.Admin_User(EmployeeID)
);

insert into stng.Budgeting_ProjectType
(ProjectType, ProjectTypeLong, RAB)
values
('CURR','Sustaining Capital','612497'),
('MCR','MCR','612497'),
('IO1','Incremental Output Stage 1','612497'),
('IO2','Incremental Output Stage 2','612497'),
('IO3','Incremental Output Stage 3','612497'),
('PMT','Engineering Request','612497'),
('AMOT','Asset Management/Incremental Capital','612497'),
('ED','Engineering Digitization','612497'),
('ISO','Isotopes','612497'),
('PRP','Project 2030','612497'),
('OMA','O&M','612497'),
('OUT','Outage Capital','612497');