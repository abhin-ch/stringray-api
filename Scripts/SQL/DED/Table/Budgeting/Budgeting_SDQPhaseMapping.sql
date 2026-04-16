CREATE TABLE stng.Budgeting_SDQPhaseMapping
(
	UniqueID UNIQUEIDENTIFIER DEFAULT NEWID(),
	SDQPhase UNIQUEIDENTIFIER REFERENCES stng.Common_ValueLabel(UniqueID),
	MPLPhase varchar(40) not null,
	CreatedDate datetime not null default stng.GetDate(),
	CreatedBy varchar(20) not null REFERENCES stng.Admin_User(EmployeeID),
	CONSTRAINT CNST_stng_Budgeting_SDQPhaseMapping_Unique unique(SDQPhase,MPLPhase)
);


/*
insert into stng.Budgeting_SDQPhaseMapping
(SDQPhase, MPLPhase, RAB, LUB)
values
(0,'Initiation','SYSTEM','SYSTEM'),
(1,'Development','SYSTEM','SYSTEM'),
(1,'Conceptual','SYSTEM','SYSTEM'),
(2,'Definition','SYSTEM','SYSTEM'),
(3,'Preparation','SYSTEM','SYSTEM'),
(4,'Execution','SYSTEM','SYSTEM'),
(5,'Closeout','SYSTEM','SYSTEM'),
(5,'Completed','SYSTEM','SYSTEM'),
(5,'Turnover','SYSTEM','SYSTEM');
*/