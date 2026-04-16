CREATE OR ALTER FUNCTION [stng].[FN_Common_GetMaximoLink] (@Type VARCHAR(30), @Number VARCHAR(30))
RETURNS VARCHAR(200)
with schemabinding, returns null on null input
AS
BEGIN

		IF @Type is null or @Number is null RETURN null;

		DECLARE @UID VARCHAR(30),@Table VARCHAR(30)
		
		SELECT @Table = [Table] FROM stng.Common_MaximoItemLink M WHERE M.Type = @Type AND M.Number =  @Number
		SELECT @UID = MaximoID FROM stng.Common_MaximoItemLink M WHERE M.Type = @Type AND M.Number =  @Number

		RETURN concat('https://prod-maximo.corp.brucepower.com/maximo/ui/maximo.jsp?event=loadapp&value=',@Table,'&uniqueid=',cast(@UID as varchar(30)));
END
GO

