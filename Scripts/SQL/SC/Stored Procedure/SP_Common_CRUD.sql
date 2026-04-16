CREATE OR ALTER   PROCEDURE [stng].[SP_Common_CRUD]
	 @Operation TINYINT
	,@SubOp		TINYINT = NULL
	,@EmployeeID NVARCHAR(255) = NULL
	,@Value1 NVARCHAR(255) = NULL
	,@Value2 NVARCHAR(255) = NULL
	,@Value3 NVARCHAR(255) = NULL
	,@Value4 NVARCHAR(255) = NULL
	,@Value5 NVARCHAR(255) = NULL
	,@Value6 NVARCHAR(max) = NULL
	,@Value7 NVARCHAR(max) = NULL
	,@Num1 INT = NULL
	,@Num2 INT = NULL
	,@Num3 INT = NULL
	,@Num4 bigint = null
	,@IsTrue1 BIT = NULL
	,@IsTrue2 BIT = NULL
	,@Date1 DATETIME = NULL
	,@Date2 DATETIME = NULL
AS
BEGIN
	SET NOCOUNT OFF;

	/*
	Operation 1: GET ValueLabel
	Operation 2: 
	Operation 3: 
	Operation 4: INSERT FileMeta  
	Operation 5: GET FileMeta list  
	Operation 6: 
	Operation 7: 
	Operation 8: DELETE file meta
	Operation 9: 
	Operation 17: Copy file
	Operation 18: Check if blob deletion necessary
	*/
	
	BEGIN TRY
	
	-- GET ValueLabel
	IF(@Operation = 1) 
		SELECT V.Label,V.Value FROM stng.Common_ValueLabel V 
		INNER JOIN stng.Admin_Module M ON M.UniqueID = V.ModuleID AND M.[NameShort] = @Value1
		WHERE V.[Group] = @Value2 AND V.Field = @Value3 ORDER BY V.Sort, V.Label

	/**/
	else IF(@Operation = 2) PRINT ''

	/**/
	else IF(@Operation = 3) PRINT ''

	/*INSERT FileMeta*/
	else IF(@Operation = 4)
		INSERT INTO stng.Common_FileMeta(Name,UUID,ParentID,GroupBy,ModuleID,CreatedBy)
			SELECT @Value1, @Value2,@Value4,@Value5,M.UniqueID, @EmployeeID FROM stng.Admin_Module M WHERE M.[NameShort] = @Value3 

	/*GET FileMeta list*/
	else IF(@Operation = 5) 
	BEGIN
		IF(@Value2 IS NOT NULL)
			SELECT F.FileMetaID, F.Name,F.ParentID,CONCAT(M.NameShort,'/',F.UUID) UUID,F.GroupBy,F.CreatedBy,U.FullName,F.CreatedDate,M.NameShort Module 
			FROM stng.Common_FileMeta F
			INNER JOIN stng.Admin_Module M ON M.UniqueID = F.ModuleID 
			INNER JOIN stng.Admin_User U ON U.EmployeeID = F.CreatedBy
			WHERE M.NameShort = @Value1 AND GroupBy = @Value2 AND Deleted = 0
			ORDER BY CreatedDate desc
		ELSE
			SELECT F.FileMetaID, F.Name,F.ParentID,CONCAT(M.NameShort,'/',F.UUID) UUID,F.GroupBy,F.CreatedBy,U.FullName,F.CreatedDate,M.NameShort Module
			FROM stng.Common_FileMeta F
			INNER JOIN stng.Admin_Module M ON M.UniqueID = F.ModuleID
			INNER JOIN stng.Admin_User U ON U.EmployeeID = F.CreatedBy
			WHERE M.NameShort = @Value1 AND Deleted = 0 
			ORDER BY CreatedDate desc
	END

	/**/
	else IF(@Operation=6) PRINT ''

	/**/
	else IF(@Operation=7) PRINT ''

	/* Delete File Meta */
	else IF(@operation=8)
	begin
		Update stng.[Common_FileMeta] set [Deleted] = 1, [DeletedBy] = @Value1, [DeletedDate] = GETDATE()
		where UUID = Convert(uniqueidentifier, @Value2) and ParentID =  @Value3
	end

	/**/
	else IF(@operation=9) PRINT ''

	/**/
	else IF(@Operation=10) PRINT ''

	--Count of non-deleted versions of UUID
	--Value1 = ModuleShort
	--Value2= UUID
	else if  @Operation = 14
		begin

			select count(a.FileMetaID) as nondeletedcount
			from stng.Common_FileMeta as a
			inner join stng.Admin_Module as b on a.ModuleID = b.UniqueID
			where a.UUID = @Value2 and a.Deleted = 0 and b.NameShort = @Value1
			option(optimize for (@Value1 unknown, @Value2 unknown));	

		end

	else if @Operation = 15
		begin

			select *
			from stng.Common_EmailTemplate
			where Name = @Value1;

		end
	
	else if @Operation = 16
		begin

			SELECT distinct Section, concat(Description, ' (',PersonGroup,')') as SectionLabel, Department, Division, Supervisor, SM, SMName, DM, DMName, DivM, DivMName
			FROM [stng].[VV_General_OrganizationView]
			where Type = 'Section' 
			and
			(@Value1 is null or Division = @Value1)
			and
			(@Value2 is null or Department = @Value2)
			order by Department asc
			option(optimize for (@Value1 unknown, @Value2 unknown));

		end

	else if @Operation = 17--copy files
	begin
		--Value6 is comma seperated list of parentids to copy to
		--Value1 is EmployeeID
		--Value2 is FileMetaID to copy from


		with parentids as
		(
			select [value] from string_split(@Value6, ',')
		),
		filemetaids as
		(
			select [value] from string_split(@Value7, ',')
		)
		INSERT INTO stng.Common_FileMeta(Name,UUID,ParentID,GroupBy,ModuleID,CreatedBy)
		select Name,UUID,p.[value] as ParentID,GroupBy,ModuleID,@Value1 as CreatedBy
		from stng.Common_FileMeta f
		join parentids p on 1 = 1
		join filemetaids m on m.[value] = f.FileMetaID
		except
		select Name,UUID,ParentID,GroupBy,ModuleID,@Value1 as CreatedBy--if the row already exists (disregarding CreatedBy), do not copy
		from stng.Common_FileMeta

		


	end
	else if @Operation = 18 --check if blobservice needs to delete record
	begin
		--Num1 is Department
		--Value1 is EmployeeID
		--Value2 is UUID
		--Value3 is ParentID


		IF EXISTS(--don't delete if there is another parentID that uses the same UUID that isn't delted yet
			select 1 from stng.Common_FileMeta
			where UUID = @Value2 and ParentID <> @Value3 and Deleted = 0
		)
		BEGIN
			SELECT 0 AS DeleteFromBlob
		END
		ELSE
		BEGIN
			SELECT 1 AS DeleteFromBlob
		END
	
	end

	END TRY
	BEGIN CATCH
        INSERT INTO stng.App_ErrorLog([Number],[Procedure],[Line],[Message],[Operation]) VALUES (
                     ERROR_NUMBER(),
                     ERROR_PROCEDURE(),
                     ERROR_LINE(),
                     ERROR_MESSAGE(),
					 @Operation
              );
			  THROW
	END CATCH

END
