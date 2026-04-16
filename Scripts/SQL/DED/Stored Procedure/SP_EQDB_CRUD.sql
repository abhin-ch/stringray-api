CREATE or ALTER PROCEDURE [stng].[SP_EQDB_CRUD] (
									@Operation TINYINT,
									@CurrentUser VARCHAR(50) = null,
									@UniqueID varchar(40) = null,
									@EQDBID nvarchar(200) = null,
									@Location varchar(25) = null,
									@Facility varchar(5) = null,
									@DocName varchar(250) = null,
									@PMNum varchar(100) = null,
									@AMLNum varchar(100) = null,
									@EC varchar(100) = null,
									@DCR varchar(100) = null,
									
									@EQEBOM bit = null,
									@AMLInstalled bit = null,
									@PredefinedCheck bit = null,
									@EQDocCheck bit = null,
									@PredefinedComplete bit = null,

									@EQEBOMReason varchar(max) = null,
									@AMLInstalledReason varchar(max) = null,
									@PredefinedCheckReason varchar(max) = null,
									@EQDocCheckReason varchar(max) = null,
									@PredefinedCompleteReason varchar(max) = null,

									@OutstandingChanges varchar(max) = null,

																
									@Error INTEGER = NULL OUTPUT,
									@ErrorDescription VARCHAR(8000) = NULL OUTPUT)
AS
    BEGIN
		if @Operation = 1 -- EQDBIndexMain
			begin

					select *
					from stng.VV_EQDB_IndexMain
					order by location, facility asc

			end 

		else if @Operation = 2 --EBOM
			begin

				select *
				from stng.VV_EQDB_IndexEQEBOM
				where location = @Location and facility = @Facility
				option(optimize for (@Location unknown, @Facility unknown));

			end
		else if @Operation = 3 --Predefined
			begin

				select distinct CONCAT(EQPM, EQJP, [Level], AMLITEM, EQJPITEM) as UniqueID, *
				from stng.VV_EQDB_IndexPredefined
				where location = @Location and facility = @Facility 
				option(optimize for (@Location unknown, @Facility unknown));
				--and OnAMLVerifiedBOM = 1

			end
		else if @Operation = 4 --Documents
			begin

				select a.*
				from stng.[VV_EQDB_IndexLocationDocs] as a 
				where location = @Location and facility = @Facility
				option(optimize for (@Location unknown, @Facility unknown));

			end
		else if @Operation = 5 --Pending ECs
			begin

				select distinct
				a.[ECNUMBER]
				,a.[ECSTATUS]
				,a.[ECSTATUSDATE]
				,a.[UNIT]
				,a.[STATION]
				,a.[ECTYPE]
				,a.[DOCUMENTDESCRIPTION]
				,b.DESCRIPTION as ECTitle
				,d.LONGDESC as [description]
				from stngetl.General_ADLInfo as a
				inner join stngetl.General_AllEC as b on a.ECNUMBER = b.EC
				left join stngetl.General_DCRECLongDesc as d on a.ECNumber = d.FK and d.BUSINESSOBJECTTYPE = 'EC'
				where a.ECSTATUS = 'WAPPR' and a.DOCUMENTDESCRIPTION = @DocName

			end
		else if @Operation = 6 --Pending DCRs
			begin

				select distinct a.CR as UniqueID, a.CR as DCR, a.CRDESC, a.CRSTATUS, a.CRSTATUSDATE,
				b.DOCNUMBER as DCRDoc, c.FACILITY, c.LOCATION, d.LONGDESC as [description]
				from stngetl.General_AllCR as a
				inner join stngetl.General_CRDoc as b on a.CR = b.CR
				inner join stngetl.EQDB_IndexLocationDocs as c on b.DOCNUMBER = c.DOCNAME
				left join stngetl.General_DCRECLongDesc as d on a.CR = d.FK and d.BUSINESSOBJECTTYPE = 'DCR'
				where a.CRCLASS like '%DCR%' and a.CRSTATUS = 'WAPPR'
				and b.DOCNUMBER = @DocName and c.LOCATION = @Location and c.FACILITY = @Facility
				option(optimize for (@DocName unknown, @Location unknown, @Facility unknown));

			end
		else if @Operation = 7 --Predefined Info
			begin

				select distinct 
				a.STATUS
				,b.pmnum
				,b.[description]
				,concat(b.frequency, ' ', b.frequnit) as frequency
				,b.jpnum
				,b.CurrentWO
				,b.CurrentWOPMDueDate
				,b.lastcompdate
				,b.nextdate
				,c.[ITEMDESC] 
				,d.DESCRIPTION as JPDescription
				from stng.VV_EQDB_IndexPredefined as a
				left join stngetl.General_PMRSupportingInfo as b on a.EQPM = b.pmnum 
				left join stngetl.[General_Item] as c on a.EQJPITEM = c.[ITEM]
				left join stngetl.[General_JobPlanLatestRev] as d on a.EQJP = d.JPNUM
				where a.EQPM = @PMNum

			end
		else if @Operation = 8 --Assembly
					
			begin

				select distinct a.ITEMNUM, b.ITEMDESC as ItemDescription, b.EQ, b.STATUS
				from stngetl.General_ItemHierarchy as a 
				left join stngetl.[General_Item] as b on a.ITEMNUM = b.ITEM
				where a.PARENTITEM = @AMLNum

			end
		
		else if @Operation = 9 --dEQLocations
					
			begin

				select distinct a.location, a.FACILITY as siteid, a.unit, b.usi, b.status, b.statusdate, b.type, a.locationdesc, b.RCE, 1 as EQ, b.locationsid
				from [stngetl].[EQDB_IndexInfo] as a
				inner join stng.VV_IQT_MEL as b on a.location = b.location and a.FACILITY = b.siteid

			end
		else if @Operation = 10 --dEQLocationDocuments
					
			begin

				select concat(a.location,'||',a.FACILITY) as UniqueID, a.location, a.FACILITY, b.dataid,
				b.docnum as [name], b.revision, b.status, b.statusdate, b.doctype, b.docsubtype, b.cslink
				from [stngetl].[EQDB_IndexInfo] as a
				inner join stng.VV_IQT_Doc as b on concat(a.location,'||',a.FACILITY) = b.fk and b.origin = 'LOCATIONS' and b.cstype = 'Controlled Doc'

			end

		else if @Operation = 11 --EQL Verification
					
			begin

				SELECT [location]
					  ,[siteid]
					  ,[unit]
					  ,LOCATIONSTATUS
					  ,[inMaximo]
					  ,[inEQIS]
					  ,[eqlIndicator]
				  FROM [stng].[VV_EQDB_EQLVerification]
			end

		else if @Operation = 12 --EQDB Override
					
			begin

				if exists(select EQDBIID
					from stng.EQDB_Main
					where [EQDBIID] = @EQDBID)

					begin 

						UPDATE stng.EQDB_Main
						set
						[EQEBOM] = @EQEBOM,
						[AMLINSTALLED] = @AMLInstalled,
						[PredefinedCheck] = @PredefinedCheck,
						[EQDOCCHECK] = @EQDocCheck,
						[PredefinedComplete] = @PredefinedComplete,
						
						EQEBOMReason = @EQEBOMReason,
						AMLInstalledReason = @AMLInstalledReason,
						PredefinedCheckReason = @PredefinedCheckReason,
						EQDocCheckReason = @EQDocCheckReason,
						PredefinedCompleteReason = @PredefinedCompleteReason,

						LUB = @CurrentUser,
						LUD = stng.GetBPTime(getdate())

						where [EQDBIID] = @EQDBID


					end

				else 
					begin

					INSERT into stng.EQDB_Main
					([EQDBIID]
					  ,[EQEBOM]
					  ,[AMLINSTALLED]
					  ,[PredefinedCheck]
					  ,[EQDOCCHECK]
					  ,[PredefinedComplete]
					  ,[EQEBOMReason]
					  ,[AMLInstalledReason]
					  ,[PredefinedCheckReason]
					  ,[EQDocCheckReason]
					  ,[PredefinedCompleteReason] 
					  ,[RAB]
					  ,[LUB])
					values
					(@EQDBID, @EQEBOM, @AMLInstalled, @PredefinedCheck, @EQDocCheck, @PredefinedComplete,
					@EQEBOMReason, @AMLInstalledReason, @PredefinedCheckReason, @EQDocCheckReason, @PredefinedCompleteReason,
					@CurrentUser, @CurrentUser)
						
					end
			end

			else if @Operation = 13 --Get Overrides
					
				begin

					SELECT *
					FROM [stng].[EQDB_Main]
					where EQDBIID = @EQDBID
					option(optimize for (@EQDBID unknown));
				end

			else if @Operation = 14 --Outstanding Changes
					
				begin

				if exists(select EQDBIID
					from stng.EQDB_Main
					where [EQDBIID] = @EQDBID)

					begin 

						UPDATE [stng].[EQDB_Main]
						set
						OutstandingChanges = @OutstandingChanges,
						LUB = @CurrentUser,
						LUD = stng.GetBPTime(getdate())
						where EQDBIID = @EQDBID


					end

				else 
					begin

					INSERT into stng.EQDB_Main
					([EQDBIID]
					  ,OutstandingChanges
					  ,[RAB]
					  ,[LUB])
					values
					(@EQDBID, @OutstandingChanges, @CurrentUser, @CurrentUser)
						
					end

					
				end

			else if @Operation = 15 --Failure Messages
					
				begin

					SELECT [UniqueID]
						,[CheckField]
						,[Message]
					FROM [stng].[EQDB_FailureMessage]
					
				end

			else if @Operation = 16 --EQEBOM Failures
					
				begin

					SELECT [LOCATION]
					  ,[FACILITY]
					  ,[Item]
					  ,[REPAIR_STRAT]
					  ,[RepairStrat12]
					  ,[RepairStrat34]
					  ,[ItemStatus]
					  ,[ActiveItem]
					  ,[ActiveScreenPenItem]
					  ,[EQ]
					  ,[Verified]
					  ,[ProcClass]
					  ,[ProcClass12]
					  ,[EQEBOM]	
					FROM stng.VV_EQDB_EQEBOMFlag 
					where [Location] = @Location and Facility = @Facility and EQEBOM = 0
					option(optimize for (@Location unknown, @Facility unknown));
					
				end

			else if @Operation = 17 --EQ Doc Failures
					
				begin

					SELECT [Location]
					  ,[Facility]
					  ,[BADocLink]
					  ,[BBEQAEQSDocLink]
					  ,[BBEQRDocLink]
					  ,[BBDocLink]
					  ,[EQDOCCHECK]
					FROM stng.VV_EQDB_EQDOCFlag
					where [Location] = @Location and Facility = @Facility and EQDOCCHECK = 0
					option(optimize for (@Location unknown, @Facility unknown));
					
				end

			else if @Operation = 18 --Predefined Completion Failures
					
				begin

					SELECT *
					FROM [stng].[VV_EQDB_PredefinedCompFlag]
					where [Location] = @Location and Facility = @Facility and [NextDateFlag] = 0
					option(optimize for (@Location unknown, @Facility unknown));
					
				end

			else if @Operation = 19 -- Failure Report
					
				begin

					Select *
					from stng.VV_EQDB_FailureReport
					order by location, SiteID asc
					
				end

    END