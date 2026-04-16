ALTER PROCEDURE [stng].[SP_PR_CRUD] (
				
						@Operation tinyint,
						@CurrentUser varchar(50) = null,
						
						@Station nvarchar(255)=null,

						@ObsolStatus nvarchar(max)=null,
						@Title varchar(max)=null,
						@Description varchar(max)=null,
						@BPStatus varchar(max)=null,
						@SolutionID varchar(max)=null,
						@APID varchar(max) = null,
						@Other varchar(max)=null,
						@PartDescription varchar(max) = null,

						@Manufacturer nvarchar(max)=null,
						@Model nvarchar(max)=null,
						@Justification nvarchar(max)=null,

						@ChangedTo varchar(max) = null,

						@LegacyAP bit = 0,
						@HideCanceled bit = 0,
						@Attribute varchar(max) = null,

						@Comment varchar(max) = null,
						@APNum bigint = null,
						@ITEMNUM varchar(50) = null,
						@AttributeID bigint = null,
						@CommentID bigint = null,
						
						@SearchVal varchar(20) = null,
						@Type varchar(20) = null,

						@APReturn varchar(255) = null output,
						@Error INTEGER = NULL OUTPUT,
						@ErrorDescription VARCHAR(8000) = NULL OUTPUT
)
AS
BEGIN
	begin try
		
		if(@LegacyAP is null)
			begin

				set @LegacyAP = 0

			end 

		if(@Operation = 1) --Saving
			begin

				declare @CurrentStatus uniqueidentifier;
				declare @ID uniqueidentifier;

				SELECT @CurrentStatus = CurrentBPStatus, @ID = UniqueID
				from stng.PR_APT_Main
				where APID = @APNum and LegacyAP = @LegacyAP
			
				update stng.PR_APT_Main set
				Station=@Station,
				--Manufacturer=@Manufacturer,
				--Model=@Model,
				--ObsolStatus=@ObsolStatus,
				Title=@Title,
				Description=@Description,
				Justification=@Justification,
				CurrentBPStatus=@BPStatus,
				--AMOTProject=@AMOTProject,
				--Other=@Other,
				PartDescription = @PartDescription,
				--RepCATID=@RepCATID,
				LUD = GETDATE(), 
				LUB = @CurrentUser
				where APID = @APNum and LegacyAP = @LegacyAP

				if (@CurrentStatus <> @BPStatus)
					 begin 
						insert into stng.PR_APT_StatusLog
						(APTID, [Status], RAD, RAB)
						values
						( @ID, @BPStatus,GETDATE(),@CurrentUser)
					 end

				--update stng.PR_APT_Main
				--set CompletedDate = GETDATE()
				--where APID = @PRID and LegacyAP = @LegacyAP and CompletedDate is null and CurrentBPStatus >= '3';

			end

		else if(@Operation = 2) --New Item
			begin

				insert into stng.PR_APR_Item
				(Item, RAD, RAB)
				values
				(@ITEMNUM, GETDATE(), @CurrentUser)
				
			end 

		else if(@Operation = 3) --Status Log
			begin

				insert into stng.PR_APT_StatusLog
				([Status], RAD, RAB)
				values
				(@ChangedTo, GETDATE(), @CurrentUser)

			end
			
		else if(@Operation = 4) --Add AP
			begin
			declare @AP float;

				--Get Max AP of Non-Legacy APs
				declare @MaxAPNonLegacy bigint;
				select @MaxAPNonLegacy = max(APID) from stng.PR_APT_Main where LegacyAP = 0

				if(@MaxAPNonLegacy is null)
					begin
						set @AP = 1
					end 

				else
					begin

						set @AP = @MaxAPNonLegacy + 1 
					
					end 
				
				declare @APRet table(UniqueID [uniqueidentifier]);
				--Insert into TT_0172
				insert into stng.PR_APT_Main
				(APID, CurrentBPStatus, LegacyAP, Title, Item, Manufacturer, Model, RAD, RAB, LUB, LUD)
				output inserted.UniqueID into @APRet
				values
				(@AP, 'DE781C75-B735-4537-A730-1D0C0BCE97AB', 0, @Title, @ITEMNUM, @Manufacturer, @Model, GETDATE(), @CurrentUser, @CurrentUser, getdate())

				declare @APTID uniqueidentifier;
				select @APTID = [UniqueID] from @APRet

				--Insert into stng.PR_APT_StatusLog
				insert into stng.PR_APT_StatusLog
				(APTID, [Status], RAD, RAB)
				values
				( @APTID, 'DE781C75-B735-4537-A730-1D0C0BCE97AB',GETDATE(),@CurrentUser)

				select @AP as APReturn
			end 

		else if @Operation = 5 --AT
			begin

				select a.*, b.*
				from [stng].[VV_PR_APTItem] as a 
				left join stngetl.General_CatalogMain as b on a.Item = b.ITEM
				order by a.Item

			end

		else if @Operation = 6 --AT Dropdown
			begin
				if @HideCanceled = 1
					begin
						select distinct UniqueID, APActual, APID
						from stng.VV_PR_APTMain
						where Item = @Other and BPStatusC <> 'Canceled'
					end
				else
					begin 
						select distinct UniqueID, APActual, APID
						from stng.VV_PR_APTMain
						where Item = @Other 
					end
			end

		else if @Operation = 7 --APTMain
			begin

				select distinct *
				from stng.VV_PR_APTMain
				where APID = @APNum 
				--and Legacy = @Legacy

			end

		else if @Operation = 8 --Strategies
			begin

				select distinct c.SolutionStrategy
				from stng.PR_APR_SolutionStrategy_Map a
				left join [stng].[VV_PR_APTMain] as b on a.APTID = b.UniqueID
				left join [stng].[PR_APT_SolutionStrategy] as c on a.SolutionStrategyID = c.UniqueID
				where b.apid = @APNum and b.item = @ITEMNUM

			end

		else if @Operation = 9 --BPStatus
			begin

				select distinct [Status] as [label], UniqueID as [value], StatusOrder
				from [stng].[PR_APT_Status]
				order by StatusOrder

			end

		else if(@Operation = 10) --Item Check
			begin

				select Item 
				from [stng].[PR_APR_Item]
				where Item = @ITEMNUM
				
			end 

		else if @Operation = 11 --Status Log
			begin

				SELECT distinct a.UniqueID, d.EmpName, a.RAD, c.[Status]
				FROM [stng].[PR_APT_StatusLog] as a
				left join [stng].[VV_PR_APTMain] as b on a.APTID = b.UniqueID
				left join [stng].[PR_APT_Status] as c on a.[Status] = c.UniqueID
				left join [stng].[VV_Admin_UserView] as d on a.RAB = d.EmployeeID
				where apid = @APNum

			end

		else if @Operation = 12 --Catalog Info
			begin

				select distinct *
				from stngetl.General_CatalogMain 
				where ITEM = @ITEMNUM

			end

		else if @Operation = 13 --Insert Strategy
			begin

				INSERT INTO [stng].[PR_APR_SolutionStrategy_Map]
				(APTID, SolutionStrategyID, RAB, RAD)
				VALUES
				(@APID, @SolutionID, @CurrentUser, GETDATE())

			end

		else if @Operation = 14 --Delete Strategy
			begin
				
				DELETE 
				FROM[stng].[PR_APR_SolutionStrategy_Map]
				WHERE APTID = @APID and SolutionStrategyID = @SolutionID

			end

		else if @Operation = 15 --GET Strategies
			begin
				
				SELECT UniqueID, SolutionStrategy
				FROM [stng].[PR_APT_SolutionStrategy]

			end

		else if @Operation = 16 -- Get Attributes
			begin
				declare @StringID varchar(300);

				SELECT @StringID = UniqueID
				from stng.VV_PR_APTMain
				where APID = @APNum and LegacyAP = @LegacyAP

				SELECT a.UniqueID, a.Attribute, a.RAD, b.AttributeType, c.EmpName as AddedBy
				FROM [stng].[PR_Attribute] as a
				LEFT JOIN [stng].[PR_AttributeType] as b on a.AttributeType = b.UniqueID
				LEFT JOIN [stng].[VV_Admin_UserView] as c on a.RAB = c.EmployeeID
				WHERE a.SubmoduleID = @StringID and a.Deleted = 0

			end

		else if @Operation = 17 --Remove Attribute
			begin

				UPDATE stng.PR_Attribute set
				Deleted = 1,
				DeletedBy = @CurrentUser,
				DeletedOn = GETDATE()
				WHERE UniqueID = @AttributeID

			end

		else if @Operation = 18 --Add Attribute
			begin
			
				declare @AttributeType varchar(100);

				SELECT @APTID = UniqueID
				from stng.VV_PR_APTMain
				where APID = @APNum and LegacyAP = @LegacyAP

				SELECT @AttributeType = UniqueID
				FROM [stng].[PR_AttributeType]
				WHERE AttributeType = @Type

				insert into stng.PR_Attribute
				(SubmoduleID, Submodule, AttributeType, Attribute, RAB)
				values
				(@APTID, 'APT', @AttributeType, @Attribute, @CurrentUser)

			end

		
		else if @Operation = 19 -- Get Comments
			begin

				SELECT a.UniqueID, a.Comment, a.RAD, b.EmpName as AddedBy
				FROM [stng].[PR_Comment] as a
				LEFT JOIN [stng].[VV_Admin_UserView] as b on a.RAB = b.EmployeeID
				WHERE a.ITEMNUM = @ITEMNUM and a.Deleted = 0
				order by a.RAD

			end

		
		else if @Operation = 20 --Delete Comment
			begin

				update [stng].[PR_Comment]
				set Deleted = 1,
				LUD = GETDATE(),
				LUB = @CurrentUser,
				DeletedBy = @CurrentUser,
				DeletedOn = GETDATE()
				where UniqueID = @CommentID;

			end

		else if @Operation = 21 --Add Comment
			begin
			
				insert into [stng].[PR_Comment]
				(ITEMNUM, Comment, RAD, RAB, LUB, LUD)
				values
				(@ITEMNUM, @Comment, GETDATE(), @CurrentUser, @CurrentUser, GETDATE());

				select SCOPE_IDENTITY() as CommentID

			end

		else if @Operation = 22 --Edit Comment
			begin

				update [stng].[PR_Comment]
				set Comment = @Comment,
				LUD = GETDATE(),
				LUB = @CurrentUser
				where UniqueID = @CommentID;

			end 

		else if @Operation = 23 --Search Projects
			begin

				SELECT distinct PROJECTID as ID, PROJECTNAME, [STATUS]
				FROM [stng].[MPL]
				WHERE PROJECTID like '%'+@SearchVal+'%'

			end 

		else if @Operation = 24 --Search Items
			begin

				SELECT distinct ITEM as ID, ITEMDESC, [STATUS]
				FROM [stngetl].[General_Item]
				WHERE ITEM like '%'+@SearchVal+'%'

			end 

		else if @Operation = 25 --Search EC
			begin

				SELECT distinct EC as ID, [DESCRIPTION], [STATUS]
				FROM [stngetl].[General_AllEC]
				WHERE EC like '%'+@SearchVal+'%'

			end 

		else if @Operation = 26 --Get AP Strategy
			begin
				
				SELECT DISTINCT SolutionStrategyID
				FROM [stng].[PR_APR_SolutionStrategy_Map]
				WHERE APTID = @APID and SolutionStrategyID = @SolutionID

			end
		

	end try

	begin catch
		INSERT INTO stng.App_ErrorLog([Number],[Procedure],[Line],[Message],Operation) VALUES (
                     ERROR_NUMBER(),
                     ERROR_PROCEDURE(),
                     ERROR_LINE(),
                     ERROR_MESSAGE(),
					 @Operation
              );
			  THROW
	end catch

END
