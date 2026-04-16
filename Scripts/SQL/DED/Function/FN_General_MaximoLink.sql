ALTER FUNCTION [stng].[FN_General_MaximoLink] (@BusinessObjectType VARCHAR(30), @UniqueID int)
RETURNS VARCHAR(200)
with schemabinding, returns null on null input
AS
BEGIN

	declare @MaximoValue varchar(30) = null;
	set @MaximoValue = case when @BusinessObjectType = 'Item' then 'plusitem' 
							when @BusinessObjectType = 'WO' then 'pluswotr'
							when @BusinessObjectType in ('WO Task','CR Activity','EC Task') then 'activity'
							when @BusinessObjectType = 'CR' then 'plusca'
							when @BusinessObjectType = 'EC' then 'pluschange'
							when @BusinessObjectType = 'Location' then 'pluslocat'
							when @BusinessObjectType = 'JP' then 'jbplan'
						end;

	if @MaximoValue is null or @UniqueID is null return null;

	RETURN concat('https://prod-maximo.corp.brucepower.com/maximo/ui/maximo.jsp?event=loadapp&value=',@MaximoValue,'&uniqueid=',cast(@UniqueID as varchar(30)));
END
