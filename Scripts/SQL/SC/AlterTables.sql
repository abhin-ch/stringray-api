ALTER TABLE stng.Admin_Role ADD CONSTRAINT UniqueRoleName UNIQUE (NameShort,ModuleID,Department)


UPDATE stng.Admin_ModuleAccess SET RequestorID = UserID FROM 
stng.Admin_User WHERE RequestorID = EmployeeID