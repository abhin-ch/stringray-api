CREATE OR ALTER procedure [stng].[SP_Admin_UserManagement]
(
	@Operation int,
	@SubOp int = null,
	@EmployeeID varchar(20) = null,

	@EmployeeIDInsert varchar(20) = null,
	
	@UniqueID varchar(40) = null,
	@UniqueIDNum bigint = null,

	@Attribute varchar(50) = null,
	@AttributeType varchar(50) = null,
	@AttributeID varchar(50) = null,
	@AttributeTypeID varchar(50) = null,

	@Supersedence bit = null,

	@Permission varchar(50) = null,
	@ParentPermission varchar(50) = null,
	@PermissionID varchar(50) = null,
	@ParentPermissionID varchar(50) = null,

	@Role varchar(50) = null,
	@RoleID varchar(50) = null,

	@Endpoint varchar(200) = null,
	@HTTPVerb varchar(15) = null,
	@EndpointID varchar(50) = null,

	@Description varchar(1000) = null,
	@LinkID bigint = null,

	@UserName varchar(255) = null,
	@FirstName varchar(255) = null,
	@LastName varchar(255) = null,
	@Email varchar(255) = null,
	@Title varchar(255) = null,
	@LANID varchar(255) = null,

	@Active bit = null,

	@Module varchar(255) = null,
	@Department varchar(255) = null,

	@ModuleID varchar(255) = null,
	@IsMimicRequest bit = null,
	@MimicOfEmployeeID varchar(50) = null,
	@RequestID varchar(50) = null,
	@SubRequestID varchar(50) = null,
	@IsApproved bit = null,

	@Origin varchar(50) = null
)
as
begin

	--Working variables
	declare @WorkingPermissionID uniqueidentifier;
	declare @WorkingRequestID uniqueidentifier;
	declare @WorkingSubRequestID uniqueidentifier;
	declare @WorkingModuleID uniqueidentifier;

	declare @WorkingRole table
	(
		RoleID uniqueidentifier
	);

	declare @WorkingPermission table
	(
		PermissionID uniqueidentifier,
		RequestID uniqueidentifier
	);

	declare @WorkingParentPermission table
	(
		PermissionID uniqueidentifier
	);

	declare @WorkingChildPermission table
	(
		PermissionID uniqueidentifier
	);

	declare @OnlyAttribute bit = 0;

	declare @AdminCheck table
	(
		AttributeID varchar(50),
		AttributeTypeID varchar(50),
		ReturnMessage varchar(250)
	);

	--OPERATIONS
	--1 - Add Attribute
	--2 - Delete Attribute
	--3 - Edit Attribute
	--4 - Get Attributes
	--5 - Add Permission
	--6 - Delete Permission
	--7 - Edit Permssion
	--8 - Get Permissions
	--9 - Add Permission Attribute
	--10 - Delete Permission Attribute
	--11 - Get Permission Attributes
	--12 - Add Permission Child
	--13 - Delete Child Permission
	--14 - Get Direct Child Permissions
	--15 - Add Role
	--16 - Delete Role
	--17 - Edit Role
	--18 - Get Roles
	--19 - Add Role Attribute
	--20 - Delete Role Attribute
	--21 - Get Role Attributes
	--22 - Add Role Permission
	--23 - Delete Role Permission
	--24 - Get Role Permissions
	--25 - Get Users
	--26 - Add User Attribute
	--27 - Delete User Attribute
	--28 - Get User Attributes
	--29 - Add User Permissions
	--30 - Delete User Permissions
	--31 - Get User Permissions
	--32 - Add User Role
	--33 - Remove User From Role
	--34 - Get User Roles
	--35 - Add Attribute type
	--36 - Remove Attribute Type
	--37 - Get Attribute Type
	--38 - Add Endpoint
	--39 - Remove Endpoint
	--40 - Get Endpoint(s)
	--41 - Edit Endpoint
	--42 - Link Endpoint Attribute
	--43 - Delink Endpoint Attribute
	--44 - Get Enpoint Attributes
	--45 - Add Endpoint Permission
	--46 - Delete Endpoint Permission
	--47 - Get Endpoint Permissions
	--48 - Get User Endpoints
	--49 - Add New User
	--50 - Edit User (Active flag for now)
	--51 - Not Implemented
	--52 - Edit Attribute Type
	--53 - Create Access Request
	--54 - Read Access Request
	--55 - Update Access Request
	--56 - Get Current User Permissions
	--57 - Get Current User Modules
	--58 - Get Department based Roles, optional to specify module and role
	--59 - Get Unnasigned Roles for a User
	--60 - Get Unnasigned Permissions for a User
	--61 - Get Unlinked Permissions for a Role
	--62 - Get RSS For an Endpoint
	--63 - Get Module/Department based permissions
	--64 - Get Unlinked Permissions for an Endpoint
	--65 - Get Unlinked Attributes for an Endpoint
	--66 - Get Statuses of Requests for a User
	--67 - Get All Comments for a Request
	--68 - Get Unlinked Attributes for a Permission
	--69 - Get Unlinked Attributes for a Role
	--70 - Get Unlinked Attributes for a User
	--71 - Check permissions then add user role (op 32)
	--72 - Show roles that user has rights to grant, given filters
	--73 - Get Inherited Permissions of User
	--74 - Get Unassigned Child Permissions of Parent Permission
	--75 - Get Current User Attributes
	--76 - Get Current User Endpoints
	


	--Add Attribute
	if @Operation = 1
		begin

			--Check if Attribute and AttributeType are null
			if @Attribute is null or (@AttributeType is null and @AttributeTypeID is null)
				begin

					select 'Attribute and AttributeType/AttributeTypeID are required' as ReturnMessage;
					return;

				end

			--Get AttributeTypeID or confirm if supplied ID exists
			if @AttributeTypeID is not null
				begin

					if not exists
					(
						select *
						from stng.Admin_AttributeType
						where UniqueID = @AttributeTypeID and Deleted = 0
					)
						begin

							select 'AttributeType does not exist' as ReturnMessage;
							return;

						end

				end
			else
				begin

					if not exists
					(
						select *
						from stng.Admin_AttributeType
						where AttributeType = @AttributeType and Deleted = 0

					)
						begin
							
							select 'AttributeType does not exist' as ReturnMessage;
							return;

						end

					else
						begin

							select @AttributeTypeID = UniqueID
							from stng.Admin_AttributeType
							where AttributeType = @AttributeType and Deleted = 0

						end

				end

			--Check if Attribute already exists
			if exists
			(
				select *
				from stng.Admin_Attribute
				where AttributeType = @AttributeTypeID and Attribute = @Attribute and Deleted = 0
			)
				begin

					select 'Attribute already exists' as ReturnMessage;
					return;

				end

			--Check if Attribute can be restored
			if exists
			(
				select *
				from stng.Admin_Attribute
				where AttributeType = @AttributeTypeID and Attribute = @Attribute and Deleted = 1
			)
				begin

					update stng.Admin_Attribute
					set Deleted = 0,
					DeletedBy = null,
					DeletedOn = null,
					RAD = stng.GetBPTime(GETDATE()),
					RAB = @EmployeeID
					from stng.Admin_Attribute as a
					where AttributeType = @AttributeTypeID and Attribute = @Attribute and Deleted = 1

				end

			--Otherwise, add new record
			else
				begin

					insert into stng.Admin_Attribute
					(Attribute, AttributeType, RAB, LUB)
					values
					(@Attribute, @AttributeTypeID, @EmployeeID, @EmployeeID);

				end

		end

	--Delete attribute
	else if @Operation = 2
		begin
			
			--Check if Attribute/AttributeID is null
			if @AttributeID is null
				begin

					if @Attribute is null or (@AttributeType is null and @AttributeTypeID is null)
						begin

							select 'Attribute and AttributeType/AttributeTypeID or AttributeID are required' as ReturnMessage;
							return;					

						end

					else
						begin

							--AttributeTypeID arg takes precedence if both are provided
							if @AttributeTypeID is null
								begin

									select @AttributeTypeID = UniqueID
									from stng.Admin_AttributeType
									where AttributeType = @AttributeType and Deleted = 0;

								end

							if @AttributeTypeID is null
								begin

									select 'Attribute Type does not exist' as ReturnMessage;
									return;

								end

							select @AttributeID = AttributeID
							from stng.VV_Admin_Attribute
							where Attribute = @Attribute and AttributeTypeID = @AttributeTypeID;

						end

				end

			--Check if Attribute exists and has not yet been deleted
			if exists
			(
				select *
				from stng.VV_Admin_Attribute
				where AttributeID = @AttributeID 
			)
				begin

					update stng.Admin_Attribute
					set Deleted = 1,
					DeletedOn = stng.GetBPTime(GETDATE()),
					DeletedBy = @EmployeeID
					where UniqueID = @AttributeID;

				end

			else
				begin
		
					select 'Attribute does not exist' as ReturnMessage;
					return;

				end


		end

	--Edit Attribute
	else if @Operation = 3
		begin

			--Check if Attribute and AttributeID are null
			if @AttributeID is null or @Attribute is null
				begin

					select 'AttributeID and Attribute are required' as ReturnMessage;
					return;

				end

			--Check if AttributeID exists
			if not exists
			(
				select *
				from stng.VV_Admin_Attribute
				where AttributeID = @AttributeID
			)
				begin
		
					select 'Attribute does not exist' as ReturnMessage;
					return;

				end

			--Get WorkingAttributeTypeID and WorkingAttributeType
			select @AttributeTypeID = AttributeTypeID
			from stng.VV_Admin_Attribute
			where AttributeID = @AttributeID;

			select @AttributeType = AttributeType
			from stng.VV_Admin_Attribute
			where AttributeID = @AttributeID;

			--Check if Attribute and AttributeType already exist
			if exists
			(
				select *
				from stng.VV_Admin_Attribute
				where Attribute = @Attribute and AttributeTypeID = @AttributeTypeID
			)
				begin

					select concat('Attribute ', @Attribute, ', AttributeType ', @AttributeType, ' already exists') as ReturnMessage;
					return;
				
				end

			--Do update
			update stng.Admin_Attribute
			set Attribute = @Attribute,
			LUD = stng.GetBPTime(GETDATE()),
			LUB = @EmployeeID
			where UniqueID = @AttributeID;

		end

	--Get Attributes
	else if @Operation = 4
		begin

			select *
			from stng.VV_Admin_Attribute
			where 
			(AttributeID = @AttributeID or @AttributeID is null)
			and
			(Attribute = @Attribute or @Attribute is null)
			and
			(AttributeType = @AttributeType or @AttributeType is null)
			and
			(AttributeTypeID = @AttributeTypeID or @AttributeTypeID is null)
			order by Attribute
			option(optimize for (@AttributeID unknown, @Attribute unknown, @AttributeTypeID unknown, @AttributeType unknown));
			
		end

	--Add Permission
	else if @Operation = 5
		begin
	
			--Check if Permission and Description are provided
			if @Permission is null or @Description is null
				begin

					select 'Permission and Description are required' as ReturnMessage;
					return;

				end

			--Check if Permission already exists
			if exists
			(
				select *
				from stng.Admin_Permission
				where Permission = @Permission and Deleted = 0	
			)
				begin

					select CONCAT('Permission ', @Permission, ' already exists') as ReturnMessage;
					return;

				end

			--Check if Permission can be resurrected
			if exists
			(
				select *
				from stng.Admin_Permission
				where Permission = @Permission and Deleted = 1
			)
				begin

					update stng.Admin_Permission
					set Deleted = 0,
					DeletedBy = null,
					DeletedOn = null,
					RAD = stng.GetBPTime(GETDATE()),
					RAB = @EmployeeID,
					PermissionDescription = @Description
					where Permission = @Permission;

				end 

			--Otherwise, add new record
			else
				begin

					insert into stng.Admin_Permission
					(Permission, PermissionDescription, RAB, LUB)
					values
					(@Permission, @Description, @EmployeeID, @EmployeeID);

				end

			--Get PermissionID
			select @PermissionID = UniqueID
			from stng.Admin_Permission
			where Permission = @Permission and Deleted = 0;

			--Upon success, check if ParentPermission or ParentPermissionID was provided
			if @ParentPermissionID is null
				begin

					if @ParentPermission is null
						begin
							
							select @ParentPermissionID = UniqueID
							from stng.Admin_Permission
							where Permission = 'SysAdmin';

						end

					else
						begin

							select @ParentPermissionID = UniqueID
							from stng.Admin_Permission
							where Permission = @ParentPermission and Deleted = 0

						end

				end

				--Confirm ParentPermissionID is active
				else
					begin

						if not exists
						(
							select *
							from stng.Admin_Permission
							where UniqueID = @ParentPermissionID and Deleted = 0
						)
							begin

								set @ParentPermissionID = null;

							end
						
					end


				--Meaning a provided ParentPermissionID/ParentPermission either does not exist
				if @ParentPermissionID is null
					begin

						select 'Provided Parent Permission does not exist' as ReturnMessage;
						return;

					end

				else
					begin

						exec stng.SP_Admin_UserManagement @Operation = 12, @EmployeeID = @EmployeeID, @PermissionID = @PermissionID, @ParentPermissionID = @ParentPermissionID;

					end

			--Return PermissionID
			select @PermissionID as PermissionID;

		end

	--Delete Permission
	else if @Operation = 6
		begin

			--Check for PermissionID or Permission
			if @PermissionID is null
				begin

					if @Permission is null
						begin

							select 'PermissionID or Permission is required' as ReturnMessage;
							return;

						end

					else
						begin

							select @PermissionID = UniqueID
							from stng.Admin_Permission
							where Deleted = 0 and Permission = @Permission;

						end


				end

			--Check if PermissionID exists
			if not exists
			(
				select *
				from stng.VV_Admin_AllPermission
				where PermissionID = @PermissionID
			)
				begin

					select CONCAT('PermissionID ',@PermissionID, ' does not exist') as ReturnMessage;
					return;

				end

			--Get children
			insert into @WorkingChildPermission
			(PermissionID)
			select PermissionID
			from stng.VV_Admin_AllPermission
			where ParentPermissionID = @PermissionID;

			--Get parents
			insert into @WorkingParentPermission
			(PermissionID)
			select ParentPermissionID
			from stng.VV_Admin_AllPermission
			where PermissionID = @PermissionID;

			--Promote any children to parents
			insert into stng.Admin_PermissionHierarchy
			(ParentPermissionID, PermissionID, RAB)
			select a.PermissionID, b.PermissionID, @EmployeeID
			from @WorkingParentPermission as a, @WorkingChildPermission as b
			--where a.PermissionID is not null and b.PermissionID is not null;

			--Delete permission
			update stng.Admin_Permission
			set Deleted = 1,
			DeletedBy = @EmployeeID,
			DeletedOn = stng.GetBPTime(GETDATE())
			where UniqueID = @PermissionID;

			--Delete permission hierarchies
			update stng.Admin_PermissionHierarchy
			set Deleted = 1,
			DeletedBy = @EmployeeID,
			DeletedOn = stng.GetBPTime(GETDATE())
			where PermissionID = @PermissionID;

		end

	--Edit Permission
	else if @Operation = 7
		begin

			--Check for Permission, PermissionID, and Description
			if @Permission is null or @PermissionID is null or @Description is null
				begin

					select 'Permission, PermissionID, and Description are required' as ReturnMessage;
					return;

				end

			--Check if PermissionID is legit
			if not exists
			(
				select *
				from stng.Admin_Permission
				where Deleted = 0 and UniqueID = @PermissionID
			)
				begin

					select 'Permission does not exist' as ReturnMessage;
					return;

				end

			--Check if Permission already exists
			if exists
			(
				select *
				from stng.Admin_Permission
				where Permission = @Permission and Deleted = 0 and UniqueID <> @PermissionID
			)
				begin
		
					select 'Permission already exists' as ReturnMessage;
					return;

				end

			else if exists
			(
				select *
				from stng.Admin_Permission
				where Permission = @Permission and Deleted = 1 and UniqueID <> @PermissionID
			)
				begin

					select 'Permission name is reserved and cannot be used at this time' as ReturnMessage;
					return; 

				end

			--Perform update
			update stng.Admin_Permission
			set Permission = @Permission,
			PermissionDescription = @Description,
			LUD = stng.GetBPTime(GETDATE()),
			LUB = @EmployeeID
			where UniqueID = @PermissionID;

		end
	
	--Get Permissions
	else if @Operation = 8
		begin

			select *
			from stng.VV_Admin_ActualUserPermission_Manage
			where 
			EmployeeID = @EmployeeID
			and
			(PermissionID = @PermissionID or @PermissionID is null)
			and
			(Permission = @Permission or @Permission is null)
			order by Permission asc
			option(optimize for (@Permission unknown, @PermissionID unknown, @EmployeeID unknown))

		end

	--Add Permission Attribute
	else if @Operation = 9
		begin

			--Check for PermissionID
			if @PermissionID is null
				begin

					if @Permission is null
						begin

							select 'PermissionID or Permission required' as ReturnMessage;
							return;

						end

					else
						begin

							select @PermissionID = UniqueID
							from stng.Admin_Permission
							where Permission = @Permission and Deleted = 0;

						end


				end

			--Check for Attribute, AttributeType or their IDs
			insert into @AdminCheck
			(AttributeID, AttributeTypeID, ReturnMessage)
			select AttributeID, AttributeTypeID, ReturnMessage
			from stng.FN_Admin_AttributeCheck(@AttributeID, @Attribute, @AttributeTypeID,@AttributeType);

			if exists
			(
				select *
				from @AdminCheck
				where ReturnMessage is not null
			)
				begin

					return (select ReturnMessage from @AdminCheck);

				end

			else
				begin

					select @AttributeID = AttributeID from @AdminCheck;
					select @AttributeTypeID = AttributeTypeID from @AdminCheck;

				end

			--Check if Permission/Attribute record already exists
			if exists
			(
				select *
				from stng.VV_Admin_PermissionAttribute
				where PermissionID = @PermissionID and (AttributeID = @AttributeID or @AttributeID is null) and (AttributeTypeID = @AttributeTypeID or @AttributeTypeID is null) 
			)
				begin

					select 'Attribute/Permission record already exists' as ReturnMessage;
					return;

				end

			--Check if record can be resurrected
			if exists
			(
				select *
				from stng.VV_Admin_PermissionAttribute_Deleted
				where PermissionID = @PermissionID and (AttributeID = @AttributeID or @AttributeID is null) and (AttributeTypeID = @AttributeTypeID or @AttributeTypeID is null) 
			)
				begin

					update stng.Admin_PermissionAttribute
					set Deleted = 0,
					DeletedBy = null,
					DeletedOn = null,
					RAD = stng.GetBPTime(GETDATE()),
					RAB = @EmployeeID
					where PermissionID = @PermissionID and (AttributeID = @AttributeID or @AttributeID is null) and (AttributeTypeID = @AttributeTypeID or @AttributeTypeID is null) 

				end

			--Else, insert new record
			else
				begin
					
					insert into stng.Admin_PermissionAttribute
					(PermissionID, AttributeID, AttributeTypeID, RAB)
					values
					(@PermissionID, @AttributeID, @AttributeTypeID, @EmployeeID);

				end 

		end

	--Delete permission attribute
	else if @Operation = 10
		begin

			--Check for PermissionID
			if @PermissionID is null
				begin

					if @Permission is null
						begin

							select 'PermissionID or Permission required' as ReturnMessage;
							return;

						end

					else
						begin

							select @PermissionID = UniqueID
							from stng.Admin_Permission
							where Permission = @Permission and Deleted = 0;

						end


				end

			--Check for Attribute, AttributeType or their IDs
			insert into @AdminCheck
			(AttributeID, AttributeTypeID, ReturnMessage)
			select AttributeID, AttributeTypeID, ReturnMessage
			from stng.FN_Admin_AttributeCheck(@AttributeID, @Attribute, @AttributeType, @AttributeTypeID);

			if exists
			(
				select *
				from @AdminCheck
				where ReturnMessage is not null
			)
				begin

					return (select ReturnMessage from @AdminCheck);

				end

			else
				begin

					select @AttributeID = AttributeID from @AdminCheck;
					select @AttributeTypeID = AttributeTypeID from @AdminCheck;

				end

			--Check if Permission/Attribute record already exists
			if not exists
			(
				select *
				from stng.VV_Admin_PermissionAttribute
				where PermissionID = @PermissionID and (AttributeID = @AttributeID or @AttributeID is null) and (AttributeTypeID = @AttributeTypeID or @AttributeTypeID is null)
			)
				begin

					select 'Attribute/Permission record does not exist' as ReturnMessage;
					return;

				end

			--Perform delete
			update stng.Admin_PermissionAttribute
			set Deleted = 1,
			DeletedBy = @EmployeeID,
			DeletedOn = stng.GetBPTime(GETDATE())
			where PermissionID = @PermissionID and ((AttributeID = @AttributeID and AttributeTypeID is null) or (AttributeTypeID = @AttributeTypeID and AttributeID is null));

		end

	--Get Permission Attributes
	else if @Operation = 11
		begin

			select *
			from stng.VV_Admin_PermissionAttribute
			where 
			(PermissionID = @PermissionID or @PermissionID is null)
			and
			(AttributeTypeID = @AttributeTypeID or @AttributeTypeID is null)
			and
			(AttributeID = @AttributeID or @AttributeID is null)
			option(optimize for (@PermissionID unknown, @AttributeTypeID unknown, @AttributeID unknown));

		end

	--Add Permission Child
	else if @Operation = 12
		begin

			--Check for ParentPermissionID and PermissionID
			if @ParentPermissionID is null or @PermissionID is null
				begin

					--Check for ParentPermission and Permission
					if @Permission is null and @ParentPermission is null
						begin

							select 'Parent Permission and Child Permission required' as ReturnMessage;
							return;

						end
					
					--Get the IDs
					else
						begin

							select @ParentPermissionID = UniqueID
							from stng.Admin_Permission
							where Permission = @ParentPermission and Deleted = 0;

							select @PermissionID = UniqueID
							from stng.Admin_Permission
							where Permission = @Permission and Deleted = 0;

						end


				end

			--Check for existence of ParentPermission and Child Permission
			if not exists
			(
				select *
				from stng.VV_Admin_AllPermission
				where PermissionID = @ParentPermissionID
			)
			or
			not exists
			(
				select *
				from stng.Admin_Permission
				where UniqueID = @PermissionID and Deleted = 0
			)
				begin

					select 'Parent and/or Child Permission do not exist' as ReturnMessage;
					return;

				end

			--Check for existence of existing Parent/Child permission relationship
			if exists
			(
				select *
				from stng.VV_Admin_AllPermission
				where PermissionID = @PermissionID and ParentPermissionID = @ParentPermissionID
			)
				begin

					select 'Parent-Child Permission relationship already exists' as ReturnMessage;
					return;

				end

			--Check for existence of deleted parent/child relationships. If so, resurrect
			if exists
			(
				select *
				from stng.Admin_PermissionHierarchy
				where Deleted = 1 and PermissionID = @PermissionID and ParentPermissionID = @ParentPermissionID
			)
				begin

					update stng.Admin_PermissionHierarchy
					set Deleted = 0,
					DeletedOn = null,
					DeletedBy = null,
					RAD = stng.GetBPTime(GETDATE()),
					RAB = @EmployeeID
					where PermissionID = @PermissionID and ParentPermissionID = @ParentPermissionID and Deleted = 1;

				end

			--Else, add new relationship record
			else
				begin
					
					insert into stng.Admin_PermissionHierarchy
					(PermissionID, ParentPermissionID, RAB)
					values
					(@PermissionID, @ParentPermissionID, @EmployeeID);

				end


		end

	--Delete child permission
	else if @Operation = 13
		begin

			--Check for ParentPermissionID and PermissionID
			if @ParentPermissionID is null or @PermissionID is null
				begin

					select 'Parent Permission and Child Permission required' as ReturnMessage;
					return;

				end

			--Check if ParentPermissionID/PermissionID combo exists
			if not exists
			(
				select *
				from stng.VV_Admin_AllPermission
				where PermissionID = @PermissionID and ParentPermissionID = @ParentPermissionID
			)
				begin

					select 'Parent/Child Permission relationship does not exist' as ReturnMessage;
					return;

				end

			--Get children
			insert into @WorkingChildPermission
			(PermissionID)
			select PermissionID
			from stng.VV_Admin_AllPermission
			where ParentPermissionID = @PermissionID;

			--Get parents
			insert into @WorkingParentPermission
			(PermissionID)
			select ParentPermissionID
			from stng.VV_Admin_AllPermission
			where PermissionID = @PermissionID;

			--Promote any children to parents
			insert into stng.Admin_PermissionHierarchy
			(ParentPermissionID, PermissionID, RAB)
			select a.PermissionID, b.PermissionID, @EmployeeID
			from @WorkingParentPermission as a, @WorkingChildPermission as b
			--where a.PermissionID is not null and b.PermissionID is not null;

			--Delete
			update stng.Admin_PermissionHierarchy
			set Deleted = 1,
			DeletedBy = @EmployeeID,
			DeletedOn = stng.GetBPTime(GETDATE())
			where PermissionID = @PermissionID and ParentPermissionID = @ParentPermissionID;

		end

	--Get Direct Child Permissions
	else if @Operation = 14
		begin

			select *
			from stng.VV_Admin_AllPermission
			where 
			(ParentPermissionID = @ParentPermissionID or @ParentPermissionID is null)
			and
			(ParentPermission = @ParentPermission or @ParentPermission is null)
			and
			(PermissionID = @PermissionID or @PermissionID is null)
			and
			(Permission = @Permission or @Permission is null)
			order by Permission asc
			option(optimize for (@ParentPermission unknown, @ParentPermissionID unknown, @Permission unknown, @PermissionID unknown));

		end

	--Add role
	else if @Operation = 15
		begin

			--Check for Role and Description
			if @Role is null or @Description is null
				begin

					select 'Role and Description are required' as ReturnMessage;
					return;

				end

			--Check if role already exists
			if exists
			(
				select *
				from stng.VV_Admin_AllRole
				where [Role] = @Role
			)
				begin

					select concat('Role ', @Role, ' already exists') as ReturnMessage;
					return;

				end

			--Check if role can be resurrected
			if exists
			(
				select *
				from stng.Admin_Role
				where [Role] = @Role and Deleted = 1
			)
				begin

					update stng.Admin_Role
					set Deleted = 0,
					DeletedBy = null,
					DeletedOn = null,
					RAD = stng.GetBPTime(GETDATE()),
					RAB = @EmployeeID,
					LUD = stng.GetBPTime(GETDATE()),
					LUB = @EmployeeID,
					RoleDescription = @Description
					where [Role] = @Role;

				end

			--Otherwise, add new role
			else
				begin

					insert into stng.Admin_Role
					([Role], RoleDescription, RAB, LUB)
					values
					(@Role, @Description, @EmployeeID, @EmployeeID);

				end

			select UniqueID as RoleID
			from stng.VV_Admin_AllRole
			where [Role] = @Role;

		end

	--Delete role
	else if @Operation = 16
		begin

			--Check for RoleID
			if @RoleID is null
				begin

					select 'RoleID required' as ReturnMessage;
					return;

				end

			--Check if RoleID exists
			if not exists
			(
				select *
				from stng.VV_Admin_AllRole
				where UniqueID = @RoleID
			)
				begin

					select 'Role does not exist' as ReturnMessage;
					return;

				end

			--Delete
			update stng.Admin_Role
			set Deleted = 1,
			DeletedBy = @EmployeeID,
			DeletedOn = stng.GetBPTime(GETDATE())
			where UniqueID = @RoleID;

		end

	--Edit role
	else if @Operation = 17
		begin
			
			--Check if RoleID, Description, and Role are provided
			if @Role is null or @RoleID is null or @Description is null
				begin

					select 'Role, RoleID, and Description are required' as ReturnMessage;
					return;

				end

			--Check if Role exists
			if not exists
			(
				select *
				from stng.VV_Admin_AllRole
				where UniqueID = @RoleID
			)
				begin

					select 'Role does not exist' as ReturnMessage;
					return;

				end

			if exists
			(
				select *
				from stng.VV_Admin_AllRole
				where UniqueID = @RoleID and [Role] = @Role
			)
				begin

					select CONCAT('Role ', @Role, ' already exists') as ReturnMessage;
					return;

				end

			--Otherwise, edit
			update stng.Admin_Role
			set [Role] = @Role,
			RoleDescription = @Description,
			LUD = stng.GetBPTime(GETDATE()),
			LUB = @EmployeeID
			where UniqueID = @RoleID;

		end

	--Get roles
	else if @Operation = 18
		begin

			select *
			from stng.VV_Admin_AllRole
			where 
			(UniqueID = @RoleID or @RoleID is null)
			and
			([Role] = @Role or @Role is null)
			order by [Role] asc
			option(optimize for (@RoleID unknown));

		end

	--Add role attribute
	else if @Operation = 19
		begin

			--Check for RoleID and AttributeID or AttributeTypeID
			if @RoleID is null
				begin

					if @Role is null
						begin 
							
							select 'RoleID or Role required' as ReturnMessage;
							return;

						end

					else if not exists
					(
						select *
						from stng.VV_Admin_AllRole
						where [Role] = @Role
					)
						begin

							select 'Role does not exist' as ReturnMessage;
							return;

						end
						
					select @RoleID = UniqueID
					from stng.VV_Admin_AllRole
					where [Role] = @Role;

				end

			--Check for Attribute, AttributeType or their IDs
			insert into @AdminCheck
			(AttributeID, AttributeTypeID, ReturnMessage)
			select AttributeID, AttributeTypeID, ReturnMessage
			from stng.FN_Admin_AttributeCheck(@AttributeID, @Attribute, @AttributeType, @AttributeTypeID);

			if exists
			(
				select *
				from @AdminCheck
				where ReturnMessage is not null
			)
				begin

					return (select ReturnMessage from @AdminCheck);

				end

			else
				begin

					select @AttributeID = AttributeID from @AdminCheck;
					select @AttributeTypeID = AttributeTypeID from @AdminCheck;

				end

			--Check if Role/Attribute record already exists
			if exists
			(
				select *
				from stng.VV_Admin_RoleAttribute
				where RoleID = @RoleID and (AttributeID = @AttributeID or @AttributeID is null) and (AttributeTypeID = @AttributeTypeID or AttributeTypeID is null) 
			)
				begin

					select 'Attribute/Role record already exists' as ReturnMessage;
					return;

				end

			--Check if record can be resurrected
			if exists
			(
				select *
				from stng.VV_Admin_RoleAttribute_Deleted
				where RoleID = @RoleID and (AttributeID = @AttributeID or @AttributeID is null) and (AttributeTypeID = @AttributeTypeID or AttributeTypeID is null)
			)
				begin

					update stng.Admin_RoleAttribute
					set Deleted = 0,
					DeletedBy = null,
					DeletedOn = null,
					RAD = stng.GetBPTime(GETDATE()),
					RAB = @EmployeeID
					where RoleID = @RoleID and (AttributeID = @AttributeID or @AttributeID is null) and (AttributeTypeID = @AttributeTypeID or AttributeTypeID is null)

				end

			--Else, insert new record
			else
				begin
					
					insert into stng.Admin_RoleAttribute
					(RoleID, AttributeID, AttributeTypeID, RAB)
					values
					(@RoleID, @AttributeID, @AttributeTypeID, @EmployeeID);

				end 

		end

	--Delete role attribute
	else if @Operation = 20
		begin

			--Check for LinkID 
			if @LinkID is null
				begin

					select 'LinkID required' as ReturnMessage;
					return;

				end

			--Check if LinkID exists
			if not exists
			(
				select *
				from stng.VV_Admin_RoleAttribute
				where UniqueID = @LinkID
			)
				begin

					select 'Role Attribute ID does not exist' as ReturnMessage;
					return;

				end

			--Perform delete
			update stng.Admin_RoleAttribute
			set Deleted = 1,
			DeletedBy = @EmployeeID,
			DeletedOn = stng.GetBPTime(GETDATE())
			where UniqueID = @LinkID;

		end

	--Get role attributes
	else if @Operation = 21
		begin

			select *
			from stng.VV_Admin_RoleAttribute
			where RoleID = @RoleID or @RoleID is null
			and
			(AttributeTypeID = @AttributeTypeID or @AttributeTypeID is null)
			and
			(AttributeID = @AttributeID or @AttributeID is null)
			option(optimize for (@RoleID unknown, @AttributeTypeID unknown, @AttributeID unknown));
			

		end

	--Add role permission
	else if @Operation = 22
		begin

			--Check if PermissionID/Permission and RoleID/Role are provided
			if @PermissionID is null
				begin

					if @Permission is null
						begin

							select 'Permission or PermissionID is required' as ReturnMessage;
							return;

						end

					else
						begin

							select @PermissionID = UniqueID
							from stng.Admin_Permission
							where Permission = @Permission and Deleted = 0;

						end

				end

			if @RoleID is null
				begin

					if @Role is null
						begin

							select 'Role or RoleID is required' as ReturnMessage;
							return;

						end 

					else
						begin

							select @RoleID = UniqueID
							from stng.VV_Admin_AllRole
							where [Role] = @Role;

						end

				end

			--Check if PermissionID and RoleID exist
			if not exists
			(
				select *
				from stng.Admin_Permission
				where UniqueID = @PermissionID
			)
			or
			not exists
			(
				select *
				from stng.VV_Admin_AllRole
				where UniqueID = @RoleID
			)
				begin

					select 'Permission and/or Role does not exist' as ReturnMessage;
					return;

				end

			--Check if PermissionID/RoleID record already exists
			if exists
			(
				select *
				from stng.VV_Admin_AllRolePermissionDirect
				where RoleID = @RoleID and PermissionID = @PermissionID
			
			)
				begin

					select 'Permission already in Role' as ReturnMessage;
					return;

				end

			--Check if PermissionID/RoleID record can be resurrected
			if exists
			(
				select *
				from stng.VV_Admin_AllRolePermissionDirect_Deleted
				where RoleID = @RoleID and PermissionID = @PermissionID
			)
				begin

					update stng.Admin_RolePermission
					set Deleted = 0,
					DeletedBy = null,
					DeletedOn = null,
					RAD = stng.GetBPTime(GETDATE()),
					RAB = @EmployeeID
					where RoleID = @RoleID and PermissionID = @PermissionID;

				end

			--Otherwise, insert new record
			else
				begin

					insert into stng.Admin_RolePermission
					(RoleID, PermissionID, RAB)
					values
					(@RoleID, @PermissionID, @EmployeeID);

				end


		end

	--Delete role permission
	else if @Operation = 23
		begin
			
			--Check if PermissionID and RoleID are provided
			if @PermissionID is null or @RoleID is null
				begin

					select 'PermissionID and RoleID are required' as ReturnMessage;
					return;

				end

			--Check if exists
			if not exists
			(
				select *
				from stng.VV_Admin_AllRolePermissionDirect
				where RoleID = @RoleID and PermissionID = @PermissionID
			)
				begin

					select 'Permission does not belong to Role' as ReturnMessage;
					return;

				end

			--Delete
			update stng.Admin_RolePermission
			set Deleted = 1,
			DeletedBy = @EmployeeID,
			DeletedOn = stng.GetBPTime(GETDATE())
			where RoleID = @RoleID and PermissionID = @PermissionID;

		end

	--Get role permissions
	else if @Operation = 24
		begin
			
			select *
			from stng.VV_Admin_AllRolePermissionDirect
			where 
			(RoleID = @RoleID or @RoleID is null)
			and
			(PermissionID = @PermissionID or @PermissionID is null)
			and
			([Role] = @Role or @Role is null)
			and
			(Permission = @Permission or @Permission is null)
			order by [Permission] asc
			option(optimize for (@RoleID unknown, @PermissionID unknown, @Role unknown, @Permission unknown));

		end

	--Get Users
	else if @Operation = 25
		begin

			select *
			from stng.VV_Admin_Users
			where 
			(@EmployeeID is null or EmployeeID = @EmployeeID)
			and
			(@Email is null or Email = @Email)
			and
			(@LANID is null or LANID = @LANID)
			and
			((@Active is null and Active = 1) or Active = @Active)
			order by EmployeeID asc
			option(optimize for (@EmployeeID unknown, @Active unknown, @Email unknown));

		end

	--Add User Attribute
	else if @Operation = 26
		begin

			--Check for EmployeeID and AttributeID or AttributeTypeID
			if @EmployeeIDInsert is null
				begin

					select 'EmployeeIDInsert required' as ReturnMessage;
					return;

				end

			--Check for Attribute, AttributeType or their IDs
			insert into @AdminCheck
			(AttributeID, AttributeTypeID, ReturnMessage)
			select AttributeID, AttributeTypeID, ReturnMessage
			from stng.FN_Admin_AttributeCheck(@AttributeID, @Attribute, @AttributeType, @AttributeTypeID);

			if exists
			(
				select *
				from @AdminCheck
				where ReturnMessage is not null
			)
				begin

					return (select ReturnMessage from @AdminCheck);

				end

			else
				begin

					select @AttributeID = AttributeID from @AdminCheck;
					select @AttributeTypeID = AttributeTypeID from @AdminCheck;

				end

			--Check if Attribute record already exists
			if exists
			(
				select *
				from stng.VV_Admin_UserAttribute
				where EmployeeID = @EmployeeIDInsert 
				and 
				(@AttributeID is null or AttributeID = @AttributeID) and 
				(@AttributeTypeID is null or AttributeTypeID = @AttributeTypeID) 
			)
				begin

					select 'Attribute/Role record already exists' as ReturnMessage;
					return;

				end

			--Check if record can be resurrected
			if exists
			(
				select *
				from stng.VV_Admin_UserAttribute_Deleted
				where EmployeeID = @EmployeeIDInsert 
				and 
				(@AttributeID is null or AttributeID = @AttributeID) and 
				(@AttributeTypeID is null or AttributeTypeID = @AttributeTypeID) 
			)
				begin
					update stng.Admin_UserAttribute
					set Deleted = 0,
					DeletedBy = null,
					DeletedOn = null,
					RAD = stng.GetBPTime(GETDATE()),
					RAB = @EmployeeID
					where EmployeeID = @EmployeeIDInsert 
					and 
					(@AttributeID is null or AttributeID = @AttributeID) and 
					(@AttributeTypeID is null or AttributeTypeID = @AttributeTypeID) 

				end

			--Else, insert new record
			else
				begin
					
					insert into stng.Admin_UserAttribute
					(EmployeeID, AttributeID, AttributeTypeID, RAB)
					values
					(@EmployeeIDInsert, @AttributeID, @AttributeTypeID, @EmployeeID);

				end 


		end

	--Delete User Attribute
	else if @Operation = 27
		begin
			
			--Check for LinkID 
			if @LinkID is null
				begin

					select 'LinkID required' as ReturnMessage;
					return;

				end

			--Check if LinkID exists
			if not exists
			(
				select *
				from stng.VV_Admin_UserAttribute
				where UniqueID = @LinkID
			)
				begin

					select 'User Attribute ID does not exist' as ReturnMessage;
					return;

				end

			--Perform delete
			update stng.Admin_UserAttribute
			set Deleted = 1,
			DeletedBy = @EmployeeID,
			DeletedOn = stng.GetBPTime(GETDATE())
			where UniqueID = @LinkID;

		end

	--Get User Attributes
	else if @Operation = 28
		begin

			select *
			from stng.VV_Admin_UserAttribute
			where EmployeeID = @EmployeeID;

		end

	--Add user permission
	else if @Operation = 29
		begin

			--Check for EmployeeIDInsert and PermissionID
			if @EmployeeIDInsert is null
				begin

					select 'EmployeeIDInsert is required' as ReturnMessage;
					return;

				end
			
			else if not exists
			(
				select *
				from stng.Admin_User
				where EmployeeID = @EmployeeIDInsert and Active = 1
			)
				begin

					select 'EmployeeID does not exist or is not an active user' as ReturnMessage;
					return;

				end

			if @PermissionID is null
				begin

					if @Permission is null
						begin

							select 'Permission is required' as ReturnMessage;
							return;

						end

					else if not exists
					(
						select *
						from stng.VV_Admin_ActualUserPermission_Manage
						where Permission = @Permission and EmployeeID = @EmployeeID
					)
						begin

							select 'Permission does not exist or cannot be managed with current execution context' as ReturnMessage;
							return;
						end

					else
						begin

							select @PermissionID = PermissionID
							from stng.VV_Admin_ActualUserPermission_Manage
							where Permission = @Permission and EmployeeID = @EmployeeID;

						end
						
				end

			else if not exists
			(
				select *
				from stng.VV_Admin_ActualUserPermission_Manage
				where PermissionID = @PermissionID and EmployeeID = @EmployeeID
			)
				begin
					
					select 'Permission does not exist or cannot be managed with current execution context' as ReturnMessage;
					return;

				end
				
			--Check if EmployeeID/PermissionID record already exists
			if exists
			(
				select *
				from stng.VV_Admin_UserPermissionDirect
				where EmployeeID = @EmployeeIDInsert and PermissionID = @PermissionID
			
			)
				begin

					select 'Permission already assigned to User' as ReturnMessage;
					return;

				end

			--Check if PermissionID/RoleID record can be resurrected
			if exists
			(
				select *
				from stng.VV_Admin_UserPermissionDirect_Deleted
				where EmployeeID = @EmployeeIDInsert and PermissionID = @PermissionID
			)
				begin

					update stng.Admin_UserPermission
					set Deleted = 0,
					DeletedBy = null,
					DeletedOn = null,
					RAD = stng.GetBPTime(GETDATE()),
					RAB = @EmployeeID
					where EmployeeID = @EmployeeIDInsert and PermissionID = @PermissionID;

				end

			--Otherwise, insert new record
			else
				begin

					insert into stng.Admin_UserPermission
					(EmployeeID, PermissionID, RAB)
					values
					(@EmployeeIDInsert, @PermissionID, @EmployeeID);

				end


		end

	--Delete user permission
	else if @Operation = 30
		begin

			--Check if PermissionID and EmployeeIDInsert are provided
			if @EmployeeIDInsert is null
				begin

					select 'EmployeeIDInsert is required' as ReturnMessage;
					return;

				end

		else if not exists
			(
				select *
				from stng.Admin_User
				where EmployeeID = @EmployeeIDInsert and Active = 1
			)
				begin

					select 'EmployeeID does not exist or is not an active user' as ReturnMessage;
					return;

				end

			if @PermissionID is null
				begin

					if @Permission is null
						begin

							select 'Permission is required' as ReturnMessage;
							return;

						end

					else if not exists
					(
						select *
						from stng.VV_Admin_ActualUserPermission_Manage
						where Permission = @Permission and EmployeeID = @EmployeeID
					)
						begin

							select 'Permission does not exist or cannot be managed with current execution context' as ReturnMessage;
							return;
						end

					else
						begin

							select @PermissionID = PermissionID
							from stng.VV_Admin_ActualUserPermission_Manage
							where Permission = @Permission and EmployeeID = @EmployeeID;

						end
						
				end

			else if not exists
			(
				select *
				from stng.VV_Admin_ActualUserPermission_Manage
				where PermissionID = @PermissionID and EmployeeID = @EmployeeID
			)
				begin
					
					select 'Permission does not exist or cannot be managed with current execution context' as ReturnMessage;
					return;

				end

			--Check if EmployeeID/PermissionID record already exists
			if not exists
			(
				select *
				from stng.VV_Admin_UserPermissionDirect
				where EmployeeID = @EmployeeIDInsert and PermissionID = @PermissionID
			
			)
				begin

					select 'Permission is not assigned to User' as ReturnMessage;
					return;

				end

			--Delete
			update stng.Admin_UserPermission
			set Deleted = 1,
			DeletedBy = @EmployeeID,
			DeletedOn = stng.GetBPTime(GETDATE())
			where EmployeeID = @EmployeeIDInsert and PermissionID = @PermissionID;

		end

	--Get inserted user's permissions that requesting user can manage
	else if @Operation = 31
		begin

			with manageablepermissions as
			(
				select *
				from stng.VV_Admin_ActualUserPermission_Manage
				where EmployeeID = @EmployeeID
			),
			relevantpermissions as
			(
				select *
				from stng.VV_Admin_ActualUserPermission
				where EmployeeID = @EmployeeIDInsert
			)

			select distinct a.UniqueID, a.Permission, a.PermissionID, a.PermissionDescription, b.EmployeeID
			from manageablepermissions as a
			inner join relevantpermissions as b on a.PermissionID = b.PermissionID
			where
			(@Permission is null or a.Permission = @Permission)
			and
			(@PermissionID is null or a.PermissionID = @PermissionID)
			and
			(@Origin is null or b.Origin = @Origin)
			order by a.Permission asc
			option(optimize for (@EmployeeIDInsert unknown, @Permission unknown, @PermissionID unknown, @EmployeeID unknown, @Origin unknown));

		end

	--Add user role
	else if @Operation = 32
		begin

			--Check for EmployeeIDInsert and RoleID
			if @EmployeeIDInsert is null or @RoleID is null
				begin

					select 'EmployeeIDInsert and RoleID is required' as ReturnMessage;
					return;

				end

			--Check if user has permission to add role
			if not exists(
				select * from stng.VV_Admin_Role_Manage
				where RoleID = @RoleID and EmployeeID = @EmployeeID
			)
				begin
					select 'User does not have permission to assign this role' as ReturnMessage;
					return;
				end

			--Check if EmployeeID/RoleID record already exists
			if exists
			(
				select *
				from stng.VV_Admin_UserRole
				where EmployeeID = @EmployeeIDInsert and RoleID = @RoleID
			
			)
				begin

					select 'User is already a member of Role' as ReturnMessage;
					return;

				end

			--Check if EmployeeID/RoleID record can be resurrected
			if exists
			(
				select *
				from stng.VV_Admin_UserRole_Deleted
				where EmployeeID = @EmployeeIDInsert and RoleID = @RoleID
			)
				begin

					update stng.Admin_UserRole
					set Deleted = 0,
					DeletedBy = null,
					DeletedOn = null,
					RAD = stng.GetBPTime(GETDATE()),
					RAB = @EmployeeID
					where EmployeeID = @EmployeeIDInsert and RoleID = @RoleID;

				end

			--Otherwise, insert new record
			else
				begin

					insert into stng.Admin_UserRole
					(EmployeeID, RoleID, RAB)
					values
					(@EmployeeIDInsert, @RoleID, @EmployeeID);

				end

		end

	--Remove user from role
	else if @Operation = 33
		begin

			--Check if RoleID and EmployeeIDInsert are provided
			if @RoleID is null or @EmployeeIDInsert is null
				begin

					select 'RoleID and EmployeeIDInsert are required' as ReturnMessage;
					return;

				end

			--Check if user can manage role
			if not exists(
				select * from stng.VV_Admin_Role_Manage
				where RoleID = @RoleID and @EmployeeID = EmployeeID
			)
				begin
					select 'User does not have permission to manage Role' as ReturnMessage;
					return;
				end


			--Check if exists
			if not exists
			(
				select *
				from stng.VV_Admin_UserRole
				where EmployeeID = @EmployeeIDInsert and RoleID = @RoleID
			)
				begin

					select 'User does not possess Role' as ReturnMessage;
					return;

				end

			--Delete
			update stng.Admin_UserRole
			set Deleted = 1,
			DeletedBy = @EmployeeID,
			DeletedOn = stng.GetBPTime(GETDATE())
			where EmployeeID = @EmployeeIDInsert and RoleID = @RoleID;

		end

	--Get User Roles
	else if @Operation = 34
		begin

			select *
			from stng.VV_Admin_UserRole
			where EmployeeID = @EmployeeID
			order by [Role] asc
			option(optimize for (@EmployeeID unknown));

		end

	--Add attribute type
	else if @Operation = 35
		begin
			
			--Check for AttributeType
			if @AttributeType is null or @Supersedence is null
				begin

					select 'AttributeType and Supersedence required' as ReturnMessage;
					return;

				end 

			--Check if AttributeType already exists
			if exists
			(
				select *
				from stng.Admin_AttributeType
				where AttributeType = @AttributeType and Deleted = 0
			)
				begin

					select 'AttributeType already exists' as ReturnMessage;
					return;

				end

			--Check if AttributeType can be resurrected
			if exists
			(
				select *
				from stng.Admin_AttributeType
				where AttributeType = @AttributeType and Deleted = 1
			)
				begin

					update stng.Admin_AttributeType
					set 
					Supersedence = @Supersedence,
					Deleted = 0,
					DeletedBy = null,
					DeletedOn = null,
					RAD = stng.GetBPTime(GETDATE()),
					RAB = @EmployeeID
					where AttributeType = @AttributeType;

				end

			--Else, add new record 
			else
				begin

					insert into stng.Admin_AttributeType
					(AttributeType, RAB, Supersedence)
					values
					(@AttributeType, @EmployeeID, @Supersedence);

				end
				

		end

	--Remove attribute type
	else if @Operation = 36
		begin
			
			--First, check for AttributeType or AttributeTypeID
			if @AttributeTypeID is null
				   begin

						  if @AttributeType is null
								 begin

									   select 'AttributeType or AttributeTypeID required';

								 end

						  else
								 begin

									if not exists
									(
										select *
										from stng.Admin_AttributeType
										where AttributeType = @AttributeType and Deleted = 0
									)
										begin

											select 'AttributeType does not exist' as ReturnMessage;
											return;

										end

									else
										begin

											select @AttributeTypeID = UniqueID
											from stng.Admin_AttributeType
											where AttributeType = @AttributeType and Deleted = 0;

										end

								 end

				   end

			--Check if AttributeTypeID exists
			if not exists
			(
				   select *
				   from stng.Admin_AttributeType
				   where UniqueID = @AttributeTypeID and Deleted = 0
			)
				   begin

						  select 'AttributeType does not exist' as ReturnMessage;
						  return;

				   end

			--Perform delete
			update stng.Admin_AttributeType
			set Deleted = 1,
			DeletedBy = @EmployeeID,
			DeletedOn = stng.GetBPTime(GETDATE())
			where UniqueID = @AttributeTypeID;

		end

	--Get Attribute Type
	else if @Operation = 37
		begin

			select UniqueID as AttributeTypeID, AttributeType
			from stng.Admin_AttributeType
			where Deleted = 0
			and
			(@AttributeTypeID is null or UniqueID = @AttributeTypeID)
			and
			(@AttributeType is null or AttributeType = @AttributeType)
			order by AttributeType asc
			option(optimize for (@AttributeType unknown, @AttributeTypeID unknown));

		end

	--Add Endpoint
	else if @Operation = 38
		begin

			--Check for Endpoint and HTTPVerb
			if @Endpoint is null or @HTTPVerb is null
				begin

					select 'Endpoint and HTTPVerb are required' as ReturnMessage;
					return;

				end

			--Clean Endpoint
			set @Endpoint = stng.FN_Admin_CleanEndpoint(@Endpoint);

			--Check if Endpoint/HTTPVerb record already exists
			if exists
			(
				select *
				from stng.VV_Admin_AllEndpoint
				where Endpoint = @Endpoint and HTTPVerb = @HTTPVerb
			)
				begin
					
					select 'Endpoint already exists' as ReturnMessage;
					return;

				end

			--Check if Endpoint can be resurrected
			if exists
			(
				select *
				from stng.Admin_Endpoint
				where Endpoint = @Endpoint and HTTPVerb = @HTTPVerb and Deleted = 1
			)
				begin

					update stng.Admin_Endpoint
					set Deleted = 0,
					DeletedBy = null,
					DeletedOn = null,
					RAD = stng.GetBPTime(GETDATE()),
					RAB = @EmployeeID,
					LUD = stng.GetBPTime(GETDATE()),
					LUB = @EmployeeID
					where Endpoint = @Endpoint and HTTPVerb = @HTTPVerb;

				end

			else
				begin 

					--Otherwise, insert new record
					insert into stng.Admin_Endpoint
					(Endpoint, HTTPVerb, RAB, LUB)
					values
					(LOWER(@Endpoint), UPPER(@HTTPVerb), @EmployeeID, @EmployeeID);

				end

			--Return EndpointID
			select UniqueID as EndpointID
			from stng.Admin_Endpoint
			where Endpoint = @Endpoint and HTTPVerb = @HTTPVerb and Deleted = 0;

		end

	--Remove endpoint
	else if @Operation = 39
		begin

			--Check for Endpoint/HTTPVerb or EndpointID
			if @EndpointID is null
				begin 

					if @Endpoint is null or @HTTPVerb is null
						begin
							
							select 'Endpoint/HTTPVerb or EndpointID required' as ReturnMessage;
							return;

						end

					else
						begin

							select @EndpointID = EndpointID
							from stng.VV_Admin_AllEndpoint
							where Endpoint = @Endpoint and HTTPVerb = @HTTPVerb;

						end

				end
			
			--Check if EndpointID exists
			if not exists
			(
				select *
				from stng.VV_Admin_AllEndpoint
				where EndpointID = @EndpointID
			)
				begin

					select 'Endpoint does not exist' as ReturnMessage;
					return;

				end

			--Perform delete
			update stng.Admin_Endpoint
			set Deleted = 1,
			DeletedBy = @EmployeeID,
			DeletedOn = stng.GetBPTime(GETDATE())
			where UniqueID = @EndpointID;

		end

	--Get endpoint(s)
	else if @Operation = 40
		begin

			select *
			from stng.VV_Admin_AllEndpoint
			where 
			(@Endpoint is null or Endpoint = @Endpoint)
			and
			(@HTTPVerb is null or HTTPVerb = @HTTPVerb)
			and
			(@EndpointID is null or EndpointID = @EndpointID)
			order by Endpoint asc, HTTPVerb asc
			option(optimize for (@Endpoint unknown, @EndpointID unknown, @HTTPVerb unknown));

		end

	--Edit endpoint
	else if @Operation = 41
		begin

			--Check if Endpoint, EndpointID, and HTTPVerb are all provided
			if @Endpoint is null or @EndpointID is null or @HTTPVerb is null
				begin 

					select 'Endpoint, EndpointID, and HTTPVerb are required' as ReturnMessage;
					return;

				end

			--Clean Endpoint
			set @Endpoint = stng.FN_Admin_CleanEndpoint(@Endpoint);

			--Check if Endpoint/HTTPVerb already exists
			if exists
			(
				select *
				from stng.VV_Admin_AllEndpoint
				where Endpoint = @Endpoint and HTTPVerb = @HTTPVerb
			)
				begin

					select 'Endpoint already exists' as ReturnMessage;
					return;

				end

			--Perform update
			update stng.Admin_Endpoint
			set Endpoint = @Endpoint,
			HTTPVerb = @HTTPVerb,
			LUD = stng.GetBPTime(GETDATE()),
			LUB = @EmployeeID
			where UniqueID = @EndpointID;

		end

	--Link Endpoint attribute
	else if @Operation = 42
		begin

			--Check for EndpointID or Endpoint/HTTPVerb
			if @EndpointID is null
				begin

					if @Endpoint is null or @HTTPVerb is null
						begin

							select 'Endpoint/HTTPVerb or EndpointID is required' as ReturnMessage;
							return;

						end

					else
						begin

							select @EndpointID = EndpointID
							from stng.VV_Admin_AllEndpoint
							where Endpoint = @Endpoint and HTTPVerb = @HTTPVerb;

							if @EndpointID is null
								begin

									select 'Endpoint does not exist' as ReturnMessage;
									return;
								end

						end

				end

			else if not exists
			(
				select *
				from stng.VV_Admin_AllEndpoint
				where EndpointID = @EndpointID
			)
				begin
				
					select 'Endpoint does not exist' as ReturnMessage;
					return;

				end

			--Check for Attribute, AttributeType or their IDs
			insert into @AdminCheck
			(AttributeID, AttributeTypeID, ReturnMessage)
			select AttributeID, AttributeTypeID, ReturnMessage
			from stng.FN_Admin_AttributeCheck(@AttributeID, @Attribute, @AttributeTypeID, @AttributeType);

			if  exists
			(
				select *
				from @AdminCheck
				where ReturnMessage is not null
			)
				begin

					select top 1 ReturnMessage from @AdminCheck;
					return;

				end

			else
				begin

					select @AttributeID = AttributeID from @AdminCheck;
					select @AttributeTypeID = AttributeTypeID from @AdminCheck;

				end


			--if @AttributeID is null
			--	begin

			--		if @Attribute is null
			--			begin

			--				if @AttributeType is null and @AttributeTypeID is null
			--					begin

			--						select 'Attribute or AttributeType is required' as ReturnMessage;
			--						return;

			--					end

			--				else if @AttributeTypeID is null
			--					begin

			--						select @AttributeTypeID = UniqueID
			--						from stng.Admin_AttributeType
			--						where AttributeType = @AttributeType and Deleted = 0;

			--						if @AttributeTypeID is null
			--							begin

			--								select 'AttributeType/AttributeTypeID does not exist' as ReturnMessage;
			--								return;

			--							end

			--					end
								
			--			end

			--		else
			--			begin

			--				if @AttributeType is null and @AttributeTypeID is null
			--					begin

			--						select 'AttributeType or AttributeTypeID is required' as ReturnMessage;
			--						return;

			--					end

			--				else if @AttributeTypeID is null
			--					begin

			--						select @AttributeTypeID = UniqueID
			--						from stng.Admin_AttributeType
			--						where AttributeType = @AttributeType and Deleted = 0;

			--						if @AttributeTypeID is null
			--							begin

			--								select 'AttributeType/AttributeTypeID does not exist' as ReturnMessage;
			--								return;

			--							end

			--					end

			--				select @AttributeID = AttributeID
			--				from stng.VV_Admin_Attribute
			--				where Attribute = @Attribute and AttributeTypeID = @AttributeTypeID;

			--				if @AttributeID is null
			--					begin

			--						select 'Attribute does not exist' as ReturnMessage;
			--						return;

			--					end

			--				set @AttributeTypeID = null;

			--			end
			--	end

			--else if not exists
			--(
			--	select *
			--	from stng.VV_Admin_Attribute
			--	where AttributeID = @AttributeID
			--)
			--	begin

			--		select 'Attribute does not exist' as ReturnMessage;
			--		return;

			--	end

			--else
			--	begin

			--		set @AttributeTypeID = null;

			--	end
				
			--Check if record already exists
			if exists
			(
				select *
				from stng.VV_Admin_EndpointAttribute
				where 
				EndpointID = @EndpointID 
				and (AttributeID = @AttributeID or @AttributeID is null) and (AttributeTypeID = @AttributeTypeID or AttributeTypeID is null)
			--	(
			--	--(AttributeID = @AttributeID and AttributeTypeID is null) or 
			--	--(AttributeTypeID = @AttributeTypeID and AttributeID is null) or
			--	(@AttributeTypeID is null or AttributeTypeID = @AttributeTypeID) or
			--	(AttributeID is null or AttributeID = @AttributeID) or
			--	(AttributeID = @AttributeID and AttributeTypeID = @AttributeTypeID )) 
			--	--(@AttributeTypeID is null or AttributeTypeID = @AttributeTypeID)
			--	--and
			--	--(@AttributeID is null or AttributeID = @AttributeID)
			--)
			)
				begin

					select 'Attribute/Endpoint record already exists' as ReturnMessage;
					return;

				end

			--Check if record can be resurrected
			if exists
			(
				select *
				from stng.VV_Admin_EndpointAttribute_Deleted
				where EndpointID = @EndpointID  
				and (AttributeID = @AttributeID or @AttributeID is null) and (AttributeTypeID = @AttributeTypeID or AttributeTypeID is null))
			--	--(AttributeID = @AttributeID and AttributeTypeID is null) or 
			--	--(AttributeTypeID = @AttributeTypeID and AttributeID is null) or
			--	(@AttributeTypeID is null or AttributeTypeID = @AttributeTypeID) or
			--	(AttributeID is null or AttributeID = @AttributeID) or
			--	(AttributeID = @AttributeID and AttributeTypeID = @AttributeTypeID )) 
			--	--(@AttributeTypeID is null or AttributeTypeID = @AttributeTypeID)
			--	--and
			--	--(@AttributeID is null or AttributeID = @AttributeID)
			--)
				begin

					update stng.Admin_EndpointAttribute
					set Deleted = 0,
					DeletedBy = null,
					DeletedOn = null,
					RAD = stng.GetBPTime(GETDATE()),
					RAB = @EmployeeID
					where EndpointID = @EndpointID 
					and (AttributeID = @AttributeID or @AttributeID is null) and (AttributeTypeID = @AttributeTypeID or AttributeTypeID is null)
				----(AttributeID = @AttributeID and AttributeTypeID is null) or 
				----(AttributeTypeID = @AttributeTypeID and AttributeID is null) or
				--(@AttributeTypeID is null or AttributeTypeID = @AttributeTypeID) or
				--(AttributeID is null or AttributeID = @AttributeID) or
				--(AttributeID = @AttributeID and AttributeTypeID = @AttributeTypeID )) 
				----(@AttributeTypeID is null or AttributeTypeID = @AttributeTypeID)
				----and
				----(@AttributeID is null or AttributeID = @AttributeID)
			

				end

			--Else, insert new record
			else
				begin
					
					insert into stng.Admin_EndpointAttribute
					(EndpointID, AttributeID, AttributeTypeID, RAB)
					values
					(@EndpointID, @AttributeID, @AttributeTypeID, @EmployeeID);

				end 


		end

	--Delink Endpoint attribute
	else if @Operation = 43
		begin
			
			--Check if LinkID was provided 
			if @LinkID is null
				begin

					select 'LinkID is required' as ReturnMessage;
					return;

				end

			--Check if exists
			if not exists
			(
				select *
				from stng.VV_Admin_EndpointAttribute
				where UniqueID = @LinkID
			)
				begin

					select 'Endpoint/Attribute record does not exist' as ReturnMessage;
					return;

				end

			--Delete
			update stng.Admin_EndpointAttribute
			set Deleted = 1,
			DeletedBy = @EmployeeID,
			DeletedOn = stng.GetBPTime(GETDATE())
			where UniqueID = @LinkID;

		end

	--Get Endpoint attributes
	else if @Operation = 44
		begin

			select *
			from stng.VV_Admin_EndpointAttribute
			where
			(Endpoint = @Endpoint or @Endpoint is null)
			and
			(HTTPVerb = @HTTPVerb or @HTTPVerb is null)
			and
			(EndpointID = @EndpointID or @EndpointID is null)
			order by Endpoint asc, HTTPVerb asc
			option(optimize for (@Endpoint unknown, @HTTPVerb unknown, @EndpointID unknown));

		end

	--Add Endpoint permission
	else if @Operation = 45
		begin

			--Check if Endpoint/HTTPVerb or EndpointID was provided
			if @EndpointID is null
				begin

					if @Endpoint is null or @HTTPVerb is null
						begin

							select 'Endpoint/HTTPVerb or EndpointID is required' as ReturnMessage;
							return;

						end

					else
						begin

							if not exists
							(
								select EndpointID
								from stng.VV_Admin_AllEndpoint
								where Endpoint = @Endpoint and HTTPVerb = @HTTPVerb
							)
								begin

									select 'Endpoint does not exist' as ReturnMessage;
									return;

								end

							else
								begin

									select @EndpointID = EndpointID
									from stng.VV_Admin_AllEndpoint
									where Endpoint = @Endpoint and HTTPVerb = @HTTPVerb;

								end

						end

				end 

			--Check if Permission or PermissionID
			if @PermissionID is null
				begin

					if @Permission is null
						begin

							select 'Permission or PermissionID is required' as ReturnMessage;
							return;

						end

					else
						begin

							if not exists
							(
								select PermissionID
								from stng.VV_Admin_AllPermission
								where Permission = @Permission
							)
								begin
									
									select 'Permission does not exist' as ReturnMessage;
									return;

								end

							else
								begin

									select @PermissionID = PermissionID
									from stng.VV_Admin_AllPermission
									where Permission = @Permission;

								end



						end

				end

			--Check if Permission/Endpoint record already exists
			if exists
			(
				select *
				from stng.VV_Admin_EndpointPermission
				where EndpointID = @EndpointID and PermissionID = @PermissionID
			)
				begin

					select 'Permission/Endpoint record already exists' as ReturnMessage;
					return;

				end

			--Check if record can be resurrected
			if exists
			(
				select *
				from stng.VV_Admin_EndpointPermission_Deleted
				where EndpointID = @EndpointID and PermissionID = @PermissionID				
			)
				begin

					update stng.Admin_EndpointPermission
					set Deleted = 0,
					DeletedBy = null,
					DeletedOn = null,
					RAD = stng.GetBPTime(GETDATE()),
					RAB = @EmployeeID
					where EndpointID = @EndpointID and PermissionID = @PermissionID;

				end

			--Otherwise, insert new record
			else
				begin

					insert into stng.Admin_EndpointPermission
					(EndpointID, PermissionID, RAB)
					values
					(@EndpointID, @PermissionID, @EmployeeID);
				end


		end

	--Delete endpoint permission
	else if @Operation = 46
		begin

			--Check if Endpoint/HTTPVerb or EndpointID was provided
			if @EndpointID is null
				begin

					if @Endpoint is null or @HTTPVerb is null
						begin

							select 'Endpoint/HTTPVerb or EndpointID is required' as ReturnMessage;
							return;

						end

					else
						begin

							select @EndpointID = EndpointID
							from stng.VV_Admin_AllEndpoint
							where Endpoint = @Endpoint and HTTPVerb = @HTTPVerb;

						end

				end 

			--Check if Permission or PermissionID
			if @PermissionID is null
				begin

					if @Permission is null
						begin

							select 'Permission or PermissionID is required' as ReturnMessage;
							return;

						end

					else
						begin

							select @PermissionID = PermissionID
							from stng.VV_Admin_AllPermission
							where Permission = @Permission;

						end

				end

			--Check if Permission/Endpoint record exists
			if not exists
			(
				select *
				from stng.VV_Admin_EndpointPermission
				where EndpointID = @EndpointID and PermissionID = @PermissionID
			)
				begin

					select 'Permission/Endpoint record does not exist' as ReturnMessage;
					return;

				end

			--Delete
			update stng.Admin_EndpointPermission
			set Deleted = 1,
			DeletedOn = stng.GetBPTime(GETDATE()),
			DeletedBy = @EmployeeID
			where EndpointID = @EndpointID and PermissionID = @PermissionID;

		end

	--Get endpoint permissions
	else if @Operation = 47
		begin

			select *
			from stng.VV_Admin_EndpointPermission
			where
			(@EndpointID is null or EndpointID = @EndpointID)
			and
			(@Endpoint is null or Endpoint = @Endpoint)
			and 
			(@HTTPVerb is null or HTTPVerb = @HTTPVerb)
			and
			(@Permission is null or Permission = @Permission)
			and
			(@PermissionID is null or PermissionID = @PermissionID)
			order by Endpoint asc, HTTPVerb asc
			option(optimize for (@EndpointID unknown, @Endpoint unknown, @HTTPVerb unknown, @Permission unknown, @PermissionID unknown));

		end

	--Get User Endpoints
	else if @Operation = 48
		begin

			select *
			from stng.VV_Admin_ActualUserEndpoint
			where EmployeeID = @EmployeeID
			and
			(@EndpointID is null or EndpointID = @EndpointID)
			and
			(@Endpoint is null or Endpoint = @Endpoint)
			and
			(@HTTPVerb is null or HTTPVerb = @HTTPVerb)
			order by Endpoint asc, HTTPVerb asc
			option(optimize for (@EmployeeID unknown, @Endpoint unknown, @EndpointID unknown, @HTTPVerb unknown));

		end

	--Add new User (Only used when user info endpoints 
	else if @Operation = 49
		begin

			if not exists
			(
				select *
				from stng.Admin_User
				where EmployeeID = @EmployeeID
			)
				begin

					insert into stng.Admin_User
					([UserID],[Username],[FirstName],[LastName],[Email],[Active],[LastLogin],[CreatedDate],[EmployeeID],[Title],[LANID])
					select max(UserID) + 1, @UserName, @FirstName, @LastName, @Email, 1, stng.GetBPTime(GETDATE()), stng.GetBPTime(GETDATE()), @EmployeeID, @Title, @LANID 
					from stng.Admin_User;

				end

			else
				begin

					select 'User already exists' as ReturnMessage;

				end

		end

	--Edit User
	--Active flag for now
	else if @Operation = 50
		begin

			update stng.Admin_User
			set Active = @Active
			where EmployeeID = @EmployeeIDInsert;

		end

	else if @Operation = 51
		begin

			select 'Not Implemented' as ReturnMessage;
			return;

		end 

	--Edit Attribute Type
	else if @Operation = 52
		begin
			
			--Check if AttributeType, AttributeTypeID, and Supersedence were provided
			if @AttributeType is null or @AttributeTypeID is null or @Supersedence is null
				begin

					select 'AttributeType, AttributeTypeID, and Supersedence are required' as ReturnMessage;
					return;

				end

			--Check if AttributeType exists
			if not exists
			(
				select *
				from stng.Admin_AttributeType
				where UniqueID = @AttributeTypeID and Deleted = 0
			)
				begin

					select 'AttributeTypeID does not exist' as ReturnMessage;
					return;

				end

			else if exists
			(
				select *
				from stng.Admin_AttributeType
				where UniqueID = @AttributeTypeID and AttributeType = @AttributeType and Deleted = 0				
			)
				begin

					select 'AttributeType already exists' as ReturnMessage;
					return;

				end

			update stng.Admin_AttributeType
			set AttributeType = @AttributeType,
			Supersedence = @Supersedence,
			LUD = stng.GetBPTime(GETDATE()),
			LUB = @EmployeeID
			where UniqueID = @AttributeTypeID;
			
		end

			--create access request
	else if @Operation = 53
		begin

			--check if module exists
			if @ModuleID is null
			begin
				if @Module is null
				begin
					select 'Module or ModuleID must be supplied as parameter' as ReturnMessage;
					return;
				end
				else
				begin
					if not exists(select * from stng.VV_Admin_Attribute where AttributeType = 'Module' and Attribute = @Module)
					begin
						select 'Module does not exist or is not a module' as ReturnMessage;
						return;
					end
					else
					begin
						set @WorkingModuleID = (select AttributeID from stng.VV_Admin_Attribute where Attribute = @Module and AttributeType = 'Module');
					end
				end
			end
			else
			begin
				if not exists(select * from stng.VV_Admin_Attribute where AttributeID = @ModuleID and AttributeType = 'Module')
				begin
					select 'ModuleID does not exist or is not a module' as ReturnMessage;
					return;
				end
				else
				begin
					set @WorkingModuleID = @ModuleID;
				end
			end

			--if it's an exact request
			if @IsMimicRequest = 0
				begin
					--check if needed parameters are there
					if @EmployeeIDInsert is null or @Description is null
						begin
							select 'EmployeeIDInsert and Description are required parameters for an EXACT admin access request' as ReturnMessage;
							return;
						end
					
					--check if request for same employee and module already exists
					else if exists(
					select * from stng.VV_Admin_SubRequests r 
					where r.ModuleAttributeID = @WorkingModuleID and r.RequestorEID = @EmployeeIDInsert and r.ActionStatus = 'Unreviewed' and r.ShortName = 'EX'
					)
					begin
						select 'Request for module already exists' as ReturnMessage;
						return;
					end
					

					set @WorkingRequestID = newid();
					set @WorkingSubRequestID = newid();

					--add new request to request table
					insert into stng.Admin_Request(RequestID, RequestorEID, AccessTypeID, ReasonGiven, RAB, OriginalModuleID)
					values (
					@WorkingRequestID,
					@EmployeeIDInsert, 
					(select AccessTypeID from stng.Admin_Request_Type where ShortName = 'EX'),
					@Description,
					@EmployeeID,
					@WorkingModuleID
					);

					--create subrequest
					insert into stng.Admin_SubRequest(RequestID, SubRequestID, StatusID, ModuleAttributeID)
					values (
					@WorkingRequestID, 
					@WorkingSubRequestID,
					(select s.StatusID from stng.Admin_SubRequestStatus s where s.ActionStatus = 'Unreviewed'),
					@WorkingModuleID
					);




				end
			--if it's a mimic request
			else if @IsMimicRequest = 1
				begin
				--check if needed parameters are there
					if @EmployeeIDInsert is null or @MimicOfEmployeeID is null or (@Module is null and @ModuleID is null)
						begin
							select 'EmployeeIDInsert, MimicOfEmployeeID, and (Module or ModuleID) are required parameters for a MIMIC admin access request' as ReturnMessage;
							return;
						end
					
					set @WorkingRequestID = newid();

					
					--check if mimicee has no roles
					if not exists
					(
						select * from stng.Admin_UserRole
						where EmployeeID = @MimicOfEmployeeID
					)
					begin
						select 'No change, selected user has no roles to mimic' as ReturnMessage;
						return;
					end


					--fill working table with roles of person being mimicked that user does not already have in that module
					insert into @WorkingRole
					(RoleID)
					select distinct t1.RoleID
					from stng.VV_Admin_UserRole t1
					left join stng.VV_Admin_UserRole t2 on t1.RoleID = t2.RoleID and t2.EmployeeID = @EmployeeIDInsert
					join stng.Admin_RoleAttribute ra on ra.AttributeID = @WorkingModuleID and ra.RoleID = t1.RoleID --only in that module
					where t2.EmployeeID is null and t1.EmployeeID = @MimicOfEmployeeID


					--check if empty
					if not exists
					(
						select * from @WorkingRole
					)
					begin
						select 'No change, User already has the same roles as requestee' as ReturnMessage;
						return;
					end

					
					--first create admin access req
					insert into stng.Admin_Request(RequestID, RequestorEID, AccessTypeID, MimicOfEID, ReasonGiven, RAB, OriginalModuleID)
					values( 
					@WorkingRequestID,
					@EmployeeIDInsert,
					(select AccessTypeID from stng.Admin_Request_Type where ShortName = 'MM'),
					@MimicOfEmployeeID,
					@Description,
					@EmployeeID,
					@WorkingModuleID
					);


					--then insert subrequests
					insert into stng.Admin_SubRequest(RequestID, SubRequestID, StatusID, ModuleAttributeID, RoleID)
					select
					@WorkingRequestID,
					newid(),
					(select s.StatusID from stng.Admin_SubRequestStatus s where s.ActionStatus = 'Unreviewed'),
					@WorkingModuleID,
					r.RoleID
					from @WorkingRole r
					--join stng.Admin_RoleAttribute ra on ra.RoleID = r.RoleID
					--join stng.Admin_Attribute att on att.UniqueID = ra.AttributeID and att.AttributeType = (select typ.UniqueID from stng.Admin_AttributeType typ where typ.AttributeType = 'Module');



				end
			else
				begin
					select 'IsMimicRequest is a required parameter' as ReturnMessage;
					return;
				end

		end

	--read access request
	else if @Operation = 54
		begin

			--check if employeeID was given
			if @EmployeeID is null
			begin
				select 'EmployeeID is a required parameter' as ReturnMessage;
				return;
			end

			--show unreviewed requests they have moduleowner permission for
			else 
			begin
				select distinct sr.SubRequestID, sr.RequestID, r.RequestorEID, sr.RoleID, uv.EmpName, attdep.Attribute as Department, attmod.Attribute as Module, rt.ShortName, r.ReasonGiven, r.RAD
				from stng.Admin_SubRequest sr
				join stng.Admin_Request r on r.RequestID = sr.RequestID
				join stng.VV_Admin_UserView uv on uv.EmployeeID = r.RequestorEID
				left join stng.Admin_DepartmentModule dm on dm.AttributeModID = sr.ModuleAttributeID
				left join stng.Admin_Attribute attdep on attdep.UniqueID = dm.AttributeDeptID
				join stng.Admin_Attribute attmod on attmod.UniqueID = sr.ModuleAttributeID
				join stng.Admin_Request_Type rt on rt.AccessTypeID = r.AccessTypeID
				join stng.Admin_PermissionAttribute pa on pa.AttributeID = sr.ModuleAttributeID
				join stng.VV_Admin_ActualUserPermission up on up.PermissionID = pa.PermissionID
				where sr.StatusID = '0CD2F0F6-4263-4CBE-BD7C-862FD2A70293' and up.EmployeeID = @EmployeeID and up.Permission like '%ModuleOwner%'
				order by r.RAD Desc;
			
			end

			

		end

	--update access request
	else if @Operation = 55
		begin


			--request id specified?
			if @SubRequestID is null
			begin
				select 'SubRequestID is a required parameter' as ReturnMessage;
				return;
			end

			--IsApproved specified?
			else if @IsApproved is null
			begin
				select 'IsApproved is a required parameter' as ReturnMessage;
				return;
			end

			--does the requestID exist?
			else if not exists (
				select * from stng.Admin_SubRequest
				where SubRequestID = @SubRequestID--may need to change
			)
			begin
				select 'No Access Request StatusLog with given ID exists' as ReturnMessage;
				return;
			end
			

			--EmployeeID present?
			else if @EmployeeID is null
			begin
				select 'EmployeeID is a required parameter' as ReturnMessage;
				return;
			end

			--check if able to modify this request
			else if not exists
			(
				select 1
				FROM stng.VV_Admin_ActualUserPermission ap
				JOIN stng.Admin_PermissionAttribute pa on pa.PermissionID = ap.PermissionID
				JOIN stng.VV_Admin_SubRequests r on r.ModuleAttributeID = pa.AttributeID
				WHERE r.SubRequestID = @SubRequestID and ap.EmployeeID = @EmployeeID and ap.Permission like '%ModuleOwner%'
			)
			begin
				select 'You do not have permission to modify this access request' as ReturnMessage;
				return;
			end

			--approved or denied?
			else if @IsApproved = 1
			begin
				update stng.Admin_SubRequest
				set StatusID = (select s.StatusID from stng.Admin_SubRequestStatus s where s.ActionStatus = 'Approved'), ReviewedBy = @EmployeeID, ReviewedOn = stng.GetBPTime(GETDATE()), Comment = @Description
				where SubRequestID = @SubRequestID;
			end
			else
			begin
				update stng.Admin_SubRequest
				set StatusID = (select s.StatusID from stng.Admin_SubRequestStatus s where s.ActionStatus = 'Rejected'), ReviewedBy = @EmployeeID, ReviewedOn = stng.GetBPTime(GETDATE()), Comment = @Description
				where SubRequestID = @SubRequestID;
			end

		end

	--Get current user permissions
	else if @Operation = 56
		begin

			select *
			from stng.VV_Admin_ActualUserPermission
			where EmployeeID = @EmployeeID and
			(@Permission is null or Permission = @Permission)
			order by Permission asc
			option(optimize for (@EmployeeID unknown));

		end

	--Get current user modules
	else if @Operation = 57
		begin

			select *
			from stng.VV_Admin_ActualUserModule um
			where um.EmployeeID = @EmployeeID
			--order by Module asc, [Endpoint] asc
			option(optimize for (@EmployeeID unknown));

		end

	-- Get Department based Roles, optional to specify module and role
	else if @Operation = 58
	begin

		select * from stng.VV_Admin_ModuleRoles
		where  Department = @Department and 
		(@Module is NULL OR Module = @Module) and
		(@RoleID is NULL OR RoleID = @RoleID) and
		(@Role is NULL or Role = @Role)

	end

	-- Get Unassigned Roles for an user that one can manage
	else if @Operation = 59
	begin

		if @EmployeeID is null or @EmployeeIDInsert is null 
			begin 
				
				select 'EmployeeID and EmployeeIDInsert are required' as ReturnMessage;
				return;

			end

		select 0 as checked, a.RoleID, a.Role, c.RoleDescription
		from stng.VV_Admin_Role_Manage as a 
		left join stng.VV_Admin_UserRole as b on a.RoleID = b.RoleID and b.EmployeeID = @EmployeeIDInsert
		inner join stng.VV_Admin_AllRole as c on a.RoleID = c.UniqueID 
		where a.EmployeeID = @EmployeeID and b.RoleID is null
		option(optimize for (@EmployeeID unknown, @EmployeeIDInsert unknown));
	end

	-- Get Unassigned Permissions for an user
	else if @Operation = 60
	begin
		select 0 as checked, a.PermissionID, a.Permission, a.PermissionDescription
		from stng.VV_Admin_ActualUserPermission_Manage as a
		left join stng.VV_Admin_UserPermissionDirect as b on a.PermissionID = b.PermissionID and b.EmployeeID = @EmployeeIDInsert
		where a.EmployeeID = @EmployeeID and b.PermissionID is null
		option(optimize for (@EmployeeID unknown, @EmployeeIDInsert unknown));
	end

	-- Get unlinked Permissions for a Role
	else if @Operation = 61
	begin
		select 0 as checked, a.PermissionID, a.Permission, c.PermissionDescription
		from stng.VV_Admin_ActualUserPermission_Manage as a
		left join stng.VV_Admin_AllRolePermissionDirect as b on a.PermissionID = b.PermissionID and b.RoleID = @RoleID
		inner join stng.Admin_Permission as c on a.PermissionID = c.UniqueID
		where a.EmployeeID = @EmployeeID and b.PermissionID is null
		option(optimize for (@EmployeeID unknown, @RoleID unknown));
	end

	--Get RSS for an Endpoint
	else if @Operation = 62
		begin

			select *
			from stng.VV_Admin_Endpoint_Expression
			where [Endpoint] = @Endpoint and HTTPVerb = @HTTPVerb
			option(optimize for (@Endpoint unknown, @HTTPVerb unknown));

		end

	--Get Module/Department based Permissions
	else if @Operation = 63
		begin
			--select *
			--from stng.VV_Admin_ModulePermissions
			--where  Department = @Department and 
			--(@Module is NULL OR Module = @Module)

			select *
			from stng.VV_Admin_Permission_DeptModuleAttribute
			where
			(depts like '%' + @Department + '%' or @Department is null)
			and
			(modules like '%' + @Module + '%')
			and
			@EmployeeID = EmployeeID
			option(optimize for (@Department unknown, @Module unknown, @EmployeeID unknown));

		end

	--Get Unlinked Permissions for an Endpoint
	else if @Operation = 64
		begin 

			select 0 as checked, a.PermissionID, a.Permission, c.PermissionDescription
			from stng.VV_Admin_ActualUserPermission_Manage as a
			left join stng.VV_Admin_EndpointPermission as b on a.PermissionID = b.PermissionID and b.EndpointID = @EndpointID
			inner join stng.Admin_Permission as c on a.PermissionID = c.UniqueID
			where a.EmployeeID = @EmployeeID and b.PermissionID is null
			option(optimize for (@EmployeeID unknown, @EndpointID unknown));
		end

	--Get Unlinked Attributes for an Endpoint
	else if @Operation = 65
		begin

			select 0 as checked, a.AttributeID, a.AttributeTypeID, a.Attribute, a.AttributeType
			from stng.VV_Admin_Attribute as a
			left join stng.VV_Admin_EndpointAttribute as b on a.AttributeID= b.AttributeID and b.EndpointID = @EndpointID
			where b.AttributeID is null
			option(optimize for (@EndpointID unknown));

		end

	else if @Operation = 66 --get statuses of requests for a user
		begin

			select * from stng.VV_Admin_Request_Status
			where EmployeeID = @EmployeeID--only allowed to see your own statuses
			order by CreatedDate desc;

		end

	else if @Operation = 67--get all comments related to request, don't want to reveal roles for security purposes
		begin

			if @RequestID is null
			begin
				select 'RequestID is a required parameter' as ReturnMessage;
				return;
			end

			select sr.Comment from stng.VV_Admin_SubRequests sr
			where @EmployeeID = sr.RequestorEID and @RequestID = sr.RequestID

		end

	--Get Unlinked Attributes for a Permission
	else if @Operation = 68
		begin
			select 0 as checked, a.AttributeID, a.AttributeTypeID, a.Attribute, a.AttributeType
			from stng.VV_Admin_Attribute as a
			left join stng.VV_Admin_PermissionAttribute as b on a.AttributeID= b.AttributeID and b.PermissionID = @PermissionID
			where b.AttributeID is null
			option(optimize for (@PermissionID unknown));
		end

	--Get Unlinked Attributes for a Role
	else if @Operation = 69
		begin
			select 0 as checked, a.AttributeID, a.AttributeTypeID, a.Attribute, a.AttributeType
			from stng.VV_Admin_Attribute as a
			left join stng.VV_Admin_RoleAttribute as b on a.AttributeID= b.AttributeID and b.RoleID = @RoleID
			where b.AttributeID is null
			option(optimize for (@RoleID unknown));
		end

	--Get Unlinked Attributes for a user
	else if @Operation = 70
		begin
			select 0 as checked, a.AttributeID, a.AttributeTypeID, a.Attribute, a.AttributeType
			from stng.VV_Admin_Attribute as a
			left join stng.VV_Admin_UserAttribute as b on a.AttributeID= b.AttributeID and b.EmployeeID = @EmployeeID
			where b.AttributeID is null
			order by a.AttributeType asc, a.Attribute asc
			option(optimize for (@EmployeeID unknown))
			
		end

	--grant a role with necessary checks for module access requests
	else if @Operation = 71
		begin
			
			--check employeeID
			if @EmployeeID is null
				begin
					select 'ERROR no EmployeeID found' as ReturnMessage;
					return;
				end

			--check if required parameters supplied
			if @RoleID is null or @SubRequestID is null
				begin
					select 'RoleID and SubRequestID are required parameters' as ReturnMessage;
					return;
				end

			
			--working variables
			declare @WorkingEID varchar(20) = (select RequestorEID from stng.VV_Admin_SubRequests where SubRequestID = @SubRequestID);
			declare @WorkingRID uniqueidentifier = (select RequestID from stng.VV_Admin_SubRequests where SubRequestID = @SubRequestID);
			declare @WorkingMAID uniqueidentifier = (select ModuleAttributeID from stng.VV_Admin_SubRequests where SubRequestID = @SubRequestID);

			if @WorkingEID is null or @WorkingMAID is null or @WorkingRID is null
			begin
				select 'Error with subrequest--incorrect values' as ReturnMessage;
				return;
			end
			

			--check if granter has permission to grant
			if not exists(
			select * from stng.VV_Admin_Role_Manage rm
			where rm.EmployeeID = @EmployeeID and rm.RoleID = @RoleID
			)
				begin
					select 'User does not have permission to grant this role' as ReturnMessage;
					return;
				end

			--add to list of modules approved for this role, for this request
			insert into stng.Admin_ModuleApprovedRoles
			(RoleID, ModuleAttributeID, RequestID, RAD, RAB)
			select
			@RoleID,
			@WorkingMAID,
			@WorkingRID,
			stng.GetBPTime(GETDATE()),
			@EmployeeID;

			--check if approved in every module linked to role
			--if exists is true that means theres a missing related module approval
			if exists(
				select rm.RoleID, rm.ModuleAttributeID
				from stng.VV_Admin_ModuleRoles rm
				left join stng.Admin_ModuleApprovedRoles mar on mar.RoleID = rm.RoleID and mar.RequestID = @WorkingRID and rm.ModuleAttributeID = mar.ModuleAttributeID
				where mar.ModuleAttributeID is null and rm.RoleID = @RoleID 
			)
			begin
				--create additional subrequests for role, to continue request (if they don't already exist)
				insert into stng.Admin_SubRequest (RequestID, ModuleAttributeID, StatusID, RoleID, Comment, SubRequestID)
				select
				@WorkingRID,
				rm.ModuleAttributeID,
				(select StatusID from stng.Admin_SubRequestStatus where ActionStatus = 'Unreviewed'), 
				@RoleID, 
				(select Comment from stng.VV_Admin_SubRequests where SubRequestID = @SubRequestID), 
				newid()
				from stng.VV_Admin_ModuleRoles rm
				left join stng.Admin_ModuleApprovedRoles mar on mar.RoleID = rm.RoleID and mar.RequestID = @WorkingRID and rm.ModuleAttributeID = mar.ModuleAttributeID
				left join stng.Admin_SubRequest sr2 on sr2.RoleID = rm.RoleID and sr2.RequestID = @WorkingRID and sr2.ModuleAttributeID = rm.ModuleAttributeID
				where rm.RoleID = @RoleID and  mar.ModuleAttributeID is null and sr2.ModuleAttributeID is null

				--More SubRequests for different modules need to be approved to grant role -- that's why this is necessary
				return;
			end
			
			exec stng.SP_Admin_UserManagement @Operation = 32, @EmployeeID = @EmployeeID, @EmployeeIDInsert = @WorkingEID, @RoleID = @RoleID;
		end

	else if @Operation = 72
		begin

			if @Module is null
				begin
					select 'Module is a required parameter' as ReturnMessage;
					return;
				end
			else if @Module = 'emptyroles'
				begin
					return;--shouldnt be necessary anymore, but keeping just in case
				end

			select mr.RoleID as UniqueID, mr.Department, mr.Module, mr.RoleDescription, mr.Role from stng.VV_Admin_ModuleRoles mr
			join stng.VV_Admin_Role_Manage rm on rm.RoleID = mr.RoleID and rm.EmployeeID = @EmployeeID
			where  
			(mr.Department = @Department or @Department is null) and 
			(mr.Module = @Module) and
			(@RoleID is NULL OR mr.RoleID = @RoleID) and
			(@Role is NULL or mr.Role = @Role)
		end

	--only show permissions that requesting user can manage
	else if @Operation = 73
		begin
			with manageablepermissions as
			(
				select *
				from stng.VV_Admin_ActualUserPermission_Manage
				where EmployeeID = @EmployeeID
			),
			relevantpermissions as
			(
				select *
				from stng.VV_Admin_ActualUserPermission
				where EmployeeID = @EmployeeIDInsert
			)

			select distinct a.UniqueID, a.Permission, a.PermissionID, a.PermissionDescription, b.EmployeeID
			from manageablepermissions as a
			inner join relevantpermissions as b on a.PermissionID = b.PermissionID
			where
			(@Permission is null or a.Permission = @Permission)
			and
			(@PermissionID is null or a.PermissionID = @PermissionID)
			and
			(@Origin is null or b.Origin != 'Direct Permission')
			order by a.Permission asc
			option(optimize for (@EmployeeIDInsert unknown, @Permission unknown, @PermissionID unknown, @EmployeeID unknown, @Origin unknown));
		end
	
	else if @Operation = 74
		begin
			select distinct x.PermissionID, x.Permission, x.PermissionDescription from stng.VV_Admin_AllPermission as x
			left join (
			SELECT b.*
			FROM [stng].[VV_Admin_ActualUserPermission_Manage] as a 
			inner join stng.VV_Admin_AllPermission as b
			on a.PermissionId = b.ParentPermissionID
			where a.EmployeeID = @EmployeeID and a.Permission = @ParentPermission ) as y
			on  x.PermissionID = y.PermissionID where y.PermissionID is NULL
			option(optimize for ( @ParentPermission unknown, @EmployeeID unknown));
		end

	--Get current user attributes
	else if @Operation = 75
		begin

			select *
			from stng.VV_Admin_UserAttribute
			where EmployeeID = @EmployeeID;

		end

	--Get current user endpoints
	else if @Operation = 76
		begin

			select *
			from stng.VV_Admin_ActualUserEndpoint um
			where um.EmployeeID = @EmployeeID;

		end

	--Get all unassigned work groups
	else if @Operation = 77
		begin

			SELECT *
			FROM [stng].[VV_Admin_UnassignedWorkGroups]

		end

	--Get a vendors assigned work groups
	else if @Operation = 78
		begin

			SELECT *
			FROM [stng].[VV_Admin_VendorWorkGroups]
			where VendorID = @AttributeID

		end

	--Remove a vendors assigned workgroup
	else if @Operation = 79
		begin

			Delete
			FROM [stng].[Admin_WorkGroup_Map]
			where UniqueID = @UniqueIDNum

		end

	--Add assigned work groups to vendor
	else if @Operation = 80
		begin

			insert into [stng].[Admin_WorkGroup_Map]
					([VendorID]
					  ,[WorkGroupID]
					  ,[RAB])
					values
					(@RoleID, @PermissionID, @EmployeeID);

		end

	--Get all ring fenced users
	else if @Operation = 81
		begin

			SELECT a.UniqueID, b.EmployeeID, b.EmpName
			FROM stng.Admin_RingFence as a 
			inner join stng.VV_Admin_Users as b on a.[User] = b.EmployeeID
			where deleted = 0
			order by EmpName asc
		end

	--Add a new ring fence user
	else if @Operation = 82
		begin

			if exists(select EmployeeID
				from stng.VV_Admin_Users
				where EmployeeID = @EmployeeIDInsert
			)
				begin
					
					if exists(
						select [User]
						from stng.Admin_RingFence
						where [User] = @EmployeeIDInsert
					)
						begin
							--revive if it exists in table
							Update stng.Admin_RingFence
							set
							Deleted = 0,
							DeletedBy = null,
							DeletedOn = null
							where [User] = @EmployeeIDInsert
						end

					else 
						begin
							Insert into 
							stng.Admin_RingFence
							([User], [RAB])
							values
							(@EmployeeIDInsert, @EmployeeID)
						end
					
				end

			else 
				begin
					select 'Employee does not exist' as ReturnMessage;
					return;
				end

		end

	-- Remove a ring fence user
	else if @Operation = 83
		begin

			if exists(select UniqueID
				from stng.Admin_RingFence
				where UniqueID = @UniqueID and Deleted = 0
			)
				begin
					Update stng.Admin_RingFence
					set
					Deleted = 1,
					DeletedBy = @EmployeeID,
					DeletedOn = stng.GetBPTime(getdate())
					where UniqueID = @UniqueID
				end
			else 
				begin
					select 'No user to remove' as ReturnMessage;
					return;
				end

		end
	--add email
	else if @Operation = 84
		BEGIN
			--special check for permissions
			IF (@EmployeeID <> @EmployeeIDInsert)
			BEGIN

				IF NOT EXISTS (
					select 1 from stng.VV_Admin_ActualUserPermission WHERE Permission = 'SysAdmin' and EmployeeID = @EmployeeID
				)
				BEGIN
					SELECT 'Only SysAdmins can alter other users'' alternate emails' as ReturnMessage;
					RETURN;
				END

			END

			--check for parameters
			IF (@EmployeeIDInsert is null or @EmployeeID IS NULL OR @Email IS NULL)
			BEGIN
				SELECT 'EmployeeID, EmployeeIDInsert, and Email are Required Parameters' as ReturnMessage;
				RETURN;
			END

			--check if email given is good email format
			--if it contains anything, @, anything, ., anything
			IF NOT (@Email LIKE '%_@__%.__%')
			BEGIN
				SELECT 'Email is not in valid format _@_._' as ReturnMessage;
				RETURN;
			END

			--check if combo exists already
				--if not deleted, returnmessage already exists
				--if deleted, undelete
			IF EXISTS (
				SELECT * FROM stng.Admin_UserAlternateEmail
				WHERE EmployeeID = @EmployeeIDInsert AND AlternateEmail = @Email
			)
			BEGIN
				IF (SELECT TOP(1) Deleted FROM stng.Admin_UserAlternateEmail WHERE EmployeeID = @EmployeeIDInsert) <> 1
				BEGIN
					SELECT 'Email record already exists' as ReturnMessage;
					RETURN;
				END
				ELSE
				BEGIN
					UPDATE stng.Admin_UserAlternateEmail
					SET Deleted = 0
					WHERE EmployeeID = @EmployeeIDInsert;
					RETURN;
				END
			END

			--if not and user already has email, update it
			IF EXISTS (
				SELECT * FROM stng.Admin_UserAlternateEmail
				WHERE EmployeeID = @EmployeeIDInsert
			)
			BEGIN
				IF (SELECT TOP(1) Deleted FROM stng.Admin_UserAlternateEmail WHERE EmployeeID = @EmployeeIDInsert) <> 1
				BEGIN
					UPDATE stng.Admin_UserAlternateEmail
					SET AlternateEmail = @Email
					WHERE EmployeeID = @EmployeeIDInsert
				END
				ELSE
				BEGIN
					UPDATE stng.Admin_UserAlternateEmail
					SET AlternateEmail = @Email, Deleted = 0
					WHERE EmployeeID = @EmployeeIDInsert
				END
				
			END

			ELSE
			BEGIN
				INSERT INTO stng.Admin_UserAlternateEmail(EmployeeID, AlternateEmail, RAB)
				SELECT @EmployeeIDInsert, @Email, @EmployeeID
			END


		END

	--get email(s)
	ELSE IF @Operation = 85
	BEGIN
		--return whatever exists
		SELECT EmployeeID, AlternateEmail
		FROM stng.Admin_UserAlternateEmail
		where
		(@EmployeeIDInsert is null or EmployeeID = @EmployeeIDInsert)
		and
		(@Email is null or AlternateEmail = @Email)
		and
		Deleted <> 1
		option(optimize for (@EmployeeIDInsert unknown, @Email unknown));
	END

	--delete email
	ELSE IF @Operation = 86
	BEGIN

		--special check for permissions
		IF (@EmployeeID <> @EmployeeIDInsert)
		BEGIN

			IF NOT EXISTS (
				select 1 from stng.VV_Admin_ActualUserPermission WHERE Permission = 'SysAdmin' and EmployeeID = @EmployeeID
			)
			BEGIN
				SELECT 'Only SysAdmins can alter other users'' alternate emails' as ReturnMessage;
				RETURN;
			END

		END

		--need employeeidinsert
		IF @EmployeeIDInsert is null
		BEGIN
			SELECT 'EmployeeIDInsert is a required parameter' as ReturnMessage;
			RETURN;
		END

		--if exists set deleted
		--else return error
		IF EXISTS (
			SELECT * FROM stng.Admin_UserAlternateEmail
			WHERE EmployeeID = @EmployeeIDInsert
		)
		BEGIN
			UPDATE stng.Admin_UserAlternateEmail
			SET Deleted = 1, DeletedBy = @EmployeeID, DeletedOn = stng.GetBPTime(GETDATE())
			WHERE EmployeeID = @EmployeeIDInsert
		END
		ELSE
		BEGIN
			SELECT 'Record does not exist for given EmployeeIDInsert' as ReturnMessage;
			RETURN;
		END
	END
	ELSE IF @Operation = 87
	BEGIN
		IF @SubOp = 1 --Get Recipient Emails
		BEGIN
			IF @ModuleID is null
			BEGIN
				IF @Module IS NULL
				BEGIN
					SELECT 'Module or ModuleID is a required parameter' as ReturnMessage;
					RETURN
				END
				ELSE
				BEGIN
					if not exists(select * from stng.VV_Admin_Attribute where AttributeType = 'Module' and Attribute = @Module)
					begin
						select 'Module does not exist or is not a module' as ReturnMessage;
						return;
					end
					else
					begin
						set @WorkingModuleID = (select AttributeID from stng.VV_Admin_Attribute where Attribute = @Module and AttributeType = 'Module');
					end
				END
			END
			else
			BEGIN
				SET @WorkingModuleID = @ModuleID
			END

			select Username as Recipients
			FROM stng.VV_Admin_ModuleOwners
			WHERE ModuleID = @WorkingModuleID
		END
		ELSE IF @SubOp = 2--Get BCC Emails
		BEGIN
			SELECT DISTINCT au.Username as bcc -- just email test team for now
			FROM stng.VV_Admin_ActualUserPermission ap
			JOIN stng.Admin_User au on au.EmployeeID  = ap.EmployeeID
			WHERE Permission = 'BCC On All Emails PCC/TOQ' AND (Origin = 'Direct Permission' OR Origin = 'Direct Permission (Delegated)' OR Origin = 'Role, Direct Permission' OR Origin = 'Role, Direct Permission (Delegated)')
		END
		ELSE IF @SubOp = 3 -- get subject and body
		BEGIN
			IF @EmployeeIDInsert is null
			BEGIN
				SELECT 'EmployeeIDInsert is a required parameter' as ReturnMessage;
			END

			IF @ModuleID is null
			BEGIN
				IF @Module IS NULL
				BEGIN
					SELECT 'Module or ModuleID is a required parameter' as ReturnMessage;
					RETURN
				END
				ELSE
				BEGIN
					if not exists(select * from stng.VV_Admin_Attribute where AttributeType = 'Module' and Attribute = @Module)
					begin
						select 'Module does not exist or is not a module' as ReturnMessage;
						return;
					end
					else
					begin
						set @WorkingModuleID = (select AttributeID from stng.VV_Admin_Attribute where Attribute = @Module and AttributeType = 'Module');
					end
				END
			END
			else
			BEGIN
				SET @WorkingModuleID = @ModuleID
			END
			
			SELECT ae.EmailSubject as [Subject], ae.EmailBody as Body, (SELECT Attribute FROM stng.Admin_Attribute WHERE UniqueID = @WorkingModuleID) as Module, uv.EmpName
			FROM stng.Admin_Emails ae
			JOIN stng.VV_Admin_UserView uv ON uv.EmployeeID = @EmployeeIDInsert
			WHERE ae.EmailType = 'Access Request Notification'
		END
	END

end