/*
Author: Habib Shakibanejad
Description: This procedure will return module and field access for the given username.
CreatedDate: 3 July 2021
RevisedDate:
RevisedBy: 
*/
CREATE OR ALTER PROCEDURE [stng].[SP_0015_UserAccess](
	@Operation TINYINT
	,@Username NVARCHAR(255)
	,@Role NVARCHAR(255) = NULL
	,@RoleID INT = NULL
	,@FieldName NVARCHAR(255) = NULL
	,@Description NVARCHAR(1000) = NULL
	,@Type NVARCHAR(255) = NULL
	,@Module NVARCHAR(255) = NULL
	,@Access BIT = NULL
	,@UserID NVARCHAR(255) = NULL
	,@FCID INT = NULL
	,@FAID INT = NULL

	,@Error INT = NULL OUTPUT
	,@ErrorDescription NVARCHAR(4000) = NULL OUTPUT 
) AS 
BEGIN
	/*
	Operation 1: GET User Access
	Operation 2: UPDATE main Role on User
	Operation 3: UPDATE Role permissions
	Operation 4: INSERT new Role
	Operation 5: GET Roles and module access
	Operation 6: UPDATE Active status on User
	Operation 7: GET field collection and field access
	Operation 8: INSERT new role to UserRole
	Operation 9: UPDATE active status on UserRole
	Operation 10: UPDATE active status on field collection
	Operation 11: INSERT new Field access to Role
	Operation 12: UPDATE Access status on field
	Operation 13: INSERT new Field to collection
	Operation 14: DELETE field from collection
	Operation 15: GET User Roles
	Operation 16: DELETE User Role
	Operation 17: GET Admin Info
	Operation 18: UPDATE send feedback email 
	Operation 19: UPDATE User email 
	Operation 20: UPDATE FirstName
	Operation 21: UPDATE LastName
	Operation 22: DELETE Role
	*/
	BEGIN TRY
		DECLARE @sql NVARCHAR(255)

		IF(@Operation = 1)
			BEGIN
			DECLARE @userRoleId INT
			DECLARE @count TINYINT
			DECLARE @guestId TINYINT

			SET @userRoleId = (SELECT U.RoleId FROM stng.Users U INNER JOIN stng.Role R ON R.RoleId = U.RoleId WHERE U.PK_Username = @Username)
			SET @count = (SELECT COUNT(*) FROM stng.Users U WHERE UPPER(U.PK_Username) = UPPER(@Username))

			IF(@count <= 0)
			BEGIN
				SET @guestId = (SELECT R.RoleId FROM [stng].[Role] R WHERE R.Name = 'Guest')

				INSERT INTO [stng].[Users](PK_Username,Role,RoleId,JoinedDate) VALUES
				(UPPER(@Username),'Guest',@guestId,FORMAT(GETDATE(),'yyyy-MM-ddTHH:mm:ss.fffZ'))
			END			
	
			/*Grab user module permissions*/
			SELECT UPPER(A.PK_Username) AS PK_Username
				,(SELECT R.Name FROM stng.Role R WHERE R.RoleId = A.RoleId) AS [Role] 
				,IIF(SUM(CAST(A.CARLA AS INT))>0,1,0) AS [CARLA]
				,IIF(SUM(CAST(A.ETDB AS INT))>0,1,0) AS [ETDB]
				,IIF(SUM(CAST(A.Escalation AS INT))>0,1,0) AS [Escalation]
				,IIF(SUM(CAST(A.Admin AS INT))>0,1,0) AS Admin
				,IIF(SUM(CAST(A.Procurement AS INT))>0,1,0) AS [Procurement]
				,IIF(SUM(CAST(A.SORT AS INT))>0,1,0) AS [SORT]
				,IIF(SUM(CAST(A.Estimating AS INT))>0,1,0) AS [Estimating]
				,A.Active
				,A.FullName
			FROM (
				SELECT U.PK_Username,R.Admin,R.CARLA,R.Escalation,R.ETDB,R.Procurement,R.SORT,R.Estimating,U.Active,U.RoleId,U.FullName
				FROM stng.Users U,stng.Role R
				WHERE UPPER(U.PK_Username) = UPPER(@Username)
				AND R.RoleId = U.RoleId
				UNION
				SELECT U.PK_Username,R.Admin,R.CARLA,R.Escalation,R.ETDB,R.Procurement,R.SORT,R.Estimating,U.Active,U.RoleId,U.FullName
				FROM stng.Role R
				INNER JOIN stng.UserRole UR ON UR.RoleID = R.RoleId 
				INNER JOIN stng.Users U ON UPPER(U.PK_Username) = UPPER(UR.UserID)
				AND UPPER(U.PK_Username) = UPPER(@Username)
				) AS A
			GROUP BY A.PK_Username,A.Active,A.RoleId,A.FullName

			/*Grab permissions from user role. This will include additional roles and field access*/
			SELECT IIF(SUM(CAST(A.Access AS INT))>0,1,0) AS [Access],A.Module,A.Name FROM (
				SELECT FA.Access,FC.Module,FC.Name FROM stng.FieldAccess FA
				INNER JOIN stng.FieldCollection FC ON FC.FCID = FA.FCID 
				LEFT JOIN stng.Users U ON U.RoleId = FA.RoleID
				WHERE UPPER(U.PK_Username) = UPPER(@Username)
				AND FC.Active = 1
				AND U.Active = 1
				UNION
				SELECT FA.Access,FC.Module,FC.Name FROM stng.FieldAccess FA
				INNER JOIN stng.FieldCollection FC ON FC.FCID = FA.FCID 
				LEFT JOIN stng.UserRole UR ON UR.RoleID = FA.RoleID
				LEFT JOIN stng.Users U ON UPPER(U.PK_Username) = UPPER(UR.UserID)
				WHERE UPPER(U.PK_Username) = UPPER(@Username)
				AND FC.Active = 1
				AND UR.Active = 1
			) A
			GROUP BY A.Module, A.Name

			/*Update last login time*/
			UPDATE stng.Users SET LastLogin = FORMAT(GETDATE(),'yyyy-MM-ddTHH:mm:ss.fffZ') WHERE UPPER(PK_Username) = UPPER(@Username)
		END

		/*Update main role on user*/
		IF(@Operation = 2)
		BEGIN
			UPDATE [stng].[Users] SET Role = @Role,
				RoleId = (SELECT R.RoleId FROM [stng].[Role] R WHERE R.Name = @Role)
			WHERE UPPER([stng].[Users].PK_Username) = UPPER(@Username)
		END

		/*Update Role permissions*/
		IF(@Operation = 3)
		BEGIN
			SELECT @sql = 'UPDATE stng.Role SET stng.Role.['+@Module+'] = '+CONVERT(NVARCHAR(2),@Access) +' WHERE Name = '+ CONCAT('''',@Role,'''')
			EXEC(@sql)
			SELECT R.Admin,R.CARLA,R.Escalation,R.ETDB,R.Name,R.Procurement,R.SORT,R.Estimating,R.RoleId 
			FROM stng.Role R ORDER BY R.Name ASC
		END

		/*Create new Role*/
		IF(@Operation = 4)
		BEGIN
			INSERT INTO stng.Role(Name,Admin,CARLA,Escalation,ETDB,Procurement,SORT) VALUES (@Role,0,0,0,0,0,0)
			SELECT Name,Admin,CARLA,Escalation,ETDB,Procurement,SORT,Estimating,RoleId FROM stng.Role ORDER BY Name ASC
		END
		
		/*Get Users,Roles and UserRoles*/
		IF(@Operation = 5)
		BEGIN
			/*Users*/
			SELECT UPPER(U.PK_Username) AS [UserId]
				,FirstName
				,LastName
				,FORMAT(CAST(U.JoinedDate AS DATETIME),'dd-MMM-yyyy') AS 'JoinedDate'
				,R.Name AS [Role]
				,U.RoleId
				,U.Active
				,FORMAT(CAST(U.LastLogin AS DATETIME),'dd-MMM-yyyy h:mm tt') AS 'LastLogin' 
			FROM stng.Users U 
			LEFT JOIN stng.Role R ON R.RoleId = U.RoleId
			ORDER BY U.PK_Username
			
			/*Roles*/
			SELECT RoleId,Name,Admin,CARLA,Escalation,ETDB,Procurement,SORT,Estimating FROM stng.Role ORDER BY Name ASC
			
			/*UserRoles*/
			SELECT UR.UserID,Active,CreatedBy,CreatedDate,R.Name AS [Role] FROM stng.UserRole UR
			INNER JOIN stng.Role R ON R.RoleId = UR.RoleID
			ORDER BY R.Name
		END

		/*Update Active Status on User*/
		IF(@Operation = 6)
		BEGIN
			UPDATE [stng].[Users] SET Active = @Access WHERE [stng].[Users].PK_Username = @Username

			SELECT UPPER(U.PK_Username) AS [UserId]
				,FirstName
				,LastName
				,FORMAT(CAST(U.JoinedDate AS DATETIME),'dd-MMM-yyyy') AS 'JoinedDate'
				,R.Name AS [Role]
				,U.RoleId
				,U.Active
				,FORMAT(CAST(U.LastLogin AS DATETIME),'dd-MMM-yyyy h:mm tt') AS 'LastLogin' 
			FROM stng.Users U 
			LEFT JOIN stng.Role R ON R.RoleId = U.RoleId
			ORDER BY U.PK_Username
		END

		/*Get field collection and field access*/
		IF(@Operation = 7)
		BEGIN	
			SELECT FC.FCID,FC.Module,FC.Name,FC.Type,FC.Description,FC.Active FROM stng.FieldCollection FC
			ORDER BY FC.Module,FC.Name
			
			SELECT R.Name,R.RoleId FROM stng.Role R

			SELECT FA.FAID,FA.FCID,R.Name AS [Role],FC.Description,FC.Active,FA.Access,FC.Module,FC.Name,FC.Type,FA.RoleID
			FROM stng.FieldAccess FA
			LEFT JOIN stng.FieldCollection FC ON FC.FCID = FA.FCID
			LEFT JOIN stng.Role R ON R.RoleId = FA.RoleID
			ORDER BY FC.Module,FC.Name
		END

		/*Add new role to UserRole*/
		IF(@Operation = 8)
		BEGIN
			INSERT INTO stng.UserRole(UserID,RoleID,CreatedBy) VALUES 
			(@UserID,@RoleID,@Username)

			/*UserRoles*/
			SELECT UR.UserID,Active,CreatedBy,CreatedDate,R.Name AS [Role] FROM stng.UserRole UR
			INNER JOIN stng.Role R ON R.RoleId = UR.RoleID
			ORDER BY R.Name
		END

		/*Update active status on UserRole*/
		IF(@Operation = 9)
		BEGIN
			UPDATE stng.UserRole SET Active = @Access 
			WHERE UserID = @UserID AND RoleID = (SELECT RoleId FROM stng.Role WHERE Name = @Role) 

			/*UserRoles*/
			SELECT UR.UserID,Active,CreatedBy,CreatedDate,R.Name AS [Role] FROM stng.UserRole UR
			INNER JOIN stng.Role R ON R.RoleId = UR.RoleID
			ORDER BY R.Name
		END

		/*Update active status on field collection*/
		IF(@Operation = 10)
		BEGIN
			UPDATE stng.FieldCollection SET Active = @Access WHERE FCID = @FCID

			SELECT FC.FCID,FC.Module,FC.Name,FC.Type,FC.Description,FC.Active FROM stng.FieldCollection FC
			ORDER BY FC.Module,FC.Name
		END

		/*Add new Field access to Role*/
		IF(@Operation = 11)
		BEGIN
			INSERT INTO stng.FieldAccess(FCID,RoleID,Access) VALUES (@FCID,@RoleID,1)

			SELECT FA.FAID,FA.FCID,R.Name AS [Role],FC.Description,FC.Active,FA.Access,FC.Module,FC.Name,FC.Type,FA.RoleID
			FROM stng.FieldAccess FA
			LEFT JOIN stng.FieldCollection FC ON FC.FCID = FA.FCID
			LEFT JOIN stng.Role R ON R.RoleId = FA.RoleID
			WHERE FA.RoleID = @RoleID
			ORDER BY FC.Module,FC.Name
		END

		/*Update Access status on field*/
		IF(@Operation = 12)
		BEGIN
			UPDATE stng.FieldAccess SET Access = @Access WHERE FAID = @FAID

			SELECT FA.FAID,FA.FCID,R.Name AS [Role],FC.Description,FC.Active,FA.Access,FC.Module,FC.Name,FC.Type,FA.RoleID
			FROM stng.FieldAccess FA
			LEFT JOIN stng.FieldCollection FC ON FC.FCID = FA.FCID
			LEFT JOIN stng.Role R ON R.RoleId = FA.RoleID
			WHERE FA.RoleID = (SELECT FA2.RoleID FROM stng.FieldAccess FA2 WHERE FA2.FAID = @FAID)
			ORDER BY FC.Module,FC.Name
		END

		/*Add new Field to collection*/
		IF(@Operation = 13)
		BEGIN
			INSERT INTO stng.FieldCollection(Module,Name,Type,Description) VALUES 
			(@Module,@FieldName,@Type,@Description)

			SELECT FC.FCID,FC.Module,FC.Name,FC.Type,FC.Description,FC.Active FROM stng.FieldCollection FC
			ORDER BY FC.Module,FC.Name
		END

		/*Delete field from collection*/
		IF(@Operation = 14)
		BEGIN
			DELETE FROM stng.FieldAccess WHERE FCID = @FCID
			DELETE FROM stng.FieldCollection WHERE FCID = @FCID
			SELECT FC.FCID,FC.Module,FC.Name,FC.Type,FC.Description,FC.Active FROM stng.FieldCollection FC
			ORDER BY FC.Module,FC.Name
		END

		/*Get User Roles*/
		IF(@Operation = 15)
		BEGIN
			SELECT UR.Active,UR.RGID,U.PK_Username AS 'UserID' FROM stng.UserRole UR
			INNER JOIN stng.Users U ON U.PK_Username = UR.UserID
			WHERE UR.RoleID = @RoleID
		END

		/*Delete User Role*/
		IF(@Operation = 16)
		BEGIN
			DELETE FROM stng.UserRole WHERE RoleID = @RoleID AND UserID = @UserID
		END
		/*Operation 17: Get Admin Info*/
		IF(@Operation = 17)
		BEGIN
			SELECT U.PK_Username AS 'Username',U.Email,U.EmailFeedback FROM stng.Users U
			INNER JOIN stng.Role R ON R.RoleId = U.RoleId
			WHERE R.Name = 'Admin' AND U.Active = 1
		END

		/*Operation 18: Update send feedback email*/
		IF(@Operation = 18)
		BEGIN
			UPDATE stng.Users SET EmailFeedback = @Access
			WHERE PK_Username = @UserID
		END

		/*Operation 19: Update User email*/
		IF(@Operation = 19)
		BEGIN
			UPDATE stng.Users SET Email = @FieldName
			WHERE PK_Username = @UserID
		END

		/*Operation 20: Update FirstName*/
		IF(@Operation = 20)
		BEGIN
			UPDATE stng.Users SET FirstName = @FieldName
			WHERE PK_Username = @UserID
		END

		/*Operation 21: Update LastName*/
		IF(@Operation = 21)
		BEGIN
			UPDATE stng.Users SET LastName = @FieldName
			WHERE PK_Username = @UserID
		END

		/*Operation 22: DELETE Role*/
		IF(@Operation = 22)
		BEGIN
			DECLARE @Total INT
			SELECT @Total = SUM(A.[User] + A.UserRole) FROM (
				SELECT COUNT(*) AS 'User',0 AS 'UserRole' FROM stng.Users U WHERE U.RoleId = @RoleID
				UNION 
				SELECT 0, COUNT(*) FROM stng.UserRole UR WHERE UR.RoleID = @RoleID
			) A

			IF(@Total > 0)
			BEGIN
				SELECT @Total AS 'Error', 'Cannot remove role. Role is currently assigned to user(s)' AS 'ErrorDescription'
				RETURN
			END
			DELETE FROM stng.UserRole WHERE RoleID = @RoleID
			DELETE FROM stng.Role WHERE RoleId = @RoleID
			DELETE FROM stng.FieldAccess WHERE RoleID = @RoleID
		END
	END TRY
	BEGIN CATCH
		INSERT INTO stng.ErrorLog([Number],[Procedure],[Line],[Message],[Date],[Operation]) VALUES (
			ERROR_NUMBER(),
			ERROR_PROCEDURE(),
			ERROR_LINE(),
			ERROR_MESSAGE(),
			FORMAT(GETDATE(),'yyyy-MM-ddTHH:mm:ss.fffZ'),
			@Operation
        )

		INSERT INTO stng.ActionLog(Action,ObjectName,ExecutionMessage,EndTime) VALUES
		('EXECPROC','SP_0015_UserAccess','Failed EXEC - '+ERROR_MESSAGE(),GETDATE())

		SET @Error = ERROR_NUMBER()
		SET @ErrorDescription = ERROR_MESSAGE()
	END CATCH
END
GO


