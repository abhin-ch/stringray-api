CREATE OR ALTER   FUNCTION [stng].[FN_Admin_GetDelegatorsAndSelf]
(	
	@EmployeeID nvarchar(20)
)
RETURNS @ReturnTable table
(
	EmployeeID nvarchar(20)
)
AS
BEGIN
	INSERT INTO @ReturnTable(EmployeeID)
	SELECT Delegator FROM stng.Admin_Delegation
	WHERE Deleted = 0 AND [Active] = 1 AND (Indefinite = 1 OR [ExpireDate] >= stng.GetDate()) AND Delegatee = @EmployeeID
	UNION
	SELECT @EmployeeID


	return;
END
GO


