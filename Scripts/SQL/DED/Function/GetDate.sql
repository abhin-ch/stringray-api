CREATE OR ALTER FUNCTION [stng].[GetDate]()
RETURNS DATETIME AS 
BEGIN
	RETURN cast(convert(datetimeoffset,GETDATE()) at time zone 'Eastern Standard Time' as datetime) 
END