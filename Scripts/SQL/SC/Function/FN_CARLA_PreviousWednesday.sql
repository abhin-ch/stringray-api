/*
CreatedBy: Habib Shakibanejad
Description: Grab the Wednesday from the Previous week (Used for CARLA review)
Date: 29 Nov 2021

*/
CREATE OR ALTER FUNCTION stng.FN_CARLA_PreviousWednesday()
RETURNS DATE
AS
BEGIN
	DECLARE @ReturnDate DATE

	IF(DATEPART(DW,GETDATE()) = 1) SET @ReturnDate = GETDATE() - 4
	IF(DATEPART(DW,GETDATE()) = 2) SET @ReturnDate = GETDATE() - 5
	IF(DATEPART(DW,GETDATE()) = 3) SET @ReturnDate = GETDATE() - 6
	IF(DATEPART(DW,GETDATE()) = 4) SET @ReturnDate = GETDATE() - 7
	IF(DATEPART(DW,GETDATE()) = 5) SET @ReturnDate = GETDATE() - 1
	IF(DATEPART(DW,GETDATE()) = 6) SET @ReturnDate = GETDATE() - 2
	IF(DATEPART(DW,GETDATE()) = 7) SET @ReturnDate = GETDATE() - 3
	RETURN @ReturnDate
END