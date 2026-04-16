/*
CreatedBy: Habib Shakibanejad
Description: Designed to create value labels. Use @IncrementValue to calculate the next Value in sequence for the specified group.    
Date: 12 Jan 2023
*/
CREATE OR ALTER PROCEDURE [stng].[SP_Common_CreateValueLabel](
	@Module NVARCHAR(255)
	,@Group NVARCHAR(255)
	,@Field NVARCHAR(255)
	,@Label NVARCHAR(255)
	,@CreatedBy NVARCHAR(255)
	,@Value NVARCHAR(1000) = NULL
	,@Value1 NVARCHAR(255) = NULL
	,@Value2 NVARCHAR(255) = NULL
	,@Sort INT = NULL
	,@Active BIT = NULL
)
AS
BEGIN
	DECLARE @ModuleID NVARCHAR(255)
	SELECT @ModuleID = UniqueID FROM stng.Admin_Module M WHERE M.NameShort = @Module

	IF(@Value IS NULL) 
	BEGIN
		SELECT @Value =  N.NextValue + 1 FROM (SELECT TOP 1 ROW_NUMBER() OVER(PARTITION BY V.ModuleID, V.[Group],V.Field ORDER BY CAST(V.Value AS INT) ASC) NextValue
						FROM stng.Common_ValueLabel V WHERE V.ModuleID = @ModuleID AND V.[Group] = @Group AND V.Field = @Field
						ORDER BY NextValue DESC) N

		IF(@Value IS NULL) SET @Value = 1
	END

	IF(@Sort IS NULL) 
	BEGIN
		SET @Sort = (SELECT TOP 1 V.Sort + 10
					FROM stng.Common_ValueLabel V WHERE V.ModuleID = @ModuleID AND V.[Group] = @Group AND V.Field = @Field
					ORDER BY Sort DESC)

		IF(@Sort IS NULL) SET @Sort = 10
	END

	IF(@Active IS NOT NULL)
		INSERT INTO stng.Common_ValueLabel(ModuleID,[Group],Field,Label,Value,Sort,CreatedBy,Value1,Value2,Active) VALUES
			(@ModuleID,@Group,@Field,@Label,@Value,@Sort,@CreatedBy,@Value1,@Value2,@Active)
	ELSE
		INSERT INTO stng.Common_ValueLabel(ModuleID,[Group],Field,Label,Value,Sort,CreatedBy,Value1,Value2) VALUES
			(@ModuleID,@Group,@Field,@Label,@Value,@Sort,@CreatedBy,@Value1,@Value2)
END