/*
CreatedBy: Habib Shakibanejad
Created Date: 18 Jan 2023
Description: Delegation CRUD
*/
CREATE OR ALTER PROCEDURE [stng].[SP_Admin_DelegateCRUD](
	@Operation TINYINT
	,@EmployeeID NVARCHAR(255) = NULL
	,@Value1 NVARCHAR(255) = NULL
	,@Value2 NVARCHAR(255) = NULL
	,@Value3 NVARCHAR(255) = NULL
	,@Num1 INT = NULL
	,@Num2 INT = NULL
	,@Num3 INT = NULL
	,@Text NVARCHAR(1000) = NULL
	,@IsTrue1 BIT = NULL
	,@Date1 DATE = NULL
)
AS
BEGIN
	/*
	Operation - 1: GET delegates
	Operation - 2: UPDATE active on delegate
	Operation - 3: DELETE delegate
	Operation - 4: INSERT delegate
	Operation - 5: GET all users  
	Operation - 6: INSERT delegate access
	Operation - 7: DELETE delegate access
	Operation - 8: GET delegate acceess
	Operation - 9: UPDATE delegate access
	Operation - 10: GET userroles on user/role
	Operation - 11: GET delegateAccess
	Operation - 12: INSERT delegate access all from role/user
	Operation - 13: UPDATE all delegate access (revoke all access) 
	Operation - 14: GET delegate login
	Operation - 15: UPDATE delegate expire date
	*/
	BEGIN TRY
		SET @EmployeeID = (SELECT  COALESCE(B.EmployeeID,A.EmployeeID) FROM stng.Admin_User A 
			LEFT JOIN (
				SELECT * FROM stng.Admin_Impersonate B WHERE B.Active = 1
			) B ON B.EmployeeID = A.EmployeeID
			WHERE A.EmployeeID = @EmployeeID)
	
	/*GET delegates*/
	IF(@Operation = 1) 
		SELECT D.DelegateID
			,D.FromUserID
			,D.ToUserID
			,UFrom.FullName 'From'
			,UTo.FullName 'To'
			,D.Description
			,D.CreatedBy
			,D.CreatedDate
			,D.Active
			,D.ExpireDate
			,UFrom.Username 'FromUsername'
			,UTo.Username 'ToUsername'
			,R.NameShort 'ToRole'
			,(SELECT COUNT(*) FROM stng.FN_Admin_DelegateAccess(UTo.EmployeeID) DA WHERE DA.DelegateID = D.DelegateID AND Type !='Endpoint') AS ActiveAccess
			,(SELECT COUNT(*) FROM stng.VV_Admin_DelegateAccess DA WHERE DA.DelegateID = D.DelegateID AND Type != 'Endpoint') AS TotalAccess
		FROM stng.Admin_Delegate D
		INNER JOIN stng.Admin_User UFrom ON UFrom.UserID = D.FromUserID
		INNER JOIN stng.Admin_User UTo ON UTo.UserID = D.ToUserID
		INNER JOIN stng.Admin_UserRole UR ON UR.UserID = UTo.UserID
		INNER JOIN stng.[Admin_Role] R ON R.RoleID = UR.RoleID AND UR.[Default] = 1

	/*UPDATE active on delegate*/
	ELSE IF(@Operation = 2) UPDATE stng.Admin_Delegate SET Active = @IsTrue1 WHERE stng.Admin_Delegate.DelegateID = @Num1

	/*DELETE delegate*/
	ELSE IF(@Operation = 3) 
		BEGIN
			DELETE D FROM stng.Admin_DelegateAccess D WHERE D.DelegateID = @Num1
			DELETE D FROM stng.Admin_Delegate D WHERE D.DelegateID = @Num1
		END

	/*INSERT delegate*/
	ELSE IF(@Operation = 4)
		BEGIN
			INSERT INTO stng.Admin_Delegate(FromUserID,ToUserID,Description,CreatedBy,ExpireDate) VALUES((SELECT U.UserID FROM stng.[Admin_User] U WHERE U.EmployeeID = @EmployeeID),@Num1,@Value1,@EmployeeID,@Date1);
			INSERT INTO stng.Admin_DelegateAccess(UAID,DelegateID,CreatedBy) SELECT V.UAID,@@IDENTITY,@EmployeeID FROM stng.FN_Admin_UserAccess(@EmployeeID) V
			SELECT D.DelegateID
				,D.FromUserID
				,D.ToUserID
				,UFrom.FullName 'From'
				,UTo.FullName 'To'
				,D.[Description]
				,D.CreatedBy
				,D.CreatedDate
				,D.Active
				,D.[ExpireDate]
				,UFrom.Username 'FromUsername'
				,UTo.Username 'ToUsername'
				,R.NameShort 'ToRole'
				,(SELECT COUNT(*) FROM stng.FN_Admin_DelegateAccess(UTo.EmployeeID) DA WHERE DA.DelegateID = D.DelegateID AND Type !='Endpoint') AS ActiveAccess
				,(SELECT COUNT(*) FROM stng.VV_Admin_DelegateAccess DA WHERE DA.DelegateID = D.DelegateID AND Type != 'Endpoint') AS TotalAccess
			FROM stng.Admin_Delegate D
			INNER JOIN stng.Admin_User UFrom ON UFrom.UserID = D.FromUserID
			INNER JOIN stng.Admin_User UTo ON UTo.UserID = D.ToUserID
			INNER JOIN stng.Admin_UserRole UR ON UR.UserID = UTo.UserID
			INNER JOIN stng.[Admin_Role] R ON R.RoleID = UR.RoleID AND UR.[Default] = 1
			WHERE UFrom.EmployeeID = @EmployeeID
		END

	/*GET all users*/
	ELSE IF(@Operation = 5) 
		BEGIN
			-- users
			SELECT U.FullName,U.UserID,R.NameShort AS 'Role'
			FROM stng.Admin_User U 
			INNER JOIN stng.Admin_UserRole UR ON UR.UserID = U.UserID
			INNER JOIN stng.[Admin_Role] R ON R.RoleID = UR.RoleID AND UR.[Default] = 1
			WHERE U.Active = 1 
			AND U.UserID NOT IN (SELECT D.ToUserID FROM stng.Admin_Delegate D WHERE D.FromUserID = 
				(SELECT U.UserID FROM stng.[Admin_User] U WHERE U.EmployeeID = @EmployeeID))
			AND U.EmployeeID != @EmployeeID
			ORDER BY FullName
		END

	/*INSERT delegate access*/
	ELSE IF(@Operation = 6) 
		BEGIN
			INSERT INTO stng.Admin_DelegateAccess(UAID,DelegateID,CreatedBy) VALUES (@Num1,@Num2,@EmployeeID)
			SELECT D.DAID
				,D.DelegateID
				,D.Access
				,A.[Name]
				,A.[Type]
				,D.UAID
				,M.[Name] [Module]
			FROM stng.Admin_DelegateAccess D
			INNER JOIN stng.Admin_UserAccess UA ON D.UAID = UA.UAID
			INNER JOIN stng.Admin_AppSecurity A ON A.ASID = UA.ASID
			INNER JOIN stng.Admin_Module M ON M.ModuleID = A.ModuleID
			WHERE DelegateID IN (SELECT D.DelegateID FROM stng.Admin_Delegate D WHERE D.FromUserID = 
				(SELECT U.UserID FROM stng.[Admin_User] U WHERE U.EmployeeID = @EmployeeID))
		END

	/*DELETE delegate access*/
	ELSE IF(@Operation = 7) DELETE FROM stng.Admin_DelegateAccess WHERE DAID = @Num1

	/*GET delegate access*/
	ELSE IF(@Operation = 8) 
		SELECT DA.DAID
			,D.DelegateID
			,DA.Access
			,A.[Name]
			,A.[Type]
			,DA.UAID
			,M.[Name] [Module]
			,A.Description
			,R.RoleID
			,R.Name [Role]
		FROM stng.Admin_DelegateAccess DA
		INNER JOIN stng.Admin_Delegate D ON D.DelegateID = DA.DelegateID
		INNER JOIN stng.Admin_UserAccess UA ON DA.UAID = UA.UAID AND UA.Access = 1
		INNER JOIN stng.Admin_AppSecurity A ON A.ASID = UA.ASID AND A.Active = 1
		INNER JOIN stng.Admin_Module M ON M.ModuleID = A.ModuleID
		LEFT JOIN stng.Admin_Role R ON R.RoleID = UA.RoleID
		WHERE D.DelegateID = @Num1 AND A.[Type] != 'Endpoint' 
		ORDER BY M.[Name],A.[Name]

	/*UPDATE delegate access*/
	ELSE IF(@Operation = 9)
		BEGIN
			/*update all matching privileges on each role and on user*/
			UPDATE stng.Admin_DelegateAccess SET Access = @IsTrue1 FROM (
				SELECT D.DAID FROM stng.Admin_DelegateAccess D
				INNER JOIN stng.Admin_UserAccess U ON U.UAID = D.UAID 
				CROSS APPLY (
					SELECT U.ASID,D.DelegateID FROM stng.Admin_DelegateAccess D 
					INNER JOIN stng.Admin_UserAccess U ON U.UAID = D.UAID AND D.DAID = @Num1
				) A
				WHERE A.ASID = U.ASID 
				AND D.DelegateID = A.DelegateID
			) B
			WHERE stng.Admin_DelegateAccess.DAID = B.DAID;

			SELECT D.DAID
				,D.DelegateID
				,D.Access
				,A.[Name]
				,A.[Type]
				,D.UAID
				,M.[Name] [Module]
				,A.Description
				,R.RoleID
			FROM stng.Admin_DelegateAccess D
			INNER JOIN stng.Admin_Delegate DA ON DA.DelegateID = D.DelegateID
			INNER JOIN stng.Admin_UserAccess UA ON D.UAID = UA.UAID AND UA.Access = 1
			INNER JOIN stng.Admin_AppSecurity A ON A.ASID = UA.ASID AND A.Active = 1
			INNER JOIN stng.Admin_Module M ON M.ModuleID = A.ModuleID
			INNER JOIN stng.Admin_DelegateAccess D2 ON D2.DelegateID = D.DelegateID AND D2.DAID = @Num1
			LEFT JOIN stng.Admin_Role R ON R.RoleID = UA.RoleID
			ORDER BY M.[Name],A.[Name]
		END

	/*GET userroles on user/role*/
	ELSE IF(@Operation = 10)	
		SELECT UR.RoleID,UR.NameShort AS [Role],UR.Department,M.Name AS Module FROM stng.VV_Admin_UserRole UR
		LEFT JOIN stng.Admin_Module M ON M.ModuleID = UR.ModuleID
		WHERE UR.EmployeeID = @EmployeeID
		
	/*GET Useraccess, DelegateAccess*/
	ELSE IF(@Operation = 11)
		BEGIN
			SELECT V.* FROM stng.FN_Admin_UserAccess(@EmployeeID) V
			SELECT D.DAID
				,D.DelegateID
				,D.Access
				,A.[Name]
				,A.[Type]
				,D.UAID
				,M.[Name] [Module]
			FROM stng.Admin_DelegateAccess D
			INNER JOIN stng.Admin_UserAccess UA ON D.UAID = UA.UAID
			INNER JOIN stng.Admin_AppSecurity A ON A.ASID = UA.ASID
			INNER JOIN stng.Admin_Module M ON M.ModuleID = A.ModuleID
			WHERE DelegateID IN (SELECT D.DelegateID FROM stng.Admin_Delegate D WHERE D.FromUserID = 
				(SELECT U.UserID FROM stng.Admin_User U WHERE U.EmployeeID = @EmployeeID))
		END

	/*INSERT delegate access all from role/user*/
	ELSE IF(@Operation = 12) 
		BEGIN
			IF(@Value1 = 'User')
				INSERT INTO stng.Admin_DelegateAccess(UAID,DelegateID,CreatedBy)
				SELECT V.UAID,@Num1,@EmployeeID FROM stng.FN_Admin_UserAccess(@EmployeeID) V
				WHERE V.UAID NOT IN (SELECT D.UAID FROM stng.Admin_DelegateAccess D WHERE D.DelegateID = @Num1)

			ELSE IF(@Value1 = 'Role')
				INSERT INTO stng.Admin_DelegateAccess(UAID,DelegateID,CreatedBy)
				SELECT V.UAID,@Num1,@EmployeeID FROM stng.FN_Admin_UserAccess(@EmployeeID) V WHERE V.RoleID = @Num2 
				AND V.UAID NOT IN (SELECT D.UAID FROM stng.Admin_DelegateAccess D WHERE D.DelegateID = @Num1)

			SELECT D.DAID
				,D.DelegateID
				,D.Access
				,A.[Name]
				,A.[Type]
				,D.UAID
				,M.[Name] [Module]
			FROM stng.Admin_DelegateAccess D
			INNER JOIN stng.Admin_UserAccess UA ON D.UAID = UA.UAID
			INNER JOIN stng.Admin_AppSecurity A ON A.ASID = UA.ASID
			INNER JOIN stng.Admin_Module M ON M.ModuleID = A.ModuleID
			WHERE DelegateID IN (SELECT D.DelegateID FROM stng.Admin_Delegate D WHERE D.FromUserID = 
				(SELECT U.UserID FROM stng.Admin_User U WHERE U.EmployeeID = @EmployeeID))
		END

	/*UPDATE all delegate access (revoke all access) */
	ELSE IF(@Operation = 13) 
		BEGIN
			DELETE A FROM stng.Admin_DelegateAccess A WHERE A.DelegateID = @Num1
			DELETE D FROM stng.Admin_Delegate D WHERE D.DelegateID = @Num1
		END
		
	/*GET delegate login*/
	ELSE IF(@Operation = 14)
		BEGIN
			-- Get delegator information 
			SELECT U.FullName name,U.Username username,U.EmployeeID employeeID,D.DelegateID delegateID,U.EmpName employeeName,U.RoleShort roleShort
			FROM stng.Admin_Delegate D 
			INNER JOIN stng.VV_Admin_UserView U ON U.UserID = D.FromUserID
			WHERE D.ToUserID = (SELECT UserID FROM stng.Admin_User U WHERE U.EmployeeID = @EmployeeID)
			AND D.Active = 1
			AND CAST(GETDATE() AS DATE) < CAST(D.ExpireDate AS DATE)

			-- Get delegate access 
			SELECT D.Name,D.Type,D.Module,D.DelegateID FROM stng.FN_Admin_DelegateAccess(@EmployeeID) D WHERE D.Type != 'Endpoint'
		END

	/*UPDATE Delegate expire date*/
	ELSE IF(@Operation = 15) UPDATE stng.Admin_Delegate SET ExpireDate = @Date1 WHERE DelegateID = @Num1

	END TRY
	BEGIN CATCH
		INSERT INTO stng.App_ErrorLog([Number],[Procedure],[Line],[Message],[Operation]) VALUES (
			ERROR_NUMBER(),
			ERROR_PROCEDURE(),
			ERROR_LINE(),
			ERROR_MESSAGE(),
			@Operation
        )
		THROW
	END CATCH
END
GO