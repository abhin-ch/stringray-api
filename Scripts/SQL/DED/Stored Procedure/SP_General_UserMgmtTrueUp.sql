CREATE OR ALTER   PROCEDURE [stngetl].[SP_General_UserMgmtTrueup]
(
	@Operation int
)
AS
BEGIN

	if @Operation = 1
		begin

			--AttributeType
			insert into stng.Admin_AttributeType
			(UniqueID, AttributeType, RAB, RAD, LUD, LUB, Supersedence, Deleted, DeletedOn, DeletedBy)
			select a.UniqueID, a.AttributeType, a.RAB, a.RAD, a.LUD, a.LUB, a.Supersedence, a.Deleted, a.DeletedOn, a.DeletedBy
			from stng.Admin_AttributeType_Temp as a
			left join stng.Admin_AttributeType as b on a.UniqueID = b.UniqueID
			where b.UniqueID is null;

			update stng.Admin_AttributeType
			set AttributeType = b.AttributeType,
			RAB = b.RAB,
			RAD = b.RAD,
			Supersedence = b.Supersedence,
			LUD = b.LUD,
			LUB = b.LUB,
			Deleted = b.Deleted,
			DeletedOn = b.DeletedOn,
			DeletedBy = b.DeletedBy
			from stng.Admin_AttributeType as a
			inner join stng.Admin_AttributeType_Temp as b on a.UniqueID = b.UniqueID;

			--Attribute
			insert into stng.Admin_Attribute
			(UniqueID, Attribute, AttributeType, RAB, RAD, LUD, LUB, Deleted, DeletedOn, DeletedBy)
			select a.UniqueID, a.Attribute, a.AttributeType, a.RAB, a.RAD, a.LUD, a.LUB, a.Deleted, a.DeletedOn, a.DeletedBy
			from stng.Admin_Attribute_Temp as a
			left join stng.Admin_Attribute as b on a.UniqueID = b.UniqueID and a.AttributeType = b.AttributeType
			where b.UniqueID is null or b.AttributeType is null;

			update stng.Admin_Attribute
			set Attribute = b.Attribute,
			AttributeType = b.AttributeType,
			RAB = b.RAB,
			RAD = b.RAD,
			LUD = b.LUD,
			LUB = b.LUB,
			Deleted = b.Deleted,
			DeletedOn = b.DeletedOn,
			DeletedBy = b.DeletedBy
			from stng.Admin_Attribute as a
			inner join stng.Admin_Attribute_Temp as b on a.UniqueID = b.UniqueID;

			--Permission
			insert into stng.Admin_Permission
			(UniqueID, Permission, PermissionDescription, RAB, RAD, LUD, LUB, Deleted, DeletedOn, DeletedBy)
			select a.UniqueID, a.Permission, a.PermissionDescription, a.RAB, a.RAD, a.LUD, a.LUB, a.Deleted, a.DeletedOn, a.DeletedBy
			from stng.Admin_Permission_Temp as a
			left join stng.Admin_Permission as b on a.UniqueID = b.UniqueID
			where b.UniqueID is null;

			update stng.Admin_Permission
			set Permission = b.Permission,
			PermissionDescription = b.PermissionDescription,
			RAB = b.RAB,
			RAD = b.RAD,
			LUD = b.LUD,
			LUB = b.LUB,
			Deleted = b.Deleted,
			DeletedOn = b.DeletedOn,
			DeletedBy = b.DeletedBy
			from stng.Admin_Permission as a
			inner join stng.Admin_Permission_Temp as b on a.UniqueID = b.UniqueID;

			--PermissionHierarchy
			set identity_insert stng.Admin_PermissionHierarchy on;
			
			insert into stng.Admin_PermissionHierarchy
			(UniqueID, ParentPermissionID, PermissionID, RAB, RAD, Deleted, DeletedOn, DeletedBy)
			select a.UniqueID, a.ParentPermissionID, a.PermissionID, a.RAB, a.RAD, a.Deleted, a.DeletedOn, a.DeletedBy
			from stng.Admin_PermissionHierarchy_Temp as a
			left join stng.Admin_PermissionHierarchy as b on a.UniqueID = b.UniqueID
			where b.UniqueID is null;

			set identity_insert stng.Admin_PermissionHierarchy off;

			update stng.Admin_PermissionHierarchy
			set ParentPermissionID = b.ParentPermissionID,
			PermissionID = b.PermissionID,
			RAB = b.RAB,
			RAD = b.RAD,
			Deleted = b.Deleted,
			DeletedOn = b.DeletedOn,
			DeletedBy = b.DeletedBy
			from stng.Admin_PermissionHierarchy as a
			inner join stng.Admin_PermissionHierarchy_Temp as b on a.UniqueID = b.UniqueID;

			--PermissionAttribute
			set identity_insert stng.Admin_PermissionAttribute on;

			insert into stng.Admin_PermissionAttribute
			(UniqueID, PermissionID, AttributeID, AttributeTypeID, RAB, RAD, Deleted, DeletedOn, DeletedBy)
			select a.UniqueID, a.PermissionID, a.AttributeID, a.AttributeTypeID, a.RAB, a.RAD, a.Deleted, a.DeletedOn, a.DeletedBy
			from stng.Admin_PermissionAttribute_Temp as a
			left join stng.Admin_PermissionAttribute as b on a.UniqueID = b.UniqueID
			where b.UniqueID is null;

			set identity_insert stng.Admin_PermissionAttribute off;

			update stng.Admin_PermissionAttribute
			set PermissionID = b.PermissionID,
			AttributeID = b.AttributeID,
			AttributeTypeID = b.AttributeTypeID,
			RAB = b.RAB,
			RAD = b.RAD,
			Deleted = b.Deleted,
			DeletedOn = b.DeletedOn,
			DeletedBy = b.DeletedBy
			from stng.Admin_PermissionAttribute as a
			inner join stng.Admin_PermissionAttribute_Temp as b on a.UniqueID = b.UniqueID;

			--Role
			insert into stng.Admin_Role
			(UniqueID, [Role], RoleDescription, RAB, RAD, LUD, LUB, Deleted, DeletedOn, DeletedBy)
			select a.UniqueID, a.[Role], a.RoleDescription, a.RAB, a.RAD, a.LUD, a.LUB, a.Deleted, a.DeletedOn, a.DeletedBy
			from stng.Admin_Role_Temp as a
			left join stng.Admin_Role as b on a.UniqueID = b.UniqueID
			where b.UniqueID is null;

			update stng.Admin_Role
			set [Role] = b.[Role],
			RoleDescription = b.RoleDescription,
			RAB = b.RAB,
			RAD = b.RAD,
			LUD = b.LUD,
			LUB = b.LUB,
			Deleted = b.Deleted,
			DeletedOn = b.DeletedOn,
			DeletedBy = b.DeletedBy
			from stng.Admin_Role as a
			inner join stng.Admin_Role_Temp as b on a.UniqueID = b.UniqueID;

			--RolePermission
			set identity_insert stng.Admin_RolePermission on;

			insert into stng.Admin_RolePermission
			(UniqueID, PermissionID, RoleID, RAB, RAD, Deleted, DeletedOn, DeletedBy)
			select a.UniqueID, a.PermissionID, a.RoleID, a.RAB, a.RAD, a.Deleted, a.DeletedOn, a.DeletedBy
			from stng.Admin_RolePermission_Temp as a
			left join stng.Admin_RolePermission as b on a.UniqueID = b.UniqueID
			where b.UniqueID is null;

			set identity_insert stng.Admin_RolePermission off;

			update stng.Admin_RolePermission
			set PermissionID = b.PermissionID,
			RoleID = b.RoleID,
			RAB = b.RAB,
			RAD = b.RAD,
			Deleted = b.Deleted,
			DeletedOn = b.DeletedOn,
			DeletedBy = b.DeletedBy
			from stng.Admin_RolePermission as a
			inner join stng.Admin_RolePermission_Temp as b on a.UniqueID = b.UniqueID;

			--RoleAttribute
			set identity_insert stng.Admin_RoleAttribute on;

			insert into stng.Admin_RoleAttribute
			(UniqueID, RoleID, AttributeID, AttributeTypeID, RAB, RAD, Deleted, DeletedOn, DeletedBy)
			select a.UniqueID, a.RoleID, a.AttributeID, a.AttributeTypeID, a.RAB, a.RAD, a.Deleted, a.DeletedOn, a.DeletedBy
			from stng.Admin_RoleAttribute_Temp as a
			left join stng.Admin_RoleAttribute as b on a.UniqueID = b.UniqueID
			where b.UniqueID is null;

			set identity_insert stng.Admin_RoleAttribute off;

			update stng.Admin_RoleAttribute
			set RoleID = b.RoleID,
			AttributeID = b.AttributeID,
			AttributeTypeID = b.AttributeTypeID,
			RAB = b.RAB,
			RAD = b.RAD,
			Deleted = b.Deleted,
			DeletedOn = b.DeletedOn,
			DeletedBy = b.DeletedBy
			from stng.Admin_RoleAttribute as a
			inner join stng.Admin_RoleAttribute_Temp as b on a.UniqueID = b.UniqueID;

			--UserAttribute
			set identity_insert stng.Admin_UserAttribute on;

			insert into stng.Admin_UserAttribute
			(UniqueID, EmployeeID, AttributeID, AttributeTypeID, RAB, RAD, Deleted, DeletedOn, DeletedBy)
			select a.UniqueID, a.EmployeeID, a.AttributeID, a.AttributeTypeID, a.RAB, a.RAD, a.Deleted, a.DeletedOn, a.DeletedBy
			from stng.Admin_UserAttribute_Temp as a
			left join stng.Admin_UserAttribute as b on a.UniqueID = b.UniqueID
			where b.UniqueID is null;

			set identity_insert stng.Admin_UserAttribute off;

			update stng.Admin_UserAttribute
			set EmployeeID = b.EmployeeID,
			AttributeID = b.AttributeID,
			AttributeTypeID = b.AttributeTypeID,
			RAB = b.RAB,
			RAD = b.RAD,
			Deleted = b.Deleted,
			DeletedOn = b.DeletedOn,
			DeletedBy = b.DeletedBy
			from stng.Admin_UserAttribute as a
			inner join stng.Admin_UserAttribute_Temp as b on a.UniqueID = b.UniqueID;

			--UserPermission
			set identity_insert stng.Admin_UserPermission on;

			insert into stng.Admin_UserPermission
			(UniqueID, PermissionID, EmployeeID, RAB, RAD, Deleted, DeletedOn, DeletedBy)
			select a.UniqueID, a.PermissionID, a.EmployeeID, a.RAB, a.RAD, a.Deleted, a.DeletedOn, a.DeletedBy
			from stng.Admin_UserPermission_Temp as a
			left join stng.Admin_UserPermission as b on a.UniqueID = b.UniqueID
			where b.UniqueID is null;

			set identity_insert stng.Admin_UserPermission off;

			update stng.Admin_UserPermission
			set PermissionID = b.PermissionID,
			EmployeeID = b.EmployeeID,
			RAB = b.RAB,
			RAD = b.RAD,
			Deleted = b.Deleted,
			DeletedOn = b.DeletedOn,
			DeletedBy = b.DeletedBy
			from stng.Admin_UserPermission as a
			inner join stng.Admin_UserPermission_Temp as b on a.UniqueID = b.UniqueID;

			--UserRole
			set identity_insert stng.Admin_UserRole on;

			insert into stng.Admin_UserRole
			(UniqueID, EmployeeID, RoleID, RAB, RAD, Deleted, DeletedOn, DeletedBy)
			select a.UniqueID, a.EmployeeID, a.RoleID, a.RAB, a.RAD, a.Deleted, a.DeletedOn, a.DeletedBy
			from stng.Admin_UserRole_Temp as a
			left join stng.Admin_UserRole as b on a.UniqueID = b.UniqueID
			where b.UniqueID is null;

			set identity_insert stng.Admin_UserRole off;

			update stng.Admin_UserRole
			set EmployeeID = b.EmployeeID,
			RoleID = b.RoleID,
			RAB = b.RAB,
			RAD = b.RAD,
			Deleted = b.Deleted,
			DeletedOn = b.DeletedOn,
			DeletedBy = b.DeletedBy
			from stng.Admin_UserRole as a
			inner join stng.Admin_UserRole_Temp as b on a.UniqueID = b.UniqueID;

			--Delegation
			insert into stng.Admin_Delegation
			(UniqueID,
			Delegator,
			Delegatee,
			Active,
			ExpireDate,
			CreatedBy,
			CreatedDate,
			Indefinite,
			Deleted)
			select
			a.UniqueID,
			a.Delegator,
			a.Delegatee,
			a.Active,
			a.ExpireDate,
			a.CreatedBy,
			a.CreatedDate,
			a.Indefinite,
			a.Deleted
			from stng.Admin_Delegation_Temp as a
			left join stng.Admin_Delegation as b on a.UniqueID = b.UniqueID
			where b.UniqueID is null;

			update stng.Admin_Delegation
			set Delegator= b.Delegator,
			Delegatee= b.Delegatee,
			Active= b.Active,
			ExpireDate= b.ExpireDate,
			CreatedBy= b.CreatedBy,
			CreatedDate= b.CreatedDate,
			Indefinite= b.Indefinite,
			Deleted= b.Deleted
			from stng.Admin_Delegation as a
			inner join stng.Admin_Delegation_Temp as b on a.UniqueID = b.UniqueID;

			--DelegatePermission
			insert into stng.Admin_DelegatePermission
			(UniqueID, DelegateUID, PermissionUID, [Enabled], CreatedBy, CreatedDate)
			select a.UniqueID, a.DelegateUID, a.PermissionUID, a.[Enabled], a.CreatedBy, a.CreatedDate
			from stng.Admin_DelegatePermission_Temp as a
			left join stng.Admin_DelegatePermission as b on a.UniqueID = b.UniqueID
			where b.UniqueID is null;

			update stng.Admin_DelegatePermission
			set 
			DelegateUID = b.DelegateUID
			, PermissionUID= b.PermissionUID
			, [Enabled]= b.[Enabled]
			, CreatedBy= b.CreatedBy
			, CreatedDate= b.CreatedDate
			from stng.Admin_DelegatePermission as a
			inner join stng.Admin_DelegatePermission_Temp as b on a.UniqueID = b.UniqueID;

			--DelegateRole
			insert into stng.Admin_DelegateRole
			(UniqueID, DelegateUID, RoleUID, [Enabled], CreatedBy, CreatedDate)
			select a.UniqueID, a.DelegateUID, a.RoleUID, a.[Enabled], a.CreatedBy, a.CreatedDate
			from stng.Admin_DelegateRole_Temp as a
			left join stng.Admin_DelegateRole as b on a.UniqueID = b.UniqueID
			where b.UniqueID is null;

			update stng.Admin_DelegateRole
			set DelegateUID = b.DelegateUID
			, RoleUID = b.RoleUID
			, [Enabled]= b.[Enabled]
			, CreatedBy= b.CreatedBy
			, CreatedDate= b.CreatedDate
			from stng.Admin_DelegateRole as a
			inner join stng.Admin_DelegateRole_Temp as b on a.UniqueID = b.UniqueID;

			--UserAlternateEmail
			insert into stng.Admin_UseralternateEmail
			(EmployeeID, AlternateEmail, RAB, RAD, Deleted, DeletedOn, DeletedBy)
			SELECT a.EmployeeID, a.AlternateEmail, a.RAB, a.RAD, a.Deleted, a.DeletedOn, a.DeletedBy
			FROM stng.Admin_UserAlternateEmail_Temp as a
			left join stng.Admin_UserAlternateEmail as b on a.EmployeeID = b.EmployeeID
			where b.EmployeeID is null

			update stng.Admin_UserAlternateEmail
			set AlternateEmail = b.AlternateEmail
			, RAB = b.RAB
			, RAD = b.RAD
			, Deleted = b.Deleted
			, DeletedOn = b.DeletedOn
			, DeletedBy = b.DeletedBy
			FROM stng.Admin_UserAlternateEmail as a
			inner join stng.Admin_UserAlternateEmail_Temp as b on a.EmployeeID = b.EmployeeID

			--Drop temp tables
			drop table stng.Admin_AttributeType_Temp;
			drop table stng.Admin_Attribute_Temp;
			drop table stng.Admin_Permission_Temp;
			drop table stng.Admin_PermissionHierarchy_Temp;
			drop table stng.Admin_PermissionAttribute_Temp;
			drop table stng.Admin_Role_Temp;
			drop table stng.Admin_RolePermission_Temp;
			drop table stng.Admin_RoleAttribute_Temp;
			drop table stng.Admin_UserAttribute_Temp;
			drop table stng.Admin_UserPermission_Temp;
			drop table stng.Admin_UserRole_Temp;
			drop table stng.Admin_Delegation_Temp;
			drop table stng.Admin_DelegatePermission_Temp;
			drop table stng.Admin_DelegateRole_Temp;
			drop table stng.Admin_UserAlternateEmail_Temp;

			--remove inactive user data
			update a
			set a.Deleted = 1, a.DeletedBy = 'SYSTEM', a.DeletedOn = stng.GetBPTime(GETDATE())
			from stng.Admin_UserAttribute a
			join stng.Admin_user u on u.EmployeeID = a.EmployeeID
			Where u.Active = 0

			update a
			set a.Deleted = 1, a.DeletedBy = 'SYSTEM', a.DeletedOn = stng.GetBPTime(GETDATE())
			from stng.Admin_UserRole a
			join stng.Admin_user u on u.EmployeeID = a.EmployeeID
			Where u.Active = 0

			update a
			set a.Deleted = 1, a.DeletedBy = 'SYSTEM', a.DeletedOn = stng.GetBPTime(GETDATE())
			from stng.Admin_UserPermission a
			join stng.Admin_user u on u.EmployeeID = a.EmployeeID
			Where u.Active = 0

			update a
			set a.Deleted = 1, a.DeletedBy = 'SYSTEM', a.DeletedOn = stng.GetBPTime(GETDATE())
			from stng.Admin_UserAlternateEmail a
			join stng.Admin_user u on u.EmployeeID = a.EmployeeID
			Where u.Active = 0

		end

END
GO