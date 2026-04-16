/*
Author: Habib Shakibanejad
Description: This will return a list of years. The number of years returned will be determined by the parameter @NumYears
@DateValue is the starting Date. Most scenarios you will use GETDATE()
CreatedDate: 28 Feb 2024
*/
CREATE OR ALTER FUNCTION stng.FN_GetYearsFromDate(@DateValue DATE, @NumYears INT)
RETURNS @Years TABLE([Year] INT)
AS 
BEGIN
	WITH Years AS ( 
		SELECT YEAR(@DateValue) AS [Year]
		UNION ALL
		SELECT [Year] + 1
		FROM Years
		WHERE Year < YEAR(@DateValue) + @numYears - 1
	)
	INSERT INTO @Years
	SELECT [Year] FROM Years

	RETURN
END
	