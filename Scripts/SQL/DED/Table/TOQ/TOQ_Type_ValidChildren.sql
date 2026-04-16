create table stng.TOQ_Type_ValidChildren
(
	UniqueID int not null primary key identity(1,1),
	TOQTypeID uniqueidentifier not null foreign key references stng.Common_ValueLabel(TOQTypeID),
	TOQTypeChildrenID uniqueidentifier not null foreign key references stng.Common_ValueLabel(UniqueID),
	RAD datetime not null default(stng.getbptime(getdate())),
	RAB varchar(20) not null foreign key references stng.Admin_User(EmployeeID),
	constraint CNST_stng_TOQ_Type_ValidChildren_Unique unique(TOQTypeID, TOQTypeChildrenID)
);

with stndchildren as
(
	select TypeID TOQTypeID
	from stng.VV_TOQ_Types
	where Type in ('EWR','SVN')
)

insert into stng.TOQ_Type_ValidChildren
(TOQTypeID, TOQTypeChildrenID, RAB)
select a.TypeID, b.TOQTypeID, '612497'
from stng.VV_TOQ_Types as a, stndchildren as b
where a.Type not in ('EWR','SVN');

insert into stng.TOQ_Type_ValidChildren
(TOQTypeID, TOQTypeChildrenID, RAB)
select a.TypeID, a.TypeID, '612497'
from stng.VV_TOQ_Types as a
where a.Type in ('EWR');