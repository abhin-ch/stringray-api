/*
CreatedBy: Habib Shakibanejad
Description: Designed to create value labels. Use @IncrementValue to calculate the next Value in sequence for the specified group.    
Date: 12 Jan 2023
*/
CREATE OR ALTER PROCEDURE [stng].[SP_Common_CreateValueLabel](
	@Module NVARCHAR(255)
	,@Group NVARCHAR(255)
	,@Name NVARCHAR(255)
	,@Label NVARCHAR(255)
	,@CreatedBy NVARCHAR(255)
	,@Value NVARCHAR(255) = NULL
	,@Sort INT = NULL
)
AS
BEGIN
	DECLARE @ModuleID INT
	SELECT @ModuleID = ModuleID FROM stng.Admin_Module M WHERE M.NameShort = @Module

	IF(@Value IS NULL) 
	BEGIN
		SELECT @Value =  N.NextValue + 1 FROM (SELECT TOP 1 ROW_NUMBER() OVER(PARTITION BY V.ModuleID, V.[Group],V.Field ORDER BY CAST(V.Value AS INT) ASC) NextValue
						FROM stng.Common_ValueLabel V WHERE V.ModuleID = @ModuleID AND V.[Group] = @Group AND V.Field = @Name
						ORDER BY NextValue DESC) N

		IF(@Value IS NULL) SET @Value = 1
	END

	IF(@Sort IS NULL) 
	BEGIN
		SET @Sort = (SELECT TOP 1 V.Sort + 1
					FROM stng.Common_ValueLabel V WHERE V.ModuleID = @ModuleID AND V.[Group] = @Group AND V.Field = @Name
					ORDER BY Sort DESC)

		IF(@Sort IS NULL) SET @Sort = 1
	END

	INSERT INTO stng.Common_ValueLabel(ModuleID,[Group],Field,Label,Value,Sort,CreatedBy) VALUES
		(@ModuleID,@Group,@Name,@Label,@Value,@Sort,@CreatedBy)

END

