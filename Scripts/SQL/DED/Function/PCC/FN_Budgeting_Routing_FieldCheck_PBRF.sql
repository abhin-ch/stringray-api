SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER FUNCTION [stng].[FN_Budgeting_Routing_FieldCheck_PBRF]
(	
	@PBRUID bigint,
	@NextStatus varchar(20)
)
RETURNS @ReturnMessage table
(
	ReturnMessage varchar(250)
)
AS
BEGIN
	
	--Working Variables
	declare @ProblemStatement varchar(max);
	declare @InstallationDate date;
	declare @ProjectTypeID uniqueidentifier;
	declare @Section varchar(50);
	declare @RC uniqueidentifier;
	declare @ProjectTitle varchar(2000);
	declare @Scope varchar(2000);
	declare @Station varchar(10);

	declare @Year1 int;
	declare @Year1External int;
	declare @Year1Internal int;
	declare @Year2 int;
	declare @Year2External int;
	declare @Year2Internal int;

	declare @ProjectNo varchar(40);
	
	--Check that PBRF actually exists
	if @PBRUID is null or not exists
	(
		select *
		from stng.VV_Budgeting_PBRFMain
		where RecordTypeUniqueID = @PBRUID
	)
		begin

			insert into @ReturnMessage
			(ReturnMessage)
			values
			('PBRF does not exist');
			return;

		end 

	--Get fields
	select @ProblemStatement = ProblemStatement, @Section = Section, @RC = RCID, @ProjectTitle = ProjectTitle, @Scope = Scope,
	@InstallationDate = CustomerNeedDate, @ProjectTypeID = ProjectTypeID, @Station = Station, @ProjectNo = ProjectNo
	from stng.VV_Budgeting_PBRFMain
	where RecordTypeUniqueID = @PBRUID;

	select @Year1 = [Year], @Year1External = [External], @Year1Internal = Internal 
	from stng.Budgeting_PBRFCostEstimate
	where PBRFUID = @PBRUID and Year1 = 1;

	select @Year2 = [Year], @Year2External = [External], @Year2Internal = Internal 
	from stng.Budgeting_PBRFCostEstimate
	where PBRFUID = @PBRUID and Year2 = 1;

	--Going to ASMA
	if @NextStatus = 'ASMA'
		begin

			--Null checks for fields required by user		
			if @ProjectTitle is null
				begin

					insert into @ReturnMessage
					(ReturnMessage)
					values
					('Project Title must be populated');
					return;

				end


			else if @ProblemStatement is null
				begin

					insert into @ReturnMessage
					(ReturnMessage)
					values
					('Problem Statement must be populated');
					return;

				end

			else if @Section is null
				begin

					insert into @ReturnMessage
					(ReturnMessage)
					values
					('Section must be selected');
					return;

				end

			else if @RC is null
				begin

					insert into @ReturnMessage
					(ReturnMessage)
					values
					('RC must be selected');
					return;

				end

			else if @InstallationDate is null or cast(@InstallationDate as date) <= cast(stng.getbptime(getdate()) as date)
				begin

					insert into @ReturnMessage
					(ReturnMessage)
					values
					('Installation Date must be populated and in the future');
					return;

				end

			else if @ProjectTypeID is null
				begin

					insert into @ReturnMessage
					(ReturnMessage)
					values
					('Project Type must be selected');
					return;

				end

				
			else if @Station is null
				begin

					insert into @ReturnMessage
					(ReturnMessage)
					values
					('Station must be selected');
					return;

				end

			else if @Scope is null
				begin

					insert into @ReturnMessage
					(ReturnMessage)
					values
					('Scope must be populated');
					return;

				end

			else if @Year1 is null or @Year1 = 0
				begin

					insert into @ReturnMessage
					(ReturnMessage)
					values
					('Year 1 must be populated');
					return;

				end

			else if @Year1External is null or @Year1External = 0
				begin

					insert into @ReturnMessage
					(ReturnMessage)
					values
					('Year 1 External must be populated');
					return;

				end

			else if @Year1Internal is null or @Year1Internal = 0
				begin

					insert into @ReturnMessage
					(ReturnMessage)
					values
					('Year 1 Internal must be populated');
					return;

				end

			else if @Year2 is null or @Year2 = 0
				begin

					insert into @ReturnMessage
					(ReturnMessage)
					values
					('Year 2 must be populated');
					return;

				end

			else if @Year2External is null or @Year2External = 0
				begin

					insert into @ReturnMessage
					(ReturnMessage)
					values
					('Year 2 External must be populated');
					return;

				end

			else if @Year2Internal is null or @Year2Internal = 0
				begin

					insert into @ReturnMessage
					(ReturnMessage)
					values
					('Year 2 Internal must be populated');
					return;

				end



		end


	--Going to APPC
	else if @NextStatus = 'APPC'
		begin

			if @ProjectNo is null or (not LEFT(@ProjectNo, 4) = 'ENG-')
				begin

					insert into @ReturnMessage
					(ReturnMessage)
					values
					('Project Number must be populated and begin with ENG-');
					return;

				end


		end

	return;
END
