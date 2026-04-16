create table stng.Budgeting_SDQ_Phase
(
	SDQPhaseID uniqueidentifier not null primary key default(newid()),
	Phase int not null unique,
	PhaseDesc varchar(200) not null,
	RAD datetime not null default(stng.getbptime(getdate())),
	RAB varchar(20) not null foreign key references stng.Admin_User(EmployeeID)
);

insert into stng.Budgeting_SDQ_Phase
(Phase, PhaseDesc, RAB)
values
(0,'Initiation','612497'),
(1,'Conceptual Design (Development)','612497'),
(2,'Preliminary Design (Definition)','612497'),
(3,'Detailed Design (Preparation)','612497'),
(4,'Eng Construction Support (Execution)','612497'),
(5,'Closeout','612497');