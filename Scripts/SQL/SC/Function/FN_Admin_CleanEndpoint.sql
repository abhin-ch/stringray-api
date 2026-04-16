/****** Object:  UserDefinedFunction [stng].[FN_Admin_CleanEndpoint]    Script Date: 10/21/2024 1:01:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [stng].[FN_Admin_CleanEndpoint]
(
    @Endpoint varchar(200)
)
RETURNS varchar(200)
AS
BEGIN
    set @Endpoint = REPLACE(@Endpoint, 'api/', '');

	if left(@Endpoint, 1) = '/'
		begin

			set @Endpoint = SUBSTRING(@Endpoint, 2,LEN(@Endpoint) -1);

		end

	if right(@Endpoint,1) = '/'
		begin

			set @Endpoint = SUBSTRING(@Endpoint, 0,LEN(@Endpoint));
		end

	return lower(@Endpoint);
END
GO


