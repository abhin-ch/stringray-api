/*
CreatedBy: Habib Shakibanejad
CreatedDate: May 7, 2023
Description: Used to create a default role when a User is created.
*/
CREATE TRIGGER stng.TR_Admin_CreateUser
   ON  stng.Admin_User
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO stng.Admin_UserRole(UserID,RoleID,CreatedBy,[Default])
	SELECT U.UserID,R.RoleID,'SYSTEM',1 FROM inserted U
	CROSS APPLY (
		SELECT R.RoleID FROM stng.Admin_Role R WHERE R.NameShort = 'Guest'
	) R
END
GO
