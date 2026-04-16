/****** Object:  UserDefinedFunction [stng].[FN_Admin_AttributeCheck]    Script Date: 10/21/2024 1:01:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [stng].[FN_Admin_AttributeCheck]
(
	@AttributeID varchar(50),
	@Attribute varchar(50),
	@AttributeTypeID varchar(50),
	@AttributeType varchar(50)
)
RETURNS @AdminCheck table
(
	ReturnMessage varchar(250) null,
	AttributeID varchar(50) null,
	AttributeTypeID varchar(50) null
)
AS
BEGIN

	if @AttributeID is null
		begin

			if @Attribute is null
				begin

					if @AttributeType is null and @AttributeTypeID is null
						begin

							
							insert into @AdminCheck
							(ReturnMessage, AttributeID, AttributeTypeID)
							values
							('Attribute or AttributeType is required', null, null);

						end

					else if @AttributeTypeID is null
						begin

							select @AttributeTypeID = UniqueID
							from stng.Admin_AttributeType
							where AttributeType = @AttributeType and Deleted = 0;

							if @AttributeTypeID is null
								begin

									insert into @AdminCheck
									(ReturnMessage, AttributeID, AttributeTypeID)
									values
									('AttributeType/AttributeTypeID does not exist', null, null);

								end

						end
								
				end

			else
				begin

					if @AttributeType is null and @AttributeTypeID is null
						begin

							insert into @AdminCheck
							(ReturnMessage, AttributeID, AttributeTypeID)
							values
							('AttributeType or AttributeTypeID is required', null, null);

						end

					else if @AttributeTypeID is null
						begin

							select @AttributeTypeID = UniqueID
							from stng.Admin_AttributeType
							where AttributeType = @AttributeType and Deleted = 0;

							if @AttributeTypeID is null
								begin

									insert into @AdminCheck
									(ReturnMessage, AttributeID, AttributeTypeID)
									values
									('AttributeType/AttributeTypeID does not exist', null, null);

								end

						end

					select @AttributeID = AttributeID
					from stng.VV_Admin_Attribute
					where Attribute = @Attribute and AttributeTypeID = @AttributeTypeID;

					if @AttributeID is null
						begin

							insert into @AdminCheck
							(ReturnMessage, AttributeID, AttributeTypeID)
							values
							('Attribute does not exist', null, null);

						end

					set @AttributeTypeID = null;

				end
		end

	else if not exists
	(
		select *
		from stng.VV_Admin_Attribute
		where AttributeID = @AttributeID
	)
		begin

			insert into @AdminCheck
			(ReturnMessage, AttributeID, AttributeTypeID)
			values
			('Attribute does not exist', null, null);

		end

	else
		begin

			set @AttributeTypeID = null;

		end

	if not exists
	(
		select *
		from @AdminCheck
		where ReturnMessage is not null
	)
		begin

			insert into @AdminCheck
			(ReturnMessage, AttributeID, AttributeTypeID)
			values
			(null, @AttributeID, @AttributeTypeID);

		end

	return;


END
GO


