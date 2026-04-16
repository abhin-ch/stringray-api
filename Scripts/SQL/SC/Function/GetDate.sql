CREATE function [stng].[GetDate]() returns datetime as
begin
	
	return stng.GetBPTime(GETDATE())

end
GO