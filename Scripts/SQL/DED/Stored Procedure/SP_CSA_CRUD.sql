/****** Object:  StoredProcedure [stng].[SP_CSA_CRUD]    Script Date: 3/10/2026 1:56:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [stng].[SP_CSA_CRUD] (
									@Operation TINYINT,
									@CurrentUser VARCHAR(50),
									@isAdmin bit = 0,

									@CSAID varchar(40) = null, 

									@ITEMNUM varchar(50) = null,
									@Revision int = null,

									@BOMUpdateRequired bit = null,

									@CSAStatus varchar(5) = null,
									@INID varchar(20) = null,
									@VERID	varchar(20) = null,
									@APPID	varchar(20) = null,

									@TMAX int = null,
									@ROP int = null,

									@ER varchar(50) = null,
									@AR varchar(50) = null,
									@AMOT	varchar(50) = null,
									@EC	varchar(50) = null,

									@Comment varchar(max) = null,

									@CSABID int = null,
									@SS int = null,
									@CriticalFlag varchar(5) = null,
									@BOMComment varchar(max) = null,

									@QueryVal int = null,

									@LANID varchar(50) = null,
									@LANIDC varchar(500) = null,
									@LANIDCStr varchar(max) = null,
									@TemplateDescription varchar(500) = null,

									@RSE varchar(200) = null,
									@RDE varchar(200) = null,
									@RCE varchar(200) = null,
									@EQTag varchar(200) = null,
									@USI varchar(20) = null,
									@StrategyOwner varchar(200) = null,
									@Manufacturer varchar(200) = null,
									@EPT varchar(200) = null,

									@ChangeType smallint = null,
									@ChangedField varchar(50) = null,
									@ChangedFromNum float = null,
									@ChangedToNum float = null,
									@ChangedFromStr varchar(max) = null,
									@ChangedToStr varchar(max) = null,
									@ChangedFromDate datetime = null,
									@ChangedToDate datetime = null,

									@SAID bigint = null,
									@SAItemID bigint = null,
									@Type varchar(20) = null,
									@RiskProb float = null,
									@RiskImpact float = null,
									@RiskEndDate datetime = null,
									@Obsolescence bit = null,
									@EquipmentReliability bit = null,
									@EndOfLife bit = null,
									@Rationale4 bit = null,
									@Other bit = null,
									@OtherText varchar(500) = null,
									
									@CSAMID bigint = null,
									@ScopeStatus varchar(50) = null,
									@RepItem varchar(20) = null,
									@Justification varchar(max) = null,
									@Reason varchar(50) = null,
																											
									@Error INTEGER = NULL OUTPUT,
									@ErrorDescription VARCHAR(8000) = NULL OUTPUT)
AS
    BEGIN

	
			declare @WorkingStatus uniqueidentifier;
		   
		   if @Operation = 1 --New CSA
		   begin
		 
				select @WorkingStatus = UniqueID
				from stng.CSA_Status
				where StatusShort = 'I';

				--Get next CSAID
				SELECT @CSAID = LOWER(newid());
				--Add to CSA_Main
				insert into stng.CSA_Main
				(UniqueID, Item, CSAStatus, INID, ItemDesc, Manufacturer, Model, CurrentCSARevision, RAD, RAB
				, CritCat, SPV
				)
				select distinct @CSAID, @ITEMNUM, @WorkingStatus, @INID, a.ITEMDESC, a.MANUFACTURER, a.MODEL,
				case when b.CSARevision is null and c.MaxRev is null 
					then 0 
					else cast(
						case
							when b.CSARevision is null then c.MaxRev
							when c.MaxRev is null then b.CSARevision
							when b.csarevision > c.MaxRev then b.csarevision else c.MaxRev
						end as int) + 1
				end,
				stng.GetBPTime(GETDATE()), @CurrentUser
				, a.mincritcat, a.maxspv
				from stngetl.VV_General_Item as a
				left join stngetl.General_LatestIssuedCSA as b on a.ITEM = b.AssocItem
				left join ( 
					select Item, max(CurrentCSARevision) as MaxRev
					from stng.VV_CSA_Main
					where StatusShort <> 'CA'
					group by Item
				) as c on a.ITEM = c.Item 
				where a.ITEM = @ITEMNUM
				option(optimize for (@ITEMNUM unknown));


				--Add to Status Log
				INSERT INTO stng.CSA_StatusLog
				(CSAID,CSAStatus,Comment,RAD,RAB)
				select distinct @CSAID, @WorkingStatus, 'Initialized by '+EmpName ,stng.GetBPTime(GETDATE()),@CurrentUser
				from stng.VV_Admin_UserView
				where EmployeeID = @CurrentUser;

				--Add to MEL Table
				insert into stng.CSA_MELReview
				(CSAID,ParentItem,SiteID,Location,Equipment_Name,SPV,Crit_Cat,Repair_Strat,MANUFACTURER,Model_Number,Verified,Approved)
				select distinct @CSAID, @ITEMNUM, SITEID, [LOCATION], EQUIPMENT_NAME
				,SPV, crit_Cat, Repair_Strat, MANUFACTURER, model_number, 
				max(Verified), Approved
				from (
					select distinct parentItem, SITEID, [LOCATION], EQUIPMENT_NAME, 
					case when SPV is null then 'No' else SPV end as SPV,
					crit_Cat, Repair_Strat, MANUFACTURER, model_number, 
					case when Verified is null then 0 else VERIFIED end as Verified, 1 as Approved
					from stng.VV_IQT_MEL
				) as a
				where ParentItem = @ITEMNUM
				group by ParentItem, SITEID, [LOCATION], EQUIPMENT_NAME, SPV, crit_Cat, Repair_Strat, MANUFACTURER, model_number, Approved
				order by a.CRIT_CAT asc
				option(optimize for (@ITEMNUM unknown));

				--Add to BOM Table
				insert into stng.CSA_BOMDetails
				(CSAID, ITEMNUM, bom_path, bom_level, BOM_CID, ITEMDESC, bom_cid_status, bom_qty, currentaup, currentrop, currenttmax, currentcriticalcode, currentsafetystock,
				manuf, model, part, RAD, RAB)
				select distinct e.[UniqueID], a.TOPITEM, a.ITEMPATH, a.ITEMLEVEL, a.ITEMNUM, b.ITEMDESC as catalog_desc, b.STATUS as bom_cid_status, a.QUANTITY,
				case when c.AVG_UNIT_PRICE is null then 0 else c.AVG_UNIT_PRICE end as currentaup, 
				case when c.RE_ORDER_POINT is null then 0 else c.RE_ORDER_POINT end as currentrop, 
				case when c.TARGET_MAXIMUM is null then 0 else c.TARGET_MAXIMUM end as currenttmax, 
				c.CRITICAL_CODE as currentcriticalcode, 
				case when c.SAFETY_STOCK is null then 0 else c.SAFETY_STOCK end as currentsafetystock, 
				d.MANUFACTURER_CODE as manuf, d.MODEL_NUMBER_CAT as model, d.MANUF_PART_NUMBER as part,
				stng.GetBPTime(GETDATE()), 'SYSTEM'
				from stngetl.General_ItemHierarchy as a 
				inner join stng.CSA_Main as e on a.TOPITEM = e.Item 
				left join stngetl.General_Item as b on a.ITEMNUM = b.ITEM
				left join stngetl.General_CatalogMain as c on a.ITEMNUM = c.ITEM
				left join 
				(
					select * 
					from stngetl.General_CatalogMFR 
					where MANUF_STATUS = 'ACTIVE' and defaultvendor = 1
				) as d on a.ITEMNUM = d.ITEMNUM
				where e.[UniqueID] = @CSAID
				option(optimize for (@CSAID unknown));

				--Copy previous BOM revision inputed info (Comment, safety stock, aup, etc)

				update a 
				set 
				SafetyStock = d.SafetyStock,
				CriticalFlag = d.CriticalFlag,
				BOMComment = d.BOMComment,
				ROP = d.ROP,
				TMAX = d.TMAX
				FROM stng.CSA_BOMDetails as a
				inner join stng.CSA_Main as b on a.CSAID = b.UniqueID
				inner join stng.VV_CSA_Main as c on b.Item = c.Item and c.CurrentCSARevision = b.CurrentCSARevision - 1 and c.StatusShort <> 'CA'
				inner join stng.CSA_BOMDetails as d on c.UniqueID = d.CSAID and d.BOM_CID = a.BOM_CID and d.bom_level = a.bom_level
				WHERE a.CSAID = @CSAID


		   end 

		   
		   else if @Operation = 2 --BOM Update
		   begin

			if @CriticalFlag = 'N'
				begin
					update stng.CSA_BOMDetails
					set SafetyStock = null,
					CriticalFlag = @CriticalFlag,
					BOMComment = @BOMComment,
					ROP = null,
					TMAX = null,
					LUD = stng.GetBPTime(GETDATE()),
					LUB = @CurrentUser
					where CSABID = @CSABID
				end
			else
				begin
					update stng.CSA_BOMDetails
					set SafetyStock = @SS,
					CriticalFlag = @CriticalFlag,
					BOMComment = @BOMComment,
					ROP = @ROP,
					TMAX = @TMAX,
					LUD = stng.GetBPTime(GETDATE()),
					LUB = @CurrentUser
					where CSABID = @CSABID
				end

			

		   end 

			else if @Operation = 3 --My View SQL
				begin
						
					select *
					, case when inid = @CurrentUser then 1 else 0 end as isInitiator
					, case when verid = @CurrentUser then 1 else 0 end as isVerifier
					, case when appid = @CurrentUser then 1 else 0 end as isApprover
					from stng.VV_CSA_Main
					where (inid = @CurrentUser or verid = @CurrentUser or appid = @CurrentUser) and StatusShort not in ('CA','C')
					order by RAD desc
					option(optimize for (@CurrentUser unknown));

				end 

			else if @Operation = 4 --All View SQL
				begin
					select * 
					, case when inid = @CurrentUser then 1 else 0 end as isInitiator
					, case when verid = @CurrentUser then 1 else 0 end as isVerifier
					, case when appid = @CurrentUser then 1 else 0 end as isApprover
					from stng.VV_CSA_Main
					where StatusShort not in ('CA','C')
					order by RAD desc;

				end

			else if @Operation = 5 --Personnel dates
				begin 

					select max(rad) as RAD
					from stng.VV_CSA_StatusLog
					where csaid = @CSAID and StatusShort = @CSAStatus
					option(optimize for (@CSAID unknown, @CSAStatus unknown));

				end

			else if @Operation = 6 --MEL
				begin

					SELECT * 
					FROM [stng].[VV_CSA_MELReview]
					WHERE csaid = @CSAID
					ORDER BY [Location];

				end 

			else if @Operation = 7 --BOM
				begin

					SELECT distinct CSABID as ID, 
					* 
					FROM stng.CSA_BOMDetails
					WHERE CSAID = @CSAID
					order by bom_path asc
					option(optimize for (@CSAID unknown));

				end

			else if @Operation = 8 --Status Log
				begin

					SELECT *
					FROM stng.VV_CSA_StatusLog
					WHERE CSAID = @CSAID
					order by RAD desc

				end
						
			else if @Operation = 9 --Search CSA
				begin

					select distinct concat(ParentItem, '-', Identifier, '-', CSAMessage) as ID, [ParentItem], [Identifier], [CSAMessage], [MANUFACTURER_CODE], [MODEL_NUMBER]
					, totcriticalends
					, [csaissued], [ITEMDESC], [CSARev]
					from stng.VV_CSA_SearchView
					where 
					(Item like '%' + @ITEMNUM + '%' or @ITEMNUM is null)
					and
					(RSE like '%' + @RSE + '%' or @RSE is null)
					and
					(RDE like '%' + @RDE + '%' or @RDE is null)
					and
					([Location] like '%' + @EQTag + '%' or @EQTag is null)
					and
					(USI like '%' + @USI + '%' or @USI is null)
					and
					(STRATEGY_OWNER like '%' + @StrategyOwner + '%' or @StrategyOwner is null)
					and
					(MANUFACTURER_CODE like '%' + @Manufacturer + '%' or @Manufacturer is null)
					and
					(ept like '%' + @EPT + '%' or @EPT is null)
					and
					(RCE like '%' + @RCE + '%' or @RCE is null)
					
					option(optimize for (@ITEMNUM unknown, @RSE unknown, @RDE unknown, @EQTag unknown, @USI unknown, @StrategyOwner unknown, @Manufacturer unknown, @EPT unknown, @RCE unknown));

				end

			else if @Operation = 10 --Existing CSA check
				begin

					select UniqueID as CSAID, Item, CurrentCSARevision
					from stng.VV_CSA_Main
					where Item = @ITEMNUM and StatusShort not in ('CA','C','IS');
						
				end 
						
			
		  -- else if @Operation = 8 --Field Changes
				--begin

				--	if @ChangeType = 1
				--		begin 

				--			insert into dems.TT_0793_CSAFieldChanges
				--			(CSAID, FieldName,ChangedFromStr, ChangedToStr, RAB)
				--			values
				--			(@CSAID, @ChangedField, @ChangedFromStr, @ChangedToStr, @CurrentUser);

				--		end

				--	else if @ChangeType = 2
				--		begin

				--			insert into dems.TT_0793_CSAFieldChanges
				--			(CSAID, FieldName,ChangedFromNum, ChangedToNum, RAB)
				--			values
				--			(@CSAID, @ChangedField, @ChangedFromNum, @ChangedToNum, @CurrentUser);

				--		end

				--	else if @ChangeType = 3
				--		begin

				--			insert into dems.TT_0793_CSAFieldChanges
				--			(CSAID, FieldName,ChangedFromDate, ChangedToDate, RAB)
				--			values
				--			(@CSAID, @ChangedField, @ChangedFromDate, @ChangedToDate, @CurrentUser);

				--		end

				--end

		   else if @Operation = 11 --Update CSA_Main
		   begin
				update stng.CSA_Main
				set INID = @INID,
				VERID = @VERID,
				APPID = @APPID,
				ER = @ER,
				AR = @AR,
				AMOT = @AMOT,
				EC = @EC,
				BOMUpdateRequired = @BOMUpdateRequired,
				LUB = @CurrentUser,
				LUD = stng.GetBPTime(GETDATE())
				where [UniqueID] = @CSAID
			end

			--else if @Operation = 12
			--	begin
			--		--Update Status
			--		update stng.CSA_Main
			--		set CSAStatus = @CSAStatus
			--		where [UniqueID] = @CSAID

			--		--Add to Status Log
			--		INSERT INTO stng.CSA_StatusLog
			--		(CSAID,CSAStatus,Comment,RAD,RAB)
			--		VALUES (@CSAID,@CSAStatus,@Comment,GETDATE(),@CurrentUser)

			--	end 

			--else if @Operation = 13
			--	begin
			--		insert into stng.SA_Main2
			--		(SAType,Revision, Preparer, RAD, RAB, LUD, LUB)
			--		values
			--		(@Type, 1, @CurrentUser, getdate(), @CurrentUser, getdate(), @CurrentUser )

			--	end 

			--else if @Operation = 14
			--	begin
			--		insert into stng.SA_Item2
			--		(SAID, Item, Deleted, RAD, RAB)
			--		values
			--		(@SAID, @ITEMNUM, 0, getdate(), @CurrentUser)
			--		option(optimize for (@ITEMNUM unknown));
			--	end 

			--else if @Operation = 15
			--	begin
			--		select 
			--		concat(a.SAType, '-', a.SAID) as [SAID-Type]
			--		, concat('Title ', a.SAType, '-', a.SAID) as title
			--		,'Active' as status
			--		, a.* 
			--		,b.EmpName as PreparerC
			--		,c.EmpName as VerifierC
			--		,d.EmpName as ApproverC
			--		from stng.SA_Main2 as a
			--		left join stng.VV_Admin_UserView as b on a.Preparer = b.EmployeeID
			--		left join stng.VV_Admin_UserView as c on a.Verifier = c.EmployeeID
			--		left join stng.VV_Admin_UserView as d on a.Approver = d.EmployeeID
			--		where (a.Preparer = @CurrentUser or a.Verifier = @CurrentUser or a.Approver = @CurrentUser) 
			--		order by a.RAD desc
			--		option(optimize for (@CurrentUser unknown));

			--	end 

			--else if @Operation = 16
			--	begin
			--		select 
			--		concat(a.SAType, '-', a.SAID) as [SAID-Type]
			--		, concat('Title ', a.SAType, '-', a.SAID) as title
			--		,'Active' as status
			--		, a.* 
			--		,b.EmpName as PreparerC
			--		,c.EmpName as VerifierC
			--		,d.EmpName as ApproverC
			--		from stng.SA_Main2 as a
			--		left join stng.VV_Admin_UserView as b on a.Preparer = b.EmployeeID
			--		left join stng.VV_Admin_UserView as c on a.Verifier = c.EmployeeID
			--		left join stng.VV_Admin_UserView as d on a.Approver = d.EmployeeID
			--		order by a.RAD desc;

			--	end 

			--else if @Operation = 17
			--	begin
			--		select distinct a.*, b.ITEMDESC, b.STATUS
			--		, stng.FN_General_MaximoLink('Item',b.ITEMID)as MaximoLink
			--		from stng.SA_Item2 as a
			--		left join stngetl.General_Item as b on a.Item = b.ITEM
			--		where a.SAID = @SAID and deleted = 0
			--		order by a.RAD desc;

			--	end 
			--else if @Operation = 18
			--	begin
			--		update stng.SA_Main2
			--		set 
			--		Preparer = @INID,
			--		Verifier = @VERID,
			--		Approver = @APPID,
			--		RiskProb = @RiskProb,
			--		RiskImpact = @RiskImpact,
			--		RiskEndDate = @RiskEndDate,
			--		Obsolescence = @Obsolescence,
			--		EquipmentReliability = @EquipmentReliability,
			--		EndOfLife = @EndOfLife,
			--		Rationale4 = @Rationale4,
			--		Other = @Other,
			--		OtherText = @OtherText,
			--		LUB = @CurrentUser,
			--		LUD = GETDATE()
			--		where SAID = @SAID

			--	end 

			else if @Operation = 19
				begin
					select distinct ITEM as Item, ITEMDESC, STATUS
					from stngetl.General_Item
					where Item like '%' + @ITEMNUM + '%'
					option(optimize for (@ITEMNUM unknown));
				end 

			--else if @Operation = 20
			--	begin
			--		update stng.SA_Item2 set
			--		deleted = 1
			--		where SAItemID = @SAItemID
			--	end 

			else if @Operation = 21
				begin
					select a.*, b.Reason 
					FROM [stng].[CSA_MgmtMain] as a
					left join [stng].[CSA_ReasonCode] as b on a.ReasonCode = b.UniqueID
					order by Item
				end 

			else if @Operation = 22
				begin

					declare @PrevScopeStatus varchar(200);
					select @PrevScopeStatus = ScopeStatus
					from  [stng].[CSA_MgmtMain]
					where CSAMID = @CSAMID

					update [stng].[CSA_MgmtMain]
					set 
					ScopeStatus = @ScopeStatus,
					RepItem = @RepItem,
					EC = @EC,
					Justification = @Justification,
					[ReasonCode] = @Reason,
					LUB = @CurrentUser,
					LUD = stng.GetBPTime(GETDATE())
					where CSAMID = @CSAMID

					if @RepItem <> ''
						begin
							insert into [stng].[CSA_MgmtMain]
							(Item,ScopeStatus,AddedScope,RAD,RAB)
							select RepItem, 'In-Scope',1,stng.GetBPTime(GETDATE()),'SYSTEM'
							from [stng].[CSA_MgmtMain]
							where CSAMID = @CSAMID and RepItem not in (select distinct Item from [stng].[CSA_MgmtMain]);
						end

					if @ScopeStatus = 'Descoped'
						begin

							if @PrevScopeStatus = 'In-Scope'
								begin
									update [stng].[CSA_MgmtMain]
									set 
									DescopedDate = stng.GetBPTime(GETDATE())
									where CSAMID = @CSAMID
								end
						end
					if @ScopeStatus = 'In-Scope'
						begin

							if @PrevScopeStatus = 'Descoped'
								begin
									update [stng].[CSA_MgmtMain]
									set 
									DescopedDate = null
									where CSAMID = @CSAMID
								end
						end
				end 

			else if @Operation = 23
				begin
					
					select CSAMID, Item 
					from [stng].[CSA_MgmtMain]
					where Item = @ITEMNUM

				end 

			else if @Operation = 24
				begin
					
					insert into [stng].[CSA_MgmtMain]
					(Item,ScopeStatus,AddedScope,RAD,RAB)
					values
					(@ITEMNUM,'In-Scope',1,stng.GetBPTime(GETDATE()),@CurrentUser);

					
					SELECT max(CSAMID) as CSAMID
					from [stng].[CSA_MgmtMain]

				end 

			else if @Operation = 25
				begin
					
					select distinct EC, DESCRIPTION, STATUS
					from [stngetl].[General_AllEC]
					where EC like '%' + @EC + '%'
					option(optimize for (@EC unknown));

				end 

				
			else if @Operation = 26 --MEL Source for CSA Export
				begin

					SELECT SiteID,Location,[equipment_name],MANUFACTURER,[model_number],
					[Crit_Cat],[SPV],[Repair_Strat], case when Verified = 1 then 'Y' else 'N' end as Verified,
					case when Approved = 1 then 'Y' else 'N' end as Approved
					FROM [stng].CSA_MELReview 
					WHERE csaid = @CSAID 
					order by Location;

				end 

			else if @Operation = 27 --Updated CSA Workflow
				begin

					declare @CurrentStatus varchar(10) = null
					declare @Preparer varchar(20) = null
					declare @Verifier varchar(20) = null
					declare @Approver varchar(20) = null
					declare @Item varchar(50) = null
					declare @Rev Int = null

					select @Item = Item, @Rev = CurrentCSARevision, @CurrentStatus = StatusShort, @Preparer = INID, @Verifier = VERID, @Approver = APPID
					from stng.VV_CSA_Main
					where UniqueID = @CSAID

					if @CSAStatus = 'R' --Reject status doesnt exist because the status just goes back to initiated. 'R' value is sent from frontend to identify the rejeted status for the checks
						begin
							select @WorkingStatus = UniqueID
							from stng.CSA_Status
							where StatusShort = 'I';
						end
					else
						begin
							select @WorkingStatus = UniqueID
							from stng.CSA_Status
							where StatusShort = @CSAStatus;
						end

					
					if @CSAStatus = 'R'
						begin
							if @Verifier <> @CurrentUser and @CurrentStatus = 'V' and @isAdmin <> 1
								begin 
									select 'You cannot Reject the CSA because you are not the Verifier' as ReturnMessage;
									return
								end

							else if @Approver <> @CurrentUser and @CurrentStatus = 'AA' and @isAdmin <> 1
								begin 
									select 'You cannot Reject the CSA because you are not the Approver' as ReturnMessage;
									return
								end

							else 
								begin
									SET @Comment = concat('User rejected CSA, sending back to Initiated: ', @Comment)
								end
										
						end

					else if @CSAStatus = 'I'
						begin
							if @CurrentStatus = 'V'
								begin

									if @Preparer <> @CurrentUser and @isAdmin <> 1
										begin 
											select 'You cannot revert the status because you are not the Preparer' as ReturnMessage;
											return
										end
									else 
										begin
											SET @Comment = concat('User reverting back to Initiated: ', @Comment)
										end
								end


			
						end

					else if @CSAStatus = 'V'
						begin
							if @CurrentStatus = 'I'
								begin

								
									if @Preparer in (@Verifier, @Approver) or @Verifier in (@Preparer, @Approver) or @Approver in (@Preparer, @Verifier)
									begin 
										select 'Distinct Initiator, Verifier and Approver required' as ReturnMessage;
										return
									end


									if @Preparer <> @CurrentUser and @isAdmin <> 1
										begin 
											select 'You cannot change the status because you are not the Preparer' as ReturnMessage;
											return
										end

									-- Crit flag can only have a value of C or N or blank, there are legacy options S and U that arent used anymore, check to see that
									-- this criteria is met.
									if exists(select 1
										from stng.VV_CSA_Main as a
										left join stng.CSA_BOMDetails as b on a.UniqueID = CSAID 
										where UniqueID = @CSAID
										and (b.CriticalFlag = 'S' or b.CriticalFlag = 'U')
									)
										begin

											select @Justification = STRING_AGG(b.BOM_CID, ', ')
											from stng.VV_CSA_Main as a
											left join stng.CSA_BOMDetails as b on a.UniqueID = CSAID 
											where UniqueID = @CSAID
											and (b.CriticalFlag = 'S' or b.CriticalFlag = 'U')

											select concat('IAS Item(s) ', @Justification, ' is/are flagged as U or S') as ReturnMessage;
											return
										end

									-- Safety stock is required if crit flag is C
									if exists(select 1
										from stng.VV_CSA_Main as a
										left join stng.CSA_BOMDetails as b on a.UniqueID = CSAID 
										where UniqueID = @CSAID
										and b.CriticalFlag = 'C'
										and b.SafetyStock is null
									)
										begin

											select @Justification = STRING_AGG(b.BOM_CID, ', ')
											from stng.VV_CSA_Main as a
											left join stng.CSA_BOMDetails as b on a.UniqueID = CSAID 
											where UniqueID = @CSAID
											and b.CriticalFlag = 'C'
											and b.SafetyStock is null

											select concat('IAS Item(s) ', @Justification, ' is/are flagged as C and the safety stock is missing') as ReturnMessage;
											return
										end

								end
							else if @CurrentStatus = 'AA'
								begin

									if @Verifier <> @CurrentUser and @isAdmin <> 1
										begin 
											select 'You cannot revert the status because you are not the Verifier' as ReturnMessage;
											return
										end

									
									SET @Comment = concat('User reverting back to Verification: ', @Comment)

								end
			
						end
					else if @CSAStatus = 'AA'
						begin
							if @CurrentStatus = 'V'
								begin
									if @Verifier <> @CurrentUser and @isAdmin <> 1
										begin 
											select 'You cannot change the status because you are not the Verifier' as ReturnMessage;
											return
										end
								end
							else
								begin
									select 'Cannot change the status of this record to Awaiting Approval, the current status is not Verification' as ReturnMessage;
									return
								end
			
						end
					else if @CSAStatus = 'AIR'
						begin
							if @CurrentStatus = 'AA'
								begin
									if @Approver <> @CurrentUser and @isAdmin <> 1
										begin 
											select 'You cannot change the status because you are not the Approver' as ReturnMessage;
											return
										end
								end
							else
								begin
									select 'Cannot change the status of this record to Awaiting Issue to Records, the current status is not Awaiting Approval' as ReturnMessage;
									return
								end
			
						end
					else if @CSAStatus = 'CA'
						begin
							if @CurrentStatus = 'I'
								begin
									if @Preparer <> @CurrentUser and @isAdmin <> 1
										begin 
											select 'You cannot change the status because you are not on the Preparer' as ReturnMessage;
											return
										end
								end
							else
								begin
									select 'Cannot change the status of this record to Canceled, the current status is not Initiated' as ReturnMessage;
									return
								end
						end
					
					else if @CSAStatus not in (
						Select StatusShort
						from stng.CSA_Status
					)
						begin 
							select 'The status you are trying to change the record to does not exist' as ReturnMessage;
							return;
						end

					if (@Preparer is null or @Verifier is null or @Approver is null) and @CSAStatus <> 'CA'
						begin
							select 'The preparer, verifier and approver fields need to be populated before the status is changed' as ReturnMessage;
							return;
						end
					else
						begin
							update stng.CSA_Main
							set CSAStatus = @WorkingStatus
							where UniqueID = @CSAID

							--Add to Status Log
							INSERT INTO stng.CSA_StatusLog
							(CSAID,CSAStatus,Comment,RAD,RAB)
							VALUES (@CSAID,@WorkingStatus,@Comment,stng.GetBPTime(GETDATE()),@CurrentUser)

							select CONCAT('The status for B-CSA-', @Item, ' Rev ',@Rev ,' has successfully been changed...') as SuccessMessage;

						end 

				end 

			else if @Operation = 28
				begin
					
					SELECT UniqueID, Reason
					FROM stng.CSA_ReasonCode
					WHERE Deleted = 0

				end 


    END
