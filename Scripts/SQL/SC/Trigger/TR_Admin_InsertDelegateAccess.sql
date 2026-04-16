/*
CreatedBy: Habib Shakibanejad
CreatedDate: 15 June 2023
Description: This trigger is designed to create delegate access records when user access records are granted on roles. This will ensure delegates will 
            have their privileges aligned with the new privileges assigned to roles after the delegate has been created.
*/
CREATE OR ALTER TRIGGER stng.TR_Admin_InsertDelegateAccess
   ON  stng.Admin_UserAccess
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    INSERT INTO stng.Admin_DelegateAccess(UAID,DelegateID,CreatedBy) SELECT UA.UAID,B.DelegateID,UA.CreatedBy FROM inserted UA,
		(SELECT D.DelegateID FROM stng.Admin_Delegate D 
			WHERE D.ToUserID IN (
				SELECT U.UserID FROM stng.Admin_User U
				INNER JOIN (
					SELECT EmployeeID FROM stng.VV_Admin_UserRole UR WHERE UR.RoleID IN (SELECT UA.RoleID FROM inserted UA)
				) A ON A.EmployeeID = U.EmployeeID
			)
		) B
		WHERE NOT EXISTS (
			SELECT 1 FROM stng.Admin_DelegateAccess DA 
			WHERE DA.UAID = UA.UAID 
			AND DA.DelegateID = B.DelegateID
		)
END
GO