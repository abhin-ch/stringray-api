CREATE TABLE stng.MPL_Override(
	UniqueID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
	RecordUniqueID NVARCHAR(255),
	RecordType NVARCHAR(255),
	Project VARCHAR(20),
	PCS VARCHAR(20) REFERENCES stng.Admin_User(EmployeeID),
	OE VARCHAR(20) REFERENCES stng.Admin_User(EmployeeID),
	SM VARCHAR(20) REFERENCES stng.Admin_User(EmployeeID),
	DM VARCHAR(20) REFERENCES stng.Admin_User(EmployeeID),
	DMEP VARCHAR(20) REFERENCES stng.Admin_User(EmployeeID),
	DMES VARCHAR(20) REFERENCES stng.Admin_User(EmployeeID),
	Planner VARCHAR(20) REFERENCES stng.Admin_User(EmployeeID),
	ProjM VARCHAR(20) REFERENCES stng.Admin_User(EmployeeID),
	ProgM VARCHAR(20) REFERENCES stng.Admin_User(EmployeeID),
	DivM VARCHAR(20) REFERENCES stng.Admin_User(EmployeeID)
)

ALTER TABLE stng.MPL_Override ADD CONSTRAINT unique_record UNIQUE (RecordUniqueID,RecordType);
ALTER TABLE stng.MPL_Override ADD Project VARCHAR(20)