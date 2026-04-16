/*
Author: Habib Shakibanejad
Description: Use this function to find SDS number for CARLA based on the Fragnet name.
CreatedDate: 14 Jan 2022
RevisedDate:
RevisedBy: 
*/
CREATE OR ALTER FUNCTION [stng].[FN_CARLA_GetSDSNumber](@FragnetName NVARCHAR(255))
RETURNS INT
AS
BEGIN
	DECLARE @Development INT, @Definition INT, @Execution INT, @Preparation INT
	SET @Definition = 50119
	SET @Development = 50109
	SET @Preparation = 50129
	SET @Execution = 50149

	RETURN CASE
		WHEN @FragnetName LIKE '%Major Material%' THEN @Preparation
		WHEN @FragnetName LIKE '%Repair/Rolling Refurb%' THEN @Execution
		WHEN @FragnetName LIKE '%Material Procurement%' THEN @Preparation
		WHEN @FragnetName LIKE '%General Execution Mat%' THEN @Execution
		WHEN @FragnetName LIKE '%Managed Task%' THEN @Preparation
		WHEN @FragnetName LIKE '%Brokered Labour%' THEN @Preparation
		WHEN @FragnetName LIKE '%Managed Labour%' THEN @Preparation
		WHEN @FragnetName LIKE '%Amendment%' THEN @Execution
		WHEN @FragnetName LIKE '%Contract Management Support%' THEN @Execution
		WHEN @FragnetName LIKE '%Estimating/Budgetary Requests%' THEN @Definition
		WHEN @FragnetName LIKE '%EBOM Updates Only%' THEN @Definition
		WHEN @FragnetName LIKE '%Category Strategy%' THEN @Development
		WHEN @FragnetName LIKE '%Commercial Strategy%' THEN @Definition
		WHEN @FragnetName LIKE '%COMMON%' THEN @Definition
		WHEN @FragnetName LIKE '%Strategic Commercial Negotiations%' THEN @Definition
		WHEN @FragnetName LIKE '%External%Screening' THEN @Definition
		WHEN @FragnetName LIKE '%GEM%' THEN @Execution
		WHEN @FragnetName LIKE '%Sourcing Strategy%' THEN @Definition
		WHEN @FragnetName LIKE '%Service Contracts%' THEN @Execution
		WHEN @FragnetName LIKE '%TAGGED EQUIPMENT%' THEN @Execution

	END
END