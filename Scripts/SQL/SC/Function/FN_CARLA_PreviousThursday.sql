/*
CreatedBy: Habib Shakibanejad
Description: Grab the Thursday from the Previous week (Used for CARLA review)
Date: 29 Nov 2021

*/
CREATE OR ALTER FUNCTION stng.FN_CARLA_PreviousThursday()
RETURNS DATE
AS
BEGIN
	DECLARE @ReturnDate DATE

	IF(DATEPART(DW,GETDATE()) = 1) SET @ReturnDate = GETDATE() - 10
	IF(DATEPART(DW,GETDATE()) = 2) SET @ReturnDate = GETDATE() - 11
	IF(DATEPART(DW,GETDATE()) = 3) SET @ReturnDate = GETDATE() - 12
	IF(DATEPART(DW,GETDATE()) = 4) SET @ReturnDate = GETDATE() - 13
	IF(DATEPART(DW,GETDATE()) = 5) SET @ReturnDate = GETDATE() - 7
	IF(DATEPART(DW,GETDATE()) = 6) SET @ReturnDate = GETDATE() - 8
	IF(DATEPART(DW,GETDATE()) = 7) SET @ReturnDate = GETDATE() - 9
	RETURN @ReturnDate
END