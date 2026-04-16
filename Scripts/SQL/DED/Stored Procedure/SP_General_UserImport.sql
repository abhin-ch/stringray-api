CREATE OR ALTER procedure [stngetl].[SP_General_UserImport]
(
	@Operation int,
	@userArray varchar(max) = null
)
as
begin

	--Add new temporary records
	if @Operation = 1
		begin

			if @userArray is null throw 50001, 'userArray required',1;

			insert into stngetl.Admin_User_Temp
			(Title, LastName, FirstName, Email, EmployeeID, LANID, WorkGroup)
			select jobTitle, surname, givenName, mail, employeeId, onPremisesSamAccountName, department
			from openjson(@userArray)
			with
			(
				jobTitle varchar(255),
				surname varchar(255),
				givenName varchar(255),
				mail varchar(50),
				employeeId varchar(10),
				onPremisesSamAccountName varchar(50),
				userPrincipalName varchar(100),
				department varchar(100)
			)
			where onPremisesSamAccountName is not null and userPrincipalName like '%brucepower.com';

		end

	--Delete all temp records
	else if @Operation = 2
		begin

			delete from stngetl.Admin_User_Temp;
			dbcc checkident('stngetl.Admin_User_Temp',RESEED,0);

		end

	--Insert new records, deactivate missing records, update fields
	else if @Operation = 3
		begin

			insert into stng.Admin_User
			(EmployeeID, Username, FirstName, LastName, Email, Active, CreatedDate, Title, LANID, WorkGroup)
			select a.EmployeeID, a.email, a.firstname, a.lastname, a.email, 1, stng.GetBPTime(GETDATE()), a.title, a.lanid, a.WorkGroup
			from stngetl.Admin_User_Temp as a
			left join stng.Admin_User as b on a.EmployeeID = b.EmployeeID
			where b.EmployeeID is null;

			update stng.Admin_User
			set Active = 0
			from stng.Admin_User as a
			left join stngetl.Admin_User_Temp as b on a.EmployeeID = b.EmployeeID
			where b.EmployeeID is null;

			update stng.Admin_User
			set Username = b.Email,
			FirstName = b.FirstName,
			LastName = b.LastName,
			Email = b.Email,
			Title = b.Title,
			LANID = b.LANID,
			WorkGroup = b.WorkGroup,
			Active = 1
			from stng.Admin_User as a
			inner join stngetl.Admin_User_Temp as b on a.EmployeeID = b.EmployeeID;

			insert into stng.Admin_WorkGroup
			(WorkGroup, RAB)
			select distinct a.WorkGroup, 'SYSTEM'
			from stng.Admin_User as a
			left join stng.Admin_WorkGroup as b on a.WorkGroup = b.WorkGroup
			where b.WorkGroup is null and a.Active = 1 and a.Title = 'External Non-Time Reporter';

		end

end
GO