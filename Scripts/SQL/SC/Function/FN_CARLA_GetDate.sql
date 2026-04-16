/*
Author: Habib Shakibanejad
Description: Return a new date according to the offset value against the date input 
CreatedDate: 01 July 2022
RevisedDate:
RevisedBy: 
*/
CREATE OR ALTER FUNCTION [stng].[FN_CARLA_GetDate](@Date DATE,@Offset INT)
RETURNS DATE
AS
BEGIN
	DECLARE @D DATE

	IF(@Offset > 0)
	BEGIN
		SET @D = (SELECT A.[Date] FROM 
					(
						SELECT *,
						ROW_NUMBER() OVER (ORDER BY W.[Date] ASC) RN
						FROM stng.Common_WorkDate W
						WHERE W.IsWorkday = 1
						AND W.Date >= @Date
					) A
					WHERE A.RN = @Offset)
	END

	IF(@Offset < 0)
	BEGIN
		SET @D = (SELECT A.[Date] FROM 
					(
						SELECT *,
						ROW_NUMBER() OVER (ORDER BY W.[Date] DESC) RN
						FROM stng.Common_WorkDate W
						WHERE W.IsWorkday = 1
						AND W.Date <= @Date
					) A
					WHERE A.RN = @Offset*-1)
	END

	IF(@Offset = 0) SET @D = @Date
	
	RETURN @D
END
GO


