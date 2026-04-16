create table stng.Budgeting_SDQ_Status
(
	SDQStatusID uniqueidentifier not null primary key default(newid()),
	SDQStatus varchar(20) not null unique,
	SDQStatusLong varchar(200) not null,
	RAD datetime not null default(stng.getbptime(getdate())),
	RAB varchar(20) not null foreign key references stng.Admin_User(EmployeeID)
);

insert into stng.Budgeting_SDQ_Status
(SDQStatus, SDQStatusLong, RAB)
values
('INIT','Initiated','612497'),
('CANC','Canceled','612497'),
('CORR','Correction Required','612497'),
('AVER','Awaiting Verification','612497'),
('AOEA','Awaiting OE Approval','612497'),
('ASMA','Awaiting SM Approval(s)','612497'),
('ADPA','Awaiting DM EP Approval','612497'),
('APJMA','Awaiting Customer (PM) Approval','612497'),
('NTAPP','Customer Not Approved','612497'),
('APGMA','Awaiting ProgM Approval','612497'),
('AOEFR','Awaiting OE Funding Release','612497'),
('APRE','Approved, Partial Release','612497'),
('APCSC','Approved, Awaiting PCS Comment','612497'),
('AFRE','Approved, Full Release','612497');