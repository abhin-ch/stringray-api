/*
Author: Arvind D
Description: A procedure used as a precursor step in the data pipeline
Created Date: 21-Feb-2023
Revised By: 
Revised Date:
*/

CREATE OR ALTER PROCEDURE [stng].[SP_ETL_PrepCRUD](
	 @Operation TINYINT
	,@Value1	NVARCHAR(255) = NULL
	,@Value2	NVARCHAR(255) = NULL
	,@Value3    Int = NULL
) AS 
BEGIN
	/*
	Operations:
		1 - Delete Data from Tables
		2 - Drop Table
		
	*/  
	BEGIN TRY
		
		DECLARE @sql nvarchar(MAX)
		/*Create Scope Sheet + Details*/
		IF @Operation = 1
			BEGIN
				
				SET @sql = 'DELETE FROM '+@Value1+''
				Exec(@sql)

			END
	
		IF @Operation = 2			
			BEGIN				
				IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@Value1) AND type in (N'U'))
				Exec('DROP TABLE '+@Value1)			
			END
		
		IF @Operation = 3
			BEGIN
				/*Fragnet*/
				ALTER TABLE [stng].[CARLA_Fragnet] ALTER COLUMN FragnetID NUMERIC(10,0)
				ALTER TABLE [stng].[CARLA_Fragnet] ALTER COLUMN ProjectID NUMERIC(10,0)
				ALTER TABLE [stng].[CARLA_Fragnet] ALTER COLUMN ParentID NUMERIC(10,0)

				CREATE CLUSTERED INDEX [IX_Fragnet_CLUSTERED] ON [stng].[CARLA_Fragnet]
				(
					[ProjectID] ASC,
					[ParentID] ASC
				);
            
				CREATE NONCLUSTERED INDEX [IX_Fragnet_FragnetID] ON [stng].[CARLA_Fragnet]
				(
					[FragnetID] ASC	            
				)

				/*FragnetActivity*/
				ALTER TABLE [stng].[CARLA_FragnetActivity] ALTER COLUMN ReendDate DATE;
				ALTER TABLE [stng].[CARLA_FragnetActivity] ALTER COLUMN ActualStartDate DATE;
				ALTER TABLE [stng].[CARLA_FragnetActivity] ALTER COLUMN EndDate DATE;
				ALTER TABLE [stng].[CARLA_FragnetActivity] ALTER COLUMN ActualEndDate DATE;
				ALTER TABLE [stng].[CARLA_FragnetActivity] ALTER COLUMN RemainingHours FLOAT;
				ALTER TABLE [stng].[CARLA_FragnetActivity] ALTER COLUMN BudgetedHours FLOAT;
				ALTER TABLE [stng].[CARLA_FragnetActivity] ALTER COLUMN Duration FLOAT;
            
				CREATE NONCLUSTERED INDEX [IX_FragnetActivity_TaskID] ON [stng].[CARLA_FragnetActivity]
				(
					[ActivityID] ASC
				);
            
				CREATE CLUSTERED INDEX [IX_FragnetActivity_CLUSTERED] ON [stng].[CARLA_FragnetActivity]
				(
					ProjectID ASC,
					[FragnetID] ASC
				);

				CREATE NONCLUSTERED INDEX [IX_FragnetActivity_FragnetID] ON [stng].[CARLA_FragnetActivity]
				(
					[FragnetID] ASC,
					[Actualized] ASC,
					[ProjShortName] ASC
				);
            
				CREATE NONCLUSTERED INDEX [IX_FragnetActivity_ProjShortName] ON [stng].[CARLA_FragnetActivity]
				(
					[ProjShortName] ASC
				);

				/*RelatedActivity*/
				CREATE CLUSTERED INDEX [IX_RelatedActivity_CLUSTERED] ON [stng].[CARLA_RelatedActivity]
				(
					[ActivityID] ASC,
					[RelatedActivityID] ASC
				);
			END

		/*ETL Log*/
		IF @Operation = 4
		BEGIN
		Insert into stng.[Common_ETLLog](ETLID, RAB, RAD)
		values(@Value3, @Value2, GETDATE())
		END

	END TRY
	BEGIN CATCH
		INSERT INTO stng.App_ErrorLog([Number],[Procedure],[Line],[Message],[Operation]) 
		VALUES (ERROR_NUMBER(),
				ERROR_PROCEDURE(),
				ERROR_LINE(),
				ERROR_MESSAGE(),
				@Operation
				)
	END CATCH
END
