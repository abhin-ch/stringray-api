/****** Object:  StoredProcedure [stng].[SP_Standardized_CRUD]    Script Date: 7/13/2023 9:55:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [stng].[SP_Standardized_CRUD] (
									@Operation TINYINT,
									@CurrentUser VARCHAR(50) = null,

									@PrimaryValue bigint = null,

									@TextField1 varchar(50) = 0,
									@TextField2 varchar(50) = 0,
									@LargeTextField1 varchar(max) = null,
									@LargeTextField2 varchar(max) = null,
									@CheckboxField1 bit = 0,
									@CheckboxField2 bit = 0,
									@DropdownField1 varchar(50) = null,
									@DropdownField2 varchar(50) = null,

									@DateField1 date = null,
									@DateField2 date = null,

									@StatusField1 varchar(250) = null,

									@Error int = NULL OUTPUT,
									@ErrorDescription VARCHAR(8000) = NULL OUTPUT)
AS
    BEGIN
	    BEGIN TRY

		if @Operation = 1 -- Main data grab
			begin

				SELECT *
				FROM [stng].[VV_Standard_Main]

			end

		else if @Operation = 2 -- Set Form Data
			begin

				if EXISTS (SELECT 1 FROM stng.Standard_WriteFields WHERE PrimaryValue = @PrimaryValue)
					begin
						UPDATE stng.Standard_WriteFields
						SET 
						TextField1 = @TextField1
						,TextField2 = @TextField2
						,LargeTextField1 = @LargeTextField1
						,LargeTextField2 = @LargeTextField2
						,CheckboxField1 = @CheckboxField1
						,CheckboxField2 = @CheckboxField2
						,DropdownField1 = @DropdownField1
						,DropdownField2 = @DropdownField2
						,DateField1 = @DateField1
						,DateField2 = @DateField2
						,StatusField1 = @StatusField1
						WHERE PrimaryValue = @PrimaryValue
					end
				else 
					begin
	
						INSERT INTO stng.Standard_WriteFields 
						(PrimaryValue,
						TextField1,
						TextField2,
						LargeTextField1,
						LargeTextField2,
						CheckboxField1,
						CheckboxField2,
						DropdownField1,
						DropdownField2,
						DateField1,
						DateField2,
						StatusField1)
						VALUES (
						@PrimaryValue
						,@TextField1
						,@TextField2
						,@LargeTextField1
						,@LargeTextField2
						,@CheckboxField1
						,@CheckboxField2
						,@DropdownField1
						,@DropdownField2
						,@DateField1
						,@DateField2
						,@StatusField1);
						end

			end
		

	    END TRY
			
	    BEGIN CATCH
			    SET @Error = ERROR_NUMBER()
			    SET @ErrorDescription = ERROR_MESSAGE()
	    END CATCH
    END
