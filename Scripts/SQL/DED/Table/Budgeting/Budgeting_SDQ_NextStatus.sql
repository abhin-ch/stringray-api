create table stng.Budgeting_SDQ_NextStatus
(
	UniqueID bigint not null primary key identity(1,1),
	ParentStatusID uniqueidentifier null foreign key references stng.Budgeting_SDQ_Status(SDQStatusID),
	StatusID uniqueidentifier null foreign key references stng.Budgeting_SDQ_Status(SDQStatusID),
	Loopback bit not null default 0,
	Reversible bit not null default 0,
	RAD datetime not null default(stng.getbptime(getdate())),
	RAB varchar(20) foreign key references stng.Admin_User(EmployeeID),
	constraint CNST_stng_Budgeting_SDQ_NextStatus_Unique unique(ParentStatusID, StatusID)
);

declare @ParentStatusID uniqueidentifier;
declare @StatusID uniqueidentifier;

--INIT
set @ParentStatusID  = null;
select @StatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'INIT';

insert into stng.Budgeting_SDQ_NextStatus
(ParentStatusID, StatusID, RAB)
values
(@ParentStatusID, @StatusID, '612497');

--AVER
select @ParentStatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'INIT';

select @StatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'AVER';

insert into stng.Budgeting_SDQ_NextStatus
(ParentStatusID, StatusID, RAB)
values
(@ParentStatusID, @StatusID, '612497');

--AOEA
select @ParentStatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'AVER';

select @StatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'AOEA';

insert into stng.Budgeting_SDQ_NextStatus
(ParentStatusID, StatusID, RAB)
values
(@ParentStatusID, @StatusID, '612497');

--ASMA
select @ParentStatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'AOEA';

select @StatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'ASMA';

insert into stng.Budgeting_SDQ_NextStatus
(ParentStatusID, StatusID, RAB)
values
(@ParentStatusID, @StatusID, '612497');

--ADPA
select @ParentStatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'ASMA';

select @StatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'ADPA';

insert into stng.Budgeting_SDQ_NextStatus
(ParentStatusID, StatusID, RAB)
values
(@ParentStatusID, @StatusID, '612497');

--APJMA
select @ParentStatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'ADPA';

select @StatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'APJMA';

insert into stng.Budgeting_SDQ_NextStatus
(ParentStatusID, StatusID, RAB)
values
(@ParentStatusID, @StatusID, '612497');

select @ParentStatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'APRE';

select @StatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'APJMA';

insert into stng.Budgeting_SDQ_NextStatus
(ParentStatusID, StatusID, RAB, Loopback)
values
(@ParentStatusID, @StatusID, '612497',1);


--APGMA
select @ParentStatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'APJMA';

select @StatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'APGMA';

insert into stng.Budgeting_SDQ_NextStatus
(ParentStatusID, StatusID, RAB)
values
(@ParentStatusID, @StatusID, '612497');

--AOEFR
select @ParentStatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'APGMA';

select @StatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'AOEFR';

insert into stng.Budgeting_SDQ_NextStatus
(ParentStatusID, StatusID, RAB)
values
(@ParentStatusID, @StatusID, '612497');

--APRE
select @ParentStatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'AOEFR';

select @StatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'APRE';

insert into stng.Budgeting_SDQ_NextStatus
(ParentStatusID, StatusID, RAB)
values
(@ParentStatusID, @StatusID, '612497');

--APCSC
select @ParentStatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'APGMA';

select @StatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'APCSC';

insert into stng.Budgeting_SDQ_NextStatus
(ParentStatusID, StatusID, RAB)
values
(@ParentStatusID, @StatusID, '612497');

--AFRE
select @ParentStatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'APCSC';

select @StatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'AFRE';

insert into stng.Budgeting_SDQ_NextStatus
(ParentStatusID, StatusID, RAB)
values
(@ParentStatusID, @StatusID, '612497');

--NTAPP
select @ParentStatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'APJMA';

select @StatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'NTAPP';

insert into stng.Budgeting_SDQ_NextStatus
(ParentStatusID, StatusID, RAB)
values
(@ParentStatusID, @StatusID, '612497');

select @ParentStatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'APGMA';

select @StatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'NTAPP';

insert into stng.Budgeting_SDQ_NextStatus
(ParentStatusID, StatusID, RAB)
values
(@ParentStatusID, @StatusID, '612497');

--CANC
select @ParentStatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'INIT';

select @StatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'CANC';

insert into stng.Budgeting_SDQ_NextStatus
(ParentStatusID, StatusID, RAB)
values
(@ParentStatusID, @StatusID, '612497');

--CORR
select @ParentStatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'AVER';

select @StatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'CORR';

insert into stng.Budgeting_SDQ_NextStatus
(ParentStatusID, StatusID, RAB, Reversible)
values
(@ParentStatusID, @StatusID, '612497',1);

select @ParentStatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'AOEA';

select @StatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'CORR';

insert into stng.Budgeting_SDQ_NextStatus
(ParentStatusID, StatusID, RAB)
values
(@ParentStatusID, @StatusID, '612497');

select @ParentStatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'ASMA';

select @StatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'CORR';

insert into stng.Budgeting_SDQ_NextStatus
(ParentStatusID, StatusID, RAB)
values
(@ParentStatusID, @StatusID, '612497');

select @ParentStatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'ADPA';

select @StatusID = SDQStatusID
from stng.Budgeting_SDQ_Status
where SDQStatus = 'CORR';

insert into stng.Budgeting_SDQ_NextStatus
(ParentStatusID, StatusID, RAB)
values
(@ParentStatusID, @StatusID, '612497');

ALTER TABLE stng.[Budgeting_SDQ_NextStatus] ADD Active BIT DEFAULT 1 
UPDATE stng.[Budgeting_SDQ_NextStatus] SET Active = 1