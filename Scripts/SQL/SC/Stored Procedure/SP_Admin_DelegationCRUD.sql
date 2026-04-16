/****** Object:  StoredProcedure [stng].[SP_Admin_DelegationCRUD]    Script Date: 10/22/2024 11:22:32 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
CreatedBy: Minh
Created Date: 26 Jul 2024
Description: Delegation CRUD

*/
ALTER   PROCEDURE [stng].[SP_Admin_DelegationCRUD](
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
	Operation - 2: Insert new delegates
	Operation - 3: Get All Users
	Operation - 4: Get User Role
	Operation - 5: Get Delegation Role  
	Operation - 6: Insert Delegate Role
	Operation - 7: Get User Permission
	Operation - 8: Insert User Permission
	Operation - 9: Get Delegate Permission
	Operation - 10: Get Delegate role-permission links
	Operation - 11: Get Delegation Checklist
	Operation - 12: Update Permission
	Operation - 13: Update Role
	Operation - 14: Clone Delegation
	Operation - 15: Update Indefinite
	Operation - 16: Update Expire Date
	Operation - 17: Update Active
	Operation - 18: Delete Delegation
	Operation - 19: Get Delegator
	Operation - 20: Get Delegator Role
	Operation - 21: Get Delegatee Permission
	Operation - 22: Get Delegatee Checklist
	Operation - 23: Get Delegatee Permission
	*/
	SET @EmployeeID = (SELECT  COALESCE(B.EmployeeID,A.EmployeeID) FROM stng.Admin_User A 
			LEFT JOIN (
				SELECT * FROM stng.Admin_Impersonate B WHERE B.Active = 1
			) B ON B.EmployeeID = A.EmployeeID
			WHERE A.EmployeeID = @EmployeeID)
	
	/*GET delegates*/
	IF(@Operation = 1) 

		BEGIN
			SELECT [UniqueID]
			  ,[Delegator]
			  ,[Delegatee]
			  , (b.FirstName + ' ' + b.LastName) as [DelegateeName]
			  --,[Description]
			  ,a.[Active]
			  ,a.Indefinite
			  ,[ExpireDate]
			  ,[CreatedBy]
			  ,a.[CreatedDate]
			  ,CASE
			
				WHEN Indefinite = 1 and a.Active = 1 THEN 'Active'
				WHEN Indefinite = 1 and a.Active = 0 THEN 'Disabled'
				WHEN a.[Active] = 1 and ExpireDate >= stng.GetDate() THEN 'Active' 
				WHEN a.[Active] = 1 and ExpireDate <= stng.GetDate() THEN 'Expired' 
				WHEN a.[Active] = 0 and ExpireDate >= stng.GetDate() THEN 'Disabled'
				WHEN a.[Active] = 0 and ExpireDate <= stng.GetDate() THEN 'Expired'
			
			  END  AS [Status]

			  FROM (SELECT * FROM [stng].[Admin_Delegation] WHERE Delegator = @EmployeeID and Deleted=0) as a
			  LEFT JOIN stng.Admin_User as b on b.EmployeeID = a.Delegatee
			  --WHERE a.Delegator = @EmployeeID and a.Deleted = 0
		  END

	/*INSERT delegate*/
	IF(@Operation = 2)

		IF exists(
		SELECT * FROM stng.Admin_Delegation WHERE Delegatee = @Value1 and Delegator = @EmployeeID and Deleted = 0
		) 
			BEGIN
				SELECT 'Delegatee already exist' as ReturnMessage;
				RETURN;
			END
		ELSE IF (@EmployeeID = @Value1)
			
			BEGIN
				SELECT 'You cannot delegate to yourself' as ReturnMessage;
				RETURN;
			END
		ELSE
			BEGIN 
				INSERT INTO stng.Admin_Delegation (Delegator,Delegatee,[Active],[ExpireDate],[CreatedBy],[CreatedDate]) VALUES (@EmployeeID,@Value1,1,@Date1,@EmployeeID,stng.GetDate())
				RETURN;
			END	

	/*GET all users*/
	IF(@Operation = 3) 
		BEGIN
			SELECT 
			  [EmployeeID]
			  , FirstName + ' ' + LastName + ' ('+ EmployeeID + ')' as [Full]
			FROM [stng].[Admin_User]
			WHERE Active = 1
		END


	/*GET userroles on user/role*/
	IF(@Operation = 4)	
		
		SELECT a.[UniqueID]
		  ,a.[EmployeeID]
		  ,[RoleID]
		  ,b.[Role]
		  ,a.[RAD]
		  ,a.[RAB]
		  ,a.[Deleted]
		  ,a.[DeletedBy]
		  ,a.[DeletedOn]
		 FROM (SELECT * FROM [stng].[Admin_UserRole] WHERE EmployeeID = @EmployeeID ) as a
		 LEFT JOIN stng.Admin_Role as b on b.UniqueID = a.RoleID
		 --WHERE a.EmployeeID = @EmployeeID
		
	/*Get Delegation Role*/
	IF(@Operation = 5)

		BEGIN
			SELECT b.[UniqueID]
			  ,b.[RoleUID]
			  ,b.DelegateUID
			  ,c.Role
			  ,b.[Enabled]
			FROM (SELECT * FROM stng.Admin_Delegation WHERE Delegator = @EmployeeID and Deleted = 0 ) as a
			LEFT JOIN  [stng].[Admin_DelegateRole] as b on a.UniqueID = b.DelegateUID
			LEFT JOIN  stng.[Admin_Role] as c on b.RoleUID = c.UniqueID
			--WHERE c.Delegator = @EmployeeID and c.Deleted = 0
		END


	/*INSERT delegate role*/
	IF(@Operation = 6) 

		
		IF exists(
		SELECT * FROM [stng].[Admin_DelegateRole] WHERE DelegateUID = @Value1 and RoleUID = @Value2
		) 
			BEGIN
				SELECT 'Role already exist' as ReturnMessage;
				RETURN;
			END
		ELSE
			BEGIN
				INSERT INTO [stng].[Admin_DelegateRole] (DelegateUID,RoleUID,[Enabled],[CreatedBy],[CreatedDate]) VALUES (@Value1,@Value2,1,@EmployeeID,stng.GetDate())

				INSERT INTO [stng].[Admin_DelegatePermission] (DelegateUID,[PermissionUID],[Enabled],[CreatedBy],[CreatedDate])
		
				SELECT
					@Value1 as DelegateUID,
					[PermissionID],
					1 as Enabled,
					@EmployeeID as CreeatedBy,
					stng.GetDate() as CreatedDate 
					FROM [stng].[Admin_RolePermission] as a
					LEFT JOIN (
					SELECT [PermissionUID] FROM [stng].[Admin_DelegatePermission]
					WHERE DelegateUID = @Value1
					) as b on b.PermissionUID = a.PermissionID
					WHERE RoleID = @Value2 and b.PermissionUID is null

				RETURN;
			END

	
	/*GET user permission*/
	IF(@Operation = 7)
		BEGIN
		  SELECT a.[UniqueID]
		  ,[PermissionID]
		  ,b.Permission
		  ,[EmployeeID]
		  ,a.[Deleted]
		  FROM (SELECT * FROM [stng].[Admin_UserPermission]  WHERE EmployeeID = @EmployeeID) as a
		  LEFT JOIN [stng].[Admin_Permission] as b on b.UniqueID = a.PermissionID
		  --WHERE EmployeeID = @EmployeeID
		END


	/*Insert user permission*/
	IF(@Operation = 8)

		
		IF exists(
		SELECT * FROM [stng].[Admin_DelegatePermission] WHERE DelegateUID = @Value1 and PermissionUID = @Value2
		) 
			BEGIN
				SELECT 'Permission already exist' as ReturnMessage;
				RETURN;
			END
		ELSE
			BEGIN
				INSERT INTO [stng].[Admin_DelegatePermission] (DelegateUID,[PermissionUID],[Enabled],[CreatedBy],[CreatedDate]) VALUES (@Value1,@Value2,1,@EmployeeID,stng.GetDate())
				RETURN;
			END
	
	/*Get delegate permission*/
	IF(@Operation = 9)

		BEGIN
			SELECT a.[UniqueID]
			  ,a.PermissionUID
			  ,a.DelegateUID
			  ,b.Permission
			  ,[Enabled]
			FROM [stng].[Admin_DelegatePermission] as a
			LEFT JOIN  stng.[Admin_Permission] as b on a.PermissionUID = b.UniqueID
			LEFT JOIN  stng.Admin_Delegation as c on a.DelegateUID = c.UniqueID
			LEFT JOIN (
			
			SELECT
			   a.[DelegateUID]
			  ,a.[UniqueID] as DelegateRoleUID
			  ,a.[RoleUID]
			  ,e.Role
			  ,c.UniqueID as DelegatePermissionUID
			  ,b.PermissionID as PermissionUID
			  ,f.Permission
			  ,a.[Enabled] as RoleEnabled
			  ,c.[Enabled] as PermissionEnabled
			  ,d.Delegator
		  FROM [stng].[Admin_DelegateRole] as a
		  LEFT JOIN stng.Admin_RolePermission as b on b.RoleID = a.RoleUID
		  LEFT JOIN stng.Admin_DelegatePermission as c on c.PermissionUID = b.PermissionID and a.DelegateUID = c.DelegateUID
		  LEFT JOIN stng.Admin_Delegation as d on d.UniqueID = a.DelegateUID
		  LEFT JOIN stng.Admin_Role as e on e.UniqueID = a.RoleUID
		  LEFT JOIN stng.Admin_Permission as f on f.UniqueID = c.PermissionUID
			
			) as d on d.DelegatePermissionUID = a.UniqueID
			WHERE d.DelegatePermissionUID is null and c.Delegator = @EmployeeID and c.Deleted = 0
		END


	/*Get delegate role-permission*/
	IF(@Operation = 10)

		BEGIN
			SELECT
			   a.[DelegateUID]
			  ,a.[UniqueID] as DelegateRoleUID
			  ,a.[RoleUID]
			  ,e.Role
			  ,c.UniqueID as DelegatePermissionUID
			  ,b.PermissionID as PermissionUID
			  ,f.Permission
			  ,a.[Enabled] as RoleEnabled
			  ,c.[Enabled] as PermissionEnabled
			  ,d.Delegator
		  FROM [stng].[Admin_DelegateRole] as a
		  LEFT JOIN stng.Admin_RolePermission as b on b.RoleID = a.RoleUID
		  LEFT JOIN stng.Admin_DelegatePermission as c on c.PermissionUID = b.PermissionID and a.DelegateUID = c.DelegateUID
		  LEFT JOIN stng.Admin_Delegation as d on d.UniqueID = a.DelegateUID
		  LEFT JOIN stng.Admin_Role as e on e.UniqueID = a.RoleUID
		  LEFT JOIN stng.Admin_Permission as f on f.UniqueID = c.PermissionUID
		  WHERE d.Delegator = @EmployeeID and d.Deleted = 0


		END

	--Delegation check list
	IF(@Operation = 11)

		BEGIN
			SELECT a.UniqueID, [Enabled] FROM
			(SELECT 
				[UniqueID]
				,DelegateUID
				,[Enabled]
			  FROM [stng].[Admin_DelegatePermission]
			  UNION 
			  SELECT [UniqueID]
				 ,DelegateUID
				 ,[Enabled]
			  FROM [stng].[Admin_DelegateRole]) as a
			  LEFT JOIN stng.Admin_Delegation as b on b.UniqueID = a.DelegateUID
			  WHERE b.Delegator = @EmployeeID and b.Deleted = 0
		END


	--Update Permission
	IF(@Operation = 12)

		BEGIN
			UPDATE [stng].[Admin_DelegatePermission]
			SET Enabled = @IsTrue1
			WHERE UniqueID = @Value1
		END

	--Update Role
	IF(@Operation = 13)

		BEGIN
			UPDATE [stng].[Admin_DelegateRole]
			SET Enabled = @IsTrue1
			WHERE UniqueID = @Value1
		END


	--Clone Delegation
	IF(@Operation = 14)


		IF exists(
			SELECT * FROM stng.Admin_Delegation WHERE Delegatee = @Value2 and Delegator = @EmployeeID and Deleted = 0
		) 
			BEGIN
				SELECT 'Delegatee already exist' as ReturnMessage;
				RETURN;
			END
		ELSE IF (@EmployeeID = @Value2)
			
			BEGIN
				SELECT 'You cannot clone to yourself' as ReturnMessage;
				RETURN;
			END
		ELSE
			BEGIN

				DECLARE @DelegateUIDReturn TABLE(UniqueID varchar(MAX))
				INSERT INTO [stng].[Admin_Delegation] (Delegator,Delegatee,Active,[ExpireDate],CreatedBy,CreatedDate,Indefinite)
				OUTPUT inserted.UniqueID INTO @DelegateUIDReturn

				  SELECT 
					  [Delegator]
					  ,@Value2 as [Delegatee]
					  --,[Description]
					  ,[Active]
					  ,[ExpireDate]
					  ,[CreatedBy]
					  ,stng.GetDate() as CreatedDate
					  ,Indefinite
				  FROM [stng].[Admin_Delegation]
				  WHERE UniqueID = @Value1

				INSERT INTO [stng].[Admin_DelegateRole] (DelegateUID,RoleUID,[Enabled],CreatedBy,CreatedDate)
  
				SELECT 
					  (SELECT TOP 1 UniqueID from @DelegateUIDReturn) as [DelegateUID] 
					  ,[RoleUID]
					  ,[Enabled]
					  ,[CreatedBy]
					  ,stng.GetDate() as CreatedDate
				  FROM [stng].[Admin_DelegateRole]
				  WHERE DelegateUID = @Value1

				INSERT INTO [stng].[Admin_DelegatePermission] (DelegateUID,[PermissionUID],[Enabled],CreatedBy,CreatedDate)

				  SELECT 
						(SELECT TOP 1 UniqueID from @DelegateUIDReturn) as [DelegateUID] 
					  ,[PermissionUID]
					  ,[Enabled]
					  ,[CreatedBy]
					  ,stng.GetDate() as CreatedDate
				  FROM [stng].[Admin_DelegatePermission]
				 WHERE DelegateUID = @Value1
				 RETURN;

			END

		--Update Indefinite
		IF(@Operation = 15)

			BEGIN
				UPDATE [stng].[Admin_Delegation]
				SET Indefinite = @IsTrue1
				WHERE UniqueID = @Value1
			END

		--Update Expire Date
		IF(@Operation = 16)

			BEGIN
				UPDATE [stng].[Admin_Delegation]
				SET ExpireDate = @Date1
				WHERE UniqueID = @Value1
			END

		--Update Active
		IF(@Operation = 17)

			BEGIN
				UPDATE [stng].[Admin_Delegation]
				SET Active = @IsTrue1
				WHERE UniqueID = @Value1
			END
		
		--Delete Delegation
		IF(@Operation = 18)

			BEGIN

				UPDATE [stng].[Admin_Delegation]
				SET Deleted = 1
				WHERE UniqueID = @Value1

				--DELETE
				--FROM [stng].[Admin_Delegation]
				--WHERE UniqueID = @Value1

				--DELETE
				--FROM [stng].[Admin_DelegatePermission]
				--WHERE DelegateUID = @Value1

				--DELETE
				--FROM [stng].[Admin_DelegateRole]
				--WHERE DelegateUID = @Value1
			END


		--Get delegator
		IF(@Operation = 19) 
		
			BEGIN
			SELECT [UniqueID]
			  ,[Delegator]
			  ,[Delegatee]
			  , (b.FirstName + ' ' + b.LastName) as [DelegatorName]
			  ,b.Username
			  --,[Description]
			  ,a.[Active]
			  ,a.Indefinite
			  ,[ExpireDate]
			  ,[CreatedBy]
			  ,a.[CreatedDate]
			  ,CASE
			
				WHEN Indefinite = 1 and a.Active = 1 THEN 'Active'
				WHEN Indefinite = 1 and a.Active = 0 THEN 'Disabled'
				WHEN a.[Active] = 1 and ExpireDate >= stng.GetDate() THEN 'Active' 
				WHEN a.[Active] = 1 and ExpireDate <= stng.GetDate() THEN 'Expired' 
				WHEN a.[Active] = 0 and ExpireDate >= stng.GetDate() THEN 'Disabled'
				WHEN a.[Active] = 0 and ExpireDate <= stng.GetDate() THEN 'Expired'
			
			  END  AS [Status]

			  FROM (SELECT * FROM [stng].[Admin_Delegation] WHERE Delegatee = @EmployeeID and Deleted=0)  as a
			  LEFT JOIN stng.Admin_User as b on b.EmployeeID = a.Delegator
			  --WHERE a.Delegatee = @EmployeeID and a.Deleted = 0
			  END

		  --Get delegator role
		  IF(@Operation = 20)

			BEGIN
				SELECT a.[UniqueID]
				  ,[RoleUID]
				  ,DelegateUID
				  ,b.Role
				  ,[Enabled]
				FROM [stng].[Admin_DelegateRole] as a
				LEFT JOIN  stng.[Admin_Role] as b on a.RoleUID = b.UniqueID
				LEFT JOIN  stng.Admin_Delegation as c on a.DelegateUID = c.UniqueID
				WHERE c.Delegatee = @EmployeeID and c.Deleted = 0
			END

		--get delegatee role-permission
		IF(@Operation = 21)

			BEGIN
				SELECT
				   a.[DelegateUID]
				  ,a.[UniqueID] as DelegateRoleUID
				  ,a.[RoleUID]
				  ,e.Role
				  ,c.UniqueID as DelegatePermissionUID
				  ,b.PermissionID as PermissionUID
				  ,f.Permission
				  ,a.[Enabled] as RoleEnabled
				  ,c.[Enabled] as PermissionEnabled
				  ,d.Delegator
			  FROM [stng].[Admin_DelegateRole] as a
			  LEFT JOIN stng.Admin_RolePermission as b on b.RoleID = a.RoleUID
			  LEFT JOIN stng.Admin_DelegatePermission as c on c.PermissionUID = b.PermissionID and a.DelegateUID = c.DelegateUID
			  LEFT JOIN stng.Admin_Delegation as d on d.UniqueID = a.DelegateUID
			  LEFT JOIN stng.Admin_Role as e on e.UniqueID = a.RoleUID
			  LEFT JOIN stng.Admin_Permission as f on f.UniqueID = c.PermissionUID
			  WHERE d.Delegatee = @EmployeeID and d.Deleted = 0
			END

		--get delegatee checklist
		IF(@Operation = 22)

			BEGIN
				SELECT a.UniqueID, [Enabled] FROM
				(SELECT 
					[UniqueID]
					,DelegateUID
					,[Enabled]
    
				  FROM [stng].[Admin_DelegatePermission]
				  UNION 
				  SELECT [UniqueID]
					 ,DelegateUID
					 ,[Enabled]
				  FROM [stng].[Admin_DelegateRole]) as a
				  LEFT JOIN stng.Admin_Delegation as b on b.UniqueID = a.DelegateUID
				  WHERE b.Delegatee = @EmployeeID and b.Deleted = 0
			END


		--Get delegtee permission roles
		IF(@Operation = 23)

		BEGIN
			
			SELECT a.[UniqueID]
			  ,a.PermissionUID
			  ,a.DelegateUID
			  ,b.Permission
			  ,[Enabled]
			FROM [stng].[Admin_DelegatePermission] as a
			LEFT JOIN  stng.[Admin_Permission] as b on a.PermissionUID = b.UniqueID
			LEFT JOIN  stng.Admin_Delegation as c on a.DelegateUID = c.UniqueID
			LEFT JOIN (
			
				SELECT
				   a.[DelegateUID]
				  ,a.[UniqueID] as DelegateRoleUID
				  ,a.[RoleUID]
				  ,e.Role
				  ,c.UniqueID as DelegatePermissionUID
				  ,b.PermissionID as PermissionUID
				  ,f.Permission
				  ,a.[Enabled] as RoleEnabled
				  ,c.[Enabled] as PermissionEnabled
				  ,d.Delegator
			    FROM [stng].[Admin_DelegateRole] as a
			    LEFT JOIN stng.Admin_RolePermission as b on b.RoleID = a.RoleUID
			    LEFT JOIN stng.Admin_DelegatePermission as c on c.PermissionUID = b.PermissionID and a.DelegateUID = c.DelegateUID
			    LEFT JOIN stng.Admin_Delegation as d on d.UniqueID = a.DelegateUID
			    LEFT JOIN stng.Admin_Role as e on e.UniqueID = a.RoleUID
			    LEFT JOIN stng.Admin_Permission as f on f.UniqueID = c.PermissionUID
			
			) as d on d.DelegatePermissionUID = a.UniqueID
			WHERE d.DelegatePermissionUID is null and c.Delegatee = @EmployeeID and c.Deleted = 0
		END


	
END
