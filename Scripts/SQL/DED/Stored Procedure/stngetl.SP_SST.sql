CREATE OR ALTER PROCEDURE [stngetl].[SP_SST]
(
	@Operation int,
	@SchemaName varchar(30) = null,
	@TableName varchar(250) = null,
	@ETLID varchar(100) = null,
	@QueryFor nvarchar(50) = null,
	@IsQueryEnd bit = null
)
as
BEGIN
	/*
		Operations
		2--Do Post Processing on daily SST ETL
	*/

	
		--Do Post Processing on daily SST ETL
		IF @Operation = 2
		BEGIN
			--Modified version of DMS 1.0 SP
			exec stngetl.SP_SST_ETL
		END
	
END
GO


