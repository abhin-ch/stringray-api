/*
Author: Neel Shah
Description: CRUD Operations for Budgeting Admin Tool
CreatedDate: 27 Feb 2024
RevisedDate: 
RevisedBy:
*/
ALTER   PROCEDURE [stng].[SP_Budgeting_AdminTool] (
	@Operation INT
	,@EmployeeID NVARCHAR(255) = NULL
	,@Value1 NVARCHAR(255) = NULL
	,@Value2 NVARCHAR(255) = NULL
	,@Value3 NVARCHAR(255) = NULL
	,@Value4 NVARCHAR(255) = NULL
	,@Value5 NVARCHAR(255) = NULL
	,@Value6 NVARCHAR(max) = NULL
	,@Num1 INT = NULL
	,@Num2 INT = NULL
	,@Num3 INT = NULL
	,@IsTrue1 BIT = NULL
	,@IsTrue2 BIT = NULL
	,@Date1 DATETIME = NULL
	,@Date2 DATETIME = NULL
)
AS
	/*
		Operation 1 - Retrieve Inactive SDQ FundingSource and BusinessDriver Options 
		Operation 2 - Turn Active option into Inactive
		Operation 3 - Turn Inactive option into Active
		Operation 4 - Edit any existing option
		Operation 5 - Add new Budgeting Option
		Operation 6 - Retrieve Inactive PBRF RC, FundingSource and Customer Need Options
		Operation 7 - Retrieve Admin Tool options Change Log
		Operation 8 - 
		Operation 9 - 
		Operation 10 - 
		Operation 11 - 
		Operation 12 - 
		Operation 13 - 
		Operation 14 - 
		Operation 15 - 
		Operation 16 - 
		Operation 17 -
		Operation 18 -
		Operation 19 -
		Operation 20 - 
		Operation 21 - 
		Operation 22 - 
		Operation 23 - 
		Operation 24 - 
		Operation 25 - 
		Operation 26 - 
		Operation 27 - 
		Operation 28 - 
	*/

	-- INSERT EXAMPLE
	-- EXEC stng.SP_Common_CreateValueLabel @Module='Budgeting', @Group='SDQ',@Field='Phase',@Label='Closeout',@CreatedBy=@EmployeeID
	-- SELECT * FROM stng.VV_Common_ValueLabel WHERE Module = 'Budgeting'

    BEGIN 

		--Proc working variables
		DECLARE @RecordType NVARCHAR(MAX)
		DECLARE @TypeID uniqueidentifier
		DECLARE @Group NVARCHAR(MAX)
		DECLARE @FieldName NVARCHAR(MAX)
		DECLARE @ChangeFrom NVARCHAR(MAX)

		/*Retrieve Inactive SDQ FundingSource and BusinessDriver Options */
		IF(@Operation = 1)
		BEGIN
		 Select A.UniqueID value, A.Label label from stng.VV_Common_ValueLabel as A where Module = 'Budgeting' and [Group] = 'SDQ' and Field = 'FundingSource' and Active = 0
		 Select A.UniqueID value, A.Label label from stng.VV_Common_ValueLabel as A where Module = 'Budgeting' and [Group] = 'SDQ' and Field = 'BusinessDriver' and Active = 0
		END

		/*Turn Active option into Inactive*/
		ELSE IF(@Operation = 2)
		BEGIN
		Declare @alreadyInactive INT

		-- Get values for RecordType, TypeID, Group, and FieldName based on UniqueID
		SELECT
			@RecordType = C.[Group],
			@ChangeFrom = C.Label,
			@Group =
				CASE
					WHEN C.[Group] = 'SDQ' AND C.Field IN ('FundingSource', 'BusinessDriver') THEN 'SDQ Header'
					WHEN C.[Group] = 'PBRF' AND C.Field IN ('FundingSource', 'RC', 'CustomerNeed') THEN 'PBRF Header'
				END,
			@FieldName = C.Field
		FROM stng.Common_ValueLabel C
		JOIN stng.VV_Common_ValueLabel V ON C.[Group] = V.[Group] AND C.Field = V.Field
		WHERE C.UniqueID = @Value1;

		Select @TypeID = UniqueID 
		from stng.VV_Common_ValueLabel as A
		where A.[Group] = 'FieldChangeLog' and A.Field = 'Options' and A.Label = 'Remove'

		-- Table to store the results of the OUTPUT clause
		DECLARE @UpdatedRows TABLE (alreadyInactive INT);

		-- Update stng.Common_ValueLabel
		UPDATE stng.Common_ValueLabel
		SET active =
			CASE
				WHEN active = 1 THEN 0
				ELSE active
			END
		OUTPUT
			CASE
				WHEN deleted.active = 0 THEN 1
				ELSE 0
			END AS alreadyInactive
		INTO @UpdatedRows
		WHERE UniqueID = @Value1;

		select top 1 @alreadyInactive = alreadyInactive from @UpdatedRows;

		-- Insert into stng.Budgeting_FieldChangeLog if the update took place
		INSERT INTO stng.Budgeting_FieldChangeLog (RecordType, RecordTypeUniqueID, TypeID, [Group], FieldName, FromValue, ToValue, CreatedBy, CreatedDate)
		SELECT
			@RecordType,
			NULL,
			@TypeID,
			@Group,
			@FieldName,
			@ChangeFrom,
			'N.A.',
			@EmployeeID,
			stng.GetBPTime(GETDATE())
		FROM @UpdatedRows
		WHERE alreadyInactive = 0

		select @alreadyInactive as alreadyInactive
		END

		/*Turn Inactive option into Active*/
		ELSE IF(@Operation = 3)
		BEGIN

		declare @alreadyActive INT
		-- Get values for RecordType, TypeID, Group, and FieldName based on UniqueID
		SELECT
			@RecordType = C.[Group],
			@ChangeFrom = C.Label,
			@Group =
				CASE
					WHEN C.[Group] = 'SDQ' AND C.Field IN ('FundingSource', 'BusinessDriver') THEN 'SDQ Header'
					WHEN C.[Group] = 'PBRF' AND C.Field IN ('FundingSource', 'RC', 'CustomerNeed') THEN 'PBRF Header'
				END,
			@FieldName = C.Field
		FROM stng.Common_ValueLabel C
		JOIN stng.VV_Common_ValueLabel V ON C.[Group] = V.[Group] AND C.Field = V.Field
		WHERE C.UniqueID = @Value1;

		Select @TypeID = UniqueID 
		from stng.VV_Common_ValueLabel as A
		where A.[Group] = 'FieldChangeLog' and A.Field = 'Options' and A.Label = 'Add'

		-- Table to store the results of the OUTPUT clause
		DECLARE @UpdatedRowsADD TABLE (alreadyActive INT);

		-- Update stng.Common_ValueLabel
	   UPDATE stng.Common_ValueLabel
			SET active = CASE
							WHEN active = 0 THEN 1
							ELSE active
						 END
			OUTPUT CASE
					 WHEN deleted.active = 1 THEN 1
					 ELSE 0
		END AS alreadyActive
		INTO @UpdatedRowsADD
		WHERE UniqueID = @Value1;

		select top 1 @alreadyActive = alreadyActive from @UpdatedRowsADD

		-- Insert into stng.Budgeting_FieldChangeLog if the update took place
		INSERT INTO stng.Budgeting_FieldChangeLog (RecordType, RecordTypeUniqueID, TypeID, [Group], FieldName, FromValue, ToValue, CreatedBy, CreatedDate)
		SELECT
			@RecordType,
			NULL,
			@TypeID,
			@Group,
			@FieldName,
			@ChangeFrom,
			'N.A.',
			@EmployeeID,
			stng.GetBPTime(GETDATE())
		FROM @UpdatedRowsADD
		WHERE alreadyActive = 0

		select @alreadyActive as alreadyActive
		END

		/*Edit any existing option*/
		ELSE IF(@Operation = 4)
		BEGIN
		DECLARE @isEmpty INT;
		DECLARE @isDuplicate INT;
		

		-- Table to store the results of the OUTPUT clause
		DECLARE @InsertedRows TABLE (isEmpty INT, isDuplicate INT);

		-- Get values for RecordType, TypeID, Group, and FieldName based on UniqueID
			SELECT
				@RecordType = C.[Group],
				@ChangeFrom = C.Label,
				@Group =
					CASE
						WHEN C.[Group] = 'SDQ' AND C.Field IN ('FundingSource', 'BusinessDriver') THEN 'SDQ Header'
						WHEN C.[Group] = 'PBRF' AND C.Field IN ('FundingSource', 'RC', 'CustomerNeed') THEN 'PBRF Header'
					END,
				@FieldName = C.Field
			FROM stng.Common_ValueLabel C
			JOIN stng.VV_Common_ValueLabel V ON C.[Group] = V.[Group] AND C.Field = V.Field
			WHERE C.UniqueID = @Value1;

			Select @TypeID = UniqueID 
			from stng.VV_Common_ValueLabel as A
			where A.[Group] = 'FieldChangeLog' and A.Field = 'Options' and A.Label = 'Modify'

		-- Check if Value2 is null or empty
		SET @isEmpty = CASE WHEN COALESCE(@Value2, '') = '' THEN 1 ELSE 0 END;

		-- Check if Value2 is exactly the same as Label in stng.Common_ValueLabel
		SELECT @isDuplicate = CASE WHEN EXISTS (
			SELECT 1
			FROM stng.Common_ValueLabel
			WHERE UniqueID = @Value1 AND Label = @Value2
		) THEN 1 ELSE 0 END;

		-- If both isEmpty and isDuplicate are 0, update the label
		IF @isEmpty = 0 AND @isDuplicate = 0
		BEGIN
			-- Update stng.Common_ValueLabel and store the results in @InsertedRows
			UPDATE stng.Common_ValueLabel
			SET Label = @Value2
			OUTPUT
				@isEmpty AS isEmpty,
				@isDuplicate AS isDuplicate
			INTO @InsertedRows
			WHERE UniqueID = @Value1;
		END

		select top 1 @isEmpty = isEmpty, @isDuplicate = isDuplicate from @InsertedRows

			-- Insert into stng.Budgeting_FieldChangeLog if the update took place
			INSERT INTO stng.Budgeting_FieldChangeLog (RecordType, RecordTypeUniqueID, TypeID, [Group], FieldName, FromValue, ToValue, CreatedBy, CreatedDate)
			SELECT
				@RecordType,
				NULL,
				@TypeID,
				@Group,
				@FieldName,
				@ChangeFrom,
				@Value2,
				@EmployeeID,
				stng.GetBPTime(GETDATE())
			FROM @InsertedRows IR
			WHERE IR.isEmpty = 0 AND IR.isDuplicate = 0

			select @isEmpty as isEmpty, @isDuplicate as isDuplicate
		
		END

		/*Add new Budgeting Option*/
		ELSE IF(@Operation = 5) 
		BEGIN 
		DECLARE @isEmptyLabel BIT;
		DECLARE @doesExist BIT;
	

			-- Check if @Value1 is NULL or empty
			IF ISNULL(@Value1, '') = ''
				SET @isEmptyLabel = 1;
			ELSE
				SET @isEmptyLabel = 0;

			DECLARE @ModuleID uniqueidentifier
			SELECT @ModuleID = UniqueID FROM stng.Admin_Module WHERE NameShort = 'Budgeting'

			-- Check if the label exists in stng.Common_ValueLabel
			IF @isEmptyLabel = 0
			BEGIN
				IF EXISTS (
					SELECT 1
					FROM stng.Common_ValueLabel
					WHERE Label = @Value1
						AND ModuleID = @ModuleID
						AND [Group] = @Value2
						AND Field = @Value3
				)
					SET @doesExist = 1;
				ELSE
					SET @doesExist = 0;
			END
			ELSE
				SET @doesExist = NULL; -- @doesExist is not applicable when @isEmpty is 1

			-- Perform action only if both isEmpty and doesExist are 0
			IF @isEmptyLabel = 0 AND @doesExist = 0
				EXEC stng.SP_Common_CreateValueLabel
					@Module = 'Budgeting',
					@Group = @Value2,
					@Field = @Value3,
					@Label = @Value1,
					@Value = @Value1,
					@CreatedBy = '623681';

			IF @isEmptyLabel = 0 AND @doesExist=0
				-- Get values for RecordType, TypeID, Group, and FieldName based on UniqueID
				SELECT
				@RecordType = C.[Group],
				@Group =
					CASE
						WHEN C.[Group] = 'SDQ' AND C.Field IN ('FundingSource', 'BusinessDriver') THEN 'SDQ Header'
						WHEN C.[Group] = 'PBRF' AND C.Field IN ('FundingSource', 'RC', 'CustomerNeed') THEN 'PBRF Header'
					END,
				@FieldName = C.Field
				FROM stng.Common_ValueLabel C
				JOIN stng.VV_Common_ValueLabel V ON C.[Group] = V.[Group] AND C.Field = V.Field
				WHERE C.UniqueID = (select UniqueID from stng.Common_ValueLabel B where B.Label = @Value1 )

			IF @isEmptyLabel = 0 AND @doesExist=0
				Select @TypeID = UniqueID 
				from stng.VV_Common_ValueLabel as A
				where A.[Group] = 'FieldChangeLog' and A.Field = 'Options' and A.Label = 'Add'

			IF @isEmptyLabel = 0 AND @doesExist=0
			-- Insert into stng.Budgeting_FieldChangeLog if the update took place
				INSERT INTO stng.Budgeting_FieldChangeLog (RecordType, RecordTypeUniqueID, TypeID, [Group], FieldName, FromValue, ToValue, CreatedBy, CreatedDate)
				SELECT
					@RecordType,
					NULL,
					@TypeID,
					@Group,
					@FieldName,
					'N.A.',
					@Value1,
					'623681',
					stng.GetBPTime(GETDATE());

		-- Output the results
		SELECT
		isEmpty = @isEmptyLabel,
		doesExist = @doesExist;
		END

		/*Retrieve Inactive PBRF RC, FundingSource and Customer Need Options*/
		ELSE IF(@Operation = 6)
		BEGIN
		 Select A.UniqueID value, A.Label label from stng.VV_Common_ValueLabel as A where Module = 'Budgeting' and [Group] = 'PBRF' and Field = 'RC' and Active = 0
		 Select A.UniqueID value, A.Label label from stng.VV_Common_ValueLabel as A where Module = 'Budgeting' and [Group] = 'PBRF' and Field = 'FundingSource' and Active = 0
		 Select A.UniqueID value, A.Label label from stng.VV_Common_ValueLabel as A where Module = 'Budgeting' and [Group] = 'PBRF' and Field = 'CustomerNeed' and Active = 0
	
		END

		/*Retrieve Admin Tool options Change Log*/
		ELSE IF(@Operation = 7)
		BEGIN
		select * from stng.VV_Budgeting_FieldChangeLog where ChangeTypeGroup = 'Options' order by CreatedDate desc
		END

		
	

    END 
	
