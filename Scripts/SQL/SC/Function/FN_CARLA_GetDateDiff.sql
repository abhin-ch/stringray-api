/*
Author: Habib Shakibanejad
Description: Return a number of days difference according to available Work Days
CreatedDate: 01 July 2022
RevisedDate:
RevisedBy: 
*/
CREATE OR ALTER   FUNCTION [stng].[FN_CARLA_GetDateDiff](@PrevDate DATE,@NewValue DATE)
RETURNS INT
AS
BEGIN
	DECLARE @NewDiff INT
	DECLARE @Direction INT

	SET @Direction = DATEDIFF(d,@PrevDate,@NewValue)
	IF(@Direction < 0)
	BEGIN
		SET @NewDiff = (SELECT COUNT(*)*-1 [Days] FROM (
							SELECT *,
								ROW_NUMBER() OVER(ORDER BY W.[Date]) RN
							FROM stng.Common_WorkDate W
							WHERE W.IsWorkday = 1
							AND W.[Date] >= @NewValue
							AND W.[Date] <= @PrevDate
							) A
						)
						
	END

	IF(@Direction > 0)
	BEGIN
		SET @NewDiff = (SELECT COUNT(*) [Days] FROM (
							SELECT *,
								ROW_NUMBER() OVER(ORDER BY W.[Date]) RN
							FROM stng.Common_WorkDate W
							WHERE W.IsWorkday = 1
							AND W.[Date] <= @NewValue
							AND W.[Date] >= @PrevDate
							) A
						)
	END

	IF(@Direction = 0) RETURN 0
	
	RETURN @NewDiff
	
END
GO